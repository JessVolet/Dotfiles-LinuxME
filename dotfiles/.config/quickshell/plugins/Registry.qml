import QtQuick
import Quickshell
import "../core" as Core

Item {
    id: root

    Component.onCompleted: {
        console.log("[Registry] Global modules:", globalModules.length, "Screen modules:", screenModules.length);
    }

    readonly property var globalModules: [
        {
            name: "ControlCenter",
            path: "ControlCenter.qml",
            enabled: true
        },
        {
            name: "Dashboard",
            path: "Dashboard.qml",
            enabled: true
        },
        {
            name: "Launcher",
            path: "Launcher.qml",
            enabled: true
        },
        {
            name: "RiceManager",
            path: "RiceManager.qml",
            enabled: true
        }
    ]

    readonly property var screenModules: [
        {
            name: "TopBar",
            path: "TopBar.qml",
            enabled: true
        }
    ]

    Repeater {
        model: root.globalModules

        delegate: Loader {
            id: pluginLoader
            required property var modelData

            active: modelData.enabled
            asynchronous: false
            source: modelData.path

            onLoaded: {
                console.log("[Registry] Plugin loaded:", modelData.name);
                if (item && item.hasOwnProperty("screen")) {
                    item.screen = Quickshell.screens.length > 0 ? Quickshell.screens[0] : null;
                }
            }

            onStatusChanged: {
                if (status === Loader.Error) {
                    console.warn("[Registry] Error loading global module:", modelData.name);
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: Item {
            id: screenHost
            required property var modelData
            property var screenRef: modelData

            Repeater {
                model: root.screenModules

                delegate: Loader {
                    id: screenPluginLoader
                    required property var modelData

                    active: modelData.enabled
                    asynchronous: false
                    source: modelData.path

                    onLoaded: {
                        console.log("[Registry] Screen plugin loaded:", modelData.name, "on", screenHost.screenRef.name);
                        if (item && item.hasOwnProperty("screen")) {
                            item.screen = screenHost.screenRef;
                        }
                    }

                    onStatusChanged: {
                        if (status === Loader.Error) {
                            console.warn("[Registry] Error loading screen module:", modelData.name, "on", screenHost.screenRef.name);
                        }
                    }
                }
            }
        }
    }
}
