# Rice Manager Backend Integration

## 🔄 Complete Flow

```
┌─────────────────────────────────────────────────────────────────┐
│ USER INTERACTION (RiceManager.qml)                              │
└─────────────────────────────────────────────────────────────────┘
                          ↓
         User clicks "Cyber Neon" theme button
                          ↓
     applyTheme("cyber-neon") called
                          ↓
┌─────────────────────────────────────────────────────────────────┐
│ PANEL STATE (RiceManager.qml)                                   │
├─────────────────────────────────────────────────────────────────┤
│ • Set isApplying = true (prevents polling during change)        │
│ • Update currentTheme = "cyber-neon"                            │
│ • Connect onSucceeded signal                                    │
│ • Execute manager: ["theme", "cyber-neon", "dark"]             │
└─────────────────────────────────────────────────────────────────┘
                          ↓
         managerProcess.running = true
                          ↓
┌─────────────────────────────────────────────────────────────────┐
│ BACKEND (~/scripts/rice-manager.sh)                             │
├─────────────────────────────────────────────────────────────────┤
│ $ rice-manager.sh theme cyber-neon dark                         │
│                                                                 │
│ 1. run_matugen(cyber-neon, dark)                               │
│    └─ matugen color hex "#00ff41" -m dark                       │
│       → Returns JSON with palette                               │
│                                                                 │
│ 2. write_theme_qml() 📝                                         │
│    └─ Generates ~/.config/quickshell/core/Theme.qml             │
│       • base, accent, highlight, text, etc from matugen         │
│       • Writes color properties: #00ff41, #000000, etc          │
│                                                                 │
│ 3. write_ghostty_theme()                                        │
│    └─ Updates ~/.config/ghostty/themes/rice-generated           │
│       • Terminal colors synced with theme                       │
│                                                                 │
│ 4. Apply wallpaper                                              │
│    └─ swaybg -i /cache/wallpaper.ppm &                          │
│       • Uses accent color to generate wallpaper                 │
│                                                                 │
│ 5. Print "Applied cyber-neon (theme) in dark mode"              │
│    └─ Returns 0 (success)                                       │
└─────────────────────────────────────────────────────────────────┘
                          ↓
         managerProcess emits onSucceeded()
                          ↓
┌─────────────────────────────────────────────────────────────────┐
│ STATE REFRESH (RiceManager.qml)                                 │
├─────────────────────────────────────────────────────────────────┤
│ Qt.callLater() → refreshState():                                │
│                                                                 │
│ • Execute statusProcess: ["status"]                             │
│ • Parse output lines:                                           │
│   - "Theme: cyber-neon" → currentTheme = "cyber-neon"          │
│   - "Mode: dark" → currentMode = "dark"                        │
│                                                                 │
│ • Set isApplying = false (resume polling)                       │
└─────────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────────┐
│ QUICKSHELL AUTO-RELOAD                                          │
├─────────────────────────────────────────────────────────────────┤
│ • Quickshell detects Theme.qml file changed                     │
│ • Hot-reloads the singleton                                     │
│ • All UI components using Core.Theme.* update instantly         │
│ • Colors propagate through all panels                           │
└─────────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────────┐
│ PANEL REFLECTS STATE                                            │
├─────────────────────────────────────────────────────────────────┤
│ • Header shows "cyber-neon" in white text                       │
│ • All active theme buttons show white border (isActive: true)   │
│ • Theme button colors updated from Core.Theme                   │
│ • Wallpaper displays new colors in background                   │
│ • Ghostty terminal shows new color scheme                       │
└─────────────────────────────────────────────────────────────────┘
```

## 🔌 Integration Points

### 1. **Process Execution**
```qml
Process { id: managerProcess }
Process { id: statusProcess }

// Manager handles: theme, wallpaper, mode, apply
// Status handles: polling for current state
```

### 2. **State Polling**
```qml
Timer {
    interval: 2000      // Every 2 seconds
    running: visible    // Only while panel is open
    repeat: true
    onTriggered: refreshState() // Unless isApplying=true
}
```

### 3. **Command Execution**
```qml
function execManager(args) {
    isApplying = true
    managerProcess.command = [script].concat(args)
    managerProcess.onSucceeded.connect(() => {
        Qt.callLater(() => {
            refreshState()      // Poll status
            isApplying = false  // Resume polling
        })
    })
    managerProcess.running = true
}
```

### 4. **State Synchronization**
```qml
function refreshState() {
    statusProcess.command = [script, "status"]
    statusProcess.onSucceeded.connect(() => {
        parseManagerStatus(statusProcess.stdout)
    })
    statusProcess.running = true
}

function parseManagerStatus(output) {
    // Extract: Theme, Mode, Source type, Source value
    // Update: currentTheme, currentMode properties
}
```

## 📝 Files Modified by Manager

| File | Updated By | Purpose |
|------|-----------|---------|
| `~/.config/quickshell/core/Theme.qml` | `write_theme_qml()` | Color palette (hot-reloaded) |
| `~/.config/ghostty/themes/rice-generated` | `write_ghostty_theme()` | Terminal colors |
| `~/.cache/rice-manager/generated-wallpaper.ppm` | `write_generated_wallpaper()` | Wallpaper image |
| (swaybg process) | `start_wallpaper()` | Display wallpaper |

## 🎨 Supported Actions

### Themes
```bash
# All apply with instant hot-reload
rice-manager.sh theme retro-gruv-dark dark
rice-manager.sh theme cyber-neon dark
rice-manager.sh theme yorha light
rice-manager.sh theme cherry dark
# ... etc
```

### Mode
```bash
# Switch light/dark (keeps current theme palette)
rice-manager.sh mode light
rice-manager.sh mode dark
```

### Wallpaper
```bash
# Generated from theme color
rice-manager.sh wallpaper generated

# Custom image
rice-manager.sh wallpaper image /path/to/img.png

# Solid color
rice-manager.sh wallpaper solid "#00ff41" dark
```

## 🔍 Debugging

Enable console logging in quickshell to see flow:
```
[RiceManager] Panel loaded, fetching initial state
[RiceManager] Refreshing state from manager
[RiceManager] Status output: Theme: retro-gruv-dark ...
[RiceManager] ✓ Theme updated to: cyber-neon
[RiceManager] ✓ Mode updated to: dark
[RiceManager] Applying theme: cyber-neon mode: dark
[RiceManager] Command succeeded: theme cyber-neon dark
```

## ✅ What Works

- ✅ Hot-reload of Theme.qml (all colors update instantly)
- ✅ Ghostty terminal theme sync
- ✅ Wallpaper generation and display
- ✅ State polling (refreshes every 2s)
- ✅ Multi-theme support (8 presets)
- ✅ Light/Dark mode toggle
- ✅ Solid color wallpaper
- ✅ Image wallpaper support
- ✅ Real-time UI feedback

## 🚀 Next Steps

- [ ] Color picker for custom hex values
- [ ] Wallpaper preview thumbnails
- [ ] Theme favorites/bookmarks
- [ ] Keyboard shortcuts in panel
- [ ] Persistent panel state
