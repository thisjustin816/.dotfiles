$modules = @()
$modules += Get-Content -Path "$PSScriptRoot\.modules"
$modules += Get-InstalledModule |
    Where-Object -Property Repository -EQ PSGallery |
    Where-Object -Property Name -NotMatch 'Az.*' |
    Select-Object -ExpandProperty Name
$modules | Sort-Object -Unique | Out-File -FilePath "$PSScriptRoot\.modules" -Encoding utf8
