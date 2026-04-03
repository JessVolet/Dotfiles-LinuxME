pragma Singleton
import QtQuick
import Quickshell
import Quickshell.I3

/**
 * Workspaces.qml
 * Singleton for managing Sway/i3 workspace state via Quickshell.I3.
 */
Singleton {
    id: root

    // Reactive list of workspaces from I3/Sway
    property var workspaceList: I3.workspaces.values

    // Focused workspace ID
    property int activeWorkspace: I3.focusedWorkspace ? I3.focusedWorkspace.number : 1

    function switchTo(num) {
        I3.dispatch(`workspace ${num}`);
    }
}
