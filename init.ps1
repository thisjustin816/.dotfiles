[CmdletBinding()]
param (
    [String]$UserName = 'Justin Beeson',
    [String]$UserEmail = 'justinbeeson@gmail.com',
    [bool]$Setup = $true,
    [bool]$SettingsSync = $true,
    [bool]$ItemSync = $true,
    [bool]$ItemExport = $false
)

begin {
    function Set-SymbolicLink {
        [CmdletBinding()]
        param (
            [String[]]$Path,
            [String]$Target
        )

        foreach ($item in $Path) {
            $originalItems = Get-ChildItem -Path $item
            $syncedItems = Get-ChildItem -Path $Target | Where-Object -NotMatch '\..*'
            foreach ($item in $originalItems) {
                if ($syncedItems.Name -contains $item.Name) {
                    $item | Remove-Item -Force -WhatIf
                    if ($item -is 'System.IO.DirectoryInfo') {
                        #$itemType = 'Junction'
                        $itemType = 'SymbolicLink'
                    }
                    else {
                        $itemType = 'SymbolicLink'
                    }
                    New-Item `
                        -ItemType $itemType `
                        -Path $item.FullName `
                        -Target "$($Target.Directory)\$($item.Name)" `
                        -WhatIf
                }
            }
        }
    }
}

process {
    $WriteProgress = @{
        Activity = '.dotfiles Initialization'
        Status = 'Downloading the latest .dotfiles...'
    }
    Write-Progress @WriteProgress
    if ( Get-Command -Name 'git' -ErrorAction SilentlyContinue ) {
        $filePath = 'git'
    }
    else {
        $filePath = '$PSScriptRoot\.MinGit\R00T64\git\git.exe'
    }
    $git = @{
        FilePath = $filePath
        WorkingDirectory = $PSScriptRoot
        NoNewWindow = $true
        Wait = $true
    }

    $WriteProgress['Status'] = 'Configuring Environment...'
    Write-Progress @WriteProgress
    $dotFilesBin = ( Resolve-Path -Path "$PSScriptRoot\bin" ).Path
    $newPath = "$dotFilesBin; " + ($env:Path -replace [Regex]::Escape("$dotFilesBin; "), '')
    $env:Path = $newPath
    [System.Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Start-Process @git -ArgumentList 'config', '--local', 'user.name', $UserName
    Start-Process @git -ArgumentList 'config', '--local', 'user.email', $UserEmail
    Start-Process @git -ArgumentList 'pull'

    $WriteProgress['Status'] = 'Gathering Items to Set Up...'
    Write-Progress @WriteProgress
    $dotFolders = Get-ChildItem -Path $PSScriptRoot -Exclude 'bin' -Directory |
        Where-Object -Property Name -NotMatch '$\..*^'
    foreach ($folder in $dotFolders) {
        $WriteProgress['Status'] = "Configuring $($folder.Name)..."
        Write-Progress @WriteProgress
        Push-Location -Path $folder.FullName
        if ($Setup -and ( Get-Item -Path ".\.setup.ps1" -ErrorAction SilentlyContinue )) {
            $WriteProgress['CurrentOperation'] = 'Setup'
            Write-Progress @WriteProgress
            . ".\.setup.ps1"
        }
        if ($SettingsSync -and ( Get-Item -Path ".\.path.ps1" -ErrorAction SilentlyContinue )) {
            $WriteProgress['CurrentOperation'] = 'Settings Sync'
            Write-Progress @WriteProgress
            $linkPath = & ".\.path.ps1"
            Set-SymbolicLink -Path $linkPath -Target $folder.FullName
        }
        if ($ItemSync -and ( Get-Item -Path ".\.sync-*.ps1" -ErrorAction SilentlyContinue )) {
            $syncs = & Get-Item -Path ".\.sync-*.ps1"
            foreach ($sync in $syncs) {
                $itemName = $sync.BaseName.Split('-')[1]
                $WriteProgress['CurrentOperation'] = "$(( Get-Culture ).TextInfo.ToTitleCase($itemName)) Sync"
                Write-Progress @WriteProgress
                . $sync.FullName
            }
        }
        if ($ItemSync -and ( Get-Item -Path ".\.export-*.ps1" -ErrorAction SilentlyContinue )) {
            $exports = & Get-Item -Path ".\.export-*.ps1"
            foreach ($export in $exports) {
                $itemName = $sync.BaseName.Split('-')[1]
                $WriteProgress['CurrentOperation'] = "$(( Get-Culture ).TextInfo.ToTitleCase($itemName)) Export"
                Write-Progress @WriteProgress
                . $export.FullName
            }
        }
    }
    Write-Progress @WriteProgress -Completed
}
