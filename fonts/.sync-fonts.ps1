Get-ChildItem -Path "$PSScriptRoot\*" -Include ('*.ttf','*.ttc','*.otf') |
    ForEach-Object -Process {
        & "$PSScriptRoot\.add-font.ps1" $_.FullName
    }