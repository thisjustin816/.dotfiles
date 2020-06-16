@echo off
goto :commands
:help
    echo usage: dot ^<command^> [section]
    echo:
    echo Command descriptions:
    echo:
    echo   init        Pulls the latest files, installs all apps and PowerShell modules, applies symbolic links to
    echo               settings directories, and syncs all configured items.
    echo:
    echo   show        Shows the functional sections that the command can apply to.
    echo:
    echo   sync        Pulls the latest files, installs all apps and PowerShell modules, and syncs all configured items.
    echo:
    echo   update      Pulls the latest files to update synced settings.
    echo:
    echo   save        Commits and pushes all local changes to the .dotfiles origin repo.
    echo:
    echo   status      Gives the git status of the .dotfiles repo.
    echo:
    echo   export      Exports all configured items on the current machine to sync to other machines.
    echo:
    echo   help        Displays this information.
    echo:
goto :eof

:commands

powershell -Command "& {Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force}"

if "%1"=="init" (
    set "valid=true"
    powershell -Command "& %~dp0..\init.ps1 -Filter '%2'"
)
if "%1"=="show" (
    set "valid=true"
    powershell -Command "& %~dp0..\init.ps1 -Filter '%2' -Pull $false -Setup $false -InitializeSettings $false -ItemSync $false"
)
if "%1"=="sync" (
    set "valid=true"
    powershell -Command "& %~dp0..\init.ps1 -Filter '%2' -Setup $false -InitializeSettings $false"
)
if "%1"=="update" (
    set "valid=true"
    powershell -Command "& %~dp0..\init.ps1 -Filter '%2' -Setup $false -InitializeSettings $false -ItemSync $false"
)
if "%1"=="save" (
    set "valid=true"
    pushd %~dp0..
    git add .
    git commit -a -m ".dotfiles saved by dot save"
    git pull
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
    powershell -Command "& %~dp0..\init.ps1 -Filter '%2' -Setup $false -InitializeSettings $false -ItemSync $false -ItemExport $true"
)
if "%1"=="help" (
    set "valid=true"
    goto :help
)

if "%valid%"=="true" (
    goto :eof
)
goto :help
