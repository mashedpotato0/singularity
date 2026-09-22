import QtQuick
import "../theme"
import "../components"
import "../services"

Rectangle {
    id: root

    readonly property bool isOpen: PanelManager.currentPanel === "notifications"
    readonly property bool isHovered: mouseArea.containsMouse

    implicitWidth: 30
    implicitHeight: 28
    radius: Theme.radiusSmall
    color: isOpen ? Theme.cardBgActive : (isHovered ? Theme.cardBgHover : "transparent")
    border.color: isOpen ? Theme.borderActive : (isHovered ? Theme.borderHover : "transparent")
    border.width: 1

    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    Item {
        id: iconContainer
        width: 15
        height: 15
        anchors.centerIn: parent

        SvgIcon {
            anchors.fill: parent
            name: NotificationService.dndEnabled ? "bell-off" : "bell"
            size: 15
            color: isOpen ? Theme.accentCyan : (NotificationService.unreadCount > 0 ? Theme.accentRed : Theme.accentSapphire)
        }

        // Unread notification dot
        Rectangle {
            id: dot
            visible: NotificationService.unreadCount > 0
            anchors.right: parent.right
            anchors.rightMargin: -2
            anchors.top: parent.top
            anchors.topMargin: -2
            width: 6
            height: 6
            radius: 3
            color: Theme.accentRed
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
