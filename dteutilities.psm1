<#
Copyright 2013 Robert J. Lomax
No rights reserved.  This document is public domain.
You are free to copy or modify this document in any manner you choose.
No warranty, merchantibility, or fitness implied, use at your own risk.
#>

# Visual Studio Folder Kind
$folderGuid = '{6BB5F8EF-4483-11D3-8BCF-00C04F8EC28C}'

function Get-Solution2 {
	Get-Interface $dte.Solution ([EnvDTE80.Solution2])
}

function Get-SolutionName {
	[System.IO.Path]::GetFileNameWithoutExtension($dte.Solution.FullName)
}

# Return a Folder or $null
function Get-Folder ( $projectItems, [string]$folderName ) {
	$projectItems | Where-Object { $_.Kind -eq $folderGuid -and $_.Name -eq $folderName }
}

function Get-StartupProject {
	$dte.Solution.Properties.Item("StartupProject").Value
}

function Set-StartupProject( [string] $projectName ) {
	$dte.Solution.Properties.Item("StartupProject").Value = $projectName
	Start-Sleep -Second 1
}

function Get-ProjectItemTemplateClassCSharp( $sln2 ) {
	$sln2.GetProjectItemTemplate("Class","CSharp")
}

function Save-AllFiles {
	$dte.ExecuteCommand("File.SaveAll")
}

function Close-AllDocuments {
	$dte.Documents | %{ $_.Close() }
}

<#
From Install-Package SqlServerCompact
function Add-ProjectItem($item, $src, $itemtype = "None") {
	$newitem = (Get-Interface $item.ProjectItems "EnvDTE.ProjectItems").AddFromFileCopy($src)
	$newitem.Properties.Item("ItemType").Value = $itemtype
}
#>

Export-ModuleMember -function Get-Solution2, Get-SolutionName, Get-Folder, Get-StartupProject, Set-StartupProject, Get-ProjectItemTemplateClassCSharp, Save-AllFiles, Close-AllDocuments
