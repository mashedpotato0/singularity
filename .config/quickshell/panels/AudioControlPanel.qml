import QtQuick
import QtQuick.Layouts
import "../theme"
import "../components"
import "../services"

GlassCard {
    id: root

    implicitWidth: 320
    implicitHeight: mainCol.height + 24
    padding: 12

    Column {
        id: mainCol
        anchors.centerIn: parent
        width: parent.width - 24
        spacing: 12

        // Header
        Item {
            width: parent.width
            height: 24

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                SvgIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: AudioService.volumeIcon
                    size: 16
                    color: Theme.accentCyan
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Audio & Volume"
                    color: Theme.fg
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeRegular
                    font.weight: Font.Bold
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

        // Sink Name & Volume readout
        Item {
            width: parent.width
            height: 20
            Text {
                width: parent.width - 60
                text: AudioService.sinkName
                color: Theme.fgSubtle
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                elide: Text.ElideRight
            }

            Text {
                anchors.right: parent.right
                text: AudioService.muted ? "Muted" : (AudioService.volumePercent + "%")
                color: AudioService.muted ? Theme.accentRed : Theme.accentCyan
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Bold
            }
        }

        // Volume Slider
        CustomSlider {
            width: parent.width
            height: 20
            trackHeight: 6
            value: AudioService.volume
            progressColor: AudioService.muted ? Theme.accentRed : Theme.accentCyan
            onMoved: val => AudioService.setVolume(val)
        }

        // Presets row
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8

            IconButton {
                text: "Mute"
                active: AudioService.muted
                implicitWidth: 50
                implicitHeight: 26
                onClicked: AudioService.toggleMute()
            }

            IconButton {
                text: "25%"
                implicitWidth: 44
                implicitHeight: 26
                onClicked: AudioService.setVolume(0.25)
            }

            IconButton {
                text: "50%"
                implicitWidth: 44
                implicitHeight: 26
                onClicked: AudioService.setVolume(0.50)
            }

            IconButton {
                text: "75%"
                implicitWidth: 44
                implicitHeight: 26
                onClicked: AudioService.setVolume(0.75)
            }

            IconButton {
                text: "100%"
                implicitWidth: 48
                implicitHeight: 26
                onClicked: AudioService.setVolume(1.00)
            }
        }

        // output sinks selector section
        Column {
            width: parent.width
            spacing: 6
            visible: AudioService.availableSinks.length > 0

            Text {
                text: "OUTPUT DEVICES"
                color: Theme.fgMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeTiny
                font.weight: Font.Bold
            }

            Repeater {
                model: AudioService.availableSinks

                Rectangle {
                    width: parent.width
                    height: 32
                    radius: Theme.radiusSmall
                    color: modelData.isDefault ? Theme.cardBgActive : (sinkMouse.containsMouse ? Theme.cardBgHover : Theme.cardBgDark)
                    border.color: modelData.isDefault ? Theme.accentCyan : (sinkMouse.containsMouse ? Theme.borderHover : Theme.border)
                    border.width: 1

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        SvgIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            name: AudioService.volumeIcon
                            size: 13
                            color: modelData.isDefault ? Theme.accentCyan : Theme.fgMuted
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 220
                            text: modelData.name
                            color: modelData.isDefault ? Theme.fg : Theme.fgSubtle
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: modelData.isDefault ? Font.Bold : Font.Normal
                            elide: Text.ElideRight
                        }
                    }

                    SvgIcon {
                        visible: modelData.isDefault
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        name: "check"
                        size: 12
                        color: Theme.accentCyan
                    }

                    MouseArea {
                        id: sinkMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: AudioService.switchSink(modelData.id)
                    }
                }
            }
        }

        // individual sound sources and apps
        Column {
            width: parent.width
            spacing: 6
            visible: AudioService.playbackStreams && AudioService.playbackStreams.length > 0

            Text {
                text: "SOUND SOURCES"
                color: Theme.fgMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeTiny
                font.weight: Font.Bold
            }

            Repeater {
                model: AudioService.playbackStreams

                Rectangle {
                    id: streamCard
                    width: parent.width
                    height: 52
                    radius: Theme.radiusSmall
                    color: Theme.cardBgDark
                    border.color: Theme.border
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 4

                        Item {
                            width: parent.width
                            height: 16

                            Row {
                                anchors.left: parent.left
                                anchors.right: streamVolText.left
                                anchors.rightMargin: 6
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 6

                                SvgIcon {
                                    anchors.verticalCenter: parent.verticalCenter
                                    name: modelData.muted ? "volume-muted" : "music"
                                    size: 12
                                    color: modelData.muted ? Theme.accentRed : Theme.accentCyan
                                }

                                Text {
                                    width: parent.width - 20
                                    text: modelData.name + (modelData.streamCount > 1 ? (" (" + modelData.streamCount + " streams)") : (modelData.streams && modelData.streams[0] && modelData.streams[0].mediaName && modelData.streams[0].mediaName !== modelData.name ? (" - " + modelData.streams[0].mediaName) : ""))
                                    color: Theme.fg
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.weight: Font.Medium
                                    elide: Text.ElideRight
                                }
                            }

                            Text {
                                id: streamVolText
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.muted ? "Muted" : (Math.round(streamSlider.value * 100) + "%")
                                color: modelData.muted ? Theme.accentRed : Theme.accentCyan
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeTiny
                                font.weight: Font.Bold
                            }
                        }

                        Row {
                            width: parent.width
                            height: 18
                            spacing: 8

                            CustomSlider {
                                id: streamSlider
                                width: parent.width - 28
                                height: 18
                                trackHeight: 4
                                value: modelData.volume
                                progressColor: modelData.muted ? Theme.accentRed : Theme.accentCyan
                                onMoved: val => AudioService.setStreamVolume(modelData.ids, val, modelData.pid)
                            }

                            IconButton {
                                anchors.verticalCenter: parent.verticalCenter
                                iconName: modelData.muted ? "volume-muted" : "volume-high"
                                iconSize: 11
                                implicitWidth: 20
                                implicitHeight: 20
                                onClicked: AudioService.toggleStreamMute(modelData.ids, modelData.muted, modelData.pid)
                            }
                        }
                    }
                }
            }
        }

        // separator
        Rectangle {
            width: parent.width
            height: 1
            color: Theme.border
        }

        // microphone mute toggle
        Item {
            width: parent.width
            height: 28

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                SvgIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: "mic"
                    size: 15
                    color: Theme.fgSubtle
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Microphone Input"
                    color: Theme.fg
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }
            }

            IconButton {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: "Toggle Mute"
                implicitHeight: 24
                onClicked: AudioService.toggleMicMute()
            }
        }
    }
}
