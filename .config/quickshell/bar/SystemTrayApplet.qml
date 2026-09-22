import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../theme"
import "../components"

Row {
    id: root

    spacing: 6
    visible: SystemTray.items && SystemTray.items.values && SystemTray.items.values.length > 0

    function resolveIcon(icon) {
        if (!icon || icon === "") return "";
        if (icon.startsWith("/") || icon.startsWith("file://")) return icon;
        if (icon.includes("?path=")) {
            const [name, path] = icon.split("?path=");
            return "file://" + path + "/" + name.slice(name.lastIndexOf("/") + 1);
        }
        const iconMap = {
            "bluetooth-disabled-symbolic": "file:///usr/share/icons/Adwaita/symbolic/status/bluetooth-disabled-symbolic.svg",
            "bluetooth-disconnected-symbolic": "file:///usr/share/icons/Adwaita/symbolic/status/bluetooth-disconnected-symbolic.svg",
            "bluetooth-symbolic": "file:///usr/share/icons/Adwaita/symbolic/devices/bluetooth-symbolic.svg",
            "bluetooth-active-symbolic": "file:///usr/share/icons/Adwaita/symbolic/devices/bluetooth-symbolic.svg",
            "edit-find-symbolic": "file:///usr/share/icons/Adwaita/symbolic/actions/edit-find-symbolic.svg",
            "document-open-recent-symbolic": "file:///usr/share/icons/Adwaita/symbolic/actions/document-open-recent-symbolic.svg",
            "document-properties-symbolic": "file:///usr/share/icons/Adwaita/symbolic/actions/document-properties-symbolic.svg",
            "application-exit-symbolic": "file:///usr/share/icons/Adwaita/symbolic/actions/application-exit-symbolic.svg",
            "audio-card-symbolic": "file:///usr/share/icons/Adwaita/symbolic/devices/audio-card-symbolic.svg",
            "audio-headset": "file:///usr/share/icons/Adwaita/symbolic/devices/audio-headset-symbolic.svg",
            "audio-headset-symbolic": "file:///usr/share/icons/Adwaita/symbolic/devices/audio-headset-symbolic.svg",
            "application-x-addon-symbolic": "file:///usr/share/icons/Adwaita/symbolic/mimetypes/application-x-addon-symbolic.svg",
            "help-about-symbolic": "file:///usr/share/icons/Adwaita/symbolic/actions/help-about-symbolic.svg"
        };
        if (iconMap[icon]) return iconMap[icon];
        return icon;
    }

    // Container pill when items are active
    Rectangle {
        visible: SystemTray.items && SystemTray.items.values && SystemTray.items.values.length > 0
        implicitHeight: 28
        implicitWidth: trayRow.width + 12
        radius: Theme.radiusSmall
        color: Theme.cardBg
        border.color: Theme.border
        border.width: 1

        Row {
            id: trayRow
            anchors.centerIn: parent
            spacing: 6

            Repeater {
                model: SystemTray.items

                delegate: Item {
                    id: trayItemRoot
                    required property SystemTrayItem modelData

                    implicitWidth: 22
                    implicitHeight: 22

                    IconImage {
                        id: iconImg
                        anchors.centerIn: parent
                        implicitSize: 18
                        asynchronous: true
                        source: root.resolveIcon(trayItemRoot.modelData.icon)
                    }

                    QsMenuAnchor {
                        id: menuAnchor
                        menu: trayItemRoot.modelData.menu
                        anchor.item: trayItemRoot
                        anchor.edges: Edges.Bottom
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                        cursorShape: Qt.PointingHandCursor

                        onClicked: (mouse) => {
                            if (mouse.button === Qt.RightButton) {
                                if (trayItemRoot.modelData.hasMenu && trayItemRoot.modelData.menu) {
                                    menuAnchor.open();
                                } else {
                                    trayItemRoot.modelData.secondaryActivate();
                                }
                            } else if (mouse.button === Qt.MiddleButton) {
                                trayItemRoot.modelData.secondaryActivate();
                            } else {
                                if (trayItemRoot.modelData.onlyMenu && trayItemRoot.modelData.hasMenu && trayItemRoot.modelData.menu) {
                                    menuAnchor.open();
                                } else {
                                    trayItemRoot.modelData.activate();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
