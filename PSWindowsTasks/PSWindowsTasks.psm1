#Get public and private function definition files.
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach ($import in (@($Public + $Private) | Sort))
{
    Try
    {
        . $import.fullname
        Write-Output $import.fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

#Export Public functions ($Public.BaseName) for WIP modules
Export-ModuleMember -Function $Public.Basename

#Set variables visible to the module and its functions only
$script:defpath = "$($env:APPDATA)\GHSWindowsTasks\"
$script:deffile = "ConsolePathDefinitions.xml"

#Read in or create an initial config file and variable
New-ConsoleDefs