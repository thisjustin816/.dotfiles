# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

# PowerShell terminal customization
$ohMyPosh = Get-Command -Name "$env:LOCALAPPDATA\Programs\oh-my-posh\bin\oh-my-posh.exe" -ErrorAction SilentlyContinue
$pwsh = $PSVersionTable.PSVersion.Major -gt 5
if ($pwsh -and $ohMyPosh) {
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

<# Begin AzCredential #> $AzCredential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList ($env:USERNAME, ( ConvertTo-SecureString -String $env:System_AccessToken -AsPlainText -Force )); $PSDefaultParameterValues = @{ "*-Module:Credential" = $AzCredential; "*-Package:Credential" = $AzCredential; "*-PackageSource:Credential" = $AzCredential; "*-PackageProvider:Credential" = $AzCredential; "*-PSResource:Credential" = $AzCredential; "*-PSRepository:Credential" = $AzCredential } <# End AzCredential #>
$updateCheckPath = "$( Get-Item -Path $profile | Split-Path -Parent )\LastPSSiOpsUpdateCheck.xml"; if (!( Get-Item -Path $updateCheckPath -ErrorAction SilentlyContinue ) -or (( Import-Clixml -Path $updateCheckPath ) -lt ( Get-Date ).AddDays(-1))) { Get-PSSiOpsUpdate -ErrorAction SilentlyContinue }
