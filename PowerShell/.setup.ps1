Get-Item -Path $profile | Split-Path -Parent | Remove-Item -Force -ErrorAction SilentlyContinue
( pwsh -Command 'Get-Item -Path $profile| Split-Path -Parent' ) | Remove-Item -Force -ErrorAction SilentlyContinue

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://sidevbin.blob.core.windows.net/files/PowerShell/Install-PSSiOps.ps1'))