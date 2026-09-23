import QtQuick
import "../theme"

// custom slider with persistent binding support
Item {
    id: root

    property real value: 0.0        // 0.0 to 1.0
    property color trackColor: Theme.border
    property color progressColor: Theme.accent
    property int trackHeight: 6
    property bool interactive: true
    readonly property bool pressed: mouseArea.pressed

    property real currentValue: value

    onValueChanged: {
        if (!mouseArea.pressed) {
            currentValue = value;
        }
    }

    signal moved(real val)

    implicitWidth: 160
    implicitHeight: 24

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        height: root.trackHeight
        radius: height / 2
        color: root.trackColor

        Rectangle {
            id: progress
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: Math.max(0, Math.min(track.width, track.width * Math.max(0.0, Math.min(1.0, root.currentValue))))
            radius: height / 2
            color: root.progressColor
        }

        // thumb handle
        Rectangle {
            id: thumb
            anchors.verticalCenter: parent.verticalCenter
            x: Math.max(0, Math.min(track.width - width, (track.width * Math.max(0.0, Math.min(1.0, root.currentValue))) - (width / 2)))
            width: 14
            height: 14
            radius: 7
            color: Theme.fg
            border.color: root.progressColor
            border.width: 2
            visible: root.interactive && (mouseArea.containsMouse || mouseArea.pressed)

            scale: mouseArea.pressed ? 1.2 : 1.0
            Behavior on scale { NumberAnimation { duration: 100 } }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.interactive
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        function updateFromMouse(mouseX) {
            let newVal = Math.max(0.0, Math.min(1.0, mouseX / track.width));
            root.currentValue = newVal;
            root.moved(newVal);
        }

        onPressed: mouse => updateFromMouse(mouse.x)
        onPositionChanged: mouse => {
            if (pressed) {
                updateFromMouse(mouse.x);
            }
        }
        onReleased: mouse => updateFromMouse(mouse.x)
    }
}
