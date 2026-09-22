pragma Singleton
import QtQuick

QtObject {
    id: root

    property string currentPanel: "" // "media", "windows", "audio", "notifications", "calendar", "power"
    readonly property bool isAnyOpen: currentPanel !== ""

    function toggle(panelName) {
        if (currentPanel === panelName) {
            currentPanel = "";
        } else {
            currentPanel = panelName;
        }
    }

    function open(panelName) {
        currentPanel = panelName;
    }

    function close() {
        currentPanel = "";
    }
}
