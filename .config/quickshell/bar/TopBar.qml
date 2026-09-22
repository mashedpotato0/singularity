import QtQuick
import "../theme"
import "../components"
import "../services"

Rectangle {
    id: root

    implicitHeight: Theme.barHeight
    radius: 0
    color: Theme.bgAlpha

    // Bottom border separator
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: Theme.border
    }

    // --- Left End / Left Background Scroll: Adjust Brightness ---
    MouseArea {
        id: leftScrollZone
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width / 2
        z: -1
        hoverEnabled: false
        scrollGestureEnabled: true

        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0) {
                SystemInfoService.increaseBrightness(0.05);
            } else if (wheel.angleDelta.y < 0) {
                SystemInfoService.decreaseBrightness(0.05);
            }
        }
    }

    // Far Left Edge dedicated handle (Fitts's Law on the left screen edge)
    MouseArea {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 12
        z: 10
        hoverEnabled: false
        scrollGestureEnabled: true

        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0) {
                SystemInfoService.increaseBrightness(0.05);
            } else if (wheel.angleDelta.y < 0) {
                SystemInfoService.decreaseBrightness(0.05);
            }
        }
    }

    // --- Right End / Right Background Scroll: Adjust Volume ---
    MouseArea {
        id: rightScrollZone
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width / 2
        z: -1
        hoverEnabled: false
        scrollGestureEnabled: true

        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0) {
                AudioService.increaseVolume(0.05);
            } else if (wheel.angleDelta.y < 0) {
                AudioService.decreaseVolume(0.05);
            }
        }
    }

    // Far Right Edge dedicated handle (Fitts's Law on the right screen edge)
    MouseArea {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 12
        z: 10
        hoverEnabled: false
        scrollGestureEnabled: true

        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0) {
                AudioService.increaseVolume(0.05);
            } else if (wheel.angleDelta.y < 0) {
                AudioService.decreaseVolume(0.05);
            }
        }
    }

    // Left container: Launcher + Workspaces + App Tray (Active Open Apps)
    Row {
        id: leftRow
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        LauncherApplet {}

        Rectangle {
            width: 1
            height: 18
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.border
        }

        WorkspacesApplet {}

        Rectangle {
            width: 1
            height: 18
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.border
        }

        ActiveWindowApplet {}
    }

    // Center container: Media Player Pill
    Row {
        id: centerRow
        anchors.centerIn: parent
        MediaBarApplet {}
    }

    // Right container: System Tray + Bluetooth + Wi-Fi + Audio + Brightness + Battery + Notifications + Clock
    Row {
        id: rightRow
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        SystemTrayApplet {}

        // vpn
        VpnApplet {}

        // Wi-Fi
        WifiApplet {}

        // Audio
        AudioApplet {}

        // Brightness
        BrightnessApplet {}

        // Battery
        BatteryApplet {}

        // Notifications
        NotificationApplet {}

        Rectangle {
            width: 1
            height: 18
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.border
        }

        // Clock & Calendar
        ClockApplet {}
    }
}
