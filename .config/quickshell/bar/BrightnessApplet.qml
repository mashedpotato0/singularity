import QtQuick
import "../theme"
import "../components"
import "../services"

Rectangle {
    id: root

    implicitWidth: contentRow.implicitWidth + 14
    implicitHeight: 28
    radius: Theme.radiusSmall
    color: mouseArea.containsMouse ? Theme.cardBgHover : "transparent"
    border.color: (PanelManager.currentPanel === "brightness") ? Theme.borderActive : (mouseArea.containsMouse ? Theme.borderHover : "transparent")
    border.width: 1

    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 6

        SvgIcon {
            anchors.verticalCenter: parent.verticalCenter
            name: SystemInfoService.brightnessIcon
            size: 20
            color: Theme.accentYellow
        }

        Text {
            id: brightText
            anchors.verticalCenter: parent.verticalCenter
            text: Math.round(SystemInfoService.brightness * 100) + "%"
            color: Theme.fg
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.Medium
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            PanelManager.toggle("brightness");
        }

        onWheel: wheel => {
            if (wheel.angleDelta.y > 0) {
                SystemInfoService.increaseBrightness(0.05);
            } else if (wheel.angleDelta.y < 0) {
                SystemInfoService.decreaseBrightness(0.05);
            }
        }
    }
}
