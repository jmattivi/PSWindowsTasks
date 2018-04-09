Function Open-Console
{
    <#
    .SYNOPSIS
        Opens administrative console if installed

    .DESCRIPTION
        Function intended to open administrative consoles from a session already started as a privileged user

        Included paths -
            "AD_UsersandComputers", "Cmd Prompt", "Computer Mgmt", "ConfigMgr", "Failover Cluster Manager", "OpsMgr", "PowerShell", "SCOrch", "SQL Server Mgmt Studio", "WMI Explorer"
    
    .NOTES
        A glorified runas function....

    .PARAMETER Name
        Console name
    
    .PARAMETER CustomPath
        Specify a custom path to open

    .EXAMPLE
        Open-Console -Name ConfigMgr

    .EXAMPLE
        Open-Console -CustomPath "C:\Program Files (x86)\Microsoft SQL Server\130\Tools\Binn\ManagementStudio\Ssms.exe"
    #>


    [CmdletBinding(DefaultParameterSetName = "Name")]
    Param
    (
        [Parameter(Mandatory = $true, ParameterSetName = "Name")]
        [ValidateSet("AD_UsersandComputers", "Cmd Prompt", "Computer Mgmt", "ConfigMgr", "Failover Cluster Manager", "OpsMgr", "PowerShell", "SCOrch", "SQL Server Mgmt Studio", "WMI Explorer")]
        [String]$Name,
        [Parameter(Mandatory = $false, ParameterSetName = "Custom")]
        [String]$CustomPath
    )

    if (-not $custompath)
    {
        SWITCH ($name)
        {
            'AD_UsersandComputers'
            {
                $process = "" | Select Path, Args
                $process.Path = "C:\Windows\system32\dsa.msc"
            }
            'Cmd Prompt'
            {
                $process = "" | Select Path, Args
                $process.Path = "C:\Windows\System32\cmd.exe"
            }
            'Computer Mgmt'
            {
                $process = "" | Select Path, Args
                $process.Path = "C:\Windows\system32\compmgmt.msc"
            }
            'ConfigMgr'
            {
                $executable = "Microsoft.ConfigurationManagement.exe"
                $process = Update-ConsoleDef -Name $name -Executable $executable
            }
            'Failover Cluster Manager'
            {
                $process = "" | Select Path, Args
                $process.Path = "C:\Windows\system32\Cluadmin.msc"
            }
            'OpsMgr'
            {
                $executable = "Microsoft.EnterpriseManagement.Monitoring.Console.exe"
                $process = Update-ConsoleDef -Name $name -Executable $executable
                $process.Args = "/clearcache"
            }
            'PowerShell'
            {
                $process = "" | Select Path, Args
                $process.Path = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
            }
            'SCOrch'
            {
                $executable = "RunbookDesigner.exe"
                $process = Update-ConsoleDef -Name $name -Executable $executable
            }
            'SQL Server Mgmt Studio'
            {
                $executable = "ssms.exe"
                $process = Update-ConsoleDef -Name $name -Executable $executable
            }
            'WMI Explorer'
            {
                $process = "" | Select Path, Args
                $process.Path = "C:\WMIExplorer.exe"
            }
        }

        try 
        {
            Test-Path -Path $($process.Path) -ea Stop | Out-Null

            if (-not $($process.Args))
            {
                Start-Process $($process.Path)
            }
            else
            {
                Start-Process $($process.Path) -ArgumentList $($process.Args)
            }
        }
        catch
        {
            Write-Error "$($_.Exception.Message)`n$name could not be found in the specified path -`n$($process.Path)"
        }
    }
    else
    {
        try 
        {
            Test-Path -Path $custompath -ea Stop | Out-Null
            Start-Process $custompath
        }
        catch
        {
            Write-Error $_.Exception.Message
        }
    }
}