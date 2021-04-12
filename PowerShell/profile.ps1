# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

Import-Module posh-git -ErrorAction Ignore
Import-Module oh-my-posh -ErrorAction Ignore
if ( Get-Command Set-Theme -ErrorAction Ignore ) { Set-Theme Paradox }

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



