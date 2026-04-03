# Quickshell Plugins

> **This is your playground.** Add modules here without touching `core/` or `shell.qml`.

## Quick Start

```bash
# 1. Create your plugin folder
mkdir plugins/my-bar

# 2. Create the entry point
touch plugins/my-bar/Main.qml

# 3. Register it in Registry.qml
```

## Plugin Template

```qml
// plugins/my-bar/Main.qml
import Quickshell
import QtQuick
import "../../core" as Core

Item {
    // Create any window type here
    Scope {
        Variants {
            model: Quickshell.screens

            PanelWindow {
                property var modelData
                screen: modelData

                anchors {
                    bottom: true
                    left: true
                    right: true
                }

                implicitHeight: Core.Theme.panelHeight
                color: Core.Theme.panelBg

                Text {
                    anchors.centerIn: parent
                    // Use the global clock — never create your own Timer!
                    text: Core.Clock.time24
                    color: Core.Theme.fg
                    font.family: Core.Theme.fontFamily
                    font.pixelSize: Core.Theme.fontSizeNormal
                }
            }
        }
    }
}
```

## Registering in Registry.qml

```qml
// Add this inside the Item {} block:
Loader {
    asynchronous: Core.Perf.asyncPluginLoad
    active: true
    source: "my-bar/Main.qml"
}
```

## Available Core Singletons

| Singleton | Access | Key Properties |
|---|---|---|
| **Clock** | `Core.Clock.*` | `time24`, `time12`, `timeSeconds`, `dateShort`, `dateFull`, `hours`, `minutes`, `seconds` |
| **Theme** | `Core.Theme.*` | `bg`, `fg`, `accent`, `panelBg`, `fontFamily`, `panelHeight`, `borderRadius`, `padding` |
| **Perf** | `Core.Perf.*` | `enableAnimations`, `enableBlur`, `tickFast`, `tickSlow`, `targetFps` |

## Performance Rules

1. **NEVER create a Timer** — use `Core.Clock` properties
2. **NEVER hardcode colors** — use `Core.Theme.*`
3. **Use `layer.enabled: Core.Perf.enableLayerCache`** on static content
4. **Check `Core.Perf.enableAnimations`** before running animations
5. **Use `asynchronous: Core.Perf.asyncPluginLoad`** on all Loaders
6. **Set `visible: false`** on offscreen content (stops rendering)

## Plugin Structure

```
plugins/
├── Registry.qml          ← Edit this to add plugins
├── README.md             ← You're reading this
├── my-bar/               ← Your plugin
│   ├── Main.qml          ← Entry point (required)
│   └── components/       ← Internal components (optional)
│       ├── Clock.qml
│       └── Workspaces.qml
└── my-widget/
    └── Main.qml
```

## Disabling a Plugin

In `Registry.qml`, set `active: false`:
```qml
Loader {
    active: false  // ← disabled, won't load
    source: "my-bar/Main.qml"
}
```
