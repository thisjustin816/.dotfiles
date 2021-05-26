$appsToInstall = @()
$appsToInstall += Get-Content -Path "$PSScriptRoot\.apps"
$currentApps = @()
$currentApps += Invoke-Command -ScriptBlock { choco list -lo } |
    Select-Object -Skip 1 |
    Select-Object -SkipLast 1 |
    ForEach-Object -Process { $_.Split(' ')[0] }
$choco = @{
    FilePath = 'choco'
    NoNewWindow = $true
    Wait = $true
}
foreach ($app in $appsToInstall) {
    if ($currentApps -notcontains $app) {
        Start-Process @choco -ArgumentList ('install', $app, '-y')
    }
}
Start-Process @choco -ArgumentList ('upgrade', 'all', '-y')

Import-Module -Name "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1" -ErrorAction Ignore
Update-SessionEnvironment -ErrorAction Ignore

$winget = Get-Command -Name winget -ErrorAction SilentlyContinue
if ($winget) {
    Start-Process -FilePath $winget.Source -ArgumentList ('upgrade', '--all') -NoNewWindow -Wait
}
