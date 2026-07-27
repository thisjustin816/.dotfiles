# Dotfiles

This repository is a personal [chezmoi](https://www.chezmoi.io/) source state
that keeps a Windows and macOS development environment consistent. It's
public so the pattern can be reused: fork it, then edit the data files under
`home/.chezmoidata/` to match your own machines.

Chezmoi manages:

- Git identity
- PowerShell profiles
- The macOS zsh profile
- Applications and command-line tools
- PowerShell modules
- Repository cloning

VS Code settings, keybindings, profiles, and extensions use VS Code Settings
Sync instead. Credentials and private repository information stay out of the
tracked repository.

## Repository layout

The `.chezmoiroot` file makes `home/` the chezmoi source state.

```text
home/
├── .chezmoidata/       Package, module, and public repository declarations
├── .chezmoiscripts/    Idempotent setup scripts
├── .chezmoitemplates/  Shared file content
└── ...                 Files applied beneath the user home directory
```

## Make it yours

After forking, edit these files instead of the templates that reference them:

- `home/.chezmoidata/packages.yaml`: Homebrew and winget packages to install.
- `home/.chezmoidata/powershell.yaml`: PowerShell modules to install.
- `home/.chezmoidata/repositories.yaml`: Git repositories to clone under
  `~/repos`.
- `home/dot_gitconfig.tmpl`: Git settings beyond name and email, which
  chezmoi prompts for on first `chezmoi init`.

Repositories that shouldn't be public (a work account, a private fork) go in
a separate, gitignored `home/.chezmoidata/repositories.local.json` instead of
`repositories.yaml`. Chezmoi merges both files into the same repository list
at apply time. See `scripts/Export-RepositoryManifest.ps1` for one way to
generate that file from an existing checkout.

## Windows setup

Install chezmoi if needed:

```powershell
winget install --id twpayne.chezmoi --exact
```

If you already have working copies under `$HOME/repos`, export them into the
local repository list first:

```powershell
pwsh -File ./scripts/Export-RepositoryManifest.ps1
```

Initialize chezmoi from this checkout, inspect the proposed changes, and
apply them:

```powershell
chezmoi init --source $PWD.Path
chezmoi diff
chezmoi apply
```

The repository script clones missing repositories and reports the status of
existing repositories. It never pulls, resets, or overwrites a working copy.

## macOS setup

Install Homebrew, then install the bootstrap tools:

```sh
brew install chezmoi git
brew install --cask powershell
```

Clone your fork into the standard development location:

```sh
mkdir -p ~/repos/github
git clone https://github.com/<you>/.dotfiles.git ~/repos/github/.dotfiles
cd ~/repos/github/.dotfiles
```

To carry over a private repository list from another machine, copy its
`home/.chezmoidata/repositories.local.json` here before applying chezmoi.

Initialize, inspect, and apply:

```sh
chezmoi init --source "$PWD"
chezmoi diff
chezmoi apply
```

Enable VS Code Settings Sync after VS Code is installed.

## Daily use

Pull the source repository and apply changes:

```text
chezmoi update
```

Inspect local drift:

```text
chezmoi diff
```

Edit a managed file:

```text
chezmoi edit <target-file>
```

Re-export the local repository list after adding or removing working copies:

```powershell
pwsh -File ./scripts/Export-RepositoryManifest.ps1
```

Install pending OS updates (Administrator on Windows, sudo on macOS):

```powershell
pwsh -File ./scripts/Update-System.ps1
```

## Local configuration

Machine-specific or private PowerShell settings belong in:

```text
~/.config/powershell/profile.local.ps1
```

The managed PowerShell profile loads that file when it exists. Do not place
credentials, private feed configuration, internal URLs, or private
repository names in tracked files.
