pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io

// audio pipewire service
Item {
    id: root

    property real volume: 0.40
    property bool muted: false
    property string sinkName: "Ryzen HD Audio Controller Speaker"
    property var availableSinks: []
    property var playbackStreams: []

    readonly property int volumePercent: Math.round(volume * 100)

    readonly property string volumeIcon: {
        if (muted || volume <= 0.01) return "volume-muted";
        if (volume < 0.33) return "volume-low";
        if (volume < 0.66) return "volume-medium";
        return "volume-high";
    }

    function setVolume(val) {
        let clamped = Math.max(0.0, Math.min(1.0, val));
        root.volume = clamped;
        let pct = Math.round(clamped * 100);
        Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", pct + "%"]);
    }

    function setStreamVolume(key, ids, val) {
        let streamIds = Array.isArray(ids) ? ids : [ids];
        let clamped = Math.max(0.0, Math.min(1.0, val));
        let pct = Math.round(clamped * 100);

        for (let i = 0; i < streamIds.length; i++) {
            Quickshell.execDetached(["wpctl", "set-volume", streamIds[i].toString(), pct + "%"]);
        }

        for (let i = 0; i < root.playbackStreams.length; i++) {
            let item = root.playbackStreams[i];
            if (item && item.key === key) {
                item.volume = clamped;
                break;
            }
        }
    }

    function toggleStreamMute(key, ids, isMuted) {
        let streamIds = Array.isArray(ids) ? ids : [ids];
        let target = isMuted ? "0" : "1";

        for (let i = 0; i < streamIds.length; i++) {
            Quickshell.execDetached(["wpctl", "set-mute", streamIds[i].toString(), target]);
        }

        let updated = [];
        for (let i = 0; i < root.playbackStreams.length; i++) {
            let item = Object.assign({}, root.playbackStreams[i]);
            if (item.key === key) {
                item.muted = !isMuted;
            }
            updated.push(item);
        }
        root.playbackStreams = updated;
    }

    function toggleMute() {
        root.muted = !root.muted;
        Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]);
    }

    function toggleMicMute() {
        Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"]);
    }

    function increaseVolume(step) {
        setVolume(volume + (step || 0.05));
    }

    function decreaseVolume(step) {
        setVolume(volume - (step || 0.05));
    }

    function switchSink(id) {
        Quickshell.execDetached(["wpctl", "set-default", id.toString()]);
        updateAll();
    }

    // query current volume and mute status
    Process {
        id: getVolProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            id: volCollector
            onDataChanged: {
                let out = volCollector.text.trim();
                let match = out.match(/Volume:\s+([0-9.]+)(?:\s+\[MUTED\])?/);
                if (match) {
                    let v = parseFloat(match[1]);
                    if (!isNaN(v)) root.volume = v;
                    root.muted = (out.indexOf("MUTED") !== -1);
                }
            }
        }
    }

    // inspect sink description
    Process {
        id: inspectProc
        command: ["sh", "-c", "wpctl inspect @DEFAULT_AUDIO_SINK@ | grep -E 'node.description' | head -n 1 | cut -d'\"' -f2"]
        stdout: StdioCollector {
            id: inspectCollector
            onDataChanged: {
                let desc = inspectCollector.text.trim();
                if (desc.length > 0) root.sinkName = desc;
            }
        }
    }

    // parse available sinks
    Process {
        id: statusProc
        command: ["sh", "-c", "wpctl status | sed -n '/Sinks:/,/Sources:/p' | grep -E '^[ │ ]*([* ])[ │ ]*([0-9]+)\\. (.*)\\[vol:'"]
        stdout: StdioCollector {
            id: statusCollector
            onDataChanged: {
                let lines = statusCollector.text.trim().split("\n");
                let sinks = [];
                for (let i = 0; i < lines.length; i++) {
                    let match = lines[i].match(/([* ])\s*(\d+)\.\s+(.*?)\s+\[vol:/);
                    if (match) {
                        sinks.push({ id: parseInt(match[2]), name: match[3].trim(), isDefault: match[1] === "*" });
                    }
                }
                if (sinks.length > 0) root.availableSinks = sinks;
            }
        }
    }

    // parse playback streams grouped by app
    Process {
        id: streamsProc
        command: ["python3", Quickshell.env("HOME") + "/.config/hypr/scripts/get_audio_streams.py"]
        stdout: StdioCollector {
            id: streamsCollector
            onDataChanged: {
                let out = streamsCollector.text.trim();
                try {
                    let parsed = JSON.parse(out);
                    if (Array.isArray(parsed)) root.playbackStreams = parsed;
                } catch (e) {}
            }
        }
    }

    function updateAll() {
        getVolProc.exec(["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]);
        inspectProc.exec(["sh", "-c", "wpctl inspect @DEFAULT_AUDIO_SINK@ | grep -E 'node.description' | head -n 1 | cut -d'\"' -f2"]);
        statusProc.exec(["sh", "-c", "wpctl status | sed -n '/Sinks:/,/Sources:/p' | grep -E '^[ │ ]*([* ])[ │ ]*([0-9]+)\\. (.*)\\[vol:'"]);
        streamsProc.exec(["python3", Quickshell.env("HOME") + "/.config/hypr/scripts/get_audio_streams.py"]);
    }

    Timer {
        id: refreshTimer
        interval: 1500
        running: true
        repeat: true
        onTriggered: root.updateAll()
    }

    Component.onCompleted: root.updateAll()
}
