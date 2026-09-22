import QtQuick
import "../theme"

Rectangle {
    id: root

    property bool active: false
    property bool hoverable: false
    property bool hovered: hoverable && mouseArea.containsMouse
    property color activeBorderColor: Theme.accentCyan
    property color defaultBorderColor: Theme.border
    property color activeBgColor: Theme.cardBgActive
    property color hoverBgColor: Theme.cardBgHover
    property color defaultBgColor: Theme.cardBg
    property int padding: 0

    color: active ? activeBgColor : (hovered ? hoverBgColor : defaultBgColor)
    border.color: active ? activeBorderColor : (hovered ? Theme.borderHover : defaultBorderColor)
    border.width: 1
    radius: Theme.radiusMedium

    Behavior on color {
        ColorAnimation { duration: Theme.animFast }
    }
    Behavior on border.color {
        ColorAnimation { duration: Theme.animFast }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.hoverable
        hoverEnabled: root.hoverable
        acceptedButtons: Qt.NoButton
    }
}
