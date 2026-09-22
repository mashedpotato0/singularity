pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// warp vpn service
Item {
    id: root

    property bool isConnected: false
    property bool isInstalled: false

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

    function toggle() {
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
