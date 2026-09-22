import QtQuick
import QtQuick.Layouts
import "../theme"
import "../components"
import "../services"

GlassCard {
    id: root

    implicitWidth: 320
    implicitHeight: mainCol.height + 24
    padding: 12

    Column {
        id: mainCol
        anchors.centerIn: parent
        width: parent.width - 24
        spacing: 12

        // Header
        Item {
            width: parent.width
            height: 24

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                SvgIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: "bluetooth"
                    size: 16
                    color: Theme.accentSapphire
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Bluetooth & Blueman"
                    color: Theme.fg
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeRegular
                    font.weight: Font.Bold
                }
            }

            IconButton {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                iconName: "window-close"
                iconSize: 12
                implicitWidth: 24
                implicitHeight: 24
                onClicked: PanelManager.close()
            }
        }

        // Power Switch Card
        Rectangle {
            width: parent.width
            height: 48
            radius: Theme.radiusSmall
            color: Theme.cardBgDark
            border.color: Theme.border
            border.width: 1

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                SvgIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: BluetoothService.bluetoothIcon
                    size: 20
                    color: BluetoothService.enabled ? Theme.accentSapphire : Theme.fgMuted
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        text: BluetoothService.enabled ? "Bluetooth Radio Enabled" : "Bluetooth Disabled"
                        color: Theme.fg
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeRegular
                        font.weight: Font.Medium
                    }

                    Text {
                        text: BluetoothService.enabled ? "Discoverable and ready" : "Blocked via rfkill"
                        color: Theme.fgMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTiny
                    }
                }
            }

            IconButton {
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: BluetoothService.enabled ? "Turn Off" : "Turn On"
                implicitHeight: 26
                onClicked: BluetoothService.togglePower()
            }
        }

        // Blueman Tools Section
        Text {
            text: "BLUEMAN TOOLS"
            color: Theme.fgMuted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeTiny
            font.weight: Font.Bold
        }

        // Launch Blueman Manager Button
        Rectangle {
            width: parent.width
            height: 40
            radius: Theme.radiusSmall
            color: mgrMouse.containsMouse ? Theme.cardBgHover : Theme.cardBgDark
            border.color: mgrMouse.containsMouse ? Theme.borderHover : Theme.border
            border.width: 1

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                SvgIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: "bluetooth"
                    size: 16
                    color: Theme.accentSapphire
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 1

                    Text {
                        text: "Launch Blueman Manager"
                        color: Theme.fg
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Font.Medium
                    }

                    Text {
                        text: "Pair, connect, and manage audio devices"
                        color: Theme.fgMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                    }
                }
            }

            MouseArea {
                id: mgrMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    BluetoothService.openManager();
                    PanelManager.close();
                }
            }
        }

        // Launch Blueman Applet Button
        Rectangle {
            width: parent.width
            height: 40
            radius: Theme.radiusSmall
            color: appletMouse.containsMouse ? Theme.cardBgHover : Theme.cardBgDark
            border.color: appletMouse.containsMouse ? Theme.borderHover : Theme.border
            border.width: 1

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                SvgIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: "sliders"
                    size: 16
                    color: Theme.accentCyan
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 1

                    Text {
                        text: "Start Blueman Tray Daemon"
                        color: Theme.fg
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Font.Medium
                    }

                    Text {
                        text: "Shows icon in quickshell system tray"
                        color: Theme.fgMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                    }
                }
            }

            MouseArea {
                id: appletMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    BluetoothService.startApplet();
                    PanelManager.close();
                }
            }
        }
    }
}
