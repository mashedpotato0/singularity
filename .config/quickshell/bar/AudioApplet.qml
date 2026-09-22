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
    border.color: (PanelManager.currentPanel === "audio") ? Theme.borderActive : (mouseArea.containsMouse ? Theme.borderHover : "transparent")
    border.width: 1

    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 6

        SvgIcon {
            anchors.verticalCenter: parent.verticalCenter
            name: AudioService.volumeIcon
            size: 20
            color: AudioService.muted ? Theme.accentRed : Theme.accentCyan
        }

        Text {
            id: volText
            anchors.verticalCenter: parent.verticalCenter
            text: AudioService.muted ? "MUTE" : (AudioService.volumePercent + "%")
            color: AudioService.muted ? Theme.accentRed : Theme.fg
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.Medium
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor

        onClicked: mouse => {
            if (mouse.button === Qt.MiddleButton) {
                AudioService.toggleMute();
            } else {
                PanelManager.toggle("audio");
            }
        }

        onWheel: wheel => {
            if (wheel.angleDelta.y > 0) {
                AudioService.increaseVolume(0.05);
            } else if (wheel.angleDelta.y < 0) {
                AudioService.decreaseVolume(0.05);
            }
        }
    }
}
