import QtQuick
import QtQuick.Layouts
import "../theme"
import "../components"
import "../services"

GlassCard {
    id: root

    implicitWidth: 360
    implicitHeight: 240
    defaultBgColor: Theme.cardBgDark
    defaultBorderColor: Theme.borderHover
    radius: Theme.radiusCard

    Column {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        // Header: Player name and close button
        Item {
            width: parent.width
            height: 24

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                SvgIcon {
                    name: "music"
                    size: 14
                    color: Theme.accentMauve
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: MediaService.playerName.length > 0 ? MediaService.playerName : "Media Player"
                    color: Theme.accentMauve
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Bold
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            IconButton {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                iconName: "window-close"
                iconSize: 12
                implicitWidth: 22
                implicitHeight: 22
                onClicked: PanelManager.close()
            }
        }

        // Track Info with Album Art or Vinyl Placeholder
        Row {
            width: parent.width
            height: 70
            spacing: 14

            // Art
            Rectangle {
                width: 64
                height: 64
                radius: Theme.radiusMedium
                color: Theme.cardBgActive
                border.color: Theme.border
                border.width: 1
                clip: true

                Image {
                    id: albumArt
                    anchors.fill: parent
                    source: MediaService.trackArtUrl
                    fillMode: Image.PreserveAspectCrop
                    visible: status === Image.Ready
                }

                SvgIcon {
                    anchors.centerIn: parent
                    name: "music"
                    size: 28
                    color: Theme.accentMauve
                    visible: albumArt.status !== Image.Ready
                }
            }

            // Titles
            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 78
                spacing: 4

                Text {
                    width: parent.width
                    text: MediaService.trackTitle
                    color: Theme.fg
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMedium
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    text: MediaService.trackArtist.length > 0 ? MediaService.trackArtist : "Unknown Artist"
                    color: Theme.fgSubtle
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    elide: Text.ElideRight
                }

                Text {
                    visible: MediaService.trackAlbum.length > 0
                    width: parent.width
                    text: MediaService.trackAlbum
                    color: Theme.fgMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeTiny
                    elide: Text.ElideRight
                }
            }
        }

        // Progress bar and timestamps
        Column {
            width: parent.width
            spacing: 4

            CustomSlider {
                width: parent.width
                height: 14
                trackHeight: 4
                progressColor: Theme.accentMauve
                value: MediaService.progress
                onMoved: val => MediaService.seekTo(val)
            }

            Item {
                width: parent.width
                height: 14
                Text {
                    anchors.left: parent.left
                    text: MediaService.positionStr
                    color: Theme.fgMuted
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeTiny
                }
                Text {
                    anchors.right: parent.right
                    text: MediaService.lengthStr
                    color: Theme.fgMuted
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeTiny
                }
            }
        }

        // Playback Controls
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 16

            IconButton {
                iconName: "previous"
                iconSize: 16
                implicitWidth: 36
                implicitHeight: 36
                onClicked: MediaService.previous()
            }

            Rectangle {
                width: 42
                height: 42
                radius: 21
                color: Theme.accentMauve
                scale: playBtnArea.pressed ? 0.93 : 1.0
                Behavior on scale { NumberAnimation { duration: 100 } }

                SvgIcon {
                    anchors.centerIn: parent
                    name: MediaService.isPlaying ? "pause" : "play"
                    size: 18
                    color: Theme.fgInverse
                }

                MouseArea {
                    id: playBtnArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: MediaService.playPause()
                }
            }

            IconButton {
                iconName: "next"
                iconSize: 16
                implicitWidth: 36
                implicitHeight: 36
                onClicked: MediaService.next()
            }
        }
    }
}
