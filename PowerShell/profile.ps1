﻿# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

Import-Module posh-git -ErrorAction Ignore
Import-Module oh-my-posh -ErrorAction Ignore
if ( Get-Command Set-Theme -ErrorAction Ignore ) { Set-Theme Paradox }

$updateCheckPath = "$( Get-Item -Path $profile | Split-Path -Parent )\LastPSSiOpsUpdateCheck.xml"; if (!( Get-Item -Path $updateCheckPath -ErrorAction SilentlyContinue ) -or (( Import-Clixml -Path $updateCheckPath ) -lt ( Get-Date ).AddDays(-1))) { Import-Module -Name PSSiSharedFunctions -MinimumVersion 2.0.13 -Force; Get-PSSiOpsUpdate -ErrorAction SilentlyContinue }

<# Begin AzCredential #> $PSDefaultParameterValues = @{ "*-Module:Credential" = Get-PatPSCredential; "*-Package:Credential" = Get-PatPSCredential; "*-PackageSource:Credential" = Get-PatPSCredential; "*-PackageProvider:Credential" = Get-PatPSCredential; "*-PSRepository:Credential" = Get-PatPSCredential } <# End AzCredential #>

function Start-DevVm {
    [CmdletBinding()]
    param(
        $Name = 'jbeeson-vm01',
        $ResourceGroupName = 'jbeeson-vm01_group'
    )
    $azVm = @{
        Name = $Name
        ResourceGroupName = $ResourceGroupName
    }
    try {
        Start-AzVm @azVm -ErrorAction Stop
    }
    catch {
        Connect-AzAccount
        Start-AzVm @azVm
    }
}
Set-Alias -Name vm -Value Start-DevVm

function Stop-DevVm {
    [CmdletBinding()]
    param(
        $Name = 'jbeeson-vm01',
        $ResourceGroupName = 'jbeeson-vm01_group'
    )
    $azVm = @{
        Name = $Name
        ResourceGroupName = $ResourceGroupName
        Force = $true
    }
    try {
        Stop-AzVm @azVm -ErrorAction Stop
    }
    catch {
        Connect-AzAccount
        Stop-AzVm @azVm
    }
}
Set-Alias -Name vmx -Value Stop-DevVm
