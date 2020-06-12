$appXPackages = @(
    '*3dbuilder*'
    '*feedback*'
    '*getstarted*'
    '*skypeapp*'
    '*zunemusic*'
    '*zune*'
    '*maps*'
    '*messaging*'
    '*wallet*'
    '*zunevideo*'
    '*commsphone*'
    '*windowsphone*'
    '*phone*'
    '*bingsports*'
    '*3d*'
    '*bingweather*'
    '*xbox*'
)
foreach ($app in $appxPackages) {
    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
}