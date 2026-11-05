#!/bin/sh
# Bootstraps macOS from this checkout: installs Homebrew, chezmoi, and gh,
# signs Git in to GitHub so private repositories can clone, then applies
# chezmoi with this checkout as the source.

set -eu

if [ "$(uname -s)" != "Darwin" ]; then
    echo "install.sh supports macOS only. See README.md for Windows setup." >&2
    exit 1
fi

source_dir=$(cd "$(dirname "$0")" && pwd)

load_brew() {
    for brew_path in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [ -x "$brew_path" ]; then
            eval "$("$brew_path" shellenv)"
            return 0
        fi
    done
    return 1
}

if ! command -v brew >/dev/null 2>&1 && ! load_brew; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    load_brew
fi

brew install chezmoi gh

if ! gh auth status --hostname github.com >/dev/null 2>&1; then
    gh auth login --hostname github.com --git-protocol https --web
fi
gh auth setup-git --hostname github.com

chezmoi init --apply --source "$source_dir"
