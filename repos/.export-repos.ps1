$reposPath = @( & "$PSScriptRoot\.path.ps1" )
New-Item -Path $reposPath -ItemType Directory -Force
$filePath = 'git'
$git = @{
    FilePath = $filePath
    NoNewWindow = $true
    Wait = $true
}

$temp = New-TemporaryFile
Get-Content -Path $temp.FullName | Set-Content -Path "$PSScriptRoot\.repos" -Force
foreach ($path in $reposPath) {
    Push-Location -Path $path
    $repos = Get-ChildItem -Directory
    foreach ($repo in $repos.FullName) {
        Push-Location -Path $repo
        Start-Process `
            @git `
            -ArgumentList (
                'config',
                '--get',
                'remote.origin.url'
            ) `
            -RedirectStandardOutput $temp.FullName
        Get-Content -Path $temp.FullName | Add-Content -Path "$PSScriptRoot\.repos"
        Pop-Location
    }
    Pop-Location
}