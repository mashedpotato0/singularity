pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Item {
    id: root

    // Defaults detected on this system
    readonly property string terminalCmd: "kitty"
    readonly property string browserCmd: "brave"
    readonly property string fileManagerCmd: "thunar"
    readonly property string launcherCmd: "bash ~/.config/hypr/scripts/toggle_applauncher.sh"
    readonly property string lockCmd: "bash ~/.config/hypr/scripts/lock.sh"

    // Battery info from sysfs
    property int batteryPercentage: 100
    property string batteryStatus: "Full"
    property bool isPluggedIn: false
    property bool isCharging: batteryStatus === "Charging" || (isPluggedIn && batteryStatus !== "Discharging")
    property bool hasBattery: true

    readonly property string batteryIcon: {
        if (isCharging) return "battery-charging";
        if (batteryPercentage <= 10) return "battery-alert";
        if (batteryPercentage <= 20) return "battery-20";
        if (batteryPercentage <= 35) return "battery-30";
        if (batteryPercentage <= 55) return "battery-50";
        if (batteryPercentage <= 70) return "battery-60";
        if (batteryPercentage <= 85) return "battery-80";
        if (batteryPercentage <= 95) return "battery-90";
        return "battery-full";
    }

    FileView {
        id: batCapacityFile
        path: "/sys/class/power_supply/BAT0/capacity"
    }

    FileView {
        id: batStatusFile
        path: "/sys/class/power_supply/BAT0/status"
    }

    FileView {
        id: acOnlineFile
        path: "/sys/class/power_supply/ACAD/online"
    }

    // Network status
    property string networkType: "ethernet"
    property string networkName: "Wired connection 1"
    property bool networkConnected: true

    readonly property string networkIcon: {
        if (!networkConnected) return "wifi-off";
        if (networkType === "wifi") return "wifi";
        return "ethernet";
    }

    Process {
        id: netProc
        command: ["nmcli", "-t", "-f", "TYPE,NAME,STATE", "connection", "show", "--active"]
        running: true
        stdout: StdioCollector {
            id: netCollector
            onDataChanged: {
                let lines = netCollector.text.trim().split("\n");
                let foundConn = false;
                for (let i = 0; i < lines.length; i++) {
                    let parts = lines[i].split(":");
                    if (parts.length >= 3 && parts[2] === "activated") {
                        root.networkConnected = true;
                        root.networkName = parts[1];
                        if (parts[0].indexOf("wireless") !== -1 || parts[0].indexOf("wifi") !== -1) {
                            root.networkType = "wifi";
                        } else {
                            root.networkType = "ethernet";
                        }
                        foundConn = true;
                        break;
                    }
                }
                if (!foundConn && lines.length > 0 && lines[0].length > 0) {
                    let parts = lines[0].split(":");
                    if (parts.length >= 2) {
                        root.networkConnected = true;
                        root.networkName = parts[1];
                        root.networkType = parts[0].indexOf("wireless") !== -1 ? "wifi" : "ethernet";
                        foundConn = true;
                    }
                }
                if (!foundConn) {
                    root.networkConnected = false;
                    root.networkName = "Disconnected";
                    root.networkType = "disconnected";
                }
            }
        }
    }

    // Brightness
    property real brightness: 1.0
    property int maxBrightness: 65535

    readonly property string brightnessIcon: {
        let pct = Math.round(brightness * 100);
        if (pct <= 33) return "brightness-low";
        if (pct <= 66) return "brightness-medium";
        return "brightness-high";
    }

    FileView {
        id: brightFile
        path: "/sys/class/backlight/amdgpu_bl2/brightness"
        watchChanges: true
        onLoaded: updateBrightness()
        onFileChanged: {
            brightFile.reload();
            updateBrightness();
        }

        function updateBrightness() {
            let txt = brightFile.text();
            if (txt) {
                let cur = parseInt(txt.trim());
                if (!isNaN(cur) && root.maxBrightness > 0) {
                    root.brightness = Math.max(0.01, Math.min(1.0, cur / root.maxBrightness));
                }
            }
        }
    }

    FileView {
        id: maxBrightFile
        path: "/sys/class/backlight/amdgpu_bl2/max_brightness"
        onLoaded: {
            let txt = maxBrightFile.text();
            if (txt) {
                let mx = parseInt(txt.trim());
                if (!isNaN(mx) && mx > 0) root.maxBrightness = mx;
            }
        }
    }

    Process {
        id: brightProc
    }

    function setBrightness(ratio) {
        let clamped = Math.max(0.05, Math.min(1.0, ratio));
        root.brightness = clamped;
        let val = Math.round(clamped * 100);
        brightProc.exec(["sh", "-c", "command -v brightnessctl >/dev/null 2>&1 && brightnessctl set " + val + "% || true"]);
    }

    function increaseBrightness(step) {
        let s = step !== undefined ? step : 0.05;
        setBrightness(root.brightness + s);
    }

    function decreaseBrightness(step) {
        let s = step !== undefined ? step : 0.05;
        setBrightness(root.brightness - s);
    }

    // Launch Helpers
    function launchTerminal(cmd) {
        if (cmd && cmd !== "") {
            Quickshell.execDetached([terminalCmd, "--title", cmd, "-e", cmd]);
        } else {
            Quickshell.execDetached([terminalCmd]);
        }
    }

    function launchBrowser() {
        Hyprland.dispatch('hl.dsp.exec_cmd("' + browserCmd + '")');
    }

    function launchFileManager() {
        Hyprland.dispatch('hl.dsp.exec_cmd("' + fileManagerCmd + '")');
    }

    function launchMenu() {
        Hyprland.dispatch('hl.dsp.exec_cmd("' + launcherCmd + '")');
    }

    function lockSession() {
        Hyprland.dispatch('hl.dsp.exec_cmd("' + lockCmd + '")');
    }

    function suspend() {
        sysProc.exec(["systemctl", "suspend"]);
    }

    function reboot() {
        sysProc.exec(["systemctl", "reboot"]);
    }

    function poweroff() {
        sysProc.exec(["systemctl", "poweroff"]);
    }

    // idle sleep timeout
    property int sleepTimerMinutes: SettingsService.sleepTimerDefault
    property bool sleepTimerActive: sleepTimerMinutes > 0

    Timer {
        id: idleUpdateTimer
        interval: 200
        repeat: false
        onTriggered: {
            Quickshell.execDetached([
                "bash",
                Quickshell.env("HOME") + "/.config/hypr/scripts/update_idle.sh",
                root.sleepTimerMinutes.toString()
            ]);
        }
    }

    Connections {
        target: SettingsService
        function onSleepTimerDefaultChanged() {
            if (root.sleepTimerMinutes !== SettingsService.sleepTimerDefault) {
                root.sleepTimerMinutes = SettingsService.sleepTimerDefault;
                idleUpdateTimer.restart();
            }
        }
    }

    readonly property string sleepTimerLabel: {
        if (!sleepTimerActive) return "Off";
        return sleepTimerMinutes >= 60 ? (sleepTimerMinutes / 60 + "h") : (sleepTimerMinutes + "m");
    }

    function setSleepTimer(minutes) {
        root.sleepTimerMinutes = minutes;
        SettingsService.set("sleep_timer_default", minutes);
        idleUpdateTimer.restart();
    }

    function cycleSleepTimer() {
        let steps = [0, 5, 10, 15, 30, 45, 60];
        let idx = steps.indexOf(root.sleepTimerMinutes);
        let nextIdx = (idx + 1) % steps.length;
        setSleepTimer(steps[nextIdx]);
    }

    Process {
        id: sysProc
    }

    Timer {
        id: pollTimer
        interval: 4000
        running: true
        repeat: true
        onTriggered: root.updateAll()
    }

    function updateAll() {
        try {
            batCapacityFile.reload();
            batStatusFile.reload();
            acOnlineFile.reload();

            let capStr = batCapacityFile.text().trim();
            if (capStr.length > 0) {
                root.batteryPercentage = parseInt(capStr) || 100;
                root.hasBattery = true;
            }
            let statStr = batStatusFile.text().trim();
            if (statStr.length > 0) {
                root.batteryStatus = statStr;
            }
            let acStr = acOnlineFile.text().trim();
            if (acStr.length > 0) {
                root.isPluggedIn = acStr === "1";
            }
        } catch (e) {
            root.hasBattery = false;
        }

        try {
            let maxStr = maxBrightFile.text().trim();
            if (maxStr.length > 0) {
                root.maxBrightness = parseInt(maxStr) || 65535;
            }
            let brStr = brightFile.text().trim();
            if (brStr.length > 0 && root.maxBrightness > 0) {
                root.brightness = (parseInt(brStr) || root.maxBrightness) / root.maxBrightness;
            }
        } catch (e) {}

        netProc.exec(["nmcli", "-t", "-f", "TYPE,NAME,STATE", "connection", "show", "--active"]);
    }

    Component.onCompleted: {
        updateAll();
        if (SettingsService.sleepTimerDefault >= 0) {
            Quickshell.execDetached([
                "bash",
                Quickshell.env("HOME") + "/.config/hypr/scripts/update_idle.sh",
                SettingsService.sleepTimerDefault.toString()
            ]);
        }
    }
}
