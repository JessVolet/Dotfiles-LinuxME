#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$REPO_DIR/install/install-fedora.sh"
"$REPO_DIR/install/deploy-dotfiles.sh"

echo "LinuxME bootstrap completed."
