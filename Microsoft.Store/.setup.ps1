$appXPackages = @(
    '*3dBuilder*'
    '*CBSPreview*'
    '*Client.CBS*'
    '*Feedback*'
    '*GetHelp*'
    '*GetStarted*'
    '*SkypeApp*'
    '*ZuneMusic*'
    '*Zune*'
    '*Maps*'
    '*Messaging*'
    '*Wallet*'
    '*ZuneVideo*'
    '*CommsPhone*'
    '*WindowsPhone*'
    '*Phone*'
    '*BingSports*'
    '*3d*'
    '*Xbox*'
)
foreach ($app in $appxPackages) {
    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
    # The AppxPackage cmdlets leave the progress bar in the console
    Write-Progress -Activity 'Clear Progress Bar' -Completed
}
