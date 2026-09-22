import QtQuick
import Quickshell
import "../theme"
import "../components"
import "../services"

GlassCard {
    id: root

    implicitWidth: 320
    implicitHeight: 330
    defaultBgColor: Theme.cardBgDark
    defaultBorderColor: Theme.borderHover
    radius: Theme.radiusCard

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Header: Big Time Display
        Item {
            width: parent.width
            height: 48

            Column {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    text: Qt.formatTime(clock.date, "hh:mm:ss AP")
                    color: Theme.fg
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.Bold
                }

                Text {
                    text: Qt.formatDate(clock.date, "dddd, MMMM d, yyyy")
                    color: Theme.accentCyan
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.DemiBold
                }
            }

            IconButton {
                anchors.right: parent.right
                anchors.top: parent.top
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

        // Mini calendar month days grid
        Column {
            width: parent.width
            spacing: 8

            // Days of week header
            Row {
                width: parent.width
                spacing: (parent.width - (7 * 32)) / 6

                Repeater {
                    model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                    Text {
                        width: 32
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData
                        color: Theme.fgMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTiny
                        font.weight: Font.Bold
                    }
                }
            }

            // Grid of days
            Grid {
                id: daysGrid
                columns: 7
                rowSpacing: 4
                columnSpacing: (parent.width - (7 * 32)) / 6

                readonly property var currentDate: clock.date
                readonly property int currentDay: currentDate.getDate()
                readonly property int currentMonth: currentDate.getMonth()
                readonly property int currentYear: currentDate.getFullYear()

                // Calculate first day of month and days in month
                readonly property int firstDayOfWeek: new Date(currentYear, currentMonth, 1).getDay()
                readonly property int daysInMonth: new Date(currentYear, currentMonth + 1, 0).getDate()

                Repeater {
                    model: 35 // 5 weeks display

                    Rectangle {
                        readonly property int dayNum: index - daysGrid.firstDayOfWeek + 1
                        readonly property bool isCurrentMonth: dayNum >= 1 && dayNum <= daysGrid.daysInMonth
                        readonly property bool isToday: isCurrentMonth && dayNum === daysGrid.currentDay

                        width: 32
                        height: 26
                        radius: Theme.radiusSmall
                        color: isToday ? Theme.accentCyan : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: isCurrentMonth ? dayNum.toString() : ""
                            color: isToday ? Theme.fgInverse : (isCurrentMonth ? Theme.fg : "transparent")
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: isToday ? Font.Bold : Font.Normal
                        }
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.border
        }

        // System status badges
        Row {
            width: parent.width
            spacing: 8

            Rectangle {
                width: (parent.width - 8) / 2
                height: 28
                radius: Theme.radiusSmall
                color: Theme.cardBgActive

                Row {
                    anchors.centerIn: parent
                    spacing: 6
                    SvgIcon {
                        name: SystemInfoService.batteryIcon
                        size: 13
                        color: SystemInfoService.isCharging ? Theme.accentGreen : (SystemInfoService.batteryPercentage <= 15 ? Theme.accentRed : (SystemInfoService.batteryPercentage <= 30 ? Theme.accentYellow : Theme.accentGreen))
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Battery: " + SystemInfoService.batteryPercentage + "%"
                        color: Theme.fg
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTiny
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            Rectangle {
                width: (parent.width - 8) / 2
                height: 28
                radius: Theme.radiusSmall
                color: Theme.cardBgActive

                Row {
                    anchors.centerIn: parent
                    spacing: 6
                    SvgIcon {
                        name: SystemInfoService.networkIcon
                        size: 13
                        color: Theme.accentSapphire
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: SystemInfoService.networkConnected ? "Online" : "Offline"
                        color: Theme.fg
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTiny
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}
