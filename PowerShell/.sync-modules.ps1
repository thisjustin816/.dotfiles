# Fix a bug in PowerShellCore that prevents NuGet from being installed
Get-ChildItem `
    -Path $env:PSModulePath.Split(';') `
    -Filter 'PackageManagement' `
    -Directory `
    -ErrorAction SilentlyContinue |
    Get-ChildItem -Directory |
    Where-Object -Property Name -Match '\d*\.\d*\.\d*' |
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

Install-PackageProvider -Name 'NuGet' -Force
$modulesToInstall = @()
$modulesToInstall += Get-Content -Path "$PSScriptRoot\.modules"
$installedModules = @()
$installedModules += Get-InstalledModule |
    Where-Object -Property Repository -EQ PSGallery |
    Where-Object -Property Name -NotMatch 'Az.*' |
    Select-Object -ExpandProperty Name
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
Get-InstalledModule |
    Where-Object -Property Name -NotMatch 'Az.*' |
    Update-Module -PassThru |
    Select-Object -Property Name, Version, Description |
    Format-Table
