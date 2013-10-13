vs-package-manager-console-cmdlets
==================================

Powershell Cmdlets to add classes, such as a Command Pattern, to Visual Studio using the Package Manager Console.
Pure PowerShell, no T4 or Extensions.

If you're reading this, hopefully you have an interest in automating some task in Visual Studio.  Perhaps you've seen
Phil Haack's wonderful post on how easy it is to add your own PowerShell CmdLets into Visual Studio.

http://haacked.com/archive/2011/04/19/writing-a-nuget-package-that-adds-a-command-to-the.aspx

This repository is a proof-of-concept of adding a Command Pattern, three C# files:

Command Parameters
Command Result
Command Handler

both in "Web" and "Service" projects.  It probaby isn't exactly what you want, but hopefully seeing some working code
will help get you closer to your goal.

This can be installed into your Visual Studio in one of two ways:

1) Add into the "global" NuGet Profile.  Just bring up the Package Manager Console (I think it should be called the
PowerShell Console) and type:
$profile

This will tell you where your profile is, if it isn't created yet, just make the folder and copy all the files except
init.ps1 in there.  It all starts up with NuGet_profile.ps1  

2) Create a NuGet Package using Nuget Package Explorer

Copy all the files except NuGet_Profile.ps1, use Nuget Package Explorer to create a NuGet Package, and then in
Visual Studio, Package Manager Settings, Package Sources, and setup a folder on your machine to install packages
from, likely the same one you placed these files in.

Of course you'll have to tweak some things.  The ProjectStructure.xml file needs the names of your solution and
project files, as well as the using namespace the Command Handler class needs.

If you are using NuGet, please use Install-Package from the Package Manager Console and not the GUI, the Console
gives useful error messages on "install", the GUI is known to fail silently.

After you're installed, try Phil Haack's CmdLet:

Get-Answer

And if you really want some fun, the one this was built for:

Add-CommandHandler  BaseName Project\Folder\Path





