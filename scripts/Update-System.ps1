#Requires -Version 7

<#
.SYNOPSIS

Installs pending operating system updates on Windows or macOS.

.DESCRIPTION

On Windows, registers the Microsoft Update service, installs updates through
PSWindowsUpdate, and offers to restart if one is required. On macOS, installs
updates through the built-in softwareupdate command. Requires an elevated
shell: Administrator on Windows, sudo on macOS.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

if ($IsWindows) {
    $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $currentPrincipal = [Security.Principal.WindowsPrincipal]::new($currentIdentity)
    if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw 'Run this script from an elevated (Administrator) PowerShell session.'
    }

    if (-not (Get-Module -Name PSWindowsUpdate -ListAvailable)) {
        throw "PSWindowsUpdate is not installed. Run 'chezmoi apply' first."
    }
    Import-Module -Name PSWindowsUpdate

    $null = Add-WUServiceManager -MicrosoftUpdate -Confirm:$false

    Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot |
        Select-Object -Property KB, Title, Description, SupportUrl |
        Sort-Object -Property KB -Unique

    if ((Get-WURebootStatus -Silent).RebootRequired) {
        $response = Read-Host -Prompt 'A restart is required to finish installing updates. Restart now? (y/N)'
        if ($response -eq 'y') {
            Restart-Computer
        }
    }
}
elseif ($IsMacOS) {
    if ((& id -u) -ne '0') {
        throw 'Run this script with sudo.'
    }

    & softwareupdate --install --all
    if ($LASTEXITCODE -ne 0) {
        throw 'softwareupdate failed.'
    }
}
else {
    throw 'Update-System.ps1 supports Windows and macOS only.'
}
