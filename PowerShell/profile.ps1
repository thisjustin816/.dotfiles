# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

Import-Module posh-git -ErrorAction Ignore
Import-Module oh-my-posh -ErrorAction Ignore
if ( Get-Command Set-Theme -ErrorAction Ignore ) { Set-Theme Paradox }

$updateCheckPath = "$( Get-Item -Path $profile.CurrentUserAllHosts | Split-Path -Parent )\LastPSSiOpsUpdateCheck.xml"; if (!( Get-Item -Path $updateCheckPath -ErrorAction SilentlyContinue ) -or (( Import-Clixml -Path $updateCheckPath ) -lt ( Get-Date ).AddDays(-1))) { Import-Module -Name PSSiSharedFunctions -MinimumVersion 2.0.13 -Force; Get-PSSiOpsUpdate -ErrorAction SilentlyContinue }
<# Begin AzCredential #> $PSDefaultParameterValues = @{ "*-Module:Credential" = ( Get-PatPSCredential ); "*-Package:Credential" = ( Get-PatPSCredential ); "*-PackageSource:Credential" = ( Get-PatPSCredential ); "*-PackageProvider:Credential" = ( Get-PatPSCredential ); "*-PSRepository:Credential" = ( Get-PatPSCredential ) } <# End AzCredential #>
