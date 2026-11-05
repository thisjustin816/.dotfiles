#!/bin/sh
# Bootstraps macOS from this checkout: installs Homebrew, chezmoi, and gh,
# signs Git in to GitHub so private repositories can clone, then applies
# chezmoi with this checkout as the source.
#
# With --dry-run, reports what it would install, skips GitHub sign-in, and
# shows `chezmoi diff` from a temporary chezmoi configuration instead of
# applying anything.

set -eu

dry_run=false
case "${1:-}" in
    --dry-run | -n) dry_run=true ;;
    "") ;;
    *)
        echo "Usage: $0 [--dry-run]" >&2
        exit 2
        ;;
esac

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
    if [ "$dry_run" = true ]; then
        echo "Would install Homebrew."
    else
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        load_brew
    fi
fi

if [ "$dry_run" = true ]; then
    echo "Would run: brew install chezmoi gh"
    echo "Would sign in to GitHub with gh and configure Git credentials."

    if ! command -v chezmoi >/dev/null 2>&1; then
        echo "chezmoi is not installed yet, so the preview of its changes is skipped." >&2
        exit 0
    fi

    # A throwaway configuration keeps the preview from initializing chezmoi for real.
    preview_dir=$(mktemp -d)
    trap 'rm -rf "$preview_dir"' EXIT
    chezmoi init --source "$source_dir" --config "$preview_dir/chezmoi.toml"
    chezmoi diff --source "$source_dir" --config "$preview_dir/chezmoi.toml" --no-pager
    exit 0
fi

brew install chezmoi gh

if ! gh auth status --hostname github.com >/dev/null 2>&1; then
    gh auth login --hostname github.com --git-protocol https --web
fi
gh auth setup-git --hostname github.com

chezmoi init --apply --source "$source_dir"
