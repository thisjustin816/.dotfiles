[CmdletBinding()]
param (
    [String]$UserName = 'GitHub User',
    [String]$UserEmail = 'email@example.com',
    [Parameter(Position = 0)]
    [AllowNull()]
    [AllowEmptyString()]
    [String[]]$Filter = @('*'),
    [bool]$Pull = $true,
    [bool]$Setup = $true,
    [bool]$InitializeSettings = $true,
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

        foreach ($originalLocation in $Path) {
            $originalItems = @( Get-ChildItem -Path $originalLocation -ErrorAction SilentlyContinue )
            $syncedItems = @( Get-ChildItem -Path $Target | Where-Object -Property Name -NotMatch '^\..*$' )
            $targetItem = Get-Item -Path $Target
            foreach ($syncedItem in $syncedItems) {
                if ($originalItems.Name -contains $syncedItem.Name) {
                    $originalItem = $originalItems |
                        Where-Object -FilterScript { $_.Name -eq $syncedItem.Name }
                    $originalItem.Delete()
                }
                New-Item `
                    -ItemType 'SymbolicLink' `
                    -Path "$originalLocation\$($syncedItem.Name)" `
                    -Target "$($targetItem.FullName)\$($syncedItem.Name)" `
                    -Force
            }
        }
    }
}

process {
    $WriteProgress = @{
        Activity = '.dotfiles Initialization'
    }

    $WriteProgress['Status'] = 'Downloading the latest .dotfiles...'
    Write-Progress @WriteProgress
    $filePath = 'git'
    $git = @{
        FilePath         = $filePath
        WorkingDirectory = $PSScriptRoot
        NoNewWindow      = $true
        Wait             = $true
    }

    $WriteProgress['Status'] = 'Configuring Environment...'
    Write-Progress @WriteProgress
    $dotFilesBin = ( Resolve-Path -Path "$PSScriptRoot\bin" ).Path
    $newPath = "$dotFilesBin; " + ($env:Path -replace [Regex]::Escape("$dotFilesBin; "), '')
    $env:Path = $newPath
    [System.Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Start-Process @git -ArgumentList 'config', '--local', 'user.name', $UserName
    Start-Process @git -ArgumentList 'config', '--local', 'user.email', $UserEmail
    if ($Pull) {
        Start-Process @git -ArgumentList 'pull'
    }
    $WriteProgress['Status'] = 'Gathering Items to Set Up...'
    Write-Progress @WriteProgress
    if ($null -eq $Filter) {
        $Filter = @('*')
    }
    $dotFolders = @()
    foreach ($pattern in $Filter) {
        if ($pattern -ne '*') {
            $pattern = "$pattern*"
        }
        $dotFolders += Get-ChildItem -Path $PSScriptRoot -Filter $pattern -Directory |
            Where-Object -FilterScript {
                $_.Name -notmatch '^\..*' -and
                $_.Name -ne 'bin'
            }
    }
    foreach ($folder in $dotFolders) {
        $folder
        $WriteProgress['Status'] = "Configuring $($folder.Name)..."
        Write-Progress @WriteProgress
        Push-Location -Path $folder.FullName
        if ($Setup -and ( Get-Item -Path ".\.setup.ps1" -ErrorAction SilentlyContinue )) {
            $WriteProgress['CurrentOperation'] = 'Setup'
            Write-Progress @WriteProgress
            . ".\.setup.ps1"
        }
        if ( $InitializeSettings -and ( Get-Item -Path ".\.path.ps1" -ErrorAction SilentlyContinue )) {
            $WriteProgress['CurrentOperation'] = 'Settings Initialization'
            Write-Progress @WriteProgress
            $linkPath = & ".\.path.ps1"
            if ( Resolve-Path -Path $linkPath -ErrorAction SilentlyContinue ) {
                Set-SymbolicLink -Path $linkPath -Target $folder.FullName
            }
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
        if ($ItemExport -and ( Get-Item -Path ".\.export-*.ps1" -ErrorAction SilentlyContinue )) {
            $exports = & Get-Item -Path ".\.export-*.ps1"
            foreach ($export in $exports) {
                $itemName = $sync.BaseName.Split('-')[1]
                $WriteProgress['CurrentOperation'] = "$(( Get-Culture ).TextInfo.ToTitleCase($itemName)) Export"
                Write-Progress @WriteProgress
                . $export.FullName
            }
        }
        Pop-Location
    }
    Write-Progress @WriteProgress -Completed
}
