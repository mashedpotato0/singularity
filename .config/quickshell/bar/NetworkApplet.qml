import QtQuick
import "../theme"
import "../components"
import "../services"

Rectangle {
    id: root

    implicitWidth: 30
    implicitHeight: 28
    radius: Theme.radiusSmall
    color: mouseArea.containsMouse ? Theme.cardBgHover : "transparent"
    border.color: mouseArea.containsMouse ? Theme.borderHover : "transparent"
    border.width: 1

    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    SvgIcon {
        anchors.centerIn: parent
        name: SystemInfoService.networkIcon
        size: 15
        color: SystemInfoService.networkConnected ? Theme.accentSapphire : Theme.accentRed
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: PanelManager.toggle("notifications")
    }
}
