pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland

Item {
    id: root

    readonly property var focusedWorkspace: Hyprland.focusedWorkspace
    readonly property var activeToplevel: Hyprland.activeToplevel

    property string activeWindowTitle: ""
    property string activeWindowClass: ""
    property string activeWindowAddress: Hyprland.activeToplevel ? Hyprland.activeToplevel.address : ""
    property var activeWorkspaces: []
    property var openWindows: []
    property int totalWindows: openWindows.length
    property bool isFullscreen: false

    function refresh() {
        Hyprland.refreshWorkspaces();
        Hyprland.refreshToplevels();
        Hyprland.refreshMonitors();
        updateState();
        asyncRefreshTimer.restart();
    }

    Timer {
        id: asyncRefreshTimer
        interval: 50
        repeat: false
        onTriggered: root.updateState()
    }

    function updateState() {
        // Windows (toplevels) first so we can use it to verify workspace windows
        let winList = [];
        let topRaw = Hyprland.toplevels ? Hyprland.toplevels.values : [];
        let activeAddr = Hyprland.activeToplevel ? Hyprland.activeToplevel.address : "";

        for (let j = 0; j < topRaw.length; j++) {
            let t = topRaw[j];
            if (!t) continue;
            
            let ipcObj = t.lastIpcObject || {};
            let winClass = ipcObj.class || (t.lastIpcObject && t.lastIpcObject.class) || "";
            
            let winWsName = "";
            let winWsId = null;
            if (t.workspace) {
                if (t.workspace.name) winWsName = t.workspace.name;
                if (t.workspace.id !== undefined) winWsId = t.workspace.id;
            } else if (ipcObj.workspace) {
                if (ipcObj.workspace.name) winWsName = ipcObj.workspace.name;
                if (ipcObj.workspace.id !== undefined) winWsId = ipcObj.workspace.id;
            }
            
            let finalWs = winWsName || (winWsId !== null ? winWsId.toString() : "");
            if (!finalWs || (!t.title && !winClass && !t.address)) continue;
            
            let isFocused = (activeAddr === t.address) || t.activated || false;
            
            winList.push({
                address: t.address || "",
                title: t.title || winClass || "Window",
                clazz: winClass,
                windowClass: winClass,
                workspace: finalWs,
                workspaceId: winWsId !== null ? winWsId : parseInt(finalWs),
                activated: t.activated || false,
                isFocused: isFocused,
                urgent: t.urgent || false
            });
        }
        root.openWindows = winList;

        // Workspaces
        let wsList = [];
        let wsRaw = Hyprland.workspaces ? Hyprland.workspaces.values : [];
        for (let i = 0; i < wsRaw.length; i++) {
            let w = wsRaw[i];
            if (!w) continue;
            let wsId = parseInt(w.name) || w.id;
            let winCount = 0;
            if (w.lastIpcObject && typeof w.lastIpcObject.windows === "number") {
                winCount = w.lastIpcObject.windows;
            } else if (w.toplevels && w.toplevels.values) {
                winCount = w.toplevels.values.length;
            } else if (w.toplevels && typeof w.toplevels.count === "number") {
                winCount = w.toplevels.count;
            } else {
                winCount = winList.filter(item => (item.workspaceId === wsId || parseInt(item.workspace) === wsId)).length;
            }
            if (wsId > 0) {
                wsList.push({
                    id: wsId,
                    name: w.name || wsId.toString(),
                    windows: winCount,
                    active: w.active || false,
                    focused: (Hyprland.focusedWorkspace && (Hyprland.focusedWorkspace.name === w.name || Hyprland.focusedWorkspace.id === w.id)) || false,
                    urgent: w.urgent || false
                });
            }
        }
        wsList.sort((a, b) => a.id - b.id);
        root.activeWorkspaces = wsList;

        // Update active window
        if (Hyprland.activeToplevel) {
            root.activeWindowTitle = Hyprland.activeToplevel.title || "";
            root.activeWindowClass = (Hyprland.activeToplevel.lastIpcObject && Hyprland.activeToplevel.lastIpcObject.class) ? Hyprland.activeToplevel.lastIpcObject.class : "";
            root.activeWindowAddress = Hyprland.activeToplevel.address || "";
            // fullscreen: 0=none, 1=maximized, 2=fullscreen
            let fsVal = Hyprland.activeToplevel.lastIpcObject ? Hyprland.activeToplevel.lastIpcObject.fullscreen : 0;
            root.isFullscreen = (fsVal === 2 || fsVal === true);
        } else if (winList.length > 0) {
            let active = winList.find(w => w.activated);
            if (active) {
                root.activeWindowTitle = active.title;
                root.activeWindowClass = active.clazz;
                root.activeWindowAddress = active.address;
            } else {
                root.activeWindowTitle = "";
                root.activeWindowClass = "";
                root.activeWindowAddress = "";
            }
        } else {
            root.activeWindowTitle = "";
            root.activeWindowClass = "";
            root.activeWindowAddress = "";
        }
    }

    function focusWorkspace(id) {
        Hyprland.dispatch("hl.dsp.focus({ workspace = " + id + " })");
        refreshTimer.restart();
    }

    function focusWindow(address) {
        let cleanAddr = address.startsWith("0x") ? address : ("0x" + address);
        Hyprland.dispatch('hl.dsp.focus({ window = "address:' + cleanAddr + '" })');
        refreshTimer.restart();
    }

    function closeWindow(address) {
        let cleanAddr = address.startsWith("0x") ? address : ("0x" + address);
        Hyprland.dispatch('hl.dsp.focus({ window = "address:' + cleanAddr + '" })');
        Hyprland.dispatch('hl.dsp.window.close()');
        refreshTimer.restart();
    }

    function execApp(cmd) {
        Hyprland.dispatch('hl.dsp.exec_cmd("' + cmd.replace(/"/g, '\\"') + '")');
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            root.refresh();
        }
        function onFocusedWorkspaceChanged() {
            root.refresh();
        }
        function onActiveToplevelChanged() {
            root.refresh();
        }
    }

    Timer {
        id: refreshTimer
        interval: 800
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: {
        root.refresh();
    }
}
