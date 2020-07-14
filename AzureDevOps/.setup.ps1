if (!( Get-Command Import-PowerShellDataFile -ErrorAction SilentlyContinue )) {
    Import-Module -Name "C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules\Microsoft.PowerShell.Utility\Microsoft.PowerShell.Utility.psd1"
}
# This file will contain sensitive information and should not be committed to the repo.
<# EXAMPLE
@{
    System_AccessToken = '*********************************************'
    System_CollectionUri = 'https://dev.azure.com/[organization]'
    System_TeamProject = 'PowerShellProject'
    Build_RequestedFor = 'Justin Beeson'
    Build_RequestedForEmail = 'jbeeson@organization.email'
}
#>
$envVariables = @{}
try {
    $envVariables = Import-PowerShellDataFile -Path $PSScriptRoot\.envVars.psd1 -ErrorAction Stop
}
catch {
    try {
        $envVarNames = (
            'System_AccessToken',
            'System_CollectionUri',
            'System_TeamProject',
            'Build_RequestedFor',
            'Build_RequestedForEmail'
        )
        foreach ($var in $envVarNames) {
            $envVariables[$var] = ( Get-Item -Path "env:$var" -ErrorAction Stop ).Value
        }
    }
    catch {
        Write-Warning -Message (
            "Couldn't import environment variables. Have you created " +
            "$PSScriptRoot\.envVars.psd1 or manually set the environment variables?"
        )
        Write-Host -Object "Example:"
        Write-Host -Object @"
@{
    System_AccessToken = '*********************************************'
    System_CollectionUri = 'https://dev.azure.com/[organization]'
    System_TeamProject = 'PowerShellProject'
    Build_RequestedFor = 'Justin Beeson'
    Build_RequestedForEmail = 'jbeeson@organization.email'
}
"@
        exit
    }
}

foreach ($var in $envVariables.Keys) {
    [System.Environment]::SetEnvironmentVariable($var, $envVariables[$var], 'User')
    New-Item -Path "env:$var" -Value $envVariables[$var] -Force |
        ForEach-Object -Process {
            if ($_.Name -match '[Tt]oken') {
                $_.Value = '***'
            }
            $_
        }
}
