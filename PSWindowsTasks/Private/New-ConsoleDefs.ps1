Function New-ConsoleDefs
{
    <#
    .SYNOPSIS
        Creates the installed console path definitions for the module function Open-Console

    .DESCRIPTION
        Creates the installed console path definitions for the module function Open-Console
    
    .NOTES

    .EXAMPLE
        New-ConsoleDefs

    #>


    [CmdletBinding()]
    Param
    ()
    
    $defpath = "$($env:APPDATA)\GHSWindowsTasks\"
    $deffile = "ConsolePathDefinitions.xml"

    $xmlcontents = @"
<?xml version="1.0" encoding="UTF-8"?>
<Applications>
  <Application Name="ConfigMgr" Path="">
  </Application>
  <Application Name="OpsMgr" Path="">
  </Application>
  <Application Name="SCOrch" Path="">
  </Application>
  <Application Name="SQL Server Mgmt Studio" Path="">
  </Application>
</Applications>
"@

    if (-not (Test-Path -Path $defpath))
    {
        New-Item -Path "$($env:APPDATA)\PSWindowsTasks\" -ItemType Directory
    }
    
    if (-not (Test-Path -Path ($defpath + $deffile)))
    {
            New-Item -Path ($defpath + $deffile) -ItemType File -Value $xmlcontents
    }
}