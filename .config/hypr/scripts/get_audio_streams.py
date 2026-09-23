#!/usr/bin/env python3
import json
import subprocess
import os
import re

def get_proc_name(pid):
    if not pid:
        return None
    try:
        with open(f"/proc/{pid}/environ", "rb") as f:
            env = dict(line.decode("utf-8", errors="ignore").split("=", 1) for line in f.read().split(b"\0") if b"=" in line)
            if "ARGV0" in env:
                base = os.path.basename(env["ARGV0"])
                return re.sub(r"\.(?:AppImage|bin|exe|sh)$", "", base, flags=re.I)
    except Exception:
        pass
    try:
        with open(f"/proc/{pid}/cmdline", "rb") as f:
            args = [a.decode("utf-8", errors="ignore") for a in f.read().split(b"\0") if a]
        for arg in args:
            m = re.search(r"/([^/]+)\.(?:AppImage|desktop)", arg)
            if m:
                return m.group(1)
            if "accella" in arg.lower() or "accela" in arg.lower():
                return "ACCELA"
    except Exception:
        pass
    try:
        with open(f"/proc/{pid}/comm", "r") as f:
            comm = f.read().strip()
            if comm and not comm.startswith("python") and comm != "electron":
                return comm
    except Exception:
        pass
    return None

SEP_APPS = {"mpv", "brave", "brave-browser", "chrome", "chromium", "firefox", "vlc", "spotify", "zen", "zen-browser", "floorp", "librewolf"}

try:
    out = subprocess.check_output(["pw-dump"], stderr=subprocess.DEVNULL)
    data = json.loads(out)
    groups = {}
    for obj in data:
        info = obj.get("info", {})
        props = info.get("props", {})
        if props.get("media.class") == "Stream/Output/Audio":
            obj_id = obj.get("id")
            pid = props.get("application.process.id")
            raw_name = props.get("application.name") or props.get("node.description") or props.get("media.name") or "App"
            media_name = props.get("media.name", "")
            resolved_app = get_proc_name(pid)
            display_name = resolved_app if resolved_app else raw_name
            vol = 1.0
            muted = False
            props_params = info.get("params", {}).get("Props", [])
            if props_params and isinstance(props_params, list) and len(props_params) > 0:
                p = props_params[0]
                cv = p.get("channelVolumes", [])
                if cv and len(cv) > 0:
                    lin = sum(cv) / len(cv)
                    vol = lin ** (1.0 / 3.0)
                elif "volume" in p:
                    vol = float(p.get("volume", 1.0))
                muted = bool(p.get("mute", False))
            app_lower = (display_name or raw_name or "").lower()
            if any(s in app_lower for s in SEP_APPS):
                key = f"stream_{obj_id}"
            elif pid:
                key = f"pid_{pid}"
            else:
                key = f"stream_{obj_id}"
            if key not in groups:
                groups[key] = {"key": key, "name": display_name, "pid": pid, "ids": [], "streams": [], "volume": 0.0, "muted": True}
            groups[key]["ids"].append(obj_id)
            groups[key]["streams"].append({"id": obj_id, "name": raw_name, "mediaName": media_name, "volume": vol, "muted": muted})
    result = []
    for g in groups.values():
        vols = [s["volume"] for s in g["streams"]]
        g["volume"] = max(vols) if vols else 1.0
        g["muted"] = all(s["muted"] for s in g["streams"])
        g["streamCount"] = len(g["streams"])
        result.append(g)
    print(json.dumps(result))
except Exception:
    print("[]")
