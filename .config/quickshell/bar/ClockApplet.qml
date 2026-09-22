import QtQuick
import Quickshell
import "../theme"
import "../components"
import "../services"

Rectangle {
    id: root

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    implicitWidth: contentRow.implicitWidth + 14
    implicitHeight: 28
    radius: Theme.radiusSmall
    color: mouseArea.containsMouse ? Theme.cardBgHover : "transparent"
    border.color: (PanelManager.currentPanel === "calendar") ? Theme.borderActive : (mouseArea.containsMouse ? Theme.borderHover : "transparent")
    border.width: 1

    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 6

        Text {
            id: timeText
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatTime(clock.date, "hh:mm")
            color: Theme.fg
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.Bold
        }

        Text {
            text: "•"
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.accentCyan
            font.pixelSize: Theme.fontSizeTiny
        }

        Text {
            id: dateText
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatDate(clock.date, "ddd, MMM d")
            color: Theme.fgSubtle
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.Normal
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: PanelManager.toggle("calendar")
    }
}
