import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import "../core" as Core

/**
 * ControlCenter.qml
 * Industrial-Cyberpunk Control Center 
 * Based on the reference image with Matugen and Predefined Themes.
 */
Core.RetroBox {
    id: controlCenter
    width: Core.DPI.s(550)
    height: Core.DPI.s(450)
    anchors.centerIn: parent
    color: Core.Theme.panelBg
    border.width: 3
    shadowOffset: 12
    visible: Core.GlobalState.controlCenterVisible

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header: PANEL DE CONTROL
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Core.DPI.s(32)
            color: Core.Theme.headerBg
            border.color: Core.Theme.outline
            border.width: 2

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Core.DPI.s(12)
                anchors.rightMargin: 4
                
                // Bevel pattern (horizontal lines)
                Rectangle {
                    Layout.fillWidth: true
                    height: Core.DPI.s(16)
                    color: "transparent"
                    border.color: Core.Theme.outline
                    border.width: 1
                    clip: true
                    Column {
                        anchors.fill: parent
                        spacing: 2
                        Repeater {
                            model: 6
                            Rectangle { width: parent.width; height: 1; color: Core.Theme.outline; opacity: 0.3 }
                        }
                    }
                }

                Text {
                    text: "PANEL DE CONTROL"
                    font.family: Core.Theme.fontSystem
                    font.pixelSize: Core.DPI.s(12)
                    font.weight: Font.Black
                    color: "black"
                }

                // Bevel pattern right
                Rectangle {
                    Layout.fillWidth: true
                    height: Core.DPI.s(16)
                    color: "transparent"
                    border.color: Core.Theme.outline
                    border.width: 1
                    clip: true
                    Column {
                        anchors.fill: parent
                        spacing: 2
                        Repeater {
                            model: 6
                            Rectangle { width: parent.width; height: 1; color: Core.Theme.outline; opacity: 0.3 }
                        }
                    }
                }

                // Close Button
                Core.RetroBox {
                    Layout.preferredWidth: 24; Layout.preferredHeight: 24
                    color: Core.Theme.buttonBg
                    Text { anchors.centerIn: parent; text: "X"; font.weight: Font.Black }
                    MouseArea { anchors.fill: parent; onClicked: Core.GlobalState.setModuleVisible("controlCenter", false) }
                }
            }
        }

        // Main Body: Tabs + Content
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Sidebar Tabs
            Rectangle {
                Layout.preferredWidth: Core.DPI.s(120)
                Layout.fillHeight: true
                color: Core.Theme.sideTabBg
                border.color: Core.Theme.outline
                border.width: 2

                ColumnLayout {
                    anchors.fill: parent
                    spacing: Core.DPI.s(4)
                    
                    // Tab: Apariencia
                    Core.RetroBox {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Core.DPI.s(32)
                        color: Core.Theme.panelBg
                        border.width: 2
                        Text { anchors.centerIn: parent; text: "🎨 Apariencia"; font.family: Core.Theme.fontSystem; font.pixelSize: Core.DPI.s(10); font.weight: Font.Bold; color: "black" }
                    }

                    // Tab: Sistema
                    Core.RetroBox {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Core.DPI.s(32)
                        color: Core.Theme.sideTabBg
                        Text { anchors.centerIn: parent; text: "💻 Sistema"; font.family: Core.Theme.fontSystem; font.pixelSize: Core.DPI.s(10); color: "white" }
                    }

                    // Tab: Red
                    Core.RetroBox {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Core.DPI.s(32)
                        color: Core.Theme.sideTabBg
                        Text { anchors.centerIn: parent; text: "🌐 Red"; font.family: Core.Theme.fontSystem; font.pixelSize: Core.DPI.s(10); color: "white" }
                    }

                    Item { Layout.fillHeight: true }
                }
            }

            // Main Content: Personalización
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                ScrollBar.vertical.policy: ScrollBar.AlwaysOn

                ColumnLayout {
                    width: parent.width - 20
                    spacing: Core.DPI.s(16)
                    anchors.margins: Core.DPI.s(16)

                    Text { text: "Personalización Visual"; font.pixelSize: Core.DPI.s(16); font.weight: Font.Black; color: Core.Theme.text }

                    // --- Wallpaper Section ---
                    ColumnLayout {
                        spacing: 8
                        Text { text: "FONDO DE PANTALLA"; font.weight: Font.Bold; font.pixelSize: Core.DPI.s(10) }
                        RowLayout {
                            spacing: Core.DPI.s(8)
                            Button { text: "Rejilla Nix"; Layout.preferredWidth: Core.DPI.s(100) }
                            Button { text: "Paisaje"; Layout.preferredWidth: Core.DPI.s(100) }
                            Button { text: "Abstracto"; Layout.preferredWidth: Core.DPI.s(100) }
                        }
                    }

                    // --- Matugen Section ---
                    Core.RetroBox {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Core.DPI.s(100)
                        color: Core.Theme.highlight
                        border.width: 3
                        
                        ColumnLayout {
                            anchors.fill: parent; anchors.margins: 12
                            Text { text: "MOTOR MATUGEN (COLORES)"; font.weight: Font.Bold }
                            
                            RowLayout {
                                spacing: 12
                                Text { text: "HEX SEED:"; font.weight: Font.Bold }
                                Rectangle {
                                    Layout.preferredWidth: Core.DPI.s(100); Layout.preferredHeight: 30
                                    color: "white"; border.color: "black"; border.width: 2
                                    TextInput { anchors.centerIn: parent; text: "#BAC4E6"; font.family: Core.Theme.fontMono }
                                }
                                Core.RetroBox {
                                    Layout.preferredWidth: Core.DPI.s(150); Layout.preferredHeight: 30
                                    color: Core.Theme.buttonAct
                                    Text { anchors.centerIn: parent; text: "APLICAR"; color: "white"; font.weight: Font.Black }
                                }
                            }
                        }
                    }

                    // --- Predefined Themes Section ---
                    ColumnLayout {
                        spacing: 8
                        Text { text: "Temas Predefinidos:"; font.weight: Font.Bold }
                        GridLayout {
                            columns: 2; columnSpacing: 12; rowSpacing: 12
                            Button { text: "YoRHa (NieR)"; Layout.preferredWidth: Core.DPI.s(140) }
                            Button { text: "Cherry Pink"; Layout.preferredWidth: Core.DPI.s(140) }
                            Button { text: "Deep Indigo"; Layout.preferredWidth: Core.DPI.s(140) }
                            Button { text: "Gleep Green"; Layout.preferredWidth: Core.DPI.s(140) }
                        }
                        
                        Core.RetroBox {
                            Layout.fillWidth: true; Layout.preferredHeight: 40
                            color: Core.Theme.accent
                            Text { anchors.centerIn: parent; text: "Restaurar Original (Gruvbox)"; color: "white"; font.weight: Font.Bold }
                        }
                    }
                }
            }
        }
    }
}
