import QtQuick
import "../theme"
import "../components"
import "../services"

GlassCard {
    id: root

    implicitWidth: 260
    implicitHeight: 240
    defaultBgColor: Theme.cardBgDark
    defaultBorderColor: Theme.borderHover
    radius: Theme.radiusCard

    Column {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 8

        // Header
        Item {
            width: parent.width
            height: 24

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "Session & Power"
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Font.Bold
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

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.border
        }

        IconButton {
            width: parent.width
            height: 34
            iconName: "lock"
            text: "Lock Screen"
            onClicked: {
                SystemInfoService.lockSession();
                PanelManager.close();
            }
        }

        IconButton {
            width: parent.width
            height: 34
            iconName: "moon"
            text: "Suspend / Sleep"
            onClicked: {
                SystemInfoService.suspend();
                PanelManager.close();
            }
        }

        IconButton {
            width: parent.width
            height: 34
            iconName: "reboot"
            text: "Restart System"
            onClicked: {
                SystemInfoService.reboot();
                PanelManager.close();
            }
        }

        IconButton {
            width: parent.width
            height: 34
            iconName: "power"
            text: "Shut Down"
            iconColor: Theme.accentRed
            onClicked: {
                SystemInfoService.poweroff();
                PanelManager.close();
            }
        }
    }
}
