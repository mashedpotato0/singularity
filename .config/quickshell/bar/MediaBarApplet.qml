import QtQuick
import "../theme"
import "../components"
import "../services"

Rectangle {
    id: root

    readonly property bool hasMedia: MediaService.hasPlayer
    readonly property bool isPlaying: MediaService.isPlaying
    readonly property string labelText: {
        if (!hasMedia) return "Media";
        let text = MediaService.trackTitle;
        if (MediaService.trackArtist.length > 0) {
            text += " • " + MediaService.trackArtist;
        }
        return text;
    }

    implicitWidth: Math.min(280, contentRow.implicitWidth + 16)
    implicitHeight: 28
    radius: Theme.radiusSmall
    color: mouseArea.containsMouse ? Theme.cardBgHover : (isPlaying ? Theme.cardBgActive : Theme.cardBg)
    border.color: (PanelManager.currentPanel === "media") ? Theme.accentMauve : (mouseArea.containsMouse ? Theme.borderHover : "transparent")
    border.width: 1

    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 6

        SvgIcon {
            anchors.verticalCenter: parent.verticalCenter
            name: "music"
            size: 14
            color: isPlaying ? Theme.accentMauve : Theme.fgMuted
        }

        Text {
            id: txt
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(180, contentWidth)
            elide: Text.ElideRight
            text: root.labelText
            color: isPlaying ? Theme.fg : Theme.fgSubtle
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.weight: isPlaying ? Font.Medium : Font.Normal
        }

        // Inline mini play/pause button
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 18
            height: 18
            radius: 9
            color: playMouse.containsMouse ? Theme.cardBgActive : "transparent"

            SvgIcon {
                anchors.centerIn: parent
                name: isPlaying ? "pause" : "play"
                size: 10
                color: Theme.accentMauve
            }

            MouseArea {
                id: playMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: MediaService.playPause()
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        // Give priority to the play button inside
        onClicked: mouse => {
            let playBtnRect = Qt.rect(contentRow.x + 200, 0, 30, 28);
            PanelManager.toggle("media");
        }
    }
}
