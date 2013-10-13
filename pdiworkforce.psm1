<#
Copyright 2013 Robert J. Lomax
No rights reserved.  This document is public domain.
You are free to copy or modify this document in any manner you choose.
No warranty, merchantibility, or fitness implied, use at your own risk.
#>

# myToolsPath is declared at SCRIPT scope, Set-PDIWorkforceConfigurationPath
# will assign it from init.ps1 | NuGet_profile.ps1 with either $toolsPath for
# a NuGet package or $profilePath for NuGet Profile configuration
$script:myToolsPath = ""

# XML configuration file
$script:projectStructure = $null

$nl = [Environment]::NewLine

$notInMySolution = "You are not in the correct solution for Add-CommandHandler"

function Set-PDIWorkforceConfigurationPath( [string] $toolsPath ) {
	Set-Variable -Name "myToolsPath" -Value $toolsPath -Scope "script"
}

<#
.SYNOPSIS
Add a Command Handler to Web and Service projects

.DESCRIPTION
Adds [HandlerBaseName]CmdParms.cs, [HandlerBaseName]CmdResult.cs, [HandlerBaseName]CmdHandler.cs
to the Web.Commands, Web.Handlers, Service.Commands, and Service.Handlers projects.

.PARAMETER HandlerBaseName
Root name of new classes.

.PARAMETER HandlerFolder
Zero or more folders seperated by \ to place the new classes into.

.NOTES
This is a pure PowerShell in Visual Studio implementation, no T4 or extensions required.
#>
function Add-CommandHandler {
	[CmdletBinding()]
	param(
		[parameter(Mandatory = $true)]
		[string]$HandlerBaseName,
		[parameter(Mandatory = $true)]
		$HandlerFolder
	)

	Log "Add-CommandHandler $HandlerBaseName [$HandlerFolder]"

	ReadXMLConfiguration

	$solutionName = $projectStructure.root.solution

	$currentSolutionName = Get-SolutionName
	if ( $currentSolutionName -ne $solutionName ) {
		Write-Host $notInMySolution
	}
	else {

	if( $HandlerFolder.Length -ne 0 ) {
		# Switch directory delimiters to Windows style
		$HandlerFolder = $HandlerFolder -replace "/", "\"
	}

	$usingPath = if ( $HandlerFolder.Length -ne 0 ) { "." + ($HandlerFolder -replace "\\", ".") } else { "" }
	Log $usingPath

	[string]$commandProjectName =	$projectStructure.root.webCommand
	[string]$handlerProjectName =	$projectStructure.root.webHandler
	[string]$usingNamespace =		$projectStructure.root.webHandlerUsing

	AddHandler $HandlerBaseName $HandlerFolder $commandProjectName $handlerProjectName "${usingNamespace}${usingPath}"

	[string]$commandProjectName =	$projectStructure.root.serviceCommand
	[string]$handlerProjectName =	$projectStructure.root.serviceHandler
	[string]$usingNamespace =		$projectStructure.root.serviceHandlerUsing

	AddHandler $HandlerBaseName $HandlerFolder $commandProjectName $handlerProjectName "${usingNamespace}${usingPath}"

	Save-AllFiles
	}
}

function ReadXMLConfiguration {
	Log "ReadXMLConfiguration $myToolsPath"

	# Only applicable for NuGet
	$contentPath = $myToolsPath.Replace("tools","content")

	[xml]$xml = Get-Content (Join-Path $contentPath "ProjectStructure.xml")

	# Store the $projectStructure at script scope
	Set-Variable -Name "projectStructure" -Value $xml -Scope "script" -Option ReadOnly

	Log $projectStructure.root.webCommand
}

function AddHandler( [string]$handlerBaseName, [string]$handlerFolder, [string]$commandProjectName, [string]$handlerProjectName, [string]$usingNamespace) {

	Log "AddHandler $handlerBaseName $handlerFolder $commandProjectName $handlerProjectName $usingNamespace"

	$sln2 = Get-Solution2
	Log "Solution: $($sln2.FullName)"

	#
	# CommandParms and CommandResult
	#

	$project = Get-Project -Name $commandProjectName
	Log "Project: $($project.Name) $($project.UniqueName)"

	# Get template for a new CSharp Class file
	$itemTemplate = Get-ProjectItemTemplateClassCSharp $sln2
	Log $itemTemplate

	$currentProjectItems = $project.ProjectItems

	GetProjectItemsForFolderChain $handlerFolder ([REF]$currentProjectItems)

	$currentProjectItems.AddFromTemplate( $itemTemplate, "${handlerBaseName}CmdParms.cs" )

	PrepForCommandParms $handlerBaseName

	$currentProjectItems.AddFromTemplate( $itemTemplate, "${handlerBaseName}CmdResult.cs" )

	PrepForCommandResult $handlerBaseName

	#
	# Handler
	#

	$project = Get-Project -Name $handlerProjectName
	Log "Project: $($project.Name) $($project.UniqueName)"

	$currentProjectItems = $project.ProjectItems

	GetProjectItemsForFolderChain $handlerFolder ([REF]$currentProjectItems)

	$currentProjectItems.AddFromTemplate( $itemTemplate, "${handlerBaseName}CmdHandler.cs" )

	PrepForCommandHandler $handlerBaseName $usingNamespace
}

function PrepForCommandHandler( [string]$handlerBaseName, [string]$handlerCommandNamespace ) {
	Log "PrepForCommandHandler ${handlerBaseName} ${handlerCommandNamespace}"

	$doc = $dte.ActiveDocument

	$dte.ActiveDocument.Selection.StartOfDocument()
	$dte.ActiveDocument.Selection.Insert("using profdata.WF.CommandProcessor;${nl}using $handlerCommandNamespace;${nl}")	

	$result = $dte.ActiveDocument.ReplaceText( "class", "public class" )
	$result = $dte.ActiveDocument.ReplaceText( "${handlerBaseName}CmdHandler", "${handlerBaseName}CmdHandler : ICommandHandler<${handlerBaseName}CmdParms,${handlerBaseName}CmdResult>" )

	$dte.ActiveDocument.Selection.StartOfDocument()
	$result = $dte.ActiveDocument.Selection.FindText("}")
	$dte.ActiveDocument.Selection = "public ${handlerBaseName}CmdResult Handle( ${handlerBaseName}CmdParms cmdParms)$nl{${nl}return new ${handlerBaseName}CmdResult();$nl }$nl$nl}"
}

function PrepForCommandParms( [string]$handlerBaseName ) {
	Log "PrepForCommandParms ${handlerBaseName}"

	$doc = $dte.ActiveDocument

	$dte.ActiveDocument.Selection.StartOfDocument()
	$dte.ActiveDocument.Selection.Insert("using profdata.WF.CommandProcessor;$nl")	

	$result = $dte.ActiveDocument.ReplaceText( "class", "public class" )
	$result = $dte.ActiveDocument.ReplaceText( "${handlerBaseName}CmdParms", "${handlerBaseName}CmdParms : ICommand" )
}

function PrepForCommandResult( [string]$handlerBaseName ) {
	Log "PrepForCommandResult ${handlerBaseName}"

	$doc = $dte.ActiveDocument

	$dte.ActiveDocument.Selection.StartOfDocument()
	$dte.ActiveDocument.Selection.Insert("using profdata.WF.CommandProcessor;$nl")

	$result = $dte.ActiveDocument.ReplaceText( "class", "public class" )
	$result = $dte.ActiveDocument.ReplaceText( "${handlerBaseName}CmdResult", "${handlerBaseName}CmdResult : CommandResult" )
}


#
# Walk the chain of folders, get or create the next folder,
# and return by reference the current ProjectItems
#
function GetProjectItemsForFolderChain( [string]$folderPath, [REF]$prjItems ) {

	Log "GetProjectItemsForFolderChain $folderpath"

	# If no folders requested, return projectItems
	if( $folderPath.Length -eq 0 ) {
		Log "No Folder Path"
		return
	}

	$folderPath.Split("\") | ForEach {

		if( $_.Length -gt 0 ) {

			$folder = Get-Folder ($prjItems.Value) $_

			# Calling .Item() failed when item not present
			# Could use try catch
			# $folder = ($prjItems.Value).Item( $_ )

			if( $folder -eq $null ) {
				$newFolder = ($prjItems.Value).AddFolder( $_ )
				$prjItems.Value = $newFolder.ProjectItems
			}
			else {
				$prjItems.Value = $folder.ProjectItems
			}
		}
	}
}

function Log( $message ) {
	Write-Host $message 
}

Export-ModuleMember Add-CommandHandler, Set-PDIWorkforceConfigurationPath
