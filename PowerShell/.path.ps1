Get-Item -Path $profile.CurrentUserAllHosts | Split-Path -Parent
pwsh -Command 'Get-Item -Path $profile.CurrentUserAllHosts | Split-Path -Parent'