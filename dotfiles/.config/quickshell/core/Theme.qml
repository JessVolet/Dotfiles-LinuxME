pragma Singleton
import QtQuick

QtObject {
    readonly property string activeTheme: "cherry"
    readonly property string activeMode: "light"
    readonly property string activePalette: "matugen-default"
    readonly property string wallpaperType: "theme"
    readonly property string wallpaperValue: "cherry"
    readonly property var availableThemes: [{"name": "cherry", "label": "Cherry", "enabled": true, "palette": "matugen-default", "affects": ["quickshell", "ghostty", "sway", "environment"]}, {"name": "cyber-neon", "label": "Cyber Neon", "enabled": true, "palette": "retro-contrast", "affects": ["quickshell", "ghostty", "sway", "environment"]}, {"name": "gleep", "label": "Gleep", "enabled": true, "palette": "matugen-default", "affects": ["quickshell", "ghostty", "sway", "environment"]}, {"name": "indigo", "label": "Indigo", "enabled": true, "palette": "matugen-default", "affects": ["quickshell", "ghostty", "sway", "environment"]}, {"name": "retro-gruv-dark", "label": "Gruvbox Dark", "enabled": true, "palette": "matugen-default", "affects": ["quickshell", "ghostty", "sway", "environment"]}, {"name": "retro-gruv-light", "label": "Gruvbox Light", "enabled": true, "palette": "matugen-default", "affects": ["quickshell", "ghostty", "sway", "environment"]}, {"name": "yorha", "label": "YoRHa", "enabled": true, "palette": "matugen-default", "affects": ["quickshell", "ghostty", "sway", "environment"]}]
    readonly property color base:      "#fff7f9"
    readonly property color highlight: "#f2e5eb"
    readonly property color bgDesktop: "#fff7f9"
    readonly property color shadow:    "#d2c2cb"
    readonly property color textDim:   "#4e444b"
    readonly property color text:      "#201a1e"
    readonly property color outline:   "#80747b"
    readonly property color accent:    "#814c77"
    readonly property color urgent:    "#ba1a1a"
    readonly property color success:   "#6e5868"
    readonly property color shadowColor: "#66d2c2cb"
    readonly property color panelBg:   "#f7eaf0"
    readonly property color insetBg:   "#f2e5eb"
    readonly property color headerBg:  "#ffd7f3"
    readonly property color sideTabBg: "#f8daee"
    readonly property color bevelLight:  "#fff7f9"
    readonly property color bevelDark:   "#d2c2cb"
    readonly property color buttonBg:    "#eedee7"
    readonly property color buttonAct:   "#ffdad6"
    readonly property var themes: ({ 'generated': { base: "#fff7f9", accent: "#814c77", highlight: "#f2e5eb", text: "#201a1e" } })
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
}
