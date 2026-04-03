import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQml
import QtQml.Models
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../core" as Core

PanelWindow {
    id: window

    screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null

    // Centering calculation using Screen and margins for Wayland Layer Shell
    property int offsetX: screen ? (screen.width - width) / 2 : 0
    property int offsetY: screen ? (screen.height - height + Core.Theme.panelHeight) / 2 : 0

    anchors {
        top: true
        left: true
    }

    margins {
        left: window.offsetX
        top: window.offsetY
    }

    width: Core.DPI.s(700)
    height: Core.DPI.s(580)

    color: "transparent"
    visible: Core.GlobalState.configVisible

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    Process {
        id: managerProcess
        onExited: {
            console.log("[RiceManager] Command finished.");
            if (window.isApplying) {
                window.refreshState();
                window.isApplying = false;
            }
        }
    }
    Process {
        id: utilityProcess
    }
    Process {
        id: statusProcess
        onExited: {
            let outText = Array.isArray(statusProcess.stdout) ? statusProcess.stdout.join('\n') : statusProcess.stdout;
            if (!outText)
                return;
            try {
                const payload = JSON.parse(outText);
                if (payload.runtime) {
                    window.currentTheme = payload.runtime.theme || window.currentTheme;
                    window.currentMode = payload.runtime.mode || window.currentMode;
                }
            } catch (e) {
                console.warn("[RiceManager] Invalid status-json output");
            }
        }
    }

    property string homeDir: Quickshell.env.HOME || "/home/admin"
    property string managerScript: homeDir + "/scripts/rice-manager.sh"
    property string picturesDir: homeDir + "/Pictures"
    property string currentTheme: Core.Theme.activeTheme || ""
    property string currentMode: Core.Theme.activeMode || ""
    property bool isApplying: false

    function execManager(args) {
        isApplying = true;
        managerProcess.command = [managerScript].concat(args);
        managerProcess.running = true;
    }

    function openFolder(path) {
        utilityProcess.command = ["thunar", path];
        utilityProcess.running = true;
    }

    function refreshState() {
        statusProcess.command = [managerScript, "status-json"];
        statusProcess.running = true;
    }

    function applyTheme(themeName) {
        if (!currentMode || currentMode.length === 0)
            currentMode = "dark";
        console.log("[RiceManager] Applying theme:", themeName, "mode:", currentMode);
        execManager(["theme", themeName, currentMode]);
        currentTheme = themeName;
    }

    function applyMode(modeName) {
        console.log("[RiceManager] Applying mode:", modeName);
        execManager(["mode", modeName]);
        currentMode = modeName;
    }

    function applyGeneratedWallpaper() {
        console.log("[RiceManager] Applying generated wallpaper with mode:", currentMode);
        execManager(["wallpaper", "generated", currentMode]);
    }

    function applyImageWallpaper() {
        var path = wallpaperPath.text.trim();
        if (path.length === 0) {
            openFolder(picturesDir);
            return;
        }
        console.log("[RiceManager] Applying image wallpaper:", path, "mode:", currentMode);
        execManager(["wallpaper", "image", path, currentMode]);
    }

    function applySolidWallpaper() {
        var seed = solidSeed.text.trim();
        if (seed.length === 0) {
            return;
        }
        console.log("[RiceManager] Applying solid wallpaper:", seed, "mode:", currentMode);
        execManager(["wallpaper", "solid", seed, currentMode]);
    }

    Component.onCompleted: {
        console.log("[RiceManager] Panel loaded, fetching backend status");
        refreshState();
    }

    // ───────────────────────────────────────────────
    // COMPONENT: Reusable Theme Button
    // ───────────────────────────────────────────────
    component ThemeButton: Core.RetroBox {
        id: themeBtn
        property string themeName: ""
        property string displayName: ""
        property bool isActive: false
        property bool isEnabled: true

        Layout.fillWidth: true
        Layout.preferredHeight: Core.DPI.s(36)
        color: isActive ? Core.Theme.accent : Core.Theme.buttonBg
        opacity: isEnabled ? 1.0 : 0.45
        border.width: isActive ? 3 : 2
        border.color: isActive ? "white" : Core.Theme.outline

        Text {
            anchors.centerIn: parent
            text: displayName
            color: isActive ? "white" : Core.Theme.text
            font.family: Core.Theme.fontSystem
            font.pixelSize: Core.DPI.s(9)
            font.weight: Font.Bold
        }

        MouseArea {
            anchors.fill: parent
            enabled: isEnabled
            cursorShape: isEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: window.applyTheme(themeName)
        }
    }

    // ───────────────────────────────────────────────
    // COMPONENT: Reusable Mode Button
    // ───────────────────────────────────────────────
    component ModeButton: Core.RetroBox {
        id: modeBtn
        property string modeName: ""
        property string displayName: ""
        property bool isActive: false

        Layout.fillWidth: true
        Layout.preferredHeight: Core.DPI.s(36)
        color: isActive ? Core.Theme.accent : Core.Theme.buttonBg
        border.width: isActive ? 3 : 2
        border.color: isActive ? "white" : Core.Theme.outline

        Text {
            anchors.centerIn: parent
            text: displayName
            color: isActive ? "white" : Core.Theme.text
            font.family: Core.Theme.fontSystem
            font.pixelSize: Core.DPI.s(10)
            font.weight: Font.Black
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: window.applyMode(modeName)
        }
    }

    // ───────────────────────────────────────────────
    // COMPONENT: Action Button (enabled/disabled state)
    // ───────────────────────────────────────────────
    component ActionButton: Core.RetroBox {
        id: actionBtn
        property string label: ""
        property bool enabled: true
        property var onAction: () => {}
        property color bgColor: enabled ? Core.Theme.accent : Core.Theme.buttonBg
        property color textColor: enabled ? (bgColor === Core.Theme.accent ? "white" : Core.Theme.text) : Core.Theme.textDim

        Layout.preferredHeight: Core.DPI.s(32)
        color: bgColor
        opacity: enabled ? 1.0 : 0.5

        Text {
            anchors.centerIn: parent
            text: label
            color: textColor
            font.family: Core.Theme.fontSystem
            font.pixelSize: Core.DPI.s(10)
            font.weight: Font.Black
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            enabled: actionBtn.enabled
            onClicked: onAction()
        }
    }

    // ═══════════════════════════════════════════════
    // MAIN PANEL UI
    // ═══════════════════════════════════════════════

    Core.RetroBox {
        anchors.fill: parent
        color: Core.Theme.panelBg
        shadowOffset: 8
        padding: Core.DPI.s(10)

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ─── HEADER ───
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Core.DPI.s(36)
                color: Core.Theme.headerBg
                border.color: Core.Theme.outline
                border.width: 2

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Core.DPI.s(10)
                    anchors.rightMargin: Core.DPI.s(6)
                    spacing: Core.DPI.s(8)

                    Text {
                        text: "⚙ RICE MANAGER"
                        color: "black"
                        font.family: Core.Theme.fontSystem
                        font.pixelSize: Core.DPI.s(11)
                        font.weight: Font.Black
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: window.currentTheme
                        color: "black"
                        font.family: Core.Theme.fontMono
                        font.pixelSize: Core.DPI.s(8)
                        font.weight: Font.Bold
                    }

                    Core.RetroBox {
                        Layout.preferredWidth: Core.DPI.s(24)
                        Layout.preferredHeight: Core.DPI.s(24)
                        color: Core.Theme.buttonBg
                        Text {
                            anchors.centerIn: parent
                            text: "×"
                            color: Core.Theme.text
                            font.family: Core.Theme.fontSystem
                            font.pixelSize: Core.DPI.s(12)
                            font.weight: Font.Black
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                console.log("[RiceManager] Close button clicked");
                                Core.GlobalState.setModuleVisible("config", false);
                                window.visible = false;
                            }
                        }
                    }
                }
            }

            // ─── CONTENT SCROLL ───
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: Core.DPI.s(8)
                clip: true

                ColumnLayout {
                    width: window.width - Core.DPI.s(52)
                    spacing: Core.DPI.s(16)
                    anchors.margins: Core.DPI.s(4)

                    // ─────────────────────────────────────
                    // SECTION 1: THEMES
                    // ─────────────────────────────────────
                    Core.RetroBox {
                        Layout.fillWidth: true
                        color: Core.Theme.highlight
                        padding: Core.DPI.s(12)

                        ColumnLayout {
                            width: parent.width
                            spacing: Core.DPI.s(10)

                            Text {
                                text: "🎨 TEMAS"
                                color: Core.Theme.text
                                font.family: Core.Theme.fontSystem
                                font.pixelSize: Core.DPI.s(12)
                                font.weight: Font.Black
                            }

                            GridLayout {
                                Layout.fillWidth: true
                                columns: 2
                                columnSpacing: Core.DPI.s(8)
                                rowSpacing: Core.DPI.s(8)

                                Repeater {
                                    model: Core.Theme.availableThemes

                                    delegate: ThemeButton {
                                        themeName: modelData.name
                                        displayName: modelData.label
                                        isEnabled: modelData.enabled !== false
                                        isActive: window.currentTheme === modelData.name
                                    }
                                }
                            }
                        }
                    }

                    // ─────────────────────────────────────
                    // SECTION 2: MODE (LIGHT/DARK)
                    // ─────────────────────────────────────
                    Core.RetroBox {
                        Layout.fillWidth: true
                        color: Core.Theme.insetBg
                        padding: Core.DPI.s(12)

                        ColumnLayout {
                            width: parent.width
                            spacing: Core.DPI.s(10)

                            Text {
                                text: "🌓 MODO"
                                color: Core.Theme.text
                                font.family: Core.Theme.fontSystem
                                font.pixelSize: Core.DPI.s(12)
                                font.weight: Font.Black
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Core.DPI.s(10)

                                ModeButton {
                                    modeName: "light"
                                    displayName: "Light"
                                    isActive: window.currentMode === "light"
                                    enabled: !window.isApplying
                                    opacity: window.isApplying ? 0.5 : 1.0
                                }

                                ModeButton {
                                    modeName: "dark"
                                    displayName: "Dark"
                                    isActive: window.currentMode === "dark"
                                    enabled: !window.isApplying
                                    opacity: window.isApplying ? 0.5 : 1.0
                                }

                                Item {
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }

                    // ─────────────────────────────────────
                    // SECTION 3: WALLPAPER
                    // ─────────────────────────────────────
                    Core.RetroBox {
                        Layout.fillWidth: true
                        color: Core.Theme.panelBg
                        padding: Core.DPI.s(12)

                        ColumnLayout {
                            width: parent.width
                            spacing: Core.DPI.s(12)

                            Text {
                                text: "🖼 WALLPAPER"
                                color: Core.Theme.text
                                font.family: Core.Theme.fontSystem
                                font.pixelSize: Core.DPI.s(12)
                                font.weight: Font.Black
                            }

                            // Wallpaper Generated
                            Core.RetroBox {
                                Layout.fillWidth: true
                                color: Core.Theme.buttonBg
                                padding: Core.DPI.s(10)

                                ColumnLayout {
                                    width: parent.width
                                    spacing: Core.DPI.s(8)

                                    Text {
                                        text: "Generado por Matugen"
                                        color: Core.Theme.text
                                        font.family: Core.Theme.fontSystem
                                        font.pixelSize: Core.DPI.s(9)
                                        font.weight: Font.Bold
                                    }

                                    ActionButton {
                                        Layout.fillWidth: true
                                        label: "Aplicar Wallpaper Generado"
                                        enabled: !window.isApplying
                                        bgColor: Core.Theme.accent
                                        onAction: () => window.applyGeneratedWallpaper()
                                    }
                                }
                            }

                            // Wallpaper from Image
                            Core.RetroBox {
                                Layout.fillWidth: true
                                color: Core.Theme.buttonBg
                                padding: Core.DPI.s(10)

                                ColumnLayout {
                                    width: parent.width
                                    spacing: Core.DPI.s(8)

                                    Text {
                                        text: "Imagen desde archivo"
                                        color: Core.Theme.text
                                        font.family: Core.Theme.fontSystem
                                        font.pixelSize: Core.DPI.s(9)
                                        font.weight: Font.Bold
                                    }

                                    RowLayout {
                                        spacing: Core.DPI.s(6)

                                        TextField {
                                            id: wallpaperPath
                                            Layout.fillWidth: true
                                            placeholderText: window.homeDir + "/Pictures/img.png"
                                            selectByMouse: true
                                            font.family: Core.Theme.fontMono
                                            font.pixelSize: Core.DPI.s(8)
                                        }

                                        ActionButton {
                                            Layout.preferredWidth: Core.DPI.s(120)
                                            label: "Seleccionar"
                                            enabled: true
                                            bgColor: Core.Theme.buttonBg
                                            onAction: () => window.openFolder(window.picturesDir)
                                        }
                                    }

                                    ActionButton {
                                        Layout.fillWidth: true
                                        label: "Aplicar Imagen"
                                        enabled: (wallpaperPath.text.trim().length > 0) && !window.isApplying
                                        bgColor: Core.Theme.accent
                                        onAction: () => window.applyImageWallpaper()
                                    }
                                }
                            }

                            // Wallpaper Solid Color
                            Core.RetroBox {
                                Layout.fillWidth: true
                                color: Core.Theme.buttonBg
                                padding: Core.DPI.s(10)

                                ColumnLayout {
                                    width: parent.width
                                    spacing: Core.DPI.s(8)

                                    Text {
                                        text: "Color sólido"
                                        color: Core.Theme.text
                                        font.family: Core.Theme.fontSystem
                                        font.pixelSize: Core.DPI.s(9)
                                        font.weight: Font.Bold
                                    }

                                    RowLayout {
                                        spacing: Core.DPI.s(6)

                                        TextField {
                                            id: solidSeed
                                            Layout.fillWidth: true
                                            placeholderText: "#076678"
                                            text: "#076678"
                                            selectByMouse: true
                                            font.family: Core.Theme.fontMono
                                            font.pixelSize: Core.DPI.s(8)
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: Core.DPI.s(40)
                                            Layout.preferredHeight: Core.DPI.s(28)
                                            color: solidSeed.text.trim().length > 0 ? solidSeed.text : "#000000"
                                            border.color: Core.Theme.outline
                                            border.width: 2
                                        }
                                    }

                                    ActionButton {
                                        Layout.fillWidth: true
                                        label: "Aplicar Color"
                                        enabled: (solidSeed.text.trim().length > 0) && !window.isApplying
                                        bgColor: Core.Theme.accent
                                        onAction: () => window.applySolidWallpaper()
                                    }
                                }
                            }
                        }
                    }

                    // ─────────────────────────────────────
                    // SECTION 4: QUICK ACTIONS
                    // ─────────────────────────────────────
                    Core.RetroBox {
                        Layout.fillWidth: true
                        color: Core.Theme.sideTabBg
                        padding: Core.DPI.s(12)

                        ColumnLayout {
                            width: parent.width
                            spacing: Core.DPI.s(10)

                            Text {
                                text: "⚡ ACCIONES"
                                color: "white"
                                font.family: Core.Theme.fontSystem
                                font.pixelSize: Core.DPI.s(12)
                                font.weight: Font.Black
                            }

                            GridLayout {
                                Layout.fillWidth: true
                                columns: 2
                                columnSpacing: Core.DPI.s(10)
                                rowSpacing: Core.DPI.s(10)

                                ActionButton {
                                    Layout.fillWidth: true
                                    label: "Abrir Pictures"
                                    enabled: true
                                    bgColor: Core.Theme.buttonBg
                                    onAction: () => window.openFolder(window.picturesDir)
                                }

                                ActionButton {
                                    Layout.fillWidth: true
                                    label: "Abrir Scripts"
                                    enabled: true
                                    bgColor: Core.Theme.buttonBg
                                    onAction: () => window.openFolder(window.homeDir + "/scripts")
                                }

                                ActionButton {
                                    Layout.fillWidth: true
                                    label: "Refrescar Todo"
                                    enabled: true
                                    bgColor: Core.Theme.accent
                                    onAction: () => window.execManager(["refresh"])
                                }

                                ActionButton {
                                    Layout.fillWidth: true
                                    label: "Ver Estado"
                                    enabled: true
                                    bgColor: Core.Theme.buttonBg
                                    onAction: () => window.refreshState()
                                }
                            }
                        }
                    }

                    Item {
                        Layout.preferredHeight: Core.DPI.s(12)
                    }
                }
            }
        }
    }
}
