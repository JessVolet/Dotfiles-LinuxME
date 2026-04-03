#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PKG_FILE="$REPO_DIR/install/fedora-packages.txt"

if ! command -v dnf >/dev/null 2>&1; then
  echo "This installer targets Fedora (dnf not found)." >&2
  exit 1
fi

sudo dnf install -y \
  "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"

sudo dnf copr enable -y swayfx/swayfx
sudo dnf copr enable -y errornointernet/quickshell
sudo dnf copr enable -y lihaohong/yazi
sudo dnf copr enable -y scottames/ghostty

mapfile -t packages < <(grep -Ev '^\s*#|^\s*$' "$PKG_FILE")
sudo dnf install -y "${packages[@]}"

if ! command -v matugen >/dev/null 2>&1; then
  cargo install matugen
fi

echo "Fedora dependencies installed."
