# .dotfiles README

I didn't find much on Windows implementations of .dotfiles, so this is my version of it after reading some of the documentation for other operating systems.

> WORK IN PROGRESS

Reference: https://dotfiles.github.io/

## Features

- Settings sync for apps that supports test-based settings
- A framework for syncing non settings file items
- A CLI tool for managing syncing (`dot`)
- A bin folder that's added to the path

## `dot` CLI

> TODO

## Settings

To add an application/folder to settings sync. Create a named folder in the root with a `.path.ps1` file containing just the path to the settings folder, and a `.setup.ps1` file with any app specific setup. All files and folders are replaced with symlinks to the versions in this repo.

## Sync/Export

For each group of manual items that can't be synced using symlinks. Create a folder here with at least these 3 files:

- `.export-[itemtype].ps1` - This should contain a method for exporting the items on the current machines and merging it with the list in this repo.
- `.sync-[itemtype].ps1` - This should contain the method for installing/applying the list of items.
- `.[itemtype]` - The list of items.
