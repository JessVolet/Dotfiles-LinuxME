#!/bin/bash

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

theme_seed() { read_config_value "themes.$1.seed"; }
theme_enabled() { [ "$(read_config_value "themes.$1.enabled")" = "false" ] && echo 0 || echo 1; }
theme_palette() { local v; v="$(read_config_value "themes.$1.palette")"; [ -n "$v" ] && echo "$v" || echo "$RICE_PALETTE"; }
target_enabled() { [ "$(read_config_value "targets.$1.enabled")" = "false" ] && echo 0 || echo 1; }

theme_affects_target() {
    python3 - "$CONFIG_FILE" "$1" "$2" <<'PY'
import json
import sys
from pathlib import Path

cfg = json.loads(Path(sys.argv[1]).read_text())
affects = cfg.get("themes", {}).get(sys.argv[2], {}).get("affects", [])
print("1" if sys.argv[3] in affects else "0")
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
print(f"{active.get('theme', 'cherry')}|{active.get('mode', 'dark')}|{active.get('palette', 'matugen-default')}|{wall.get('type', 'theme')}|{wall.get('value', active.get('theme', 'cherry'))}")
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
print("Available themes:")
for name in sorted(cfg.get("themes", {})):
    t = cfg["themes"][name]
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
print("Available palettes:")
for name in sorted(cfg.get("palettes", {})):
    p = cfg["palettes"][name]
    print(f"  {name} ({p.get('label', name)})")
PY
}

resolve_mode() { local mode="${1:-}"; [ "$mode" = "light" ] || [ "$mode" = "dark" ] && printf '%s\n' "$mode" || printf '%s\n' "$RICE_MODE"; }