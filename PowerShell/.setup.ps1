$profile.CurrentUserAllHosts | Remove-Item -Force -ErrorAction SilentlyContinue
( pwsh -Command '$profile.CurrentUserAllHosts' ) | Remove-Item -Force -ErrorAction SilentlyContinue
. $PSScriptRoot\profile.ps1