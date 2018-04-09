Function Get-PerfCounters
{
    <#
    .SYNOPSIS
       List CPU and memory percentage in use

    .DESCRIPTION
      Function that will retrieve cpu and memory utilization
    
    .NOTES

    .PARAMETER ComputerName
        Optionally specify a remote host to connect to
        Default is local host

    .EXAMPLE
        Get-PerfCounters

    .EXAMPLE
        Get-PerfCounters -ComputerName myserver
    #>


    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $false, Position = 1)]
        [String]$ComputerName = $env:COMPUTERNAME
    )

    $cpu = @()
    $memory = @()

    if ($computername -ne $env:COMPUTERNAME)
    {
        $cpucores = (Get-CimInstance -ComputerName $computername -Class Win32_ComputerSystem).NumberOfLogicalProcessors
    }
    else
    {
        $cpucores = (Get-CimInstance -Class Win32_ComputerSystem).NumberOfLogicalProcessors
    }
        $cpu = (Get-Counter -Counter "\\$computername\Process(*)\% Processor Time" -ea SilentlyContinue).CounterSamples | Select @{Name = "PID"; Expression = {$_.Path -match ".?\((.*?)\).*" | Out-Null; $Matches[1]}}, @{Name = "CPU %"; Expression = {[Decimal]::Round(($_.CookedValue / $CpuCores), 2)}}
        $memory = (Get-Counter -Counter "\\$computername\Process(*)\Working Set - Private" -ea SilentlyContinue).CounterSamples | Select @{Name = "PID"; Expression = {$_.Path -match ".?\((.*?)\).*" | Out-Null; $Matches[1]}}, @{Name = "Memory (MB)"; Expression = {[Math]::Round(($_.CookedValue / 1mb), 2)}}

        $i = 0
        $id = @{}
        $memory.ForEach( {
                $id["$($psitem.pid)"] = $i
                $i++
            })
        $cpu.ForEach( {
                $cpuitem = $psitem
                $counters = New-Object System.Object
                $temp = $null
                try
                {
                    $temp = $memory[($id[$psitem.pid])]
                }
                catch
                {
                }
                finally
                {
                    $counters | Add-Member -MemberType NoteProperty -Name Process -Value $cpuitem.pid
                    $counters | Add-Member -MemberType NoteProperty -Name "CPU %" -Value $cpuitem."CPU %"
                    $counters | Add-Member -MemberType NoteProperty -Name "Memory (MB)" -Value $temp."Memory (MB)"
                }
                return $counters
            }) | Sort InstanceName
    }