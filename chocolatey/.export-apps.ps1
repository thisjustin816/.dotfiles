$apps = @()
$apps += Get-Content -Path "$PSScriptRoot\.apps"
$apps += Invoke-Command -ScriptBlock { choco list -lo } |
    Select-Object -Skip 2 |
    Select-Object -SkipLast 1 |
    ForEach-Object -Process { $_.Split(' ')[0] }
$apps | Sort-Object -Unique | Out-File -FilePath "$PSScriptRoot\.apps" -Encoding utf8
