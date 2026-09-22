import QtQuick
import QtQuick.Layouts
import "../theme"
import "../components"
import "../services"

GlassCard {
    id: root

    implicitWidth: 340
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
                    name: "wifi"
                    size: 16
                    color: Theme.accentCyan
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Wi-Fi & Networks"
                    color: Theme.fg
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeRegular
                    font.weight: Font.Bold
                }
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                IconButton {
                    iconName: "refresh"
                    iconSize: 13
                    implicitWidth: 26
                    implicitHeight: 24
                    onClicked: NetworkService.scanNetworks()
                }

                IconButton {
                    iconName: "window-close"
                    iconSize: 12
                    implicitWidth: 24
                    implicitHeight: 24
                    onClicked: PanelManager.close()
                }
            }
        }

        // Active Connection / Power Switch Card
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
                    name: NetworkService.wifiIcon
                    size: 20
                    color: NetworkService.wifiEnabled ? Theme.accentGreen : Theme.fgMuted
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        text: NetworkService.wifiEnabled ? (NetworkService.isConnected ? NetworkService.activeSsid : "Disconnected") : "Wi-Fi Disabled"
                        color: Theme.fg
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeRegular
                        font.weight: Font.Medium
                    }

                    Text {
                        text: NetworkService.wifiEnabled ? (NetworkService.isConnected ? (NetworkService.activeType === "wifi" ? "Wireless Connection" : "Wired Ethernet") : "Select a network below") : "Radio turned off"
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
                text: NetworkService.wifiEnabled ? "Turn Off" : "Turn On"
                implicitHeight: 26
                onClicked: NetworkService.toggleWifi()
            }
        }

        // Available Networks Section
        Text {
            visible: NetworkService.wifiEnabled
            text: "AVAILABLE NETWORKS (" + NetworkService.wifiNetworks.length + ")"
            color: Theme.fgMuted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeTiny
            font.weight: Font.Bold
        }

        // Scanned Networks List
        Column {
            width: parent.width
            spacing: 4
            visible: NetworkService.wifiEnabled

            Repeater {
                model: NetworkService.wifiNetworks.slice(0, 7)

                Rectangle {
                    width: parent.width
                    height: 36
                    radius: Theme.radiusSmall
                    color: netMouse.containsMouse ? Theme.cardBgHover : (modelData.inUse ? Theme.cardBgActive : "transparent")
                    border.color: modelData.inUse ? Theme.accentCyan : (netMouse.containsMouse ? Theme.borderHover : "transparent")
                    border.width: 1

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        SvgIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            name: "wifi"
                            size: 14
                            color: modelData.inUse ? Theme.accentCyan : Theme.fgSubtle
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1

                            Text {
                                text: modelData.ssid
                                color: modelData.inUse ? Theme.accentCyan : Theme.fg
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: modelData.inUse ? Font.Bold : Font.Normal
                            }

                            Text {
                                text: (modelData.security || "Open") + " • " + modelData.signal + "% signal"
                                color: Theme.fgMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 9
                            }
                        }
                    }

                    IconButton {
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.inUse ? "Active" : "Connect"
                        implicitHeight: 22
                        onClicked: {
                            if (!modelData.inUse) {
                                // Launch nmtui or connect
                                SystemInfoService.launchTerminal("nmtui");
                                PanelManager.close();
                            }
                        }
                    }

                    MouseArea {
                        id: netMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton
                        onClicked: {
                            if (!modelData.inUse) {
                                SystemInfoService.launchTerminal("nmtui");
                                PanelManager.close();
                            }
                        }
                    }
                }
            }
        }

        // Footer: Network Manager tool button
        Rectangle {
            width: parent.width
            height: 32
            radius: Theme.radiusSmall
            color: Theme.cardBgDark
            border.color: Theme.border
            border.width: 1

            Row {
                anchors.centerIn: parent
                spacing: 6

                SvgIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: "sliders"
                    size: 13
                    color: Theme.accentCyan
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Advanced Network Settings (nmtui)"
                    color: Theme.fg
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    SystemInfoService.launchTerminal("nmtui");
                    PanelManager.close();
                }
            }
        }
    }
}
