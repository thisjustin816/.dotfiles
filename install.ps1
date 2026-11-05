#Requires -Version 5.1

<#
.SYNOPSIS

Bootstraps Windows from this checkout.

.DESCRIPTION

Installs PowerShell 7, Git, the GitHub CLI, and chezmoi with WinGet, signs Git in to GitHub so
private repositories can clone, then applies chezmoi with this checkout as the source. The script
targets Windows PowerShell 5.1 because a new machine has no PowerShell 7 until this script installs
it, and the chezmoi scripts require PowerShell 7.
#>
[CmdletBinding()]
param()

process {
    $ErrorActionPreference = 'Stop'

    if (-not (Get-Command -Name 'winget' -ErrorAction SilentlyContinue)) {
        throw 'WinGet is required. Install App Installer from the Microsoft Store, then run this script again.'
    }

    $packageIds = @(
        'Git.Git'
        'GitHub.cli'
        'Microsoft.PowerShell'
        'twpayne.chezmoi'
    )

    foreach ($packageId in $packageIds) {
        & winget list --id $packageId --exact --accept-source-agreements
        if ($LASTEXITCODE -eq 0) {
            Write-Verbose -Message "$packageId is already installed."
            continue
        }

        & winget install `
            --id $packageId `
            --exact `
            --source winget `
            --accept-package-agreements `
            --accept-source-agreements
        if ($LASTEXITCODE -ne 0) {
            throw "WinGet failed to install $packageId."
        }
    }

    # WinGet writes PATH changes to the machine and user environment, not to this process, so reload
    # PATH before calling the tools it just installed.
    $env:Path = (
        [Environment]::GetEnvironmentVariable('Path', 'Machine') +
        ';' +
        [Environment]::GetEnvironmentVariable('Path', 'User')
    )

    & gh auth status --hostname github.com
    if ($LASTEXITCODE -ne 0) {
        & gh auth login --hostname github.com --git-protocol https --web
        if ($LASTEXITCODE -ne 0) {
            throw 'GitHub CLI sign-in failed.'
        }
    }

    & gh auth setup-git --hostname github.com
    if ($LASTEXITCODE -ne 0) {
        throw 'GitHub CLI failed to configure Git credentials.'
    }

    & chezmoi init --apply --source $PSScriptRoot
    if ($LASTEXITCODE -ne 0) {
        throw 'chezmoi failed to apply the dotfiles.'
    }
}
