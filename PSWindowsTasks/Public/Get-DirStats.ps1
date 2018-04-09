function Get-DirStats
{
    <#
    .SYNOPSIS
        Outputs file system directory statistics (number of files and the sum of all file sizes) for one or more directories.
        
        Used for finding directories and/or files taking up the most space.

    .DESCRIPTION
        Borrowed from Bill Stewart
    
    .NOTES

    .PARAMETER Path
        Specifies a path to one or more file system directories. Wildcards are not permitted. The default path is the current directory (.).

    .PARAMETER LiteralPath
        Specifies a path to one or more file system directories. Unlike Path, the value of LiteralPath is used exactly as it is typed.

    .PARAMETER Root
        Outputs statistics for a directory but not any of its subdirectories.

    .PARAMETER Recurse
        Outputs statistics for every directory in the specified path instead of only the first level of directories.

    .PARAMETER ExcludeWindows
        Switch to exclude the Windows folder from statistics.  Mainly used to increase speed and efficiency of result.
    
    .PARAMETER ExcludeDirectories
        Comma separated values used to exclude directories from being analyzed.
    
    .EXAMPLE
        Get-DirStats -Path '\\serverA\c$\inetpub
    
    .EXAMPLE
        Get-DirStats -Path '\\serverA\c$\inetpub -Recurse
    
    .EXAMPLE
        Get-DirStats -Path '\\serverA\c$' -ExcludeDirectories "ccmsetup,commvault" -ExcludeWindows
    #>

    [CmdletBinding(DefaultParameterSetName = "Path")]
    param(
        [parameter(Position = 0, Mandatory = $false, ParameterSetName = "Path", ValueFromPipeline = $true)]
        $Path = (get-location).Path,
        [parameter(Position = 0, Mandatory = $true, ParameterSetName = "LiteralPath")]
        [String[]] $LiteralPath,
        [Switch] $Root,
        [Switch] $Recurse,
        [Switch] $ExcludeWindows,
        [Object] $ExcludeDirectories
    )

    begin
    {
        $ParamSetName = $PSCmdlet.ParameterSetName
        if ( $ParamSetName -eq "Path" )
        {
            $PipelineInput = ( -not $PSBoundParameters.ContainsKey("Path") ) -and ( -not $Path )
        }
        elseif ( $ParamSetName -eq "LiteralPath" )
        {
            $PipelineInput = $false
        }

        # Script-level variables used with -Total.
        [UInt64] $script:totalcount = 0
        [UInt64] $script:totalbytes = 0    
    }

    process
    {
        # Get the item to process, no matter whether the input comes from the
        # pipeline or not.
        if ( $PipelineInput )
        {
            $item = $_
        }
        else
        {
            if ( $ParamSetName -eq "Path" )
            {
                $item = $Path
            }
            elseif ( $ParamSetName -eq "LiteralPath" )
            {
                $item = $LiteralPath
            }
        }

        # Write an error if the item is not a directory in the file system.
        $directory = Get-Directory -item $item
        if ( -not $directory )
        {
            Write-Error -Message "Path '$item' is not a directory in the file system." -Category InvalidType
            return
        }

        # Get the statistics for the first-level directory.
        Get-DirectoryStats -directory $directory -recurse:$false -format:$FormatNumbers
        # -Root means no further processing past the first-level directory.
        if ( $root )
        {
            return 
        }

        # Get the subdirectories of the first-level directory and get the statistics
        # for each of them.
        $exclusions = @()
        if ($excludewindows -and $excludedirectories)
        {
            $exclusions = ($excludedirectories).Split(",") + "Windows"
        }
        elseif ($excludewindows)
        {
            $exclusions += "Windows"
        }
        elseif ($excludedirectories)
        {
            $exclusions += ($excludedirectories).Split(",")
        }

        return $directory | Get-ChildItem -Directory -Force -Recurse:$recurse | ? {$_.Name -notin $exclusions} | ForEach-Object {
            Get-DirectoryStats -directory $_ -recurse:(-not $recurse)
        }
    }

    end
    {
        $output = "" | Select-Object `
        @{Name = "Path"; Expression = {"<Total>"}},
        @{Name = "Files"; Expression = {"{0:N0}" -f ($script:totalcount)}},
        @{Name = "Size(GB)"; Expression = {"{0:N2}" -f ($script:totalbytes / 1073741824)}}

       Write-Verbose $output | ft -AutoSize
    }
}