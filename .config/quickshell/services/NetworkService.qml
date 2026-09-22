pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property bool wifiEnabled: true
    property string activeSsid: ""
    property int activeSignal: 0
    property string activeType: "ethernet" // ethernet, wifi, none
    property bool isConnected: true
    property var wifiNetworks: []

    readonly property string wifiIcon: {
        if (!wifiEnabled) return "wifi-off";
        if (!isConnected && activeType === "wifi") return "wifi-off";
        return "wifi";
    }

    function toggleWifi() {
        let cmd = root.wifiEnabled ? "off" : "on";
        wifiCmdProc.exec(["nmcli", "radio", "wifi", cmd]);
        root.wifiEnabled = !root.wifiEnabled;
        refreshTimer.restart();
    }

    function scanNetworks() {
        if (root.wifiEnabled) {
            scanProc.exec(["sh", "-c", "nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY dev wifi list --rescan yes | head -n 25"]);
        }
    }

    function connect(ssid, password) {
        if (!ssid) return;
        if (password && password.length > 0) {
            connectProc.exec(["nmcli", "dev", "wifi", "connect", ssid, "password", password]);
        } else {
            connectProc.exec(["nmcli", "dev", "wifi", "connect", ssid]);
        }
    }

    Process { id: wifiCmdProc }
    Process { id: connectProc }

    // Check Wi-Fi radio status
    Process {
        id: radioProc
        command: ["nmcli", "radio", "wifi"]
        stdout: StdioCollector {
            id: radioCollector
            onDataChanged: {
                let out = radioCollector.text.trim();
                root.wifiEnabled = (out.indexOf("enabled") !== -1);
            }
        }
    }

    // Check active connection
    Process {
        id: activeConnProc
        command: ["sh", "-c", "nmcli -t -f TYPE,NAME,STATE connection show --active | head -n 5"]
        stdout: StdioCollector {
            id: activeConnCollector
            onDataChanged: {
                let lines = activeConnCollector.text.trim().split("\n");
                let found = false;
                for (let i = 0; i < lines.length; i++) {
                    let parts = lines[i].split(":");
                    if (parts.length >= 2 && parts[1].length > 0) {
                        found = true;
                        root.isConnected = true;
                        if (parts[0].indexOf("wireless") !== -1 || parts[0].indexOf("wifi") !== -1) {
                            root.activeType = "wifi";
                            root.activeSsid = parts[1];
                        } else {
                            root.activeType = "ethernet";
                            root.activeSsid = parts[1];
                        }
                        break;
                    }
                }
                if (!found) {
                    root.isConnected = false;
                    root.activeSsid = "Disconnected";
                    root.activeType = "none";
                }
            }
        }
    }

    // Scan nearby Wi-Fi networks
    Process {
        id: scanProc
        command: ["sh", "-c", "nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY dev wifi list | head -n 25"]
        stdout: StdioCollector {
            id: scanCollector
            onDataChanged: {
                let lines = scanCollector.text.trim().split("\n");
                let list = [];
                let seen = {};
                for (let i = 0; i < lines.length; i++) {
                    let parts = lines[i].split(":");
                    if (parts.length >= 4) {
                        let inUse = parts[0] === "*";
                        let ssid = parts[1].trim();
                        let signal = parseInt(parts[2]) || 0;
                        let sec = parts[3].trim();
                        if (ssid.length > 0 && !seen[ssid]) {
                            seen[ssid] = true;
                            list.push({
                                inUse: inUse,
                                ssid: ssid,
                                signal: signal,
                                security: sec
                            });
                        }
                    }
                }
                root.wifiNetworks = list;
            }
        }
    }

    function updateAll() {
        radioProc.exec(["nmcli", "radio", "wifi"]);
        activeConnProc.exec(["sh", "-c", "nmcli -t -f TYPE,NAME,STATE connection show --active | head -n 5"]);
        if (root.wifiEnabled) {
            scanProc.exec(["sh", "-c", "nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY dev wifi list | head -n 25"]);
        }
    }

    Timer {
        id: refreshTimer
        interval: 4000
        running: true
        repeat: true
        onTriggered: root.updateAll()
    }

    Component.onCompleted: {
        root.updateAll();
    }
}
