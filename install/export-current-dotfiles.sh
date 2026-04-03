#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOTFILES_DIR="$REPO_DIR/dotfiles"

mkdir -p "$DOTFILES_DIR/.config" "$DOTFILES_DIR/scripts" "$DOTFILES_DIR/themes"

copy_if_exists() {
  local src="$1"
  local dest="$2"
  if [ -e "$src" ] || [ -L "$src" ]; then
    rm -rf "$dest"
    cp -a "$src" "$dest"
  fi
}

for name in sway quickshell rice-manager rofi mako ghostty gtk-3.0 gtk-4.0; do
  copy_if_exists "$HOME/.config/$name" "$DOTFILES_DIR/.config/$name"
done

copy_if_exists "$HOME/scripts/rice-manager.sh" "$DOTFILES_DIR/scripts/rice-manager.sh"
copy_if_exists "$HOME/scripts/rice-manager.d" "$DOTFILES_DIR/scripts/rice-manager.d"
copy_if_exists "$HOME/scripts/rofi-launcher.sh" "$DOTFILES_DIR/scripts/rofi-launcher.sh"

if [ -d "$HOME/themes" ]; then
  mkdir -p "$DOTFILES_DIR/themes"
  find "$HOME/themes" -maxdepth 1 -type f -name "*.theme" -exec cp -a {} "$DOTFILES_DIR/themes/" \;
fi

echo "Current dotfiles exported to: $DOTFILES_DIR"
