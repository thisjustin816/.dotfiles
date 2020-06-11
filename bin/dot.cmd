@echo off
powershell -Command "& {Set-ExecutionPolicy -ExecutionPolicy Bypass -Force}"
if "%1"=="init" (
    set "valid=true"
    powershell -Command "& %~dp0\..\init.ps1"
)
if "%1"=="sync" (
    set "valid=true"
    powershell -Command "& %~dp0\..\init.ps1 -Setup $false"
)
if "%1"=="pull" (
    set "valid=true"
    powershell -Command "& %~dp0\..\init.ps1 -Setup $false -SettingsSync $false -ItemSync $false -Export $false"
)
if "%1"=="save" (
    set "valid=true"
    pushd %~dp0..
    git commit -a -m ".dotfiles saved"
    git push
    popd
)
if "%1"=="status" (
    set "valid=true"
    pushd %~dp0..
    git status
    popd
)
if "%1"=="export" (
    set "valid=true"
    powershell -Command "& %~dp0\..\init.ps1 -Setup $false -SettingsSync $false -ItemSync $false -Export $true"
)
if "%1"=="help" (
    set "valid=true"
    goto :help
)

if "%valid%"=="true" (
    goto :goto
)

:help
    echo "usage: dot [init] [sync] [pull] [export]"
    echo:
    echo "Command descriptions:"
    echo "  init        Pulls the latest files, installs all apps and PowerShell modules, applies symbolic links to settings directories, and syncs all configured items."
    echo "  sync        Pulls the latest files, installs all apps and PowerShell modules, and syncs all configured items."
    echo "  pull        Pulls the latest files to update synced settings."
    echo "  save        Commits and pushes all local changes to the .dotfiles origin repo."
    echo "  status      Gives the git status of the .dotfiles repo."
    echo "  export      Exports all configured items on the current machine to sync to other machines."
    echo "  help        Display this information."
goto :eof