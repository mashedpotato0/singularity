import QtQuick
import Quickshell

Item {
    id: root
    property var targetScreen: null

    VolumeOsd {
        targetScreen: root.targetScreen
    }

    BrightnessOsd {
        targetScreen: root.targetScreen
    }
}
