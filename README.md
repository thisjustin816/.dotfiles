# .dotfiles README

An original `.dotfiles` implementation for Windows. I didn't find much on Windows implementations of .dotfiles, so this is my version of it after reading some of the documentation for other operating systems.

More information on what `.dotfiles` are: [https://dotfiles.github.io/](https://dotfiles.github.io/)

## Features

- Install a preset set of apps via Chocolatey
- Settings sync for apps that supports text-based settings (VS Code, Microsoft Terminal, PowerShell profiles, etc.)
- A framework for syncing non settings file items (VS Code Extensions, PowerShell modules, etc.)
- A CLI tool for managing syncing (`dot`)
- A bin folder that's added to the path

## Prerequisites

- [Git for Windows](https://git-scm.com/download/win)

## Getting Started

### Fork and clone the `.dotfiles` repository

```batch
curl -u "[username]" "https://api.github.com/repos/thisjustin816/.dotfiles/forks" -d " "

git clone https://github.com/[username]/.dotfiles.git`

cd .dotfiles

git remote add upstream https://github.com/thisjustin816/.dotfiles.git
```

### Change any user specific settings

- Review the settings files in each directory.
- Check the parameters in the `init.ps1`, `.sync-*.ps1`, and `.setup.ps1` PowerShell scripts.
- Modify the `.[item]` lists in each folder.

### Run the initialization script

`powershell init.ps1`

---

## Settings Sync

To add an application/folder to settings sync. Create a named folder in the root with a `.path.ps1` file containing just the path to the settings folder, and a `.setup.ps1` file with any app specific setup. Copy the settings files and folders that you want synced into this repo. After running `init`, all those files and folders are replaced with symlinks to the versions here.

## Item Sync/Export

For each group of manual items that can't be synced using symlinks, create a folder here with at least these 3 files:

- `.export-[itemtype].ps1` - This should contain a method for exporting the items on the current machines and merging it with the list in this repo.
- `.sync-[itemtype].ps1` - This should contain the method for installing/applying the list of items.
- `.[itemtype]` - The list of items to sync.

---

## `dot` CLI Reference

### Usage

`dot <command> [section]`

### Commands

#### `init`

Pulls the latest files, installs all apps and PowerShell modules, applies symbolic links to settings directories, and syncs all configured items.

#### `show`

Shows the functional sections that the command can apply to.

#### `sync`

Pulls the latest files, installs all apps and PowerShell modules, and syncs all configured items.

#### `update`

Pulls the latest files to update synced settings.

#### `save`

Commits and pushes all local changes to the .dotfiles origin repo.

#### `discard`

Discards all local changes.

#### `status`

Gives the git status of the .dotfiles repo.

#### `export`

Exports all configured items on the current machine to sync to other machines.

#### `help`

Displays this information.

### Examples

`dot update`  
Pulls the latest from all folders.

`dot sync VSCode`  
Gets the latest settings and installs any missing extensions for VS Code.

`dot sync PowerShell, apps`
Gets the latest settings and syncs PowerShell modules and apps.
