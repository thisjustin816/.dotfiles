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
            $envVariables[$var] = ( Get-Item -Path "env:$var" ).Value
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

if (!( Get-InstalledModule -Name PSSiOps -ErrorAction SilentlyContinue )) {
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://sidevbin.blob.core.windows.net/files/PowerShell/Install-PSSiOps.ps1'))
}

$noInstall = (
    ( Get-Command -Name 'cm' -ErrorAction SilentlyContinue ) -and
    ( Get-Item -Path '\\127.0.0.1\ScmFeed' -ErrorAction SilentlyContinue )
)
if (!$noInstall) {
    Start-CmToolsSetup
}
