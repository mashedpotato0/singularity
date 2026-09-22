import QtQuick
import "../theme"
import "../services"

Row {
    id: root
    spacing: 4

    // Prepare list of workspace IDs: 1 to 5, plus any active workspaces with ID > 5
    readonly property var workspaceIds: {
        let ids = [1, 2, 3, 4, 5];
        let openWins = HyprlandService.openWindows || [];
        for (let i = 0; i < openWins.length; i++) {
            let wsId = parseInt(openWins[i].workspace);
            if (wsId && wsId > 5 && ids.indexOf(wsId) === -1) {
                ids.push(wsId);
            }
        }
        let activeWs = HyprlandService.activeWorkspaces || [];
        for (let j = 0; j < activeWs.length; j++) {
            let wsId = activeWs[j].id;
            if (wsId && wsId > 5 && ids.indexOf(wsId) === -1) {
                ids.push(wsId);
            }
        }
        ids.sort((a, b) => a - b);
        return ids;
    }

    Repeater {
        model: root.workspaceIds

        Rectangle {
            id: wsPill

            readonly property int wsId: modelData
            readonly property bool isFocused: {
                let fw = HyprlandService.focusedWorkspace;
                if (fw) {
                    return (fw.id === wsId || parseInt(fw.name) === wsId);
                }
                return wsId === 1;
            }
            readonly property bool hasWindows: {
                let ws = (HyprlandService.activeWorkspaces || []).find(w => w.id === wsId);
                return (ws && ws.windows > 0) ? true : false;
            }

            implicitWidth: isFocused ? 28 : (hasWindows ? 22 : 18)
            implicitHeight: 26
            radius: Theme.radiusSmall

            color: isFocused ? Theme.accentCyan : (mouseArea.containsMouse ? Theme.cardBgHover : (hasWindows ? Theme.cardBg : "transparent"))
            border.color: isFocused ? Theme.accentCyan : (mouseArea.containsMouse ? Theme.borderHover : "transparent")
            border.width: 1

            Behavior on implicitWidth { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutQuad } }
            Behavior on color { ColorAnimation { duration: Theme.animFast } }

            Text {
                id: label
                anchors.centerIn: parent
                text: wsId.toString()
                color: isFocused ? Theme.fgInverse : (hasWindows ? Theme.fg : Theme.fgMuted)
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.weight: isFocused ? Font.Bold : (hasWindows ? Font.Medium : Font.Normal)
            }

            // Tiny dot indicator for windows when not focused
            Rectangle {
                visible: hasWindows && !isFocused
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 2
                anchors.horizontalCenter: parent.horizontalCenter
                width: 3
                height: 3
                radius: 1.5
                color: Theme.accent
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: HyprlandService.focusWorkspace(wsId)
            }
        }
    }
}
