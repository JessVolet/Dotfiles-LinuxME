#!/bin/bash

run_matugen() {
    local source_type="$1"
    local source_value="$2"
    local mode="$3"
    local templates_dir="$HOME/.config/quickshell/matugen/templates"
    local dynamic_config
    local matugen_status=0

    if ! command -v matugen >/dev/null 2>&1; then
        echo "matugen is not installed or not in PATH" >&2
        return 1
    fi

    if [ "$source_type" = "image" ] && [ ! -f "$source_value" ]; then
        echo "Wallpaper file not found: $source_value" >&2
        return 1
    fi

    if [ ! -d "$templates_dir" ]; then
        echo "Matugen templates directory not found: $templates_dir" >&2
        return 1
    fi

    dynamic_config="$(mktemp)"
    cat > "$dynamic_config" <<EOF
[config]

[templates.sway_rice_colors]
input_path = "$HOME/.config/quickshell/matugen/templates/sway-colors.conf"
output_path = "$HOME/.config/sway/rice-colors.conf"

[templates.sway_custom_colors]
input_path = "$HOME/.config/quickshell/matugen/templates/sway-custom-colors.conf"
output_path = "$HOME/.config/sway/custom/colors"

[templates.ghostty_rice_theme]
input_path = "$HOME/.config/quickshell/matugen/templates/ghostty-colors.conf"
output_path = "$HOME/.config/ghostty/themes/rice-generated"

[templates.rofi_rice_theme]
input_path = "$HOME/.config/quickshell/matugen/templates/rofi-rice.rasi"
output_path = "$HOME/.config/rofi/rice-generated.rasi"

[templates.mako_theme]
input_path = "$HOME/.config/quickshell/matugen/templates/mako.conf"
output_path = "$HOME/.config/mako/config"

[templates.rice_manager_env]
input_path = "$HOME/.config/quickshell/matugen/templates/rice-manager.env"
output_path = "$HOME/.config/rice-manager/rice-colors.env"

[templates.onestepback_gtk3]
input_path = "$HOME/.config/quickshell/matugen/templates/onestepback-colors.css"
output_path = "$HOME/.config/gtk-3.0/onestepback-colors.css"

[templates.onestepback_gtk4]
input_path = "$HOME/.config/quickshell/matugen/templates/onestepback-colors.css"
output_path = "$HOME/.config/gtk-4.0/onestepback-colors.css"

[templates.onestepback_wm2_gtk3]
input_path = "$HOME/.config/quickshell/matugen/templates/onestepback-wm2-colors.css"
output_path = "$HOME/.config/gtk-3.0/onestepback-wm2-colors.css"

[templates.onestepback_wm2_gtk4]
input_path = "$HOME/.config/quickshell/matugen/templates/onestepback-wm2-colors.css"
output_path = "$HOME/.config/gtk-4.0/onestepback-wm2-colors.css"

[templates.background_qml]
input_path = "$HOME/.config/quickshell/matugen/templates/background.qml"
output_path = "$HOME/.config/quickshell/core/background.qml"
EOF

    mkdir -p "$HOME/.config/rofi" "$HOME/.config/mako"

    if [ "$source_type" = "image" ]; then
        matugen image "$source_value" -m "$mode" -c "$dynamic_config" >/dev/null || matugen_status=$?
    elif [ "$source_type" = "solid" ] || [ "$source_type" = "color" ]; then
        matugen color hex "$source_value" -m "$mode" -c "$dynamic_config" >/dev/null || matugen_status=$?
    else
        echo "Unknown source type: $source_type" >&2
        rm -f "$dynamic_config"
        return 1
    fi

    if [ "$matugen_status" -ne 0 ]; then
        echo "matugen template generation failed (exit $matugen_status)" >&2
        rm -f "$dynamic_config"
        return "$matugen_status"
    fi

    # Output JSON for downstream mapping logic
    local tmp_output
    tmp_output="$(mktemp)"
    if [ "$source_type" = "image" ]; then
        matugen image "$source_value" -m "$mode" --dry-run -j hex > "$tmp_output"
    else
        matugen color hex "$source_value" -m "$mode" --dry-run -j hex > "$tmp_output"
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
    rm -f "$dynamic_config"
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

keys = ["base", "highlight", "bgDesktop", "shadow", "textDim", "text", "outline", "accent", "urgent", "success", "panelBg", "insetBg", "headerBg", "sideTabBg", "bevelLight", "bevelDark", "buttonBg", "buttonAct"]
out = {}
for k in keys:
    v = overrides.get(k)
    if v is None:
        path = mapping.get(k)
        v = resolve_path(path) if path else None
    out[k] = v if v is not None else "#000000"
print(json.dumps(out))
PY
}

available_themes_json() {
    python3 - "$CONFIG_FILE" <<'PY'
import json
import sys
from pathlib import Path

cfg = json.loads(Path(sys.argv[1]).read_text())
out = []
for name in sorted(cfg.get("themes", {})):
    t = cfg["themes"][name]
    out.append({"name": name, "label": t.get("label", name), "enabled": t.get("enabled", True), "palette": t.get("palette", "matugen-default"), "affects": t.get("affects", [])})
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
active_theme, active_mode, wallpaper_type, wallpaper_value, active_palette, available = sys.argv[3:9]
shadow = palette["shadow"].lstrip("#")
shadow_color = f"#66{shadow}" if len(shadow) == 6 else "#66000000"
content = f'''pragma Singleton
import QtQuick

QtObject {{
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
    readonly property var themes: ({{ 'generated': {{ base: "{palette['base']}", accent: "{palette['accent']}", highlight: "{palette['highlight']}", text: "{palette['text']}" }} }})
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
    readonly property int fontSizeLarge:   DPI.fontLarge
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
import json, sys
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
import json, sys
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
import json, sys
from pathlib import Path

p = json.loads(sys.argv[1])
out = Path(sys.argv[2])
mode = sys.argv[3]
inactive = "#ffffff" if mode == "dark" else p["success"]
unfocused = "#ffffff" if mode == "dark" else p["outline"]
out.write_text(f"""# Generated by rice-manager.sh
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
import json, sys
from pathlib import Path

p = json.loads(sys.argv[1])
out = Path(sys.argv[2])
out.write_text(f"""# Generated by rice-manager.sh
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
import struct, json, sys
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
    f.write(f'P6\n{width} {height}\n255\n'.encode())
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
    [ -z "$swaybg_bin" ] && { echo "swaybg not found in PATH"; return 1; }
    [ "$kind" != "solid" ] && [ ! -f "$value" ] && { echo "Wallpaper file not found: $value"; return 1; }

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

should_apply_target() {
    local target="$1"
    if [ "$(target_enabled "$target")" != "1" ]; then
        echo "0"
        return
    fi
    if [ "$RICE_SOURCE_TYPE" = "theme" ]; then
        [ "$(theme_affects_target "$RICE_THEME" "$target")" = "1" ] && echo "1" || echo "0"
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
        image) start_wallpaper image "$source_value" ;;
        solid) start_wallpaper solid "$source_value" ;;
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