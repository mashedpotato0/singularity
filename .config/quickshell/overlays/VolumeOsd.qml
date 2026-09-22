import QtQuick
import Quickshell
import Quickshell.Wayland
import "../theme"
import "../components"
import "../services"

PanelWindow {
    id: root

    property var targetScreen: null
    screen: targetScreen

    anchors {
        top: true
    }

    margins {
        top: Theme.barHeight + 20
    }

    implicitWidth: 280
    implicitHeight: 48
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-volume-osd"

    property bool shouldShow: false
    visible: shouldShow

    Timer {
        id: hideTimer
        interval: 1800
        onTriggered: root.shouldShow = false
    }

    Connections {
        target: AudioService
        function onVolumeChanged() {
            root.shouldShow = true;
            hideTimer.restart();
        }
        function onMutedChanged() {
            root.shouldShow = true;
            hideTimer.restart();
        }
    }

    GlassCard {
        anchors.fill: parent
        padding: 8

        Row {
            anchors.centerIn: parent
            width: parent.width - 24
            spacing: 10

            SvgIcon {
                anchors.verticalCenter: parent.verticalCenter
                name: AudioService.volumeIcon
                size: 18
                color: AudioService.muted ? Theme.accentRed : Theme.accentCyan
            }

            CustomSlider {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 70
                height: 16
                trackHeight: 6
                value: AudioService.volume
                progressColor: AudioService.muted ? Theme.accentRed : Theme.accentCyan
                interactive: false
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: AudioService.muted ? "Muted" : (AudioService.volumePercent + "%")
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Bold
            }
        }
    }
}
