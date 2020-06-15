$profile | Remove-Item -Force -ErrorAction SilentlyContinue
( pwsh -Command '$profile' ) | Remove-Item -Force -ErrorAction SilentlyContinue
. $PSScriptRoot\profile.ps1