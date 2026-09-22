pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property bool enabled: true
    property bool isConnected: false
    property string connectedDevice: ""
    property string statusText: enabled ? (isConnected ? connectedDevice : "On") : "Off"

    readonly property string bluetoothIcon: enabled ? (isConnected ? "bluetooth" : "bluetooth") : "bluetooth-disabled"

    function togglePower() {
        let cmd = root.enabled ? "block" : "unblock";
        rfkillProc.exec(["rfkill", cmd, "bluetooth"]);
        root.enabled = !root.enabled;
        refreshTimer.restart();
    }

    function openManager() {
        mgrProc.exec(["blueman-manager"]);
    }

    function startApplet() {
        mgrProc.exec(["blueman-applet"]);
    }

    Process { id: rfkillProc }
    Process { id: mgrProc }

    // Check rfkill bluetooth status
    Process {
        id: statusProc
        command: ["sh", "-c", "rfkill list bluetooth | grep -i 'soft blocked' | head -n 1"]
        stdout: StdioCollector {
            id: statusCollector
            onDataChanged: {
                let out = statusCollector.text.trim().toLowerCase();
                root.enabled = (out.indexOf("yes") === -1);
            }
        }
    }

    function updateStatus() {
        statusProc.exec(["sh", "-c", "rfkill list bluetooth | grep -i 'soft blocked' | head -n 1"]);
    }

    Timer {
        id: refreshTimer
        interval: 3000
        running: true
        repeat: true
        onTriggered: root.updateStatus()
    }

    Component.onCompleted: {
        root.updateStatus();
    }
}
