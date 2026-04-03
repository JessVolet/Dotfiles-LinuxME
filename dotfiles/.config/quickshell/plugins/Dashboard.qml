import QtQuick
import QtQuick.Layouts
import Quickshell
import "../core" as Core

PanelWindow {
    id: window
    
    screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    
    anchors {
        top: true
        right: true
    }

    margins {
        top: Core.Theme.panelHeight + Core.DPI.s(8)
        right: Core.DPI.s(10)
    }

    width: Core.DPI.s(320)
    height: Core.DPI.s(380)
    
    color: "transparent"
    visible: Core.GlobalState.dashboardVisible
    
    onVisibleChanged: {
        if (visible) {
            console.log("[DEBUG] Dashboard opened");
            Core.GlobalState.notify("Catálogo", "Panel de componentes activo");
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
            z: 100 // Topmost
            opacity: 0.1
            visible: true
            color: "transparent"
            clip: true
            
            Column {
                anchors.fill: parent
                spacing: 2
                Repeater {
                    model: 300 // Hardcoded approximate for height
                    Rectangle { width: window.width; height: 1; color: "black"; opacity: 0.5 }
                }
            }
            
            MouseArea { anchors.fill: parent; enabled: false }
        }

        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            spacing: 0

            // --- Header: UI CATALOG ---
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Core.DPI.s(24)
                color: Core.Theme.accent
                border.color: Core.Theme.outline
                border.width: 2

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Core.DPI.s(8)
                    anchors.rightMargin: Core.DPI.s(4)
                    spacing: Core.DPI.s(4)

                    Text {
                        text: "🧩 CATÁLOGO UI (SISTEMA)"
                        color: "white"
                        font.family: Core.Theme.fontSystem
                        font.pixelSize: Core.DPI.s(10)
                        font.weight: Font.Black
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        width: Core.DPI.s(16)
                        height: Core.DPI.s(16)
                        color: Core.Theme.buttonBg
                        border.color: Core.Theme.outline
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "×"
                            font.family: Core.Theme.fontSystem
                            font.pixelSize: Core.DPI.s(12)
                            font.weight: Font.Bold
                            color: "black"
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: Core.GlobalState.setModuleVisible("dashboard", false)
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: Core.DPI.s(12)
                spacing: Core.DPI.s(10)

                Core.RetroBox {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Core.DPI.s(100)
                    color: Core.Theme.highlight
                    padding: Core.DPI.s(10)
                    shadowOffset: 2

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 2
                        
                        Text { text: "INFO DEL SISTEMA"; color: Core.Theme.text; font.family: Core.Theme.fontSystem; font.pixelSize: Core.DPI.s(9); font.weight: Font.Black }
                        Rectangle { Layout.fillWidth: true; height: 1; color: Core.Theme.outline; opacity: 0.3 }
                        
                        GridLayout {
                            columns: 2
                            rowSpacing: 1
                            Text { text: "NÚCLEO:"; color: Core.Theme.textDim; font.family: Core.Theme.fontSystem; font.pixelSize: Core.DPI.s(9) }
                            Text { text: "FEDORA ARM64"; color: Core.Theme.text; font.family: Core.Theme.fontSystem; font.weight: Font.Bold; font.pixelSize: Core.DPI.s(9) }
                            Text { text: "ESTADO:"; color: Core.Theme.textDim; font.family: Core.Theme.fontSystem; font.pixelSize: Core.DPI.s(9) }
                            Text { text: "OPTIMIZADO"; color: Core.Theme.success; font.family: Core.Theme.fontSystem; font.weight: Font.Bold; font.pixelSize: Core.DPI.s(9) }
                        }
                    }
                }

                Text { text: "LISTA DE COMPONENTES"; color: Core.Theme.text; font.family: Core.Theme.fontSystem; font.pixelSize: Core.DPI.s(9); font.weight: Font.Black }
                
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: ["Retro Button", "Status Box", "Divider Rail", "Grid Inset", "Label Component"]
                    delegate: Rectangle {
                        width: parent.width
                        height: Core.DPI.s(28)
                        color: "transparent"
                        
                        Rectangle { width: parent.width; height: 1; color: Core.Theme.outline; opacity: 0.1; anchors.bottom: parent.bottom }
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 4
                            Text { text: "• " + modelData; color: Core.Theme.text; font.family: Core.Theme.fontSystem; font.pixelSize: Core.DPI.s(10) }
                        }
                    }
                }

                Core.RetroBox {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: Core.DPI.s(140)
                    Layout.preferredHeight: Core.DPI.s(32)
                    color: Core.Theme.buttonBg
                    shadowOffset: 3

                    Text {
                        anchors.centerIn: parent
                        text: "REFRESCAR"
                        font.family: Core.Theme.fontSystem
                        font.pixelSize: Core.DPI.s(10)
                        font.weight: Font.Bold
                        color: Core.Theme.text
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: console.log("Catalog refresh Requested")
                    }
                }
            }
        }
    }
}
