import QtQuick
import Quickshell
import Quickshell.Io
import "../theme"
import "../components"
import "../services"

Rectangle {
    id: root

    property string statusScript: Quickshell.env("HOME") + "/.config/hypr/scripts/vpn_status.sh"
    property string managerScript: Quickshell.env("HOME") + "/.config/hypr/scripts/vpn_manager.sh"

    property bool isConnected: false
    property string currentServer: ""

    implicitWidth: contentRow.implicitWidth + 14
    implicitHeight: 28
    radius: Theme.radiusSmall
    color: mouseArea.containsMouse ? Theme.cardBgHover : "transparent"
    border.color: isConnected ? Theme.accentGreen : (mouseArea.containsMouse ? Theme.borderHover : "transparent")
    border.width: 1

    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    Process {
        id: statusProc
        command: ["bash", root.statusScript]
        stdout: StdioCollector {
            onStreamFinished: {
                let out = text.trim();
                if (out.startsWith("CONNECTED")) {
                    root.isConnected = true;
                    let name = out.split(":")[1] || "VPN";
                    name = name.replace(".ovpn", "").split(".")[0];
                    name = name.replace("-free-", "-");
                    root.currentServer = name;
                } else {
                    root.isConnected = false;
                    root.currentServer = "";
                }
            }
        }
    }

    Timer {
        interval: 2500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            statusProc.running = false;
            statusProc.running = true;
        }
    }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 6

        SvgIcon {
            anchors.verticalCenter: parent.verticalCenter
            name: "lock"
            size: 14
            color: root.isConnected ? Theme.accentGreen : Theme.fgMuted
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.isConnected ? root.currentServer : "VPN"
            color: root.isConnected ? Theme.accentGreen : Theme.fgMuted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.weight: root.isConnected ? Font.Bold : Font.Normal
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor

        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton && root.isConnected) {
                Quickshell.execDetached(["bash", "-c", "kill $(cat /tmp/openvpn_manager.pid 2>/dev/null) 2>/dev/null; rm -f /tmp/openvpn_manager.pid /tmp/openvpn_manager_status.txt; notify-send 'VPN' 'Disconnected'"]);
                statusProc.running = false;
                statusProc.running = true;
            } else {
                Quickshell.execDetached(["kitty", "--title", "VPN Manager", "-e", "sudo", root.managerScript]);
            }
        }
    }
}
