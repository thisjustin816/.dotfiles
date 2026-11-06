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
- `home/.chezmoidata/repositories.yaml`: Git repositories to clone beneath
  the home directory, such as `~/repos` or agent configuration folders.
- `home/dot_config/git/config.tmpl`: Git settings beyond name and email,
  which chezmoi prompts for on first `chezmoi init`. Git reads this file as
  well as `~/.gitconfig`, which stays unmanaged for machine-specific settings
  and for settings that tools such as `gh auth setup-git` write.

Repositories that shouldn't be public (a work account, a private fork) go in
a separate, gitignored `home/.chezmoidata/repositories.local.json` instead of
`repositories.yaml`. Chezmoi merges both files into the same repository list
at apply time. See `scripts/Export-RepositoryManifest.ps1` for one way to
generate that file from an existing checkout.

## Windows setup

Install Git, then clone your fork:

```powershell
winget install --id Git.Git --exact --source winget
git clone https://github.com/<you>/.dotfiles.git "$HOME/repos/github/.dotfiles"
Set-Location "$HOME/repos/github/.dotfiles"
```

If you already have working copies under `$HOME/repos`, export them into the
local repository list first:

```powershell
pwsh -File ./scripts/Export-RepositoryManifest.ps1
```

Run the install script from Windows PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File ./install.ps1
```

The script installs PowerShell 7, Git, the GitHub CLI, and chezmoi with
WinGet, and signs Git in to GitHub in the browser so that private
repositories can clone. It then runs `chezmoi init --apply` with this
checkout as the source. Add `-WhatIf` to list the packages it would
install and show `chezmoi diff` without changing anything.

The repository script clones missing repositories and reports the status of
existing repositories. It never pulls, resets, or overwrites a working copy.

## macOS setup

Clone your fork into the standard development location:

```sh
mkdir -p ~/repos/github
git clone https://github.com/<you>/.dotfiles.git ~/repos/github/.dotfiles
cd ~/repos/github/.dotfiles
```

To carry over a private repository list from another machine, copy its
`home/.chezmoidata/repositories.local.json` here before you run the install
script.

Run the install script:

```sh
./install.sh
```

The script installs Homebrew if it is missing, installs chezmoi and the
GitHub CLI, and signs Git in to GitHub in the browser so that private
repositories can clone. It then runs `chezmoi init --apply` with this
checkout as the source. Add `--dry-run` to report what it would install and
show `chezmoi diff` without changing anything. The first macOS `git`
command can prompt you to install the Xcode Command Line Tools; accept and
run `git clone` again.

Enable VS Code Settings Sync after VS Code is installed. Set the terminal
font to CaskaydiaCove Nerd Font so the oh-my-posh prompt renders its
glyphs.

### Agent-assisted setup

A Claude Code session on a machine that is already set up can drive the
macOS setup through
[cross-session messaging](https://code.claude.com/docs/en/cross-session-messaging).
Both sessions must sign in to the same claude.ai account, and on a Team or
Enterprise plan an owner must turn on Remote Control in the Claude Code admin
settings.

1. Install Claude Code on the Mac. The native installer needs no developer
   tools. Start it once and sign in with your claude.ai account:

   ```sh
   curl -fsSL https://claude.ai/install.sh | bash
   claude
   ```

2. Exit, then start a named Remote Control session from your home directory:

   ```sh
   cd ~
   claude --remote-control "mac-setup"
   ```

3. Paste this prompt into the Mac session:

   ```text
   This Mac is new. A Claude Code session on my other machine will send you
   setup steps with SendMessage. Run each step it sends, then reply to it
   with SendMessage, including the command output and any errors. When a step
   needs sudo, a password, or a GUI prompt, stop and ask me to do that part.
   Do not do other work unless I ask for it.
   ```

4. On the other machine, run `/remote-control` in its Claude Code session,
   then `/list-agents`. The `mac-setup` session shows as a Remote Control row.
   Ask that session to set up the Mac from this README.

The Homebrew install, the Xcode Command Line Tools prompt, and the GitHub
browser sign-in need you at the Mac.

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
