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
    WlrLayershell.namespace: "qs-brightness-osd"

    property bool shouldShow: false
    visible: shouldShow

    Timer {
        id: hideTimer
        interval: 1800
        onTriggered: root.shouldShow = false
    }

    Connections {
        target: SystemInfoService
        function onBrightnessChanged() {
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
                name: SystemInfoService.brightnessIcon
                size: 18
                color: Theme.accentYellow
            }

            CustomSlider {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 70
                height: 16
                trackHeight: 6
                value: SystemInfoService.brightness
                progressColor: Theme.accentYellow
                interactive: false
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Math.round(SystemInfoService.brightness * 100) + "%"
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Bold
            }
        }
    }
}
