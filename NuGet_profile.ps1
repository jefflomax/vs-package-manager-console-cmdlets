Write-Host "$profile installed including PDI Workforce Components"

function Set-FontSize {
	param(
		[ValidateRange(6, 128)]
		[Parameter(position=0, mandatory=$true)]
		[int]$Size
	)
	$dte.Properties("FontsAndColors", "TextEditor").Item("FontSize").Value = $Size
}

$profilePath = Split-Path ($profile)

#
# Phil Haack example of adding a cmdlet to Package Manager Console (PowerShell Console)
# http://haacked.com/archive/2011/04/19/writing-a-nuget-package-that-adds-a-command-to-the.aspx
#
Import-Module (Join-Path $profilePath philhaack.psm1)

Import-Module (Join-Path $profilePath dteutilities.psm1)

Import-Module (Join-Path $profilePath pdiworkforce.psm1)

#
# If your NuGet packages are in the standard location, you can
# dead-reacon the $toolsPath inside your Module from the Solution
# path.  This CmdLet pushes the $toolsPath | $profilePath into your module
# but requires an "initialization" method
#
Set-PDIWorkforceConfigurationPath $profilePath
