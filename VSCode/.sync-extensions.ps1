$extensionsToInstall = @()
$extensionsToInstall += Get-Content -Path "$PSScriptRoot\.extensions"
$currentExtensions = @()
$currentExtensions += Invoke-Command -ScriptBlock { code --list-extensions }
$code = @{
    FilePath = "$env:ProgramFiles\Microsoft VS Code\bin\code.cmd"
    NoNewWindow = $true
    Wait = $true
}
foreach ($extension in $extensionsToInstall) {
    if ($currentExtensions -notcontains $extension) {
        Start-Process @code -ArgumentList ('--install-extension', $extension, '--force')
    }
}
