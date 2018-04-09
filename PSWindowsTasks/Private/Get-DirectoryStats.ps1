function Get-DirectoryStats
{
    <#
    .SYNOPSIS
        Outputs directory statistics for the specified directory

    .DESCRIPTION
        Outputs directory statistics for the specified directory. With -recurse, the function includes files in all subdirectories of the specified directory. With -format, numbers in the output objects are formatted with the Format-Output filter.

    .NOTES   

    #>


    param( $directory, $recurse )

    Write-Progress -Activity "Get-DirStats" -Status "Reading '$($directory.FullName)'"
    try
    {
        $files = $directory | Get-ChildItem -Force -Recurse:$recurse -ea SilentlyContinue | Where-Object { -not $_.PSIsContainer }
    }
    catch
    {
        Write-Warning $_.Exception.Message
    }
    if ( $files )
    {
        Write-Progress -Activity "Get-DirStats" -Status "Calculating '$($directory.FullName)'"
        $output = $files | Measure-Object -Sum -Property Length | Select-Object `
        @{Name = "Path"; Expression = {$directory.FullName}},
        @{Name = "Files"; Expression = {"{0:N0}" -f ($_.Count); $script:totalcount += $_.Count}},
        @{Name = "Size(GB)"; Expression = {"{0:N2}" -f ($_.Sum / 1073741824); $script:totalbytes += $_.Sum}}
    }
    else
    {
        $output = "" | Select-Object `
        @{Name = "Path"; Expression = {$directory.FullName}},
        @{Name = "Files"; Expression = {0}},
        @{Name = "Size(GB)"; Expression = {0}}
    }
    $output 
}