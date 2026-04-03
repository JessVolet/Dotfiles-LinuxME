import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../core" as Core

PanelWindow {
    id: window

    screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null

    anchors {
        top: true
        left: true
    }

    margins {
        top: Core.Theme.panelHeight + Core.DPI.s(8)
        left: Core.DPI.s(10)
    }

    width: Core.DPI.s(260)
    height: contentColumn.implicitHeight + (Core.Theme.padding * 2)

    color: "transparent"
    visible: Core.GlobalState.launcherVisible

    onVisibleChanged: {
        if (visible) {
            console.log("[DEBUG] Launcher opened");
            Core.GlobalState.notify("Launcher", "Menú de sistema desplegado");
        }
    }

    Core.RetroBox {
        anchors.fill: parent
        color: Core.Theme.panelBg
        shadowOffset: 6
        padding: 0

        // --- CRT Scanline Overlay ---
        Rectangle {
            anchors.fill: parent
            z: 100
            opacity: 0.12 // Increased slightly for visibility
            visible: true
            color: "transparent"
            clip: true

            Column {
                anchors.fill: parent
                spacing: 2
                Repeater {
                    model: 200
                    Rectangle {
                        width: window.width
                        height: 1
                        color: "black"
                        opacity: 0.6
                    }
                }
            }
            MouseArea {
                anchors.fill: parent
                enabled: false
            }
        }

        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            spacing: 0

            // --- Header: SISTEMA ---
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: Core.DPI.s(45)

                RowLayout {
                    anchors.centerIn: parent
                    width: parent.width - Core.DPI.s(24)
                    spacing: Core.DPI.s(12)

                    Column {
                        spacing: 2
                        Layout.fillWidth: true
                        Repeater {
                            model: 4
                            Rectangle {
                                width: parent.width
                                height: 1
                                color: Core.Theme.outline
                                opacity: 0.7
                            }
                        }
                    }

                    Text {
                        text: "SISTEMA"
                        color: Core.Theme.text
                        font.family: Core.Theme.fontSystem
                        font.pixelSize: Core.DPI.s(10)
                        font.weight: Font.Black
                        font.letterSpacing: 1
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Column {
                        spacing: 2
                        Layout.fillWidth: true
                        Repeater {
                            model: 4
                            Rectangle {
                                width: parent.width
                                height: 1
                                color: Core.Theme.outline
                                opacity: 0.7
                            }
                        }
                    }
                }
            }

            // --- Body: Actions ---
            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: Core.DPI.s(12)
                Layout.topMargin: 0
                spacing: Core.DPI.s(8) // More breathing room

                NavButton {
                    iconText: ""
                    text: "Terminal OS"
                    action: () => {
                        shell.command = ["ghostty"];
                        shell.running = true;
                    }
                }

                NavButton {
                    iconText: "📂"
                    text: "Explorador"
                    action: () => {
                        shell.command = ["thunar"];
                        shell.running = true;
                    }
                }

                NavButton {
                    iconText: ""
                    text: "Catálogo UI (Nuevo)"
                    action: () => Core.GlobalState.toggleDashboard()
                }

                NavButton {
                    iconText: ""
                    text: "Configuración"
                    action: () => Core.GlobalState.toggleConfig()
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 3
                    Layout.topMargin: Core.DPI.s(2)
                    Layout.bottomMargin: Core.DPI.s(2)
                    color: Core.Theme.outline
                }

                NavButton {
                    iconText: "🚪"
                    text: "Cerrar Sesión"
                    isUrgent: true
                    action: () => {
                        shell.command = ["swaymsg", "exit"];
                        shell.running = true;
                    }
                }

                NavButton {
                    text: "Apagar Sistema"
                    isUrgent: true
                    action: () => {
                        shell.command = ["systemctl", "poweroff"];
                        shell.running = true;
                    }
                }
            }

            Item {
                Layout.preferredHeight: Core.DPI.s(12)
            }
        }
    }

    component NavButton: Rectangle {
        id: btn
        property alias text: label.text
        property string iconText: ""
        property var action: null
        property bool isUrgent: false

        Layout.fillWidth: true
        Layout.preferredHeight: Core.DPI.s(38)

        color: isUrgent ? Core.Theme.urgent : (mouse.hovered ? Core.Theme.highlight : Core.Theme.buttonBg)
        border.color: Core.Theme.outline
        border.width: 2

        // Gloss effect
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            color: "transparent"
            border.color: "white"
            opacity: 0.15
            visible: !mouse.containsPress
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Core.DPI.s(12)
            spacing: Core.DPI.s(12)

            Text {
                text: btn.iconText
                font.family: Core.Theme.fontMono
                font.pixelSize: Core.DPI.s(16)
                color: btn.isUrgent ? "white" : Core.Theme.text
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                id: label
                font.family: Core.Theme.fontSystem
                font.pixelSize: Core.DPI.s(11)
                font.weight: Font.Bold
                color: btn.isUrgent ? "white" : Core.Theme.text
                verticalAlignment: Text.AlignVCenter
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (parent.action)
                    parent.action();
                Core.GlobalState.setModuleVisible("launcher", false);
            }
        }
    }

    Process {
        id: shell
    }
}
