pragma Singleton
import QtQuick
import Quickshell

/**
 * DPI.qml - Specialized scaling engine for Retro Cyber UI.
 * Handles adaptive sizing for 1080p @ 1.25x scale and other variants.
 */
QtObject {
    id: scaler

    // --- Base Config (Target: 1080p standard) ---
    // We define our base design for a logical "scale 1.0" at 1080p
    readonly property real baseDpi: 96
    
    // This is the global multiplier. 
    // You can manually adjust this or bind it to a system setting.
    property real scaleFactor: 1.25 

    // --- Scaling Function ---
    // Use this for any pixel value to make it responsive
    function s(value) {
        return Math.round(value * scaleFactor);
    }

    // --- Standard scaled tokens ---
    readonly property int panelHeight: s(32)
    readonly property int iconSize: s(16)
    readonly property int spacing: s(8)
    readonly property int padding: s(10)
    readonly property int borderWidth: s(2)
    readonly property int shadowOffset: s(8)

    // --- Font Scaling ---
    readonly property int fontTiny: s(9)
    readonly property int fontSmall: s(11)
    readonly property int fontNormal: s(13)
    readonly property int fontLarge: s(18)
    readonly property int fontTitle: s(24)
}
