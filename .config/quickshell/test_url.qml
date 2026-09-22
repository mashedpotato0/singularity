
import QtQuick
import Quickshell

ShellRoot {
    Component.onCompleted: {
        let path = "/home/mash/wallpapers/desktop/wallpaperflare.com_wallpaper (2).jpg";
        console.log("Raw string URL:", "file://" + path);
        console.log("Qt.resolvedUrl:", Qt.resolvedUrl("file://" + path));
        Qt.quit();
    }
}
