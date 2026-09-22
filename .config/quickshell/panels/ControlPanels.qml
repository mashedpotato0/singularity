import QtQuick
import Quickshell
import Quickshell.Wayland
import "../theme"
import "../services"

Item {
    id: root

    property var targetScreen: null

    readonly property int topMarginVal: Theme.barHeight + 6

    // 1. Outside-click dismissal backdrop: covers the full screen behind panels
    PanelWindow {
        id: backdrop
        screen: root.targetScreen

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs-backdrop"
        visible: PanelManager.isAnyOpen

        MouseArea {
            anchors.fill: parent
            hoverEnabled: false
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: PanelManager.close()
        }
    }

    // 2. Media Control Panel (Centered below top bar)
    PanelWindow {
        id: mediaWin
        screen: root.targetScreen

        anchors {
            top: true
        }

        margins {
            top: root.topMarginVal
        }

        implicitWidth: 360
        implicitHeight: mediaCard.implicitHeight
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs-media-panel"
        visible: PanelManager.currentPanel === "media"

        MediaControlPanel {
            id: mediaCard
            anchors.fill: parent
        }
    }

    // 3. Windows Control Panel / Task Switcher (Left side below active window)
    PanelWindow {
        id: windowsWin
        screen: root.targetScreen

        anchors {
            top: true
            left: true
        }

        margins {
            top: root.topMarginVal
            left: 160
        }

        implicitWidth: 380
        implicitHeight: winCard.implicitHeight
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs-windows-panel"
        visible: PanelManager.currentPanel === "windows"

        WindowsControlPanel {
            id: winCard
            anchors.fill: parent
        }
    }

    // 4. Audio Control Panel (Right side below audio applet)
    PanelWindow {
        id: audioWin
        screen: root.targetScreen

        anchors {
            top: true
            right: true
        }

        margins {
            top: root.topMarginVal
            right: 140
        }

        implicitWidth: 320
        implicitHeight: audioCard.implicitHeight
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs-audio-panel"
        visible: PanelManager.currentPanel === "audio"

        AudioControlPanel {
            id: audioCard
            anchors.fill: parent
        }
    }

    // 4b. Brightness Control Panel
    PanelWindow {
        id: brightnessWin
        screen: root.targetScreen

        anchors {
            top: true
            right: true
        }

        margins {
            top: root.topMarginVal
            right: 180
        }

        implicitWidth: 300
        implicitHeight: brightCard.implicitHeight
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs-brightness-panel"
        visible: PanelManager.currentPanel === "brightness"

        BrightnessPanel {
            id: brightCard
            anchors.fill: parent
        }
    }

    // 5. Wi-Fi & Networks Panel
    PanelWindow {
        id: wifiWin
        screen: root.targetScreen

        anchors {
            top: true
            right: true
        }

        margins {
            top: root.topMarginVal
            right: 210
        }

        implicitWidth: 340
        implicitHeight: wifiCard.implicitHeight
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs-wifi-panel"
        visible: PanelManager.currentPanel === "wifi"

        WifiPanel {
            id: wifiCard
            anchors.fill: parent
        }
    }

    // 6. Bluetooth & Blueman Panel
    PanelWindow {
        id: bluetoothWin
        screen: root.targetScreen

        anchors {
            top: true
            right: true
        }

        margins {
            top: root.topMarginVal
            right: 270
        }

        implicitWidth: 320
        implicitHeight: btCard.implicitHeight
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs-bluetooth-panel"
        visible: PanelManager.currentPanel === "bluetooth"

        BluetoothPanel {
            id: btCard
            anchors.fill: parent
        }
    }

    // 7. Calendar Panel (Right side below clock)
    PanelWindow {
        id: calendarWin
        screen: root.targetScreen

        anchors {
            top: true
            right: true
        }

        margins {
            top: root.topMarginVal
            right: 10
        }

        implicitWidth: 320
        implicitHeight: calCard.implicitHeight
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs-calendar-panel"
        visible: PanelManager.currentPanel === "calendar"

        CalendarPanel {
            id: calCard
            anchors.fill: parent
        }
    }

    // 8. Notification Center & Quick Settings (Right side below bell)
    PanelWindow {
        id: notifWin
        screen: root.targetScreen

        anchors {
            top: true
            right: true
        }

        margins {
            top: root.topMarginVal
            right: 10
        }

        implicitWidth: 380
        implicitHeight: notifCard.implicitHeight
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs-notification-center"
        visible: PanelManager.currentPanel === "notifications"

        NotificationCenter {
            id: notifCard
            anchors.fill: parent
        }
    }

    // 9. Power & Session Menu (Left side below launcher)
    PanelWindow {
        id: powerWin
        screen: root.targetScreen

        anchors {
            top: true
            left: true
        }

        margins {
            top: root.topMarginVal
            left: 10
        }

        implicitWidth: 260
        implicitHeight: powerCard.implicitHeight
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs-power-panel"
        visible: PanelManager.currentPanel === "power"

        PowerMenuPanel {
            id: powerCard
            anchors.fill: parent
        }
    }
}
