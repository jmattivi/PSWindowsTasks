Function Update-ConsoleDef
{
    <#
    .SYNOPSIS
        Updates the installed console path definitions for the module function Open-Console

    .DESCRIPTION
        Updates the installed console path definitions for the module function Open-Console
    
    .NOTES

    .PARAMETER Name
        Application name

    .PARAMETER Executable
        Executable name

    .EXAMPLE
        Update-ConsoleDef -Name SCOrch -Executable RunbookDesigner.exe

    #>


    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [String]$Name,
        [Parameter(Mandatory = $true)]
        [String]$Executable
    )

    New-ConsoleDefs

    $xml = [xml](gc -Path ($defpath + $deffile))
    $xmlelement = $xml.SelectSingleNode("//Application[@Name = `'$name`']")
    $discoveredpath = $xmlelement.Path
    if ($discoveredpath)
    {
        if (Test-Path -Path $discoveredpath -ea SilentlyContinue)
        {
            $process = "" | Select Path, Args
            $process.Path = $discoveredpath
        }
    }
    else
    {
        $programpaths = ("C:\Program Files", "C:\Program Files (x86)")
        foreach ($programpath in $programpaths)
        {
            $discoveredpath = gci -Path $programpath -Filter $executable -Recurse -ea SilentlyContinue | Select -First 1 -ExpandProperty FullName
            if ($discoveredpath)
            {
                break
            }
        }
        $xmlelement.Path = $discoveredpath.ToString()
        $xml.Save(($defpath + $deffile))
    }
    $process = "" | Select Path, Args
    $process.Path = $discoveredpath

    return $process
}