




$updateCheckPath = "$( Get-Item -Path $profile | Split-Path -Parent )\LastPSSiOpsUpdateCheck.xml"; if (!( Get-Item -Path $updateCheckPath -ErrorAction SilentlyContinue ) -or (( Import-Clixml -Path $updateCheckPath ) -lt ( Get-Date ).AddDays(-1))) { Import-Module -Name PSSiSharedFunctions -MinimumVersion 2.0.13 -Force; Get-PSSiOpsUpdate -ErrorAction SilentlyContinue }

<# Begin AzCredential #> $AzCredential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList ($env:USERNAME, ( ConvertTo-SecureString -String $env:System_AccessToken -AsPlainText -Force )); $PSDefaultParameterValues = @{ "*-Module:Credential" = $AzCredential; "*-Package:Credential" = $AzCredential; "*-PackageSource:Credential" = $AzCredential; "*-PackageProvider:Credential" = $AzCredential; "*-PSRepository:Credential" = $AzCredential } <# End AzCredential #>
