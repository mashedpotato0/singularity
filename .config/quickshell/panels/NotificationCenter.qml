import QtQuick
import QtQuick.Layouts
import "../theme"
import "../components"
import "../services"

GlassCard {
    id: root

    implicitWidth: 380
    implicitHeight: Math.min(620, contentCol.implicitHeight + 28)
    defaultBgColor: Theme.cardBgDark
    defaultBorderColor: Theme.borderHover
    radius: Theme.radiusCard

    property bool showSleepMenu: false

    Column {
        id: contentCol
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        // Header: Title and Close
        Item {
            width: parent.width
            height: 24

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                SvgIcon {
                    name: "sliders"
                    size: 15
                    color: Theme.accentCyan
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Control Center"
                    color: Theme.fg
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMedium
                    font.weight: Font.Bold
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            IconButton {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                iconName: "window-close"
                iconSize: 12
                implicitWidth: 22
                implicitHeight: 22
                onClicked: PanelManager.close()
            }
        }

        // Quick Settings Toggles Grid
        Grid {
            width: parent.width
            columns: 4
            rowSpacing: 6
            columnSpacing: 6

            IconButton {
                width: (parent.width - 18) / 4
                height: 48
                iconName: SystemInfoService.networkIcon
                text: SystemInfoService.networkType === "wifi" ? "Wi-Fi" : "Ethernet"
                active: SystemInfoService.networkConnected
                onClicked: SystemInfoService.launchTerminal()
            }

            IconButton {
                width: (parent.width - 18) / 4
                height: 48
                iconName: AudioService.volumeIcon
                text: AudioService.muted ? "Muted" : "Sound"
                active: !AudioService.muted
                onClicked: AudioService.toggleMute()
            }

            IconButton {
                width: (parent.width - 18) / 4
                height: 48
                iconName: NotificationService.dndEnabled ? "bell-off" : "bell"
                text: "DND"
                active: NotificationService.dndEnabled
                onClicked: NotificationService.toggleDnd()
            }

            IconButton {
                width: (parent.width - 18) / 4
                height: 48
                iconName: Theme.isDark ? "moon" : "sun"
                text: Theme.isDark ? "Dark" : "Light"
                active: Theme.isDark
                onClicked: Theme.toggleDarkMode()
            }

            IconButton {
                width: (parent.width - 18) / 4
                height: 48
                iconName: "camera"
                text: "Capture"
                onClicked: {
                    HyprlandService.execApp("command -v grim >/dev/null 2>&1 && grim ~/screenshot-$(date +%s).png || true");
                    PanelManager.close();
                }
            }

            IconButton {
                width: (parent.width - 18) / 4
                height: 48
                iconName: "cloud"
                text: WarpService.isConnected ? "WARP On" : "WARP Off"
                active: WarpService.isConnected
                onClicked: WarpService.toggle()
            }

            IconButton {
                width: (parent.width - 18) / 4
                height: 48
                iconName: "moon"
                text: SystemInfoService.sleepTimerActive ? SystemInfoService.sleepTimerLabel : "Sleep"
                active: SystemInfoService.sleepTimerActive
                onClicked: SystemInfoService.cycleSleepTimer()
                onRightClicked: {
                    root.showSleepMenu = !root.showSleepMenu;
                }
            }

            IconButton {
                width: (parent.width - 18) / 4
                height: 48
                iconName: "lock"
                text: "Lock"
                onClicked: {
                    SystemInfoService.lockSession();
                    PanelManager.close();
                }
            }
        }

        // Expandable Sleep Timer Selector (shown only on right-clicking Sleep)
        Rectangle {
            id: sleepMenu
            visible: root.showSleepMenu
            width: parent.width
            height: root.showSleepMenu ? 38 : 0
            radius: Theme.radiusSmall
            color: Theme.cardBgActive
            border.color: Theme.accentCyan
            border.width: 1
            clip: true

            Behavior on height { NumberAnimation { duration: Theme.animFast } }

            Item {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10

                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6

                    SvgIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: "moon"
                        size: 14
                        color: Theme.accentCyan
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Idle sleep:"
                        color: Theme.fg
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Font.Medium
                    }
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    Repeater {
                        model: [5, 10, 15, 30, 45, 60, 0]
                        Rectangle {
                            width: 28
                            height: 24
                            radius: 4
                            color: (SystemInfoService.sleepTimerMinutes === modelData) ? Theme.accentCyan : (chipMouse.containsMouse ? Theme.cardBgHover : Theme.cardBg)
                            border.color: (SystemInfoService.sleepTimerMinutes === modelData) ? Theme.accentCyan : Theme.border
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: modelData === 0 ? "Off" : (modelData >= 60 ? (modelData / 60 + "h") : (modelData + "m"))
                                color: (SystemInfoService.sleepTimerMinutes === modelData) ? Theme.fgInverse : Theme.fg
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                font.weight: Font.Bold
                            }

                            MouseArea {
                                id: chipMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    SystemInfoService.setSleepTimer(modelData);
                                    root.showSleepMenu = false;
                                }
                            }
                        }
                    }
                }
            }
        }

        // Sliders Section (Volume & Brightness)
        Column {
            width: parent.width
            spacing: 8

            // Volume Slider
            Row {
                width: parent.width
                spacing: 8

                SvgIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: AudioService.volumeIcon
                    size: 15
                    color: Theme.accentCyan
                }

                CustomSlider {
                    width: parent.width - 66
                    height: 18
                    value: AudioService.volume
                    progressColor: AudioService.muted ? Theme.accentRed : Theme.accentCyan
                    onMoved: val => AudioService.setVolume(val)
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 32
                    horizontalAlignment: Text.AlignRight
                    text: AudioService.volumePercent + "%"
                    color: Theme.fgSubtle
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeSmall
                }
            }

            // Brightness Slider
            Row {
                width: parent.width
                spacing: 8

                SvgIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: "sun"
                    size: 15
                    color: Theme.accentYellow
                }

                CustomSlider {
                    width: parent.width - 66
                    height: 18
                    value: SystemInfoService.brightness
                    progressColor: Theme.accentYellow
                    onMoved: val => SystemInfoService.setBrightness(val)
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 32
                    horizontalAlignment: Text.AlignRight
                    text: Math.round(SystemInfoService.brightness * 100) + "%"
                    color: Theme.fgSubtle
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeSmall
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.border
        }

        // Notifications Header
        Item {
            width: parent.width
            height: 24

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Text {
                    text: "Notifications"
                    color: Theme.fg
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeRegular
                    font.weight: Font.Bold
                }

                Rectangle {
                    visible: NotificationService.unreadCount > 0
                    width: Math.max(16, notifCount.contentWidth + 6)
                    height: 16
                    radius: 8
                    color: Theme.accentRed
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        id: notifCount
                        anchors.centerIn: parent
                        text: NotificationService.unreadCount.toString()
                        color: Theme.fgInverse
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                        font.weight: Font.Bold
                    }
                }
            }

            IconButton {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: "Clear All"
                iconName: "trash"
                iconSize: 12
                implicitHeight: 22
                visible: NotificationService.unreadCount > 0
                onClicked: NotificationService.clearAll()
            }
        }

        // Notifications Scrollable List
        ListView {
            id: notifList
            width: parent.width
            height: Math.min(220, count > 0 ? (count * 64) : 70)
            clip: true
            model: NotificationService.notificationList
            spacing: 6

            delegate: Rectangle {
                id: notifCard
                width: notifList.width
                height: 58
                radius: Theme.radiusSmall
                color: Theme.cardBgActive
                border.color: Theme.border
                border.width: 1

                // Urgency bar
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 3
                    radius: 1
                    color: (modelData.urgency === 2) ? Theme.accentRed : Theme.accentCyan
                }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 8
                    spacing: 8

                    SvgIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: "bell"
                        size: 16
                        color: Theme.accentCyan
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 56
                        spacing: 2

                        Item {
                            width: parent.width
                            height: 14
                            Text {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.appName || "Notification"
                                color: Theme.accentCyan
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeTiny
                                font.weight: Font.Bold
                            }
                            Text {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.timeStr || ""
                                color: Theme.fgMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeTiny
                            }
                        }

                        Text {
                            width: parent.width
                            text: modelData.summary || ""
                            color: Theme.fg
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width
                            text: modelData.body || ""
                            color: Theme.fgSubtle
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeTiny
                            elide: Text.ElideRight
                        }
                    }

                    IconButton {
                        anchors.verticalCenter: parent.verticalCenter
                        iconName: "window-close"
                        iconSize: 12
                        implicitWidth: 20
                        implicitHeight: 20
                        onClicked: NotificationService.dismissNotification(modelData)
                    }
                }
            }
        }

        // Empty state
        Item {
            visible: NotificationService.unreadCount === 0
            width: parent.width
            height: 60

            Column {
                anchors.centerIn: parent
                spacing: 4
                SvgIcon {
                    anchors.horizontalCenter: parent.horizontalCenter
                    name: "bell"
                    size: 20
                    color: Theme.fgMuted
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "No notifications"
                    color: Theme.fgMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.border
        }

        // Session & Power Row
        Row {
            width: parent.width
            height: 32
            spacing: 8

            IconButton {
                width: (parent.width - 24) / 4
                height: 30
                iconName: "lock"
                text: "Lock"
                onClicked: {
                    SystemInfoService.lockSession();
                    PanelManager.close();
                }
            }

            IconButton {
                width: (parent.width - 24) / 4
                height: 30
                iconName: "moon"
                text: SystemInfoService.sleepTimerActive ? SystemInfoService.sleepTimerLabel : "Sleep"
                active: SystemInfoService.sleepTimerActive
                onClicked: SystemInfoService.cycleSleepTimer()
                onRightClicked: {
                    root.showSleepMenu = !root.showSleepMenu;
                }
            }

            IconButton {
                width: (parent.width - 24) / 4
                height: 30
                iconName: "reboot"
                text: "Reboot"
                onClicked: {
                    SystemInfoService.reboot();
                    PanelManager.close();
                }
            }

            IconButton {
                width: (parent.width - 24) / 4
                height: 30
                iconName: "power"
                text: "Power"
                iconColor: Theme.accentRed
                onClicked: {
                    SystemInfoService.poweroff();
                    PanelManager.close();
                }
            }
        }
    }
}
