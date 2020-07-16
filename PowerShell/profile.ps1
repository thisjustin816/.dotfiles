# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

Import-Module posh-git -ErrorAction Ignore
Import-Module oh-my-posh -ErrorAction Ignore
if ( Get-Module posh-git, oh-my-posh -ErrorAction Ignore ) { Set-Theme Paradox }
