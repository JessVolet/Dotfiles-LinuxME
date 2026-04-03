import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../core" as Core

PanelWindow {
    id: window
    property var screen: null

    anchors {
        top: true
        left: true
        right: true
    }

    height: Core.Theme.panelHeight
    color: "transparent"

    Core.RetroBox {
        id: bar
        anchors.fill: parent
        showShadow: false
        border.width: 0
        color: Core.Theme.panelBg
        padding: 0 // Allow RowLayout to manage its own space

        // Process executors
        Process {
            id: launcherProcess
            command: ["bash", "-lc", "$HOME/scripts/rofi-launcher.sh"]
        }

        RowLayout {
            anchors.centerIn: parent
            width: parent.width - (Core.Theme.padding * 2)
            spacing: 0
            height: parent.height

            // --- Left: FEDORA Logo ---
            Core.RetroBox {
                padding: Core.DPI.s(6)
                Layout.alignment: Qt.AlignVCenter
                color: Core.Theme.highlight
                border.width: 2
                shadowOffset: 2

                Row {
                    anchors.centerIn: parent
                    spacing: Core.DPI.s(4)

                    Text {
                        text: "" // Fedora Icon (requires Nerd Font)
                        font.family: Core.Theme.fontMono
                        font.pixelSize: Core.DPI.s(12)
                        font.weight: Font.Black
                        color: Core.Theme.text
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        text: "FEDORA"
                        font.family: Core.Theme.fontSystem
                        font.pixelSize: Core.DPI.s(10)
                        font.weight: Font.Black
                        color: Core.Theme.text
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Core.GlobalState.toggleLauncher()
                }
            }

            Rail {
                Layout.fillWidth: false
                Layout.preferredWidth: Core.DPI.s(10)
            }

            // --- Workspaces Section (Showing exactly 3 centered) ---
            Repeater {
                id: workspaceRepeater
                model: 3

                // Calculates a base such that activeWorkspace is in the middle of a 3-pack or follows the user's logic
                // For now, let's stick to the 3-pack logic: 1-2-3, 4-5-6, etc., as it is simpler and familiar
                property int base: Math.floor((Core.Workspaces.activeWorkspace - 1) / 3) * 3 + 1

                delegate: RowLayout {
                    spacing: 0
                    property int wsNum: workspaceRepeater.base + index
                    // Find actual workspace data to check for 'urgent' state
                    property var ws: Core.Workspaces.workspaceList.find(w => w.number === wsNum) || {
                        number: wsNum,
                        focused: false,
                        urgent: false
                    }

                    Core.RetroBox {
                        Layout.alignment: Qt.AlignVCenter
                        padding: Core.DPI.s(4)

                        // Active state: White box, black text. Inactive: Panel color, gray text/outline
                        color: (wsNum === Core.Workspaces.activeWorkspace) ? "white" : (ws.urgent ? Core.Theme.urgent : Core.Theme.panelBg)
                        border.width: 2
                        border.color: (wsNum === Core.Workspaces.activeWorkspace) ? "white" : Core.Theme.outline
                        shadowOffset: (wsNum === Core.Workspaces.activeWorkspace) ? 0 : 2

                        Text {
                            anchors.centerIn: parent
                            text: wsNum
                            font.family: Core.Theme.fontSystem
                            font.pixelSize: Core.DPI.s(10)
                            font.weight: Font.Bold
                            color: (wsNum === Core.Workspaces.activeWorkspace) ? "black" : Core.Theme.outline
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: Core.Workspaces.switchTo(wsNum)
                        }
                    }

                    Rail {
                        visible: index < 2
                        Layout.fillWidth: false
                        Layout.preferredWidth: Core.DPI.s(6)
                    }
                }
            }

            // Central Rail
            Rail {
                Layout.fillWidth: true
                Layout.leftMargin: Core.DPI.s(4)
                Layout.rightMargin: Core.DPI.s(4)
            }

            // Right Area: UI_CATALOG
            Core.RetroBox {
                Layout.alignment: Qt.AlignVCenter
                padding: Core.DPI.s(4)
                color: Core.Theme.buttonBg
                border.width: 2
                shadowOffset: 2

                Text {
                    anchors.centerIn: parent
                    text: "CONTROL_CENTER"
                    font.family: Core.Theme.fontSystem
                    font.pixelSize: Core.DPI.s(10)
                    font.weight: Font.Black
                    color: "black"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Core.GlobalState.toggleControlCenter()
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                }
            }

            Rail {
                Layout.fillWidth: false
                Layout.preferredWidth: Core.DPI.s(16)
            }

            // Clock
            Core.RetroBox {
                Layout.alignment: Qt.AlignVCenter
                padding: Core.DPI.s(6)
                color: Core.Theme.panelBg
                border.width: 2
                shadowOffset: 0

                Text {
                    id: clockText
                    anchors.centerIn: parent
                    text: Core.Clock.time24
                    font.family: Core.Theme.fontDisplay
                    font.pixelSize: Core.DPI.s(11)
                    font.weight: Font.Bold
                    color: Core.Theme.text
                }
            }

            Rail {
                Layout.fillWidth: false
                Layout.preferredWidth: Core.DPI.s(10)
            }
        }
    }

    // --- Rail Component (The dynamic horizontal line) ---
    component Rail: Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 2
        Layout.alignment: Qt.AlignVCenter
        color: Core.Theme.outline
        opacity: 0.8
        antialiasing: true
    }
}
