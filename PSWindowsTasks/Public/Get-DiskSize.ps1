Function Get-DiskSize
{
    <#
    .SYNOPSIS
       List disk partition usage

    .DESCRIPTION
      Function that will retrieve cpu and memory utilization
    
    .NOTES

    .PARAMETER ComputerName
        Optionally specify a remote host to connect to
        Default is local host

    .EXAMPLE
        Get-DiskSize

    .EXAMPLE
        Get-DiskSize -ComputerName myserver   
    #>


    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $false, Position = 1)]
        [String]$ComputerName = $env:COMPUTERNAME
    )

    if ($computername -ne $env:COMPUTERNAME)
    {
        Get-CimInstance -ComputerName $computername win32_logicaldisk | ? {$_.MediaType -notin ("5", "11")} | ft DeviceId, MediaType, @{n = "Size(GB)"; e = {[math]::Round($_.Size / 1GB, 2)}}, @{n = "FreeSpace(GB)"; e = {[math]::Round($_.FreeSpace / 1GB, 2)}}, @{L = 'FreeSpace(%)'; E = {($_.FreeSpace / $_.Size).ToString("P")}}
    }
    else
    {
        Get-CimInstance win32_logicaldisk | ? {$_.MediaType -notin ("5", "11")} | ft DeviceId, VolumeName, @{n = "Size(GB)"; e = {[math]::Round($_.Size / 1GB, 2)}}, @{n = "FreeSpace(GB)"; e = {[math]::Round($_.FreeSpace / 1GB, 2)}}, @{L = 'FreeSpace(%)'; E = {($_.FreeSpace / $_.Size).ToString("P")}}
    }
}