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
}
