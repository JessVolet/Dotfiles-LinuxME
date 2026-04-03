#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOTFILES_DIR="$REPO_DIR/dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BACKUP_DIR" "$HOME/.config" "$HOME/scripts" "$HOME/themes"

link_or_copy() {
  local src="$1"
  local dest="$2"

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    mv "$dest" "$BACKUP_DIR/$(basename "$dest")"
  fi

  ln -s "$src" "$dest"
}

# Config directories
for name in sway quickshell rice-manager rofi mako ghostty gtk-3.0 gtk-4.0; do
  if [ -e "$DOTFILES_DIR/.config/$name" ]; then
    link_or_copy "$DOTFILES_DIR/.config/$name" "$HOME/.config/$name"
  fi
done

# Scripts and themes
if [ -d "$DOTFILES_DIR/scripts" ]; then
  for f in "$DOTFILES_DIR/scripts"/*; do
    [ -e "$f" ] || continue
    link_or_copy "$f" "$HOME/scripts/$(basename "$f")"
  done
fi

if [ -d "$DOTFILES_DIR/themes" ]; then
  for f in "$DOTFILES_DIR/themes"/*; do
    [ -e "$f" ] || continue
    link_or_copy "$f" "$HOME/themes/$(basename "$f")"
  done
fi

echo "Dotfiles deployed. Backups in: $BACKUP_DIR"
