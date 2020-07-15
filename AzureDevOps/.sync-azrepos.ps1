param (
    [String]$UserName = $env:Build_RequestedFor,
    [String]$UserEmail = $env:Build_RequestedForEmail
)

$repos = Get-Content -Path "$PSScriptRoot\.azrepos"
$reposPath = @( & "$PSScriptRoot\.path.ps1" )
New-Item -Path $reposPath -ItemType Directory -Force
$filePath = 'git'
$git = @{
    FilePath = $filePath
    NoNewWindow = $true
    Wait = $true
}
Start-Process @git -ArgumentList 'config', '--global', 'user.name', $UserName
Start-Process @git -ArgumentList 'config', '--global', 'user.email', $UserEmail
foreach ($path in $reposPath) {
    Push-Location -Path $path
    foreach ($repo in $repos) {
        $replacement = "https://anything:$env:System_AccessToken@"
        Start-Process @git -ArgumentList (
            'clone',
            $repo -replace ('https:\/\/(([Nn]uva[Dd]ev@)|(?=dev.*))', $replacement)
        )
    }
    Pop-Location
}