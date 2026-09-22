import QtQuick
import Quickshell
import Quickshell.Wayland
import "../services"
import "../theme"

PanelWindow {
    id: root

    property var targetScreen: null
    screen: targetScreen

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Background
    exclusionMode: ExclusionMode.Ignore
    color: Theme.bgDark

    Image {
        id: bgImg
        anchors.fill: parent
        source: WallpaperService.wallpaperPath
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false

        Behavior on opacity {
            NumberAnimation { duration: 300 }
        }
    }

    // wallpaper clock at calculated least busy region
    Item {
        id: clockContainer
        x: Math.max(30, Math.min(root.width - width - 30, Theme.clockX))
        y: Math.max(Theme.barHeight + 20, Math.min(root.height - height - 30, Theme.clockY))
        width: clockColumn.implicitWidth
        height: clockColumn.implicitHeight

        Behavior on x { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
        Behavior on y { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }

        SystemClock {
            id: sysClock
            precision: SystemClock.Minutes
        }

        Column {
            id: clockColumn
            spacing: 2

            Text {
                text: Qt.formatTime(sysClock.date, "HH:mm")
                font.family: Theme.fontFamily
                font.pixelSize: 76
                font.weight: Font.Bold
                color: Theme.fg
                style: Text.Outline
                styleColor: Qt.rgba(0, 0, 0, 0.4)
            }

            Text {
                text: Qt.formatDate(sysClock.date, "dddd, MMMM d")
                font.family: Theme.fontFamily
                font.pixelSize: 22
                font.weight: Font.Medium
                color: Theme.fgSubtle
                style: Text.Outline
                styleColor: Qt.rgba(0, 0, 0, 0.4)
            }
        }
    }
}
