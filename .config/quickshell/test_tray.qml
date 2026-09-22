
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

ShellRoot {
    Component.onCompleted: {
        console.log("SystemTray available:", SystemTray.items !== null);
        console.log("SystemTray count:", SystemTray.items.values.length);
        Qt.quit();
    }
}
