param($installPath, $toolsPath, $package)

Import-Module (Join-Path $toolsPath philhaack.psm1)

Import-Module (Join-Path $toolsPath dteutilities.psm1)

Import-Module (Join-Path $toolsPath pdiworkforce.psm1)

#
# If your NuGet packages are in the standard location, you can
# dead-reacon the $toolsPath inside your Module from the Solution
# path.  This CmdLet pushes the $toolsPath | $profilePath into your module
# but requires an "initialization" method
#
Set-PDIWorkforceConfigurationPath $toolsPath


