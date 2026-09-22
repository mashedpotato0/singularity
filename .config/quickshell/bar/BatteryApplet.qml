import QtQuick
import "../theme"
import "../components"
import "../services"

Rectangle {
    id: root

    visible: SystemInfoService.hasBattery

    readonly property color batColor: {
        if (SystemInfoService.isCharging) return Theme.accentGreen;
        if (SystemInfoService.batteryPercentage <= 15) return Theme.accentRed;
        if (SystemInfoService.batteryPercentage <= 30) return Theme.accentYellow;
        return Theme.accentGreen;
    }

    implicitWidth: contentRow.implicitWidth + 12
    implicitHeight: 28
    radius: Theme.radiusSmall
    color: mouseArea.containsMouse ? Theme.cardBgHover : "transparent"
    border.color: mouseArea.containsMouse ? Theme.borderHover : "transparent"
    border.width: 1

    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 5

        SvgIcon {
            anchors.verticalCenter: parent.verticalCenter
            name: SystemInfoService.batteryIcon
            size: 20
            color: root.batColor
        }

        Text {
            id: batText
            anchors.verticalCenter: parent.verticalCenter
            text: SystemInfoService.batteryPercentage + "%"
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
        cursorShape: Qt.PointingHandCursor
        onClicked: PanelManager.toggle("notifications")
    }
}
