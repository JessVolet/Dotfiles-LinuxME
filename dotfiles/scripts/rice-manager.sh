#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CONFIG_DIR="$HOME/.config/rice-manager"
CONFIG_FILE="$CONFIG_DIR/config.json"
PALETTES_FILE="$CONFIG_DIR/palettes.json"
LEGACY_CONFIG_FILE="$CONFIG_DIR/rice-manager.json"
QS_CORE_DIR="$HOME/.config/quickshell/core"
GHOSTTY_CONFIG="$HOME/.config/ghostty/config"
GHOSTTY_THEME_DIR="$HOME/.config/ghostty/themes"
SWAY_THEME_FILE="$HOME/.config/sway/rice-colors.conf"
MAKO_CONFIG="$HOME/.config/mako/config"
ENV_EXPORTS_FILE="$CONFIG_DIR/rice-env.sh"
GENERATED_WALLPAPER="$CONFIG_DIR/generated-wallpaper.ppm"
SWAYBG_PID_FILE="$CONFIG_DIR/swaybg.pid"

source "$SCRIPT_DIR/rice-manager.d/config.sh"
source "$SCRIPT_DIR/rice-manager.d/operations.sh"

usage() {
    cat <<EOF
Usage: $(basename "$0") <command> [args]

Commands:
  themes
      List themes from config.json.

  palettes
      List palettes from palettes.json.

  theme <name> [light|dark]
      Apply theme from config.json using its seed and palette.

  theme-set <name> <seed> [label] [palette]
      Add or update a theme in config.json.

  theme-enable <name>
  theme-disable <name>
      Enable/disable a theme in config.json.

  palette <name>
      Set active palette and re-apply current source.

  wallpaper <image|solid|generated> [value] [light|dark]
      Apply wallpaper source.

  mode <light|dark>
      Re-apply current source in selected mode.

  apply
      Re-apply current saved state.

  refresh
      Re-apply theme outputs, reload Sway/Quickshell/Mako, and send a desktop notification.

  status
      Human-readable status.

  status-json
      Full JSON status for UI.

  help
      Show this help.

Files:
  config:   $CONFIG_FILE
  palettes: $PALETTES_FILE
EOF
}

init_palettes_json() {
    if [ -f "$PALETTES_FILE" ]; then
        return
    fi

    cat > "$PALETTES_FILE" <<'EOF'
{
  "schemaVersion": 1,
  "palettes": {
    "matugen-default": {
      "label": "Matugen Default",
      "description": "Default mapping from Matugen colors to Quickshell theme variables.",
      "mapping": {
        "base": "colors.surface",
        "highlight": "colors.surface_container_high",
        "bgDesktop": "colors.background",
        "shadow": "colors.outline_variant",
        "textDim": "colors.on_surface_variant",
        "text": "colors.on_background",
        "outline": "colors.outline",
        "accent": "colors.primary",
        "urgent": "colors.error",
        "success": "colors.secondary",
        "panelBg": "colors.surface_container",
        "insetBg": "colors.surface_container_high",
        "headerBg": "colors.primary_container",
        "sideTabBg": "colors.secondary_container",
        "bevelLight": "colors.surface",
        "bevelDark": "colors.outline_variant",
        "buttonBg": "colors.surface_variant",
        "buttonAct": "colors.error_container"
      },
      "overrides": {}
    },
    "retro-contrast": {
      "label": "Retro Contrast",
      "description": "Higher contrast variant for readability.",
      "mapping": {
        "base": "colors.surface",
        "highlight": "colors.surface_container_high",
        "bgDesktop": "colors.background",
        "shadow": "colors.shadow",
        "textDim": "colors.on_surface_variant",
        "text": "colors.on_background",
        "outline": "colors.outline",
        "accent": "colors.primary",
        "urgent": "colors.error",
        "success": "colors.secondary",
        "panelBg": "colors.surface_container",
        "insetBg": "colors.surface_variant",
        "headerBg": "colors.primary",
        "sideTabBg": "colors.secondary",
        "bevelLight": "colors.surface",
        "bevelDark": "colors.outline",
        "buttonBg": "colors.surface_variant",
        "buttonAct": "colors.error"
      },
      "overrides": {
        "text": "#ffffff"
      }
    }
  }
}
EOF
}

init_config_json() {
    if [ -f "$CONFIG_FILE" ]; then
        return
    fi

    if [ -f "$LEGACY_CONFIG_FILE" ]; then
        python3 - "$LEGACY_CONFIG_FILE" "$CONFIG_FILE" <<'PY'
import json
import sys
from pathlib import Path

legacy = json.loads(Path(sys.argv[1]).read_text())
themes = legacy.get("themes", {})
converted = {
    "schemaVersion": 1,
    "active": {
        "theme": legacy.get("activeTheme", "cherry"),
        "mode": legacy.get("activeMode", "dark"),
        "palette": "matugen-default"
    },
    "wallpaper": legacy.get("wallpaper", {"type": "theme", "value": legacy.get("activeTheme", "cherry")}),
    "targets": {
        "quickshell": {"enabled": True},
        "ghostty": {"enabled": True},
        "sway": {"enabled": True},
        "environment": {"enabled": True}
    },
    "themes": {}
}
for name, info in themes.items():
    converted["themes"][name] = {
        "label": info.get("label", name),
        "seed": info.get("seed", "#83a598"),
        "enabled": info.get("enabled", True),
        "palette": "matugen-default",
        "affects": ["quickshell", "ghostty", "sway", "environment"]
    }
if not converted["themes"]:
    converted["themes"] = {
        "cherry": {
            "label": "Cherry",
            "seed": "#c950bb",
            "enabled": True,
            "palette": "matugen-default",
            "affects": ["quickshell", "ghostty", "sway", "environment"]
        }
    }
Path(sys.argv[2]).write_text(json.dumps(converted, indent=2) + "\n")
PY
        return
    fi

    cat > "$CONFIG_FILE" <<'EOF'
{
  "schemaVersion": 1,
  "active": {
    "theme": "cherry",
    "mode": "dark",
    "palette": "matugen-default"
  },
  "wallpaper": {
    "type": "theme",
    "value": "cherry"
  },
  "targets": {
    "quickshell": { "enabled": true },
    "ghostty": { "enabled": true },
    "sway": { "enabled": true },
    "environment": { "enabled": true }
  },
  "themes": {
    "retro-gruv-light": {
      "label": "Gruvbox Light",
      "seed": "#076678",
      "enabled": true,
      "palette": "matugen-default",
      "affects": ["quickshell", "ghostty", "sway", "environment"]
    },
    "retro-gruv-dark": {
      "label": "Gruvbox Dark",
      "seed": "#83a598",
      "enabled": true,
      "palette": "matugen-default",
      "affects": ["quickshell", "ghostty", "sway", "environment"]
    },
    "cyber-neon": {
      "label": "Cyber Neon",
      "seed": "#00ff41",
      "enabled": true,
      "palette": "retro-contrast",
      "affects": ["quickshell", "ghostty", "sway", "environment"]
    },
    "yorha": {
      "label": "YoRHa",
      "seed": "#626335",
      "enabled": true,
      "palette": "matugen-default",
      "affects": ["quickshell", "ghostty", "sway", "environment"]
    },
    "cherry": {
      "label": "Cherry",
      "seed": "#c950bb",
      "enabled": true,
      "palette": "matugen-default",
      "affects": ["quickshell", "ghostty", "sway", "environment"]
    },
    "indigo": {
      "label": "Indigo",
      "seed": "#3e7c99",
      "enabled": true,
      "palette": "matugen-default",
      "affects": ["quickshell", "ghostty", "sway", "environment"]
    },
    "gleep": {
      "label": "Gleep",
      "seed": "#3e9949",
      "enabled": true,
      "palette": "matugen-default",
      "affects": ["quickshell", "ghostty", "sway", "environment"]
    }
  }
}
EOF
}

read_config_value() {
    local expr="$1"
    python3 - "$CONFIG_FILE" "$expr" <<'PY'
import json
import sys
from pathlib import Path

cfg = json.loads(Path(sys.argv[1]).read_text())
expr = sys.argv[2]
cur = cfg
for part in expr.split('.'):
    if isinstance(cur, dict) and part in cur:
        cur = cur[part]
    else:
        print("")
        raise SystemExit(0)
if isinstance(cur, bool):
    print("true" if cur else "false")
elif cur is None:
    print("")
else:
    print(cur)
PY
}

theme_seed() {
    local theme_name="$1"
    read_config_value "themes.${theme_name}.seed"
}

theme_enabled() {
    local theme_name="$1"
    local v
    v="$(read_config_value "themes.${theme_name}.enabled")"
    [ "$v" = "false" ] && echo "0" || echo "1"
}

theme_palette() {
    local theme_name="$1"
    local v
    v="$(read_config_value "themes.${theme_name}.palette")"
    if [ -n "$v" ]; then
        echo "$v"
    else
        echo "$RICE_PALETTE"
    fi
}

target_enabled() {
    local target="$1"
    local v
    v="$(read_config_value "targets.${target}.enabled")"
    [ "$v" = "false" ] && echo "0" || echo "1"
}

theme_affects_target() {
    local theme_name="$1"
    local target="$2"
    python3 - "$CONFIG_FILE" "$theme_name" "$target" <<'PY'
import json
import sys
from pathlib import Path

cfg = json.loads(Path(sys.argv[1]).read_text())
theme_name = sys.argv[2]
target = sys.argv[3]
affects = cfg.get("themes", {}).get(theme_name, {}).get("affects", [])
print("1" if target in affects else "0")
PY
}

load_state() {
    init_palettes_json
    init_config_json

    IFS='|' read -r RICE_THEME RICE_MODE RICE_PALETTE RICE_SOURCE_TYPE RICE_SOURCE_VALUE < <(
        python3 - "$CONFIG_FILE" <<'PY'
import json
import sys
from pathlib import Path

cfg = json.loads(Path(sys.argv[1]).read_text())
active = cfg.get("active", {})
wall = cfg.get("wallpaper", {})

theme = active.get("theme", "cherry")
mode = active.get("mode", "dark")
palette = active.get("palette", "matugen-default")
source_type = wall.get("type", "theme")
source_value = wall.get("value", theme)

print(f"{theme}|{mode}|{palette}|{source_type}|{source_value}")
PY
    )
}

save_state() {
    python3 - "$CONFIG_FILE" "$RICE_THEME" "$RICE_MODE" "$RICE_PALETTE" "$RICE_SOURCE_TYPE" "$RICE_SOURCE_VALUE" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
cfg = json.loads(path.read_text())
cfg.setdefault("active", {})
cfg["active"]["theme"] = sys.argv[2]
cfg["active"]["mode"] = sys.argv[3]
cfg["active"]["palette"] = sys.argv[4]
cfg["wallpaper"] = {"type": sys.argv[5], "value": sys.argv[6]}
path.write_text(json.dumps(cfg, indent=2) + "\n")
PY
}

list_themes() {
    python3 - "$CONFIG_FILE" <<'PY'
import json
import sys
from pathlib import Path

cfg = json.loads(Path(sys.argv[1]).read_text())
themes = cfg.get("themes", {})
print("Available themes:")
for name in sorted(themes.keys()):
    t = themes[name]
    marker = "enabled" if t.get("enabled", True) else "disabled"
    print(f"  {name} ({t.get('label', name)}) [{marker}] palette={t.get('palette', 'matugen-default')}")
PY
}

list_palettes() {
    python3 - "$PALETTES_FILE" <<'PY'
import json
import sys
from pathlib import Path

cfg = json.loads(Path(sys.argv[1]).read_text())
pals = cfg.get("palettes", {})
print("Available palettes:")
for name in sorted(pals.keys()):
    p = pals[name]
    print(f"  {name} ({p.get('label', name)})")
PY
}

resolve_mode() {
    local mode="${1:-}"
    if [ "$mode" = "light" ] || [ "$mode" = "dark" ]; then
        printf '%s\n' "$mode"
    else
        printf '%s\n' "$RICE_MODE"
    fi
}

run_matugen() {
    local source_type="$1"
    local source_value="$2"
    local mode="$3"
    local tmp_output
    tmp_output="$(mktemp)"

    if [ "$source_type" = "image" ]; then
        matugen image "$source_value" -m "$mode" --json hex --dry-run --show-colors > "$tmp_output"
    else
        matugen color hex "$source_value" -m "$mode" --json hex --dry-run --show-colors > "$tmp_output"
    fi

    python3 - "$tmp_output" <<'PY'
import json
import sys
from pathlib import Path

text = Path(sys.argv[1]).read_text()
start = text.find('{')
if start < 0:
    raise SystemExit('matugen did not produce JSON output')
obj = json.loads(text[start:])
print(json.dumps(obj))
PY

    rm -f "$tmp_output"
}

build_quickshell_palette_json() {
    local payload_file="$1"
    local palette_name="$2"
    python3 - "$payload_file" "$PALETTES_FILE" "$palette_name" <<'PY'
import json
import sys
from pathlib import Path

payload = json.loads(Path(sys.argv[1]).read_text())
pals = json.loads(Path(sys.argv[2]).read_text()).get("palettes", {})
palette_name = sys.argv[3]
palette = pals.get(palette_name) or pals.get("matugen-default") or {}

mapping = palette.get("mapping", {})
overrides = palette.get("overrides", {})

variant = "light" if payload.get("mode") == "light" or not payload.get("is_dark_mode", True) else "dark"


def resolve_path(path):
    cur = payload
    for part in path.split('.'):
        if isinstance(cur, dict) and part in cur:
            cur = cur[part]
        else:
            return None

    if isinstance(cur, dict):
        if variant in cur and isinstance(cur[variant], dict) and "color" in cur[variant]:
            return cur[variant]["color"]
        if "default" in cur and isinstance(cur["default"], dict) and "color" in cur["default"]:
            return cur["default"]["color"]
        vals = list(cur.values())
        if vals and isinstance(vals[0], dict) and "color" in vals[0]:
            return vals[0]["color"]
        if vals:
            return vals[0]
    return cur

keys = [
    "base", "highlight", "bgDesktop", "shadow", "textDim", "text", "outline",
    "accent", "urgent", "success", "panelBg", "insetBg", "headerBg", "sideTabBg",
    "bevelLight", "bevelDark", "buttonBg", "buttonAct"
]

out = {}
for k in keys:
    v = overrides.get(k)
    if v is None:
        path = mapping.get(k)
        v = resolve_path(path) if path else None
    if v is None:
        v = "#000000"
    out[k] = v

print(json.dumps(out))
PY
}

available_themes_json() {
    python3 - "$CONFIG_FILE" <<'PY'
import json
import sys
from pathlib import Path

cfg = json.loads(Path(sys.argv[1]).read_text())
themes = cfg.get("themes", {})
out = []
for name in sorted(themes.keys()):
    t = themes[name]
    out.append({
        "name": name,
        "label": t.get("label", name),
        "enabled": t.get("enabled", True),
        "palette": t.get("palette", "matugen-default"),
        "affects": t.get("affects", [])
    })
print(json.dumps(out))
PY
}

write_theme_qml() {
    local palette_json="$1"
    local available_json

    available_json="$(available_themes_json)"

    python3 - "$palette_json" "$QS_CORE_DIR/Theme.qml" "$RICE_THEME" "$RICE_MODE" "$RICE_SOURCE_TYPE" "$RICE_SOURCE_VALUE" "$RICE_PALETTE" "$available_json" <<'PY'
import json
import sys
from pathlib import Path

palette = json.loads(sys.argv[1])
out_file = Path(sys.argv[2])
active_theme = sys.argv[3]
active_mode = sys.argv[4]
wallpaper_type = sys.argv[5]
wallpaper_value = sys.argv[6]
active_palette = sys.argv[7]
available = sys.argv[8]

shadow = palette["shadow"].lstrip("#")
shadow_color = f"#66{shadow}" if len(shadow) == 6 else "#66000000"

content = f'''pragma Singleton
import QtQuick

QtObject {{
    // Generated by rice-manager.sh from config.json + palettes.json + matugen
    readonly property string activeTheme: "{active_theme}"
    readonly property string activeMode: "{active_mode}"
    readonly property string activePalette: "{active_palette}"
    readonly property string wallpaperType: "{wallpaper_type}"
    readonly property string wallpaperValue: "{wallpaper_value}"

    readonly property var availableThemes: {available}

    readonly property color base:      "{palette['base']}"
    readonly property color highlight: "{palette['highlight']}"
    readonly property color bgDesktop: "{palette['bgDesktop']}"
    readonly property color shadow:    "{palette['shadow']}"
    readonly property color textDim:   "{palette['textDim']}"
    readonly property color text:      "{palette['text']}"
    readonly property color outline:   "{palette['outline']}"

    readonly property color accent:    "{palette['accent']}"
    readonly property color urgent:    "{palette['urgent']}"
    readonly property color success:   "{palette['success']}"

    readonly property color shadowColor: "{shadow_color}"

    readonly property color panelBg:   "{palette['panelBg']}"
    readonly property color insetBg:   "{palette['insetBg']}"
    readonly property color headerBg:  "{palette['headerBg']}"
    readonly property color sideTabBg: "{palette['sideTabBg']}"

    readonly property color bevelLight:  "{palette['bevelLight']}"
    readonly property color bevelDark:   "{palette['bevelDark']}"
    readonly property color buttonBg:    "{palette['buttonBg']}"
    readonly property color buttonAct:   "{palette['buttonAct']}"

    readonly property var themes: ({{
        'generated': {{ base: "{palette['base']}", accent: "{palette['accent']}", highlight: "{palette['highlight']}", text: "{palette['text']}" }}
    }})

    readonly property int panelHeight: DPI.panelHeight
    readonly property int borderWidth: DPI.borderWidth
    readonly property int cornerRadius: 0
    readonly property int spacing: DPI.spacing
    readonly property int spacingSmall: DPI.s(4)
    readonly property int padding: DPI.padding

    readonly property string fontMono:    "JetBrains Mono"
    readonly property string fontSans:    "IBM Plex Sans"
    readonly property string fontDisplay: "Departure Mono"
    readonly property string fontSystem:  "W95FA"

    readonly property int fontSizeTiny:   DPI.fontTiny
    readonly property int fontSizeSmall:  DPI.fontSmall
    readonly property int fontSizeNormal: DPI.fontNormal
    readonly property int fontSizeLarge:  DPI.fontLarge
    readonly property int fontSizeXL:     DPI.s(16)
    readonly property int fontSizeTitle:  DPI.s(20)

    readonly property int borderRadius:   0
    readonly property int shadowOffsetX:  DPI.s(6)
    readonly property int shadowOffsetY:  DPI.s(6)
    readonly property int insetDepth:     DPI.s(6)

    readonly property int animFast:       80
    readonly property int animNormal:     150
    readonly property int animSlow:       250
}}
'''
out_file.write_text(content)
PY
}

write_ghostty_theme() {
    local payload_file="$1"
    local bg fg cursor sel_bg sel_fg

    pick_base16() {
        python3 - "$payload_file" "$1" <<'PY'
import json
import sys
from pathlib import Path

obj = json.loads(Path(sys.argv[1]).read_text())
key = sys.argv[2]
entry = obj.get("base16", {}).get(key)
variant = "light" if obj.get("mode") == "light" or not obj.get("is_dark_mode", True) else "dark"
if isinstance(entry, dict):
    if variant in entry and isinstance(entry[variant], dict) and "color" in entry[variant]:
        print(entry[variant]["color"])
    elif "default" in entry and isinstance(entry["default"], dict) and "color" in entry["default"]:
        print(entry["default"]["color"])
    else:
        vals = list(entry.values())
        print(vals[0].get("color") if vals and isinstance(vals[0], dict) else vals[0])
else:
    print(entry)
PY
    }

    pick_color() {
        python3 - "$payload_file" "$1" <<'PY'
import json
import sys
from pathlib import Path

obj = json.loads(Path(sys.argv[1]).read_text())
key = sys.argv[2]
entry = obj.get("colors", {}).get(key)
variant = "light" if obj.get("mode") == "light" or not obj.get("is_dark_mode", True) else "dark"
if isinstance(entry, dict):
    if variant in entry and isinstance(entry[variant], dict) and "color" in entry[variant]:
        print(entry[variant]["color"])
    elif "default" in entry and isinstance(entry["default"], dict) and "color" in entry["default"]:
        print(entry["default"]["color"])
    else:
        vals = list(entry.values())
        print(vals[0].get("color") if vals and isinstance(vals[0], dict) else vals[0])
else:
    print(entry)
PY
    }

    bg="$(pick_base16 base00)"
    fg="$(pick_base16 base07)"
    cursor="$(pick_base16 base07)"
    sel_bg="$(pick_color primary_container)"
    sel_fg="$(pick_color on_primary_container)"

    {
        echo '# Generated by rice-manager.sh'
        echo "background = $bg"
        echo "foreground = $fg"
        echo "cursor-color = $cursor"
        echo "selection-background = $sel_bg"
        echo "selection-foreground = $sel_fg"
        echo ''
        for i in 00 08 0b 0a 0d 0e 0c 05 03 09 02 0a 0d 06 0c 07; do
            idx=$((16#${i#0}))
            echo "palette = $idx=$(pick_base16 base$i)"
        done
        echo ''
        echo 'window-decoration = false'
        echo 'window-padding-x = 10'
        echo 'window-padding-y = 10'
        echo 'cursor-style = block'
    } > "$GHOSTTY_THEME_DIR/rice-generated"

    mkdir -p "$(dirname "$GHOSTTY_CONFIG")"
    touch "$GHOSTTY_CONFIG"
    sed -i '/^theme = /d' "$GHOSTTY_CONFIG"
    printf 'theme = rice-generated\n' >> "$GHOSTTY_CONFIG"
}

write_sway_theme() {
    local palette_json="$1"
    python3 - "$palette_json" "$SWAY_THEME_FILE" "$RICE_MODE" <<'PY'
import json
import sys
from pathlib import Path

p = json.loads(sys.argv[1])
out = Path(sys.argv[2])
mode = sys.argv[3]

# In dark mode force bright borders to emulate white "shadows" in sway window chrome.
inactive = "#ffffff" if mode == "dark" else p["success"]
unfocused = "#ffffff" if mode == "dark" else p["outline"]

out.write_text(
f"""# Generated by rice-manager.sh
# class                 border      bground     text       indicator   child_border
client.focused          {p['accent']} {p['accent']} {p['base']} {p['accent']} {p['accent']}
client.focused_inactive {inactive} {inactive} {p['base']} {inactive} {inactive}
client.unfocused        {unfocused} {unfocused} {p['text']} {unfocused} {unfocused}
client.urgent           {p['urgent']} {p['urgent']} {p['base']} {p['urgent']} {p['urgent']}
""")
PY

    if pgrep sway >/dev/null; then
        source "$SWAY_THEME_FILE" >/dev/null 2>&1 || true
        swaymsg "reload" >/dev/null 2>&1 || true
    fi
}

write_environment_exports() {
    local palette_json="$1"
    python3 - "$palette_json" "$ENV_EXPORTS_FILE" "$RICE_THEME" "$RICE_MODE" "$RICE_PALETTE" <<'PY'
import json
import sys
from pathlib import Path

p = json.loads(sys.argv[1])
out = Path(sys.argv[2])
out.write_text(
f"""# Generated by rice-manager.sh
export RICE_THEME=\"{sys.argv[3]}\"
export RICE_MODE=\"{sys.argv[4]}\"
export RICE_PALETTE=\"{sys.argv[5]}\"
export RICE_COLOR_BASE=\"{p['base']}\"
export RICE_COLOR_TEXT=\"{p['text']}\"
export RICE_COLOR_ACCENT=\"{p['accent']}\"
export RICE_COLOR_URGENT=\"{p['urgent']}\"
""")
PY
}

write_generated_wallpaper() {
    local payload_file="$1"
    python3 - "$payload_file" "$GENERATED_WALLPAPER" <<'PY'
import struct
import json
import sys
from pathlib import Path

obj = json.loads(Path(sys.argv[1]).read_text())
out_path = Path(sys.argv[2])

variant = "light" if obj.get("mode") == "light" or not obj.get("is_dark_mode", True) else "dark"

def pick(group, key):
    entry = obj[group][key]
    if isinstance(entry, dict):
        if variant in entry and isinstance(entry[variant], dict) and "color" in entry[variant]:
            return entry[variant]["color"]
        if "default" in entry and isinstance(entry["default"], dict) and "color" in entry["default"]:
            return entry["default"]["color"]
        vals = list(entry.values())
        if vals and isinstance(vals[0], dict) and "color" in vals[0]:
            return vals[0]["color"]
        return vals[0]
    return entry

bg = pick("colors", "background").lstrip('#')
dot = pick("colors", "outline").lstrip('#')
accent = pick("colors", "primary").lstrip('#')
shadow = pick("colors", "shadow").lstrip('#')

width, height = 1600, 900
bg_rgb = tuple(int(bg[i:i+2], 16) for i in (0, 2, 4))
dot_rgb = tuple(int(dot[i:i+2], 16) for i in (0, 2, 4))
accent_rgb = tuple(int(accent[i:i+2], 16) for i in (0, 2, 4))
shadow_rgb = tuple(int(shadow[i:i+2], 16) for i in (0, 2, 4))

with out_path.open('wb') as f:
    f.write(f'P6\\n{width} {height}\\n255\\n'.encode())
    for y in range(height):
        row = bytearray()
        for x in range(width):
            base = list(bg_rgb)
            dx = (x - width / 2) / width
            dy = (y - height / 2) / height
            shade = max(0.0, 1.0 - ((dx * dx + dy * dy) * 1.5))
            for idx in range(3):
                base[idx] = max(0, min(255, int(base[idx] * (0.92 + shade * 0.08))))
            if x % 24 == 0 and y % 24 == 0:
                base = list(dot_rgb)
            elif x % 96 == 0 and y % 48 == 0:
                base = list(accent_rgb)
            elif y % 3 == 0:
                base = [max(0, c - 2) for c in base]
            elif (x + y) % 137 == 0:
                base = list(shadow_rgb)
            row.extend(struct.pack('BBB', *base))
        f.write(row)
PY
}

start_wallpaper() {
    local kind="$1"
    local value="$2"
    local swaybg_bin

    swaybg_bin="$(command -v swaybg || true)"
    if [ -z "$swaybg_bin" ]; then
        echo "swaybg not found in PATH"
        return 1
    fi

    if [ "$kind" != "solid" ] && [ ! -f "$value" ]; then
        echo "Wallpaper file not found: $value"
        return 1
    fi

    if [ -f "$SWAYBG_PID_FILE" ]; then
        kill "$(cat "$SWAYBG_PID_FILE")" 2>/dev/null || true
        rm -f "$SWAYBG_PID_FILE"
    fi
    pkill -x swaybg 2>/dev/null || true

    if [ "$kind" = "solid" ]; then
        "$swaybg_bin" -c "$value" >/dev/null 2>&1 &
    else
        "$swaybg_bin" -i "$value" -m fill >/dev/null 2>&1 &
    fi
    echo $! > "$SWAYBG_PID_FILE"
}

reload_mako() {
    if command -v makoctl >/dev/null 2>&1; then
        makoctl reload >/dev/null 2>&1 || true
    else
        pkill -x mako >/dev/null 2>&1 || true
        if command -v mako >/dev/null 2>&1; then
            nohup mako >/dev/null 2>&1 &
        fi
    fi
}

should_apply_target() {
    local target="$1"
    if [ "$(target_enabled "$target")" != "1" ]; then
        echo "0"
        return
    fi
    if [ "$RICE_SOURCE_TYPE" = "theme" ]; then
        if [ "$(theme_affects_target "$RICE_THEME" "$target")" = "1" ]; then
            echo "1"
        else
            echo "0"
        fi
    else
        echo "1"
    fi
}

apply_source() {
    local source_type="$1"
    local source_value="$2"
    local mode="$3"
    local matugen_source_type="$source_type"
    local matugen_source_value="$source_value"
    local payload_file
    local palette_json
    payload_file="$(mktemp)"

    if [ "$source_type" = "theme" ]; then
        matugen_source_type="solid"
        matugen_source_value="$(theme_seed "$source_value")"
        if [ -z "$matugen_source_value" ]; then
            echo "Theme seed missing in config.json: $source_value"
            rm -f "$payload_file"
            exit 1
        fi
        if [ -z "$RICE_PALETTE" ]; then
            RICE_PALETTE="$(theme_palette "$source_value")"
        fi
    fi

    run_matugen "$matugen_source_type" "$matugen_source_value" "$mode" > "$payload_file"
    palette_json="$(build_quickshell_palette_json "$payload_file" "$RICE_PALETTE")"

    # Matugen updates ~/.config/mako/config via template; reload daemon so palette changes apply immediately.
    reload_mako

    if [ "$(should_apply_target quickshell)" = "1" ]; then
        write_theme_qml "$palette_json"
    fi
    if [ "$(should_apply_target ghostty)" = "1" ]; then
        write_ghostty_theme "$payload_file"
        pkill -USR1 -x ghostty 2>/dev/null || true
    fi
    if [ "$(should_apply_target sway)" = "1" ]; then
        write_sway_theme "$palette_json"
    fi
    if [ "$(should_apply_target environment)" = "1" ]; then
        write_environment_exports "$palette_json"
    fi

    case "$source_type" in
        image)
            start_wallpaper image "$source_value"
            ;;
        solid)
            start_wallpaper solid "$source_value"
            ;;
        theme)
            write_generated_wallpaper "$payload_file"
            start_wallpaper generated "$GENERATED_WALLPAPER"
            ;;
    esac

    if [ "$source_type" = "image" ] || [ "$source_type" = "solid" ]; then
        write_generated_wallpaper "$payload_file"
    fi

    save_state
    rm -f "$payload_file"

    printf 'Applied %s (%s) in %s mode with palette %s\n' "$RICE_THEME" "$RICE_SOURCE_TYPE" "$RICE_MODE" "$RICE_PALETTE"
}

command_theme() {
    load_state
    local theme_name="${1:-}"
    local mode
    mode="$(resolve_mode "${2:-}")"

    if [ -z "$theme_name" ]; then
        echo "Missing theme name."
        list_themes
        exit 1
    fi
    if [ -z "$(theme_seed "$theme_name")" ]; then
        echo "Unknown theme: $theme_name"
        list_themes
        exit 1
    fi
    if [ "$(theme_enabled "$theme_name")" != "1" ]; then
        echo "Theme disabled in config.json: $theme_name"
        exit 1
    fi

    RICE_THEME="$theme_name"
    RICE_MODE="$mode"
    RICE_SOURCE_TYPE="theme"
    RICE_SOURCE_VALUE="$theme_name"
    RICE_PALETTE="$(theme_palette "$theme_name")"
    apply_source "$RICE_SOURCE_TYPE" "$RICE_SOURCE_VALUE" "$RICE_MODE"
}

command_theme_set() {
    load_state
    local name="${1:-}"
    local seed="${2:-}"
    local label="${3:-$name}"
    local palette="${4:-$DEFAULT_PALETTE}"

    if [ -z "$name" ] || [ -z "$seed" ]; then
        echo "Usage: theme-set <name> <seed> [label] [palette]"
        exit 1
    fi

    python3 - "$CONFIG_FILE" "$name" "$seed" "$label" "$palette" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
name, seed, label, palette = sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5]
cfg = json.loads(path.read_text())
cfg.setdefault("themes", {})
prev = cfg["themes"].get(name, {})
affects = prev.get("affects", ["quickshell", "ghostty", "sway", "environment"])
cfg["themes"][name] = {
    "label": label,
    "seed": seed,
    "enabled": prev.get("enabled", True),
    "palette": palette,
    "affects": affects,
}
path.write_text(json.dumps(cfg, indent=2) + "\n")
PY

    echo "Theme saved: $name"
}

command_theme_toggle() {
    load_state
    local name="$1"
    local enabled="$2"

    python3 - "$CONFIG_FILE" "$name" "$enabled" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
name = sys.argv[2]
enabled = sys.argv[3] == "true"
cfg = json.loads(path.read_text())
if name not in cfg.get("themes", {}):
    print(f"Unknown theme: {name}")
    raise SystemExit(1)
cfg["themes"][name]["enabled"] = enabled
path.write_text(json.dumps(cfg, indent=2) + "\n")
PY

    echo "Theme $name enabled=$enabled"
}

command_palette() {
    load_state
    local palette_name="${1:-}"

    if [ -z "$palette_name" ]; then
        echo "Missing palette name."
        list_palettes
        exit 1
    fi

    if ! python3 - "$PALETTES_FILE" "$palette_name" <<'PY'
import json
import sys
from pathlib import Path
p = json.loads(Path(sys.argv[1]).read_text()).get("palettes", {})
raise SystemExit(0 if sys.argv[2] in p else 1)
PY
    then
        echo "Unknown palette: $palette_name"
        list_palettes
        exit 1
    fi

    RICE_PALETTE="$palette_name"
    apply_source "$RICE_SOURCE_TYPE" "$RICE_SOURCE_VALUE" "$RICE_MODE"
}

command_wallpaper() {
    load_state
    local kind="${1:-}"
    local value="${2:-}"
    local mode
    mode="$(resolve_mode "${3:-}")"

    case "$kind" in
        generated)
            RICE_SOURCE_TYPE="theme"
            RICE_SOURCE_VALUE="$RICE_THEME"
            RICE_MODE="$mode"
            apply_source "$RICE_SOURCE_TYPE" "$RICE_SOURCE_VALUE" "$RICE_MODE"
            ;;
        solid)
            if [ -z "$value" ]; then
                echo "Missing hex color for solid wallpaper."
                exit 1
            fi
            RICE_SOURCE_TYPE="solid"
            RICE_SOURCE_VALUE="$value"
            RICE_MODE="$mode"
            apply_source "$RICE_SOURCE_TYPE" "$RICE_SOURCE_VALUE" "$RICE_MODE"
            ;;
        image)
            if [ -z "$value" ] || [ ! -f "$value" ]; then
                echo "Wallpaper file not found: ${value:-<missing>}"
                exit 1
            fi
            RICE_SOURCE_TYPE="image"
            RICE_SOURCE_VALUE="$value"
            RICE_MODE="$mode"
            apply_source "$RICE_SOURCE_TYPE" "$RICE_SOURCE_VALUE" "$RICE_MODE"
            ;;
        *)
            if [ ! -f "$kind" ]; then
                echo "Wallpaper file not found: $kind"
                exit 1
            fi
            RICE_SOURCE_TYPE="image"
            RICE_SOURCE_VALUE="$kind"
            RICE_MODE="$mode"
            apply_source "$RICE_SOURCE_TYPE" "$RICE_SOURCE_VALUE" "$RICE_MODE"
            ;;
    esac
}

command_mode() {
    local mode="${1:-}"
    if [ "$mode" != "light" ] && [ "$mode" != "dark" ]; then
        echo "Mode must be light or dark."
        exit 1
    fi
    load_state
    RICE_MODE="$mode"
    apply_source "$RICE_SOURCE_TYPE" "$RICE_SOURCE_VALUE" "$RICE_MODE"
}

command_apply() {
    load_state
    apply_source "$RICE_SOURCE_TYPE" "$RICE_SOURCE_VALUE" "$RICE_MODE"
}

command_refresh() {
    local apply_ok=true

    load_state
    if ! apply_source "$RICE_SOURCE_TYPE" "$RICE_SOURCE_VALUE" "$RICE_MODE"; then
        apply_ok=false
    fi

    swaymsg reload >/dev/null 2>&1 || true
    reload_mako

    pkill -x quickshell >/dev/null 2>&1 || true
    if command -v quickshell >/dev/null 2>&1; then
        nohup quickshell >/dev/null 2>&1 &
    fi

    if command -v notify-send >/dev/null 2>&1; then
        if [ "$apply_ok" = true ]; then
            notify-send -a "Rice Manager" -i preferences-desktop-theme \
                "Rice refrescado" \
                "Sway + Quickshell + Matugen sincronizados. GTK, Rofi y Mako actualizados."
        else
            notify-send -u critical -a "Rice Manager" -i dialog-error \
                "Error al refrescar rice" \
                "Fallo en rice-manager apply; revisa Matugen o templates."
        fi
    fi
}

command_status() {
    load_state
    printf 'Theme: %s\nMode: %s\nPalette: %s\nSource type: %s\nSource value: %s\n' "$RICE_THEME" "$RICE_MODE" "$RICE_PALETTE" "$RICE_SOURCE_TYPE" "$RICE_SOURCE_VALUE"
    printf 'Targets: quickshell=%s ghostty=%s sway=%s environment=%s mako=%s\n' "$(target_enabled quickshell)" "$(target_enabled ghostty)" "$(target_enabled sway)" "$(target_enabled environment)" "$(target_enabled mako)"
    printf 'Theme file: %s\n' "$QS_CORE_DIR/Theme.qml"
    printf 'Ghostty theme: %s\n' "$GHOSTTY_THEME_DIR/rice-generated"
    printf 'Sway theme: %s\n' "$SWAY_THEME_FILE"
    printf 'Mako config: %s\n' "$MAKO_CONFIG"
    printf 'Generated wallpaper: %s\n' "$GENERATED_WALLPAPER"
    printf 'Config JSON: %s\n' "$CONFIG_FILE"
    printf 'Palettes JSON: %s\n' "$PALETTES_FILE"
}

command_status_json() {
    load_state
    python3 - "$CONFIG_FILE" "$PALETTES_FILE" "$RICE_THEME" "$RICE_MODE" "$RICE_PALETTE" "$RICE_SOURCE_TYPE" "$RICE_SOURCE_VALUE" "$QS_CORE_DIR/Theme.qml" "$GHOSTTY_THEME_DIR/rice-generated" "$SWAY_THEME_FILE" "$GENERATED_WALLPAPER" "$ENV_EXPORTS_FILE" "$MAKO_CONFIG" <<'PY'
import json
import sys
from pathlib import Path

cfg = json.loads(Path(sys.argv[1]).read_text())
pals = json.loads(Path(sys.argv[2]).read_text())
out = {
    "config": cfg,
    "palettes": pals,
    "runtime": {
        "theme": sys.argv[3],
        "mode": sys.argv[4],
        "palette": sys.argv[5],
        "sourceType": sys.argv[6],
        "sourceValue": sys.argv[7],
        "targets": cfg.get("targets", {}),
        "files": {
            "themeFile": sys.argv[8],
            "ghosttyTheme": sys.argv[9],
            "swayTheme": sys.argv[10],
            "generatedWallpaper": sys.argv[11],
            "environmentExports": sys.argv[12],
            "makoConfig": sys.argv[13]
        }
    }
}
print(json.dumps(out))
PY
}

source "$SCRIPT_DIR/rice-manager.d/config.sh"
source "$SCRIPT_DIR/rice-manager.d/operations.sh"

load_state

case "${1:-help}" in
    themes) list_themes ;;
    palettes) list_palettes ;;
    theme) command_theme "${2:-}" "${3:-}" ;;
    theme-set) command_theme_set "${2:-}" "${3:-}" "${4:-}" "${5:-}" ;;
    theme-enable) command_theme_toggle "${2:-}" true ;;
    theme-disable) command_theme_toggle "${2:-}" false ;;
    palette) command_palette "${2:-}" ;;
    wallpaper) command_wallpaper "${2:-}" "${3:-}" "${4:-}" ;;
    mode) command_mode "${2:-}" ;;
    apply) command_apply ;;
    refresh) command_refresh ;;
    status) command_status ;;
    status-json) command_status_json ;;
    help|--help|-h) usage ;;
    *) echo "Unknown command: $1"; usage; exit 1 ;;
esac
