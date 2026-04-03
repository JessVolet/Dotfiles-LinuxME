pragma Singleton
import QtQuick

QtObject {
    property bool dashboardVisible: false
    property bool controlCenterVisible: false
    property bool launcherVisible: false
    property bool configVisible: false

    function setModuleVisible(moduleName, visible) {
        switch (moduleName) {
        case "dashboard":
            dashboardVisible = visible;
            break;
        case "controlCenter":
            controlCenterVisible = visible;
            break;
        case "launcher":
            launcherVisible = visible;
            break;
        case "config":
            configVisible = visible;
            break;
        default:
            console.warn("[GlobalState] Unknown module:", moduleName);
            break;
        }
    }

    function isModuleVisible(moduleName) {
        switch (moduleName) {
        case "dashboard":
            return dashboardVisible;
        case "controlCenter":
            return controlCenterVisible;
        case "launcher":
            return launcherVisible;
        case "config":
            return configVisible;
        default:
            return false;
        }
    }

    function toggleModule(moduleName) {
        setModuleVisible(moduleName, !isModuleVisible(moduleName));
    }

    function toggleDashboard() {
        toggleModule("dashboard");
    }

    function toggleControlCenter() {
        toggleModule("controlCenter");
    }

    function toggleLauncher() {
        toggleModule("launcher");
    }

    function toggleConfig() {
        toggleModule("config");
    }

    function closeTransientModules() {
        dashboardVisible = false;
        controlCenterVisible = false;
        launcherVisible = false;
        configVisible = false;
    }

    // --- Simple Debug Notify System ---
    function notify(title, message) {
        console.log(`[NOTIFICATION] ${title}: ${message}`);
        // Here we could trigger a real notification plugin if active
    }
}
