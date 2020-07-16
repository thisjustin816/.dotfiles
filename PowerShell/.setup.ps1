"$($profile.CurrentUserAllHosts)" | Remove-Item -Force -ErrorAction SilentlyContinue
( pwsh -NoProfile -Command '"$($profile.CurrentUserAllHosts)"' -ErrorAction SilentlyContinue ) |
    Remove-Item -Force -ErrorAction SilentlyContinue
