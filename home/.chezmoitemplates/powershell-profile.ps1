Import-Module -Name 'posh-git' -ErrorAction SilentlyContinue

if (Get-Command -Name 'oh-my-posh' -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh | Invoke-Expression
}

$localProfile = Join-Path $HOME '.config/powershell/profile.local.ps1'
if (Test-Path -LiteralPath $localProfile -PathType Leaf) {
    . $localProfile
}
