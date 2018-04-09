function Get-Directory
{
    <#
    .SYNOPSIS
        Returns a [System.IO.DirectoryInfo] object if it exists.

    .DESCRIPTION
        Returns a [System.IO.DirectoryInfo] object if it exists.

    .NOTES   

    #>


    param( $item )

    if ( $ParamSetName -eq "Path" )
    {
        if ( Test-Path -Path $item -PathType Container )
        {
            $item = Get-Item -Path $item -Force
        }
    }
    elseif ( $ParamSetName -eq "LiteralPath" )
    {
        if ( Test-Path -LiteralPath $item -PathType Container )
        {
            $item = Get-Item -LiteralPath $item -Force
        }
    }
    if ( $item -and ($item -is [System.IO.DirectoryInfo]) )
    {
        return $item
    }
}