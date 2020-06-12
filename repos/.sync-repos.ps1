param (
    [String]$UserName = 'Justin Beeson',
    [String]$UserEmail = 'justinbeeson@gmail.com'
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
        Start-Process @git -ArgumentList 'config', '--local', 'user.name', $UserName
        Start-Process @git -ArgumentList 'config', '--local', 'user.email', $UserEmail
    }
    Pop-Location
}