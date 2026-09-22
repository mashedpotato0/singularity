import QtQuick
import QtQuick.Layouts
import "../theme"
import "../components"
import "../services"

GlassCard {
    id: root

    implicitWidth: 300
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
                    name: "sun"
                    size: 16
                    color: Theme.accentYellow
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Display Brightness"
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
                implicitWidth: 22
                implicitHeight: 22
                onClicked: PanelManager.close()
            }
        }

        // Percentage readout
        Item {
            width: parent.width
            height: 20

            Text {
                anchors.left: parent.left
                text: "Backlight Level"
                color: Theme.fgSubtle
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
            }

            Text {
                anchors.right: parent.right
                text: Math.round(SystemInfoService.brightness * 100) + "%"
                color: Theme.accentYellow
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Bold
            }
        }

        // Brightness Slider Bar
        CustomSlider {
            width: parent.width
            height: 20
            trackHeight: 6
            value: SystemInfoService.brightness
            progressColor: Theme.accentYellow
            onMoved: val => SystemInfoService.setBrightness(val)
        }

        // Quick Preset Buttons
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8

            IconButton {
                text: "25%"
                implicitWidth: 54
                implicitHeight: 26
                onClicked: SystemInfoService.setBrightness(0.25)
            }

            IconButton {
                text: "50%"
                implicitWidth: 54
                implicitHeight: 26
                onClicked: SystemInfoService.setBrightness(0.50)
            }

            IconButton {
                text: "75%"
                implicitWidth: 54
                implicitHeight: 26
                onClicked: SystemInfoService.setBrightness(0.75)
            }

            IconButton {
                text: "100%"
                implicitWidth: 54
                implicitHeight: 26
                onClicked: SystemInfoService.setBrightness(1.00)
            }
        }
    }
}
