#Requires -Version 7

<#
.SYNOPSIS

Exports existing Git working copies to the gitignored chezmoi repository manifest.

.DESCRIPTION

Finds Git working copies beneath the repository root, excludes generated dependency
and tool-cache directories, removes credentials from HTTPS origins, and writes a
stable JSON manifest. Chezmoi merges this local data with the tracked public
repository list.

.PARAMETER RepositoriesRoot

Root directory containing working copies.

.PARAMETER OutputPath

Destination for the local chezmoi data file.
#>
[CmdletBinding()]
param(
    [String]$RepositoriesRoot = (Join-Path $HOME 'repos'),

    [String]$OutputPath = (
        Join-Path $PSScriptRoot '../home/.chezmoidata/repositories.local.json'
    )
)

$ErrorActionPreference = 'Stop'

$existingRepositories = @{}
if (Test-Path -LiteralPath $OutputPath -PathType Leaf) {
    $existingManifest = Get-Content -LiteralPath $OutputPath -Raw | ConvertFrom-Json -AsHashtable
    if ($existingManifest.repositories) {
        $existingRepositories = $existingManifest.repositories
    }
}

$repositoriesRootPath = (Resolve-Path -LiteralPath $RepositoriesRoot -ErrorAction Stop).Path
$outputFilePath = [IO.Path]::GetFullPath($OutputPath)
$excludedDirectoryNames = @(
    '.external_modules'
    '.terraform'
    '.terragrunt-cache'
    'node_modules'
)

$gitMarkers = Get-ChildItem `
    -LiteralPath $repositoriesRootPath `
    -Filter '.git' `
    -Recurse `
    -Force `
    -ErrorAction SilentlyContinue

$repositoryDirectories = $gitMarkers |
    ForEach-Object -Process {
        if ($_.PSIsContainer) {
            $_.Parent.FullName
        }
        else {
            $_.DirectoryName
        }
    } |
    Sort-Object -Unique

$repositories = [Ordered]@{}
foreach ($repositoryDirectory in $repositoryDirectories) {
    $relativePath = [IO.Path]::GetRelativePath($repositoriesRootPath, $repositoryDirectory)
    $pathSegments = $relativePath -split '[\\/]'
    if ($pathSegments | Where-Object -FilterScript { $_ -in $excludedDirectoryNames }) {
        continue
    }

    $origin = & git `
        -c 'safe.directory=*' `
        -C $repositoryDirectory `
        config `
        --get `
        remote.origin.url 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $origin) {
        Write-Warning -Message "Skipping $repositoryDirectory because it has no origin remote."
        continue
    }

    $sanitizedOrigin = $origin -replace '^(https?://)[^/@]+@', '$1'
    $manifestPath = (
        'repos/' +
        $relativePath.Replace([IO.Path]::DirectorySeparatorChar, '/')
    )
    $key = ($relativePath -replace '[^A-Za-z0-9]+', '_').Trim('_').ToLowerInvariant()
    if ($repositories.Contains($key)) {
        throw "Repository key '$key' is not unique. Rename one of the working-copy directories."
    }

    $repositories[$key] = [Ordered]@{
        path = $manifestPath
        url = $sanitizedOrigin
    }
    $existing = $existingRepositories[$key]
    if ($existing -and $existing.path -eq $manifestPath -and $existing.skills) {
        $repositories[$key].skills = @($existing.skills)
    }
}

$outputDirectory = Split-Path -Path $outputFilePath -Parent
$null = New-Item -Path $outputDirectory -ItemType Directory -Force

@{
    repositories = $repositories
} |
    ConvertTo-Json -Depth 5 |
    Set-Content -LiteralPath $outputFilePath -Encoding utf8NoBOM

[PSCustomObject]@{
    OutputPath = $outputFilePath
    RepositoryCount = $repositories.Count
}
