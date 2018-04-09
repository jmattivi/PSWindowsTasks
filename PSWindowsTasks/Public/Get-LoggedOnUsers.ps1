Function Get-LoggedOnUsers
{
    <#
    .SYNOPSIS
        Queries for active user sessions

    .DESCRIPTION
        Uses the query user executable to look up logged on users locally and/or remotely

    .NOTES   
        This function borrows from:
        Jaap Brasser

    .PARAMETER ComputerName
        The string or array of string for which a query will be executed

    .EXAMPLE
        Get-LoggedOnUsers -ComputerName myserver

    .EXAMPLE
        ('server01','server02') | Get-LoggedOnUsers
    #>
    
    [CmdletBinding()] 
    param(
        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )
    
    foreach ($Computer in $ComputerName)
    {
        try
        {
            query user /server:$Computer 2>&1 | Select-Object -Skip 1 | ForEach-Object {
                $CurrentLine = $_.Trim() -Replace '\s+', ' ' -Split '\s'
                $HashProps = @{
                    UserName     = $CurrentLine[0]
                    ComputerName = $Computer
                }

                # If session is disconnected different fields will be selected
                if ($CurrentLine[2] -eq 'Disc')
                {
                    $HashProps.SessionName = $null
                    $HashProps.Id = $CurrentLine[1]
                    $HashProps.State = $CurrentLine[2]
                    $HashProps.IdleTime = $CurrentLine[3]
                    $HashProps.LogonTime = $CurrentLine[4..6] -join ' '
                    $HashProps.LogonTime = $CurrentLine[4..($CurrentLine.GetUpperBound(0))] -join ' '
                }
                else
                {
                    $HashProps.SessionName = $CurrentLine[1]
                    $HashProps.Id = $CurrentLine[2]
                    $HashProps.State = $CurrentLine[3]
                    $HashProps.IdleTime = $CurrentLine[4]
                    $HashProps.LogonTime = $CurrentLine[5..($CurrentLine.GetUpperBound(0))] -join ' '
                }

                New-Object -TypeName PSCustomObject -Property $HashProps |
                    Select-Object -Property UserName, ComputerName, SessionName, Id, State, IdleTime, LogonTime, Error
            }
        }
        catch
        {
            New-Object -TypeName PSCustomObject -Property @{
                ComputerName = $Computer
                Error        = $_.Exception.Message
            } | Select-Object -Property UserName, ComputerName, SessionName, Id, State, IdleTime, LogonTime, Error
        }
    }
}