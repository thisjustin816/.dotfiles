# This file will contain sensitive information and should not be committed to the repo.
$envVariables = Import-PowerShellDataFile -Path "$PSScriptRoot\.envVars.psd1"
<# EXAMPLE
@{
    System_AccessToken = '*********************************************'
    System_CollectionUri = 'https://dev.azure.com/[organization]'
    System_TeamProject = 'PowerShellProject'
    Build_RequestedFor = 'Justin Beeson'
    Build_RequestedForEmail = 'jbeeson@organization.email'
}
#>

foreach ($var in $envVariables.Keys) {
    [System.Environment]::SetEnvironmentVariable($var, $envVariables[$var], 'User')
    New-Item -Path "env:$var" -Value $envVariables[$var] -Force
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
