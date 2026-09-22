pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    readonly property string settingsPath: Quickshell.env("HOME") + "/.config/quickshell/settings.json"
    property var values: ({})

    property bool dnd: get("dnd", false)
    property bool isDark: get("is_dark", true)
    property int sleepTimerDefault: get("sleep_timer_default", 0)

    FileView {
        id: settingsFile
        path: root.settingsPath
        watchChanges: true
        onLoaded: root.loadSettings()
        onFileChanged: {
            settingsFile.reload();
            root.loadSettings();
        }
    }

    function loadSettings() {
        try {
            let txt = "";
            if (typeof settingsFile.text === "function") {
                txt = settingsFile.text();
            } else if (typeof settingsFile.text === "string") {
                txt = settingsFile.text;
            }
            if (txt && txt.trim().length > 0) {
                root.values = JSON.parse(txt.trim());
                root.dnd = root.get("dnd", false);
                root.isDark = root.get("is_dark", true);
                root.sleepTimerDefault = root.get("sleep_timer_default", 0);
            }
        } catch (e) {
            console.log("failed to load settings", e);
        }
    }

    function get(key, defaultValue) {
        if (root.values && root.values[key] !== undefined) {
            return root.values[key];
        }
        return defaultValue;
    }

    function set(key, value) {
        let copy = Object.assign({}, root.values);
        copy[key] = value;
        root.values = copy;

        if (key === "dnd") root.dnd = value;
        if (key === "is_dark") root.isDark = value;
        if (key === "sleep_timer_default") root.sleepTimerDefault = value;

        saveSettings();
    }

    function saveSettings() {
        try {
            let jsonStr = JSON.stringify(root.values, null, 4);
            Quickshell.execDetached([
                "python3",
                "-c",
                "import sys, os; p = os.path.expanduser('~/.config/quickshell/settings.json'); open(p, 'w').write(sys.argv[1])",
                jsonStr
            ]);
        } catch (e) {
            console.log("failed to save settings", e);
        }
    }

    Component.onCompleted: {
        loadSettings();
    }
}
