# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

<# Begin AzCredential #> $AzCredential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList ($env:USERNAME, ( ConvertTo-SecureString -String $env:System_AccessToken -AsPlainText -Force )); $PSDefaultParameterValues = @{ "*-Module:Credential" = $AzCredential; "*-Package:Credential" = $AzCredential; "*-PackageSource:Credential" = $AzCredential; "*-PackageProvider:Credential" = $AzCredential; "*-PSResource:Credential" = $AzCredential; "*-PSRepository:Credential" = $AzCredential } <# End AzCredential #>
$updateCheckPath = "$( Get-Item -Path $profile | Split-Path -Parent )\LastPSSiOpsUpdateCheck.xml"; if (!( Get-Item -Path $updateCheckPath -ErrorAction SilentlyContinue ) -or (( Import-Clixml -Path $updateCheckPath ) -lt ( Get-Date ).AddDays(-1))) { Get-PSSiOpsUpdate -ErrorAction SilentlyContinue }
