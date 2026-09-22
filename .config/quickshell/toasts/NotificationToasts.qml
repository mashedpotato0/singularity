import QtQuick
import Quickshell
import Quickshell.Wayland
import "../theme"
import "../components"
import "../services"

PanelWindow {
    id: root

    property var targetScreen: null
    screen: targetScreen

    anchors {
        top: true
        right: true
    }

    margins {
        top: Theme.barHeight + Theme.barMarginTop + 10
        right: Theme.barMarginSide + 4
    }

    implicitWidth: 340
    implicitHeight: Math.min(400, toastCol.implicitHeight)
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-toasts"
    visible: NotificationService.toastList.length > 0 && !PanelManager.isAnyOpen

    Column {
        id: toastCol
        anchors.top: parent.top
        anchors.right: parent.right
        width: 340
        spacing: 8

        Repeater {
            model: NotificationService.toastList

            GlassCard {
                id: toastCard
                width: 340
                implicitHeight: 70
                defaultBgColor: Theme.cardBgDark
                defaultBorderColor: Theme.accentCyan
                radius: Theme.radiusMedium

                Timer {
                    interval: 6000
                    running: true
                    repeat: false
                    onTriggered: NotificationService.removeToastById(modelData.id)
                }

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
                    anchors.leftMargin: 12
                    anchors.rightMargin: 10
                    spacing: 10

                    SvgIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: "bell"
                        size: 20
                        color: Theme.accentCyan
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 66
                        spacing: 2

                        Row {
                            width: parent.width
                            Text {
                                text: modelData.appName || "Notification"
                                color: Theme.accentCyan
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeTiny
                                font.weight: Font.Bold
                            }
                            Item { width: 8; height: 1 }
                            Text {
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
                            font.weight: Font.Bold
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
                        implicitWidth: 22
                        implicitHeight: 22
                        onClicked: NotificationService.removeToastById(modelData.id)
                    }
                }
            }
        }
    }
}
