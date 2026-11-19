#!/usr/bin/env bash
# Install this Hyprland config by symlinking it to ~/.config/hypr.
# An existing ~/.config/hypr directory is backed up into the current directory.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${XDG_CONFIG_HOME:-$HOME/.config}/hypr"

if [[ -L "$TARGET" ]]; then
    if [[ "$(readlink -f "$TARGET")" == "$REPO_DIR" ]]; then
        echo "Already installed: $TARGET -> $REPO_DIR"
        exit 0
    fi
    echo "Removing existing symlink $TARGET -> $(readlink "$TARGET")"
    rm "$TARGET"
elif [[ -e "$TARGET" ]]; then
    BACKUP="$PWD/hypr.backup.$(date +%Y%m%d-%H%M%S)"
    echo "Backing up $TARGET to $BACKUP"
    mv "$TARGET" "$BACKUP"
fi

mkdir -p "$(dirname "$TARGET")"
ln -s "$REPO_DIR" "$TARGET"
echo "Installed: $TARGET -> $REPO_DIR"
