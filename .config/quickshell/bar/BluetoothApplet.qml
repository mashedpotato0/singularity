import QtQuick
import "../theme"
import "../components"
import "../services"

Rectangle {
    id: root

    implicitHeight: 28
    implicitWidth: contentRow.width + 16
    radius: Theme.radiusSmall

    readonly property bool isOpen: PanelManager.currentPanel === "bluetooth"
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
            name: "bluetooth"
            size: 14
            color: BluetoothService.enabled ? (isOpen ? Theme.accentCyan : Theme.accentSapphire) : Theme.fgMuted
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: BluetoothService.enabled ? "BT" : "Off"
            color: BluetoothService.enabled ? Theme.fg : Theme.fgMuted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                PanelManager.toggle("bluetooth");
            } else if (mouse.button === Qt.RightButton) {
                BluetoothService.openManager();
            } else if (mouse.button === Qt.MiddleButton) {
                BluetoothService.togglePower();
            }
        }
    }
}
