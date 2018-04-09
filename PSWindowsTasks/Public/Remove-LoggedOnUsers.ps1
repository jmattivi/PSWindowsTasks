Function Remove-LoggedOnUsers
{
    <#
    .SYNOPSIS
        Removes active or disconnected user sessions

    .DESCRIPTION
        Uses the logoff executable to remove logged on users locally and/or remotely

    .NOTES   
    
    .PARAMETER ComputerName
        The string or array of string for which logoffs will be executed
    
    .PARAMETER Username
        Specific user to logoff

    .PARAMETER Id
        Session Id to logoff
    
    .EXAMPLE
        Remove-LoggedOnUsers -ComputerName myserver -Username jdoe
    
    .EXAMPLE
        Remove-LoggedOnUesrs -ComputerName myserver -Id 2
    
    .EXAMPLE
        Get-LoggedOnUsers -ComputerName myserver | Remove-LoggedOnUesrs
    #>
    
    [CmdletBinding(DefaultParameterSetName = "Username")]
    param(
        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Mandatory = $true)]
        [string[]]$ComputerName,
        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Mandatory = $true,
            ParameterSetName = "Username")]
        [string[]]$Username,
        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Mandatory = $true,
            ParameterSetName = "Id")]
        [string[]]$Id
    )
    
    foreach ($computer in $computername)
    {
        try
        {
            if ($username)
            {
                $sessions = Get-LoggedOnUsers -ComputerName $computer
                $sessionid = $sessions | ? {$_.UserName -eq $username} | Select -ExpandProperty Id
                if ($sessionid)
                {
                    logoff.exe $sessionid /server:$computer
                    if ($LASTEXITCODE -eq 0)
                    {
                        Write-Output "Successfully logged off $username from $computer"
                    }
                    else
                    {
                        Write-Error "Failed to logoff $username from $computer!"
                    }
                }
                else
                {
                    Write-Warning "No session found for $username on $computer!"
                }
            }
            else
            {
                logoff.exe $id /server:$computer
            }
        }
        catch
        {
            throw $_.Exception.Message
        }
    }
}