param (
    [String]$UserName = 'GitHub User',
    [String]$UserEmail = 'email@example.com'
)

$repos = Get-Content -Path "$PSScriptRoot\.repos"
$reposPath = @( & "$PSScriptRoot\.path.ps1" )
New-Item -Path $reposPath -ItemType Directory -Force
$git = @{
    FilePath = 'git'
    NoNewWindow = $true
    Wait = $true
}

foreach ($path in $reposPath) {
    Push-Location -Path $path
    foreach ($repo in $repos) {
        Start-Process @git -ArgumentList 'clone', $repo
        $localRepoPath = Join-Path `
            -Path $path `
            -ChildPath ( $repo.Split('/') | Select-Object -Last 1 ).Replace('.git', '')
        Push-Location -Path $localRepoPath
        Start-Process @git -ArgumentList 'config', '--local', 'user.name', $UserName
        Start-Process @git -ArgumentList 'config', '--local', 'user.email', $UserEmail
        Pop-Location
    }
    Pop-Location
}