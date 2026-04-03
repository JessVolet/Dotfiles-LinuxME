import QtQuick
import "." // Import current directory for Theme, Clock, Perf singletons

/**
 * RetroBox.qml
 * A reusable container that implements the Retro Cyber aesthetic:
 * - Solid border
 * - Hard rectangular shadow
 * - Flat background
 */
Item {
    id: root

    property int padding: Theme.padding
    property alias color: background.color
    property alias border: background.border
    property int shadowOffset: Theme.shadowOffsetX
    property bool showShadow: Perf.enableShadows
    default property alias data: content.data

    implicitWidth: content.childrenRect.width + (root.padding * 2)
    implicitHeight: content.childrenRect.height + (root.padding * 2)

    // The Shadow (rectangular, offset)
    Rectangle {
        id: shadowRect
        anchors.fill: background
        anchors.margins: 0
        color: Theme.shadowColor
        visible: root.showShadow
        z: -1

        transform: Translate {
            x: root.shadowOffset
            y: root.shadowOffset
        }
    }

    // The Main Content Box
    Rectangle {
        id: background
        anchors.fill: parent
        color: Theme.base
        border.color: Theme.outline
        border.width: Theme.borderWidth
        radius: Theme.borderRadius // Always 0 in Retro

        Item {
            id: content
            anchors.fill: parent
            anchors.margins: root.padding
        }
    }
}
