# .dotfiles README

An original `.dotfiles` implementation for Windows. I didn't find much on Windows implementations of .dotfiles, so this is my version of it after reading some of the documentation for other operating systems.

More information: [https://dotfiles.github.io/](https://dotfiles.github.io/)

## Features

- Settings sync for apps that supports text-based settings
- A framework for syncing non settings file items
- A CLI tool for managing syncing (`dot`)
- A bin folder that's added to the path

## `dot` CLI

### `init`

Pulls the latest files, installs all apps and PowerShell modules, applies symbolic links to settings directories, and syncs all configured items.

### `show`

Shows the functional sections that the command can apply to.

### `sync`

Pulls the latest files, installs all apps and PowerShell modules, and syncs all configured items.

### `update`

Pulls the latest files to update synced settings.

### `save`

Commits and pushes all local changes to the .dotfiles origin repo.

### `status`

Gives the git status of the .dotfiles repo.

### `export`

Exports all configured items on the current machine to sync to other machines.

### `help`

Displays this information.

## Settings Sync

To add an application/folder to settings sync. Create a named folder in the root with a `.path.ps1` file containing just the path to the settings folder, and a `.setup.ps1` file with any app specific setup. All files and folders are replaced with symlinks to the versions in this repo.

## Item Sync/Export

For each group of manual items that can't be synced using symlinks, create a folder here with at least these 3 files:

- `.export-[itemtype].ps1` - This should contain a method for exporting the items on the current machines and merging it with the list in this repo.
- `.sync-[itemtype].ps1` - This should contain the method for installing/applying the list of items.
- `.[itemtype]` - The list of items to sync.
