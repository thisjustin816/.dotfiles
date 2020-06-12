if (!( Get-Command -Name choco -ErrorAction SilentlyContinue )) {
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    Start-Process `
        -FilePath 'choco' `
        -ArgumentList ('feature', 'enable', '-n=allowGlobalConfirmation') `
        -NoNewWindow `
        -Wait
}
