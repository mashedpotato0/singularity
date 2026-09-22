import QtQuick
import "../theme"
import "../components"
import "../services"

Rectangle {
    id: root

    implicitHeight: 28
    implicitWidth: contentRow.width + 16
    radius: Theme.radiusSmall

    readonly property bool isOpen: PanelManager.currentPanel === "wifi"
    readonly property bool isHovered: mouseArea.containsMouse

    color: isOpen ? Theme.cardBgActive : (isHovered ? Theme.cardBgHover : Theme.cardBg)
    border.color: isOpen ? Theme.accentCyan : (isHovered ? Theme.borderHover : Theme.border)
    border.width: 1

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 5

        SvgIcon {
            anchors.verticalCenter: parent.verticalCenter
            name: NetworkService.wifiIcon
            size: 14
            color: NetworkService.isConnected ? (isOpen ? Theme.accentCyan : Theme.accentGreen) : Theme.fgMuted
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: {
                if (!NetworkService.wifiEnabled) return "Off";
                if (!NetworkService.isConnected) return "Offline";
                let s = NetworkService.activeSsid || "Connected";
                if (s.length > 12) return s.substring(0, 10) + "..";
                return s;
            }
            color: NetworkService.isConnected ? Theme.fg : Theme.fgMuted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                PanelManager.toggle("wifi");
            } else if (mouse.button === Qt.RightButton) {
                NetworkService.toggleWifi();
            }
        }
    }
}
