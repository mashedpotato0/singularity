import QtQuick
import "../theme"
import "../components"
import "../services"

Rectangle {
    id: root

    implicitWidth: 34
    implicitHeight: 28
    radius: Theme.radiusSmall
    color: mouseArea.containsMouse ? Theme.cardBgHover : "transparent"
    border.color: mouseArea.containsMouse ? Theme.borderHover : "transparent"
    border.width: 1

    scale: mouseArea.pressed ? 0.94 : 1.0
    Behavior on scale { NumberAnimation { duration: 100 } }
    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    SvgIcon {
        anchors.centerIn: parent
        name: "hyprland"
        size: 18
        color: mouseArea.containsMouse ? Theme.accentCyan : Theme.accent
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                PanelManager.toggle("power");
            } else {
                SystemInfoService.launchMenu();
            }
        }
    }
}
