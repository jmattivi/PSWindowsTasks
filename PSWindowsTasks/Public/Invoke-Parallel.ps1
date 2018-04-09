Function Invoke-Parallel
{
    <#
    .SYNOPSIS
        Utilizes PowerShell runspaces for multithreading

    .DESCRIPTION
        Function that can be easily ported to allow parallel code execution against array of objects
    
    .NOTES

    .PARAMETER Array
        Group of objects to run the specified scriptblock against

    .PARAMETER ScriptBlock
        The code which executes against each target

    .PARAMETER ThrottleLimit
        Specify the max threads that are allowed to execute simultaneously.  Default is 10.
    
    .EXAMPLE
        $customarray = ("ServerA", "ServerB", "ServerC")
        $code = {
            param($target)
            $result = "" | Select Name, PSVersion
            $result.Name = $target
            $result.PSVersion = Invoke-Command -ComputerName $target -ScriptBlock {$PSVersionTable.PSVersion.ToString()}

            return $result
        }
        Invoke-Parallel -Array $customarray -ScriptBlock $code
    
    #>


    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Object] $Array,
        [parameter(Mandatory = $true)]
        [String] $ScriptBlock,
        [parameter(Mandatory = $false)]
        [Int] $ThrottleLimit = 10
    )

    #Create the Runspace Pool
    $RunspacePool = [RunspaceFactory]::CreateRunspacePool(1, $throttlelimit)
    $RunspacePool.Open()
    $RunspaceCollection = New-Object system.collections.arraylist    

    foreach ($object in $array)
    {        
        $Job = [PowerShell]::Create()
        $Job.RunspacePool = $RunspacePool

        #Add the script block
        $Job.AddScript($scriptblock) | Out-Null
        $Job.AddArgument($object) | Out-Null

        #create a temporary runspace object
        $RS = New-Object -TypeName PSObject -Property @{
            Runspace   = $Job.BeginInvoke() 
            PowerShell = $Job
        }

        $RunspaceCollection.Add($RS) | Out-Null
    }

    $return = @()

    While ($RunspaceCollection)
    {
        ForEach ($Runspace in $RunspaceCollection.ToArray())
        {
            if ($Runspace.RunSpace.IsCompleted -eq $true)
            {
                $return += $Runspace.Powershell.EndInvoke($Runspace.RunSpace)
                $Runspace.Powershell.dispose()
                $RunspaceCollection.Remove($Runspace)
            }
        }
    }
    return $return
}