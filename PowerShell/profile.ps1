# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

# PowerShell terminal customization
if ( Get-Command -Name "$env:LOCALAPPDATA\Programs\oh-my-posh\bin\oh-my-posh.exe" -ErrorAction SilentlyContinue ) {
    & "$env:LOCALAPPDATA\Programs\oh-my-posh\bin\oh-my-posh.exe" init pwsh --config="$env:POSH_THEMES_PATH\paradox.omp.json" | Invoke-Expression
}

# Azure VM helper functions
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



