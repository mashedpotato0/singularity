import QtQuick
import "../theme"
import "../components"
import "../services"

GlassCard {
    id: root

    implicitWidth: 380
    implicitHeight: Math.min(480, contentCol.implicitHeight + 28)
    defaultBgColor: Theme.cardBgDark
    defaultBorderColor: Theme.borderHover
    radius: Theme.radiusCard

    Column {
        id: contentCol
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        // Header
        Item {
            width: parent.width
            height: 24

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                SvgIcon {
                    name: "grid"
                    size: 15
                    color: Theme.accentCyan
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Windows & Tasks"
                    color: Theme.fg
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMedium
                    font.weight: Font.Bold
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: 20
                    height: 18
                    radius: 9
                    color: Theme.cardBgActive
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        anchors.centerIn: parent
                        text: (HyprlandService.openWindows ? HyprlandService.openWindows.length : 0).toString()
                        color: Theme.accentCyan
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTiny
                        font.weight: Font.Bold
                    }
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

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.border
        }

        // Window list
        ListView {
            id: winList
            width: parent.width
            height: Math.min(320, count * 44)
            clip: true
            model: HyprlandService.openWindows || []
            spacing: 4

            delegate: Rectangle {
                id: winRow
                width: winList.width
                height: 40
                radius: Theme.radiusSmall
                color: modelData.activated ? Theme.cardBgActive : (rowMouse.containsMouse ? Theme.cardBgHover : "transparent")
                border.color: modelData.activated ? Theme.accentCyan : "transparent"
                border.width: 1

                readonly property string winClass: (modelData.windowClass || "").toLowerCase()
                readonly property string rowIcon: {
                    if (winClass.indexOf("kitty") !== -1 || winClass.indexOf("term") !== -1) return "terminal";
                    if (winClass.indexOf("brave") !== -1 || winClass.indexOf("browser") !== -1) return "globe";
                    if (winClass.indexOf("thunar") !== -1 || winClass.indexOf("nautilus") !== -1) return "folder";
                    if (winClass.indexOf("kate") !== -1 || winClass.indexOf("code") !== -1) return "code";
                    return "window";
                }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 8

                    SvgIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: winRow.rowIcon
                        size: 16
                        color: modelData.activated ? Theme.accentCyan : Theme.fg
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 96
                        spacing: 2

                        Text {
                            width: parent.width
                            text: modelData.title || "Window"
                            color: Theme.fg
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: modelData.activated ? Font.Bold : Font.Normal
                            elide: Text.ElideRight
                        }

                        Text {
                            text: modelData.windowClass || "Application"
                            color: Theme.fgMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeTiny
                        }
                    }

                    // Workspace tag
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 38
                        height: 18
                        radius: Theme.radiusSmall
                        color: Theme.cardBg
                        Text {
                            anchors.centerIn: parent
                            text: "WS " + (modelData.workspace || "1")
                            color: Theme.fgSubtle
                            font.family: Theme.fontMono
                            font.pixelSize: 9
                        }
                    }

                    // Close Window Button
                    IconButton {
                        anchors.verticalCenter: parent.verticalCenter
                        iconName: "window-close"
                        iconSize: 12
                        implicitWidth: 22
                        implicitHeight: 22
                        onClicked: HyprlandService.closeWindow(modelData.address)
                    }
                }

                MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton
                    onClicked: {
                        HyprlandService.focusWindow(modelData.address);
                        PanelManager.close();
                    }
                }
            }
        }

        // Empty state
        Item {
            visible: (HyprlandService.openWindows ? HyprlandService.openWindows.length : 0) === 0
            width: parent.width
            height: 60
            Text {
                anchors.centerIn: parent
                text: "No open windows"
                color: Theme.fgMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.border
        }

        // Footer info
        Item {
            width: parent.width
            height: 24

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "Click any window to focus"
                color: Theme.fgMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeTiny
            }

            IconButton {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                iconName: "folder"
                text: "Files"
                implicitHeight: 22
                onClicked: {
                    SystemInfoService.launchFileManager();
                    PanelManager.close();
                }
            }
        }
    }
}
