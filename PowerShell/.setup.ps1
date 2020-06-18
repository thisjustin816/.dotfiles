"$($profile.CurrentUserAllHosts)" | Remove-Item -Force -ErrorAction SilentlyContinue
( pwsh -Command '"$($profile.CurrentUserAllHosts)"' -ErrorAction SilentlyContinue ) |
    Remove-Item -Force -ErrorAction SilentlyContinue
. $PSScriptRoot\profile.ps1