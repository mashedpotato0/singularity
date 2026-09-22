import QtQuick
import Quickshell
import Quickshell.Io
import "../theme"
import "../components"
import "../services"

Rectangle {
    id: root

    property bool isConnected: false
    property bool isInstalled: false

    implicitWidth: contentRow.implicitWidth + 14
    implicitHeight: 28
    radius: Theme.radiusSmall
    color: mouseArea.containsMouse ? Theme.cardBgHover : "transparent"
    border.color: isConnected ? Theme.accentPeach : (mouseArea.containsMouse ? Theme.borderHover : "transparent")
    border.width: 1

    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    Process {
        id: statusProc
        command: ["bash", "-c", "command -v warp-cli >/dev/null 2>&1 && warp-cli status 2>/dev/null || echo 'NOT_INSTALLED'"]
        stdout: StdioCollector {
            onStreamFinished: {
                let out = text.toLowerCase().trim();
                if (out.includes("not_installed")) {
                    root.isInstalled = false;
                    root.isConnected = false;
                } else {
                    root.isInstalled = true;
                    if (out.includes("connected") && !out.includes("disconnected")) {
                        root.isConnected = true;
                    } else {
                        root.isConnected = false;
                    }
                }
            }
        }
    }

    Timer {
        interval: 3000
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
            name: "cloud"
            size: 15
            color: root.isConnected ? Theme.accentPeach : Theme.fgMuted
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.isConnected ? "WARP" : (root.isInstalled ? "WARP: Off" : "WARP")
            color: root.isConnected ? Theme.accentPeach : Theme.fgMuted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.weight: root.isConnected ? Font.Bold : Font.Normal
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (!root.isInstalled) {
                Quickshell.execDetached(["kitty", "--title", "Install Cloudflare WARP", "-e", Quickshell.env("HOME") + "/.config/hypr/scripts/install_warp.sh"]);
                return;
            }
            if (root.isConnected) {
                Quickshell.execDetached(["bash", "-c", "warp-cli disconnect && notify-send 'Cloudflare WARP' 'Disconnected'"]);
            } else {
                Quickshell.execDetached(["bash", "-c", "warp-cli connect && notify-send 'Cloudflare WARP' 'Connecting...'"]);
            }
            statusProc.running = false;
            statusProc.running = true;
        }
    }
}
