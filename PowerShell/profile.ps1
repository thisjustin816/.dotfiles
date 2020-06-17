$updateCheckPath = "$( Get-Item -Path $profile.CurrentUserAllHosts | Split-Path -Parent )\LastPSSiOpsUpdateCheck.xml"; if (!( Get-Item -Path $updateCheckPath -ErrorAction SilentlyContinue ) -or (( Import-Clixml -Path $updateCheckPath ) -lt ( Get-Date ).AddDays(-1))) { Import-Module -Name PSSiSharedFunctions -MinimumVersion 2.0.13 -Force; Get-PSSiOpsUpdate -ErrorAction SilentlyContinue }

<# Begin AzCredential #> $AzCredential = Import-Clixml -Path "C:\Users\jbeeson\OneDrive - Nuvasive Inc\Documents\WindowsPowerShell\AzNugetCredential.xml"; $PSDefaultParameterValues = @{ "*-Module:Credential" = $AzCredential; "*-Package:Credential" = $AzCredential; "*-PackageSource:Credential" = $AzCredential; "*-PackageProvider:Credential" = $AzCredential; "*-PSRepository:Credential" = $AzCredential } <# End AzCredential #>

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

Import-Module posh-git
Import-Module oh-my-posh
Set-Theme Paradox
