import QtQuick
import "../theme"

Rectangle {
    id: root

    property string iconName: ""
    property int iconSize: 16
    property color iconColor: active ? Theme.accentCyan : (hovered ? Theme.accent : Theme.fg)
    property bool active: false
    property string text: ""
    property string tooltip: ""
    property int badgeCount: 0
    property color badgeColor: Theme.accentRed

    signal clicked()
    signal rightClicked()

    readonly property bool hovered: mouseArea.containsMouse
    readonly property bool pressed: mouseArea.pressed

    implicitWidth: contentRow.implicitWidth + 14
    implicitHeight: 28
    radius: Theme.radiusSmall
    color: active ? Theme.cardBgActive : (hovered ? Theme.cardBgHover : "transparent")
    border.color: active ? Theme.borderActive : (hovered ? Theme.borderHover : "transparent")
    border.width: 1

    scale: pressed ? 0.96 : 1.0

    Behavior on color { ColorAnimation { duration: Theme.animFast } }
    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
    Behavior on scale { NumberAnimation { duration: 100 } }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 6

        SvgIcon {
            id: icon
            anchors.verticalCenter: parent.verticalCenter
            name: root.iconName
            size: root.iconSize
            color: root.iconColor
        }

        Text {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            visible: root.text.length > 0
            text: root.text
            color: root.iconColor
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.DemiBold
        }
    }

    // Badge for notifications or count
    Rectangle {
        id: badge
        visible: root.badgeCount > 0
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: -2
        width: Math.max(14, badgeText.contentWidth + 6)
        height: 14
        radius: 7
        color: root.badgeColor

        Text {
            id: badgeText
            anchors.centerIn: parent
            text: root.badgeCount > 99 ? "99+" : root.badgeCount.toString()
            color: Theme.fgInverse
            font.family: Theme.fontFamily
            font.pixelSize: 9
            font.weight: Font.Bold
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                root.rightClicked();
            } else {
                root.clicked();
            }
        }
    }
}
