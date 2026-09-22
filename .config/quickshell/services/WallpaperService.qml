pragma Singleton
import QtQuick
import QtCore
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string wallpaperPath: ""

    FileView {
        id: confWatcher
        path: StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.config/hypr/hyprpaper.conf"
        watchChanges: true
        onLoaded: updateWall()
        onFileChanged: {
            confWatcher.reload();
            updateWall();
        }

        function updateWall() {
            let txt = confWatcher.text();
            if (!txt) return;
            let lines = txt.split("\n");
            for (let line of lines) {
                line = line.trim();
                if (line.startsWith("$wall")) {
                    let parts = line.split("=");
                    if (parts.length > 1) {
                        let p = parts[1].trim();
                        if (p !== "") {
                            root.wallpaperPath = "file://" + p;
                            return;
                        }
                    }
                }
            }
        }
    }

    function reload() {
        confWatcher.reload();
        confWatcher.updateWall();
    }
}
