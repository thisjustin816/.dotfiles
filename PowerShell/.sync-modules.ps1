$progress = @{
    Activity = 'Syncing PowerShell Modules'
    Status = 'Fixing PackageManagement...'
}
Write-Progress @progress
# Fix a bug in PowerShellCore that prevents NuGet from being installed
Get-ChildItem `
    -Path $env:PSModulePath.Split(';') `
    -Filter 'PackageManagement' `
    -Directory `
    -ErrorAction SilentlyContinue |
    Get-ChildItem -Directory |
    Where-Object -Property Name -Match '\d*\.\d*\.\d*' |
    Where-Object -Property Name -NotMatch '.*\.dotfiles.*'
    Get-ChildItem -Filter 'netstandard2.0' -Directory |
    ForEach-Object -Process {
        foreach ($clr in 'fullclr', 'coreclr') {
            Copy-Item `
                -Path $_.FullName `
                -Destination "$($_.Parent)\$clr" `
                -Recurse `
                -ErrorAction SilentlyContinue
        }
    }

. $PSScriptRoot\profile.ps1

$progress['Status'] = 'Installing NuGet...'
Write-Progress @progress
Install-PackageProvider -Name 'NuGet' -Force | Select-Object -Property Name, Version

$progress['Status'] = 'Finding already installed modules...'
Write-Progress @progress
$modulesToInstall = @()
$modulesToInstall += Get-Content -Path "$PSScriptRoot\.modules"
$installedModules = @()
$installedModules += Get-InstalledModule |
    Where-Object -Property Repository -EQ PSGallery |
    Select-Object -ExpandProperty Name

$progress['Status'] = 'Installing missing modules...'
Write-Progress @progress
foreach ($module in $modulesToInstall) {
    if ($installedModules -notcontains $module) {
        Install-Module `
            -Name $module `
            -Repository PSGallery `
            -AllowClobber `
            -SkipPublisherCheck `
            -Force `
            -PassThru |
            Select-Object -Property Name, Version, Description | Format-Table
    }
}

$progress['Status'] = 'Updating all installed modules...'
Write-Progress @progress
Get-InstalledModule |
    Update-Module -PassThru |
    Select-Object -Property Name, Version, Description |
    Format-Table

Write-Progress @progress -Completed