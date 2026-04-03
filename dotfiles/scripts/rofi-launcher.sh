#!/bin/bash
set -euo pipefail

ROFI_BIN="rofi"
if command -v rofi-wayland >/dev/null 2>&1; then
    ROFI_BIN="rofi-wayland"
fi

THEME_PATH="$HOME/.config/rofi/rice-generated.rasi"
if [ ! -f "$THEME_PATH" ]; then
    echo "rofi theme not found: $THEME_PATH" >&2
    exec "$ROFI_BIN" -show drun -show-icons
fi

exec "$ROFI_BIN" -show drun -show-icons -theme "$THEME_PATH"
