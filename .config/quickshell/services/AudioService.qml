pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io

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
        wpctlCmdProc.exec(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", pct + "%"]);
        refreshTimer.restart();
    }

    function setStreamVolume(ids, val, pid) {
        let streamIds = Array.isArray(ids) ? ids : [ids];
        let clamped = Math.max(0.0, Math.min(1.5, val));
        let valStr = clamped.toFixed(2);
        if (pid) {
            wpctlCmdProc.exec(["wpctl", "set-volume", "-p", pid.toString(), valStr]);
        } else if (streamIds.length === 1) {
            wpctlCmdProc.exec(["wpctl", "set-volume", streamIds[0].toString(), valStr]);
        } else if (streamIds.length > 1) {
            wpctlCmdProc.exec(["sh", "-c", streamIds.map(id => "wpctl set-volume " + id + " " + valStr).join(" ; ")]);
        }
        for (let i = 0; i < root.playbackStreams.length; i++) {
            let item = root.playbackStreams[i];
            if ((pid && item.pid === pid) || (item.ids && item.ids.some(id => streamIds.indexOf(id) !== -1))) {
                item.volume = clamped;
                break;
            }
        }
        refreshTimer.restart();
    }

    function toggleStreamMute(ids, isMuted, pid) {
        let streamIds = Array.isArray(ids) ? ids : [ids];
        let target = isMuted ? "0" : "1";
        if (pid) {
            wpctlCmdProc.exec(["wpctl", "set-mute", "-p", pid.toString(), target]);
        } else if (streamIds.length === 1) {
            wpctlCmdProc.exec(["wpctl", "set-mute", streamIds[0].toString(), target]);
        } else if (streamIds.length > 1) {
            wpctlCmdProc.exec(["sh", "-c", streamIds.map(id => "wpctl set-mute " + id + " " + target).join(" ; ")]);
        }
        for (let i = 0; i < root.playbackStreams.length; i++) {
            let item = root.playbackStreams[i];
            if ((pid && item.pid === pid) || (item.ids && item.ids.some(id => streamIds.indexOf(id) !== -1))) {
                item.muted = !isMuted;
                break;
            }
        }
        root.playbackStreamsChanged();
        refreshTimer.restart();
    }

    function toggleMute() {
        root.muted = !root.muted;
        wpctlCmdProc.exec(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]);
        refreshTimer.restart();
    }

    function toggleMicMute() {
        wpctlCmdProc.exec(["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"]);
    }

    function increaseVolume(step) {
        setVolume(volume + (step || 0.05));
    }

    function decreaseVolume(step) {
        setVolume(volume - (step || 0.05));
    }

    function switchSink(id) {
        wpctlCmdProc.exec(["wpctl", "set-default", id.toString()]);
        updateAll();
    }

    Process {
        id: wpctlCmdProc
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
                    if (!isNaN(v)) {
                        root.volume = v;
                    }
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
                if (desc.length > 0) {
                    root.sinkName = desc;
                }
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
                    let line = lines[i];
                    let match = line.match(/([* ])\s*(\d+)\.\s+(.*?)\s+\[vol:/);
                    if (match) {
                        sinks.push({
                            id: parseInt(match[2]),
                            name: match[3].trim(),
                            isDefault: match[1] === "*"
                        });
                    }
                }
                if (sinks.length > 0) {
                    root.availableSinks = sinks;
                }
            }
        }
    }

    // parse playback streams grouped by app
    Process {
        id: streamsProc
        command: ["python3", "-c", "import json, subprocess, os, re\ndef get_proc_name(pid):\n    if not pid: return None\n    try:\n        with open(f'/proc/{pid}/environ', 'rb') as f:\n            env = dict(line.decode('utf-8', errors='ignore').split('=', 1) for line in f.read().split(b'\\0') if b'=' in line)\n            if 'ARGV0' in env:\n                base = os.path.basename(env['ARGV0'])\n                return re.sub(r'\\.(?:AppImage|bin|exe|sh)$', '', base, flags=re.I)\n    except Exception: pass\n    try:\n        with open(f'/proc/{pid}/cmdline', 'rb') as f:\n            args = [a.decode('utf-8', errors='ignore') for a in f.read().split(b'\\0') if a]\n        for arg in args:\n            m = re.search(r'/([^/]+)\\.(?:AppImage|desktop)', arg)\n            if m: return m.group(1)\n            if 'accella' in arg.lower() or 'accela' in arg.lower(): return 'ACCELA'\n    except Exception: pass\n    try:\n        with open(f'/proc/{pid}/comm', 'r') as f:\n            comm = f.read().strip()\n            if comm and not comm.startswith('python') and comm != 'electron': return comm\n    except Exception: pass\n    return None\nSEP_APPS = {'mpv', 'brave', 'brave-browser', 'chrome', 'chromium', 'firefox', 'vlc', 'spotify', 'zen', 'zen-browser', 'floorp', 'librewolf'}\ntry:\n    out = subprocess.check_output(['pw-dump'], stderr=subprocess.DEVNULL)\n    data = json.loads(out)\n    groups = {}\n    for obj in data:\n        info = obj.get('info', {})\n        props = info.get('props', {})\n        if props.get('media.class') == 'Stream/Output/Audio':\n            obj_id = obj.get('id')\n            pid = props.get('application.process.id')\n            raw_name = props.get('application.name') or props.get('node.description') or props.get('media.name') or 'App'\n            media_name = props.get('media.name', '')\n            resolved_app = get_proc_name(pid)\n            display_name = resolved_app if resolved_app else raw_name\n            vol = 1.0\n            muted = False\n            props_params = info.get('params', {}).get('Props', [])\n            if props_params and isinstance(props_params, list) and len(props_params) > 0:\n                vol = float(props_params[0].get('volume', 1.0))\n                muted = bool(props_params[0].get('mute', False))\n            app_lower = (display_name or raw_name or '').lower()\n            if any(s in app_lower for s in SEP_APPS):\n                key = f'stream_{obj_id}'\n            elif pid:\n                key = f'pid_{pid}'\n            else:\n                key = f'stream_{obj_id}'\n            if key not in groups:\n                groups[key] = {'key': key, 'name': display_name, 'pid': pid, 'ids': [], 'streams': [], 'volume': 0.0, 'muted': True}\n            groups[key]['ids'].append(obj_id)\n            groups[key]['streams'].append({'id': obj_id, 'name': raw_name, 'mediaName': media_name, 'volume': vol, 'muted': muted})\n    result = []\n    for g in groups.values():\n        vols = [s['volume'] for s in g['streams']]\n        g['volume'] = max(vols) if vols else 1.0\n        g['muted'] = all(s['muted'] for s in g['streams'])\n        g['streamCount'] = len(g['streams'])\n        result.append(g)\n    print(json.dumps(result))\nexcept Exception:\n    print('[]')\n"]
        stdout: StdioCollector {
            id: streamsCollector
            onDataChanged: {
                let out = streamsCollector.text.trim();
                try {
                    let parsed = JSON.parse(out);
                    if (Array.isArray(parsed)) {
                        root.playbackStreams = parsed;
                    }
                } catch (e) {
                }
            }
        }
    }

    function updateAll() {
        getVolProc.exec(["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]);
        inspectProc.exec(["sh", "-c", "wpctl inspect @DEFAULT_AUDIO_SINK@ | grep -E 'node.description' | head -n 1 | cut -d'\"' -f2"]);
        statusProc.exec(["sh", "-c", "wpctl status | sed -n '/Sinks:/,/Sources:/p' | grep -E '^[ │ ]*([* ])[ │ ]*([0-9]+)\\. (.*)\\[vol:'"]);
        streamsProc.exec(["python3", "-c", "import json, subprocess, os, re\ndef get_proc_name(pid):\n    if not pid: return None\n    try:\n        with open(f'/proc/{pid}/environ', 'rb') as f:\n            env = dict(line.decode('utf-8', errors='ignore').split('=', 1) for line in f.read().split(b'\\0') if b'=' in line)\n            if 'ARGV0' in env:\n                base = os.path.basename(env['ARGV0'])\n                return re.sub(r'\\.(?:AppImage|bin|exe|sh)$', '', base, flags=re.I)\n    except Exception: pass\n    try:\n        with open(f'/proc/{pid}/cmdline', 'rb') as f:\n            args = [a.decode('utf-8', errors='ignore') for a in f.read().split(b'\\0') if a]\n        for arg in args:\n            m = re.search(r'/([^/]+)\\.(?:AppImage|desktop)', arg)\n            if m: return m.group(1)\n            if 'accella' in arg.lower() or 'accela' in arg.lower(): return 'ACCELA'\n    except Exception: pass\n    try:\n        with open(f'/proc/{pid}/comm', 'r') as f:\n            comm = f.read().strip()\n            if comm and not comm.startswith('python') and comm != 'electron': return comm\n    except Exception: pass\n    return None\nSEP_APPS = {'mpv', 'brave', 'brave-browser', 'chrome', 'chromium', 'firefox', 'vlc', 'spotify', 'zen', 'zen-browser', 'floorp', 'librewolf'}\ntry:\n    out = subprocess.check_output(['pw-dump'], stderr=subprocess.DEVNULL)\n    data = json.loads(out)\n    groups = {}\n    for obj in data:\n        info = obj.get('info', {})\n        props = info.get('props', {})\n        if props.get('media.class') == 'Stream/Output/Audio':\n            obj_id = obj.get('id')\n            pid = props.get('application.process.id')\n            raw_name = props.get('application.name') or props.get('node.description') or props.get('media.name') or 'App'\n            media_name = props.get('media.name', '')\n            resolved_app = get_proc_name(pid)\n            display_name = resolved_app if resolved_app else raw_name\n            vol = 1.0\n            muted = False\n            props_params = info.get('params', {}).get('Props', [])\n            if props_params and isinstance(props_params, list) and len(props_params) > 0:\n                vol = float(props_params[0].get('volume', 1.0))\n                muted = bool(props_params[0].get('mute', False))\n            app_lower = (display_name or raw_name or '').lower()\n            if any(s in app_lower for s in SEP_APPS):\n                key = f'stream_{obj_id}'\n            elif pid:\n                key = f'pid_{pid}'\n            else:\n                key = f'stream_{obj_id}'\n            if key not in groups:\n                groups[key] = {'key': key, 'name': display_name, 'pid': pid, 'ids': [], 'streams': [], 'volume': 0.0, 'muted': True}\n            groups[key]['ids'].append(obj_id)\n            groups[key]['streams'].append({'id': obj_id, 'name': raw_name, 'mediaName': media_name, 'volume': vol, 'muted': muted})\n    result = []\n    for g in groups.values():\n        vols = [s['volume'] for s in g['streams']]\n        g['volume'] = max(vols) if vols else 1.0\n        g['muted'] = all(s['muted'] for s in g['streams'])\n        g['streamCount'] = len(g['streams'])\n        result.append(g)\n    print(json.dumps(result))\nexcept Exception:\n    print('[]')\n"]);
    }

    Timer {
        id: refreshTimer
        interval: 1200
        running: true
        repeat: true
        onTriggered: root.updateAll()
    }

    Component.onCompleted: {
        root.updateAll();
    }
}
