import QtQuick
import "../theme"
import "../components"
import "../services"

Rectangle {
    id: root

    readonly property string title: HyprlandService.activeWindowTitle || "Desktop"
    readonly property string winClass: HyprlandService.activeWindowClass.toLowerCase()

    readonly property string iconName: {
        if (winClass.indexOf("kitty") !== -1 || winClass.indexOf("term") !== -1) return "terminal";
        if (winClass.indexOf("brave") !== -1 || winClass.indexOf("browser") !== -1) return "globe";
        if (winClass.indexOf("thunar") !== -1 || winClass.indexOf("nautilus") !== -1) return "folder";
        if (winClass.indexOf("kate") !== -1 || winClass.indexOf("code") !== -1) return "code";
        return "window";
    }

    implicitWidth: Math.min(260, Math.max(80, contentRow.implicitWidth + 16))
    implicitHeight: 28
    radius: Theme.radiusSmall
    color: mouseArea.containsMouse ? Theme.cardBgHover : Theme.cardBg
    border.color: (PanelManager.currentPanel === "windows") ? Theme.borderActive : (mouseArea.containsMouse ? Theme.borderHover : "transparent")
    border.width: 1

    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    Row {
        id: contentRow
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        SvgIcon {
            anchors.verticalCenter: parent.verticalCenter
            name: root.iconName
            size: 14
            color: Theme.accent
        }

        Text {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            width: root.width - 32
            elide: Text.ElideRight
            text: root.title
            color: Theme.fg
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.Medium
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: PanelManager.toggle("windows")
    }
}
