#!/usr/bin/env python3
"""
AppImage Integrator & Real-time Watcher
Recursively scans for AppImages, extracts desktop entries & icons,
and keeps ~/.local/share/applications/ updated in real-time.
"""

import os
import sys
import glob
import time
import shutil
import hashlib
import tempfile
import subprocess
import configparser
import ctypes
import select

HOME = os.path.expanduser("~")
APPS_DIR = os.path.join(HOME, ".local", "share", "applications")
ICONS_DIR = os.path.join(HOME, ".local", "share", "icons", "appimages")

# Directories to ignore during recursive search
EXCLUDE_DIRS = {
    ".cache", ".local", ".gemini", ".cargo", ".rustup", ".steam",
    ".wine", ".var", ".npm", "node_modules", ".git", ".vscode",
    ".gradle", ".android", ".venv", "venv", "__pycache__"
}

os.makedirs(APPS_DIR, exist_ok=True)
os.makedirs(ICONS_DIR, exist_ok=True)

def get_appimage_id(path: str) -> str:
    """Generate a stable short identifier for an AppImage path."""
    return hashlib.sha256(path.encode("utf-8")).hexdigest()[:12]

def make_executable(path: str):
    """Ensure AppImage is executable."""
    try:
        st = os.stat(path)
        os.chmod(path, st.st_mode | 0o111)
    except Exception:
        pass

def extract_metadata_and_icon(appimage_path: str, app_id: str):
    """
    Extracts internal .desktop and icon from an AppImage.
    Returns (desktop_meta_dict, icon_path)
    """
    make_executable(appimage_path)
    temp_dir = tempfile.mkdtemp(prefix=f"appimage_ext_{app_id}_")
    desktop_data = {}
    icon_dest_path = ""

    try:
        has_7z = shutil.which("7z") is not None
        if has_7z:
            subprocess.run(
                ["7z", "e", appimage_path, "-r", "-y", f"-o{temp_dir}", "*.desktop", "*.png", "*.svg", ".DirIcon"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                timeout=10
            )
        else:
            old_cwd = os.getcwd()
            os.chdir(temp_dir)
            try:
                subprocess.run(
                    [appimage_path, "--appimage-extract", "*.desktop"],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                    timeout=8
                )
                subprocess.run(
                    [appimage_path, "--appimage-extract", "*.png"],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                    timeout=8
                )
                subprocess.run(
                    [appimage_path, "--appimage-extract", "*.svg"],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                    timeout=8
                )
            finally:
                os.chdir(old_cwd)

        # Find desktop file
        desktop_files = []
        for root, _, files in os.walk(temp_dir):
            for f in files:
                if f.endswith(".desktop"):
                    desktop_files.append(os.path.join(root, f))

        if desktop_files:
            chosen_desktop = desktop_files[0]
            for df in desktop_files:
                if not os.path.islink(df) and os.path.getsize(df) > 0:
                    chosen_desktop = df
                    break

            try:
                parser = configparser.ConfigParser(interpolation=None, strict=False)
                parser.read(chosen_desktop, encoding="utf-8", errors="ignore")
                if parser.has_section("Desktop Entry"):
                    desktop_data = dict(parser.items("Desktop Entry"))
            except Exception:
                pass

        # Find icon file
        icon_files = []
        for root, _, files in os.walk(temp_dir):
            for f in files:
                if f.lower().endswith((".png", ".svg")) or f == ".DirIcon":
                    icon_files.append(os.path.join(root, f))

        if icon_files:
            best_icon = icon_files[0]
            best_size = 0
            for ic in icon_files:
                try:
                    if not os.path.islink(ic):
                        sz = os.path.getsize(ic)
                        if sz > best_size:
                            best_size = sz
                            best_icon = ic
                except Exception:
                    continue

            ext = os.path.splitext(best_icon)[1]
            if not ext:
                ext = ".png"
            target_icon = os.path.join(ICONS_DIR, f"appimage_{app_id}{ext}")
            try:
                shutil.copyfile(best_icon, target_icon)
                icon_dest_path = target_icon
            except Exception:
                pass

    except Exception:
        pass
    finally:
        shutil.rmtree(temp_dir, ignore_errors=True)

    return desktop_data, icon_dest_path

def generate_desktop_entry(appimage_path: str):
    """Generates and writes a .desktop entry for the AppImage."""
    app_id = get_appimage_id(appimage_path)
    dest_file = os.path.join(APPS_DIR, f"appimage_{app_id}.desktop")

    desktop_meta, icon_path = extract_metadata_and_icon(appimage_path, app_id)

    # Derive Name
    base_name = os.path.splitext(os.path.basename(appimage_path))[0]
    clean_name = base_name.replace("-Linux", "").replace("-x86_64", "").replace("_x86_64", "").replace("-x86", "").replace("-sdl", "")
    name = desktop_meta.get("name", clean_name)
    comment = desktop_meta.get("comment", f"AppImage application ({base_name})")
    categories = desktop_meta.get("categories", "Utility;")
    if not categories.endswith(";"):
        categories += ";"

    icon_entry = icon_path if icon_path else desktop_meta.get("icon", "application-x-executable")

    content = f"""[Desktop Entry]
Type=Application
Name={name}
Comment={comment}
Exec="{appimage_path}" %U
Icon={icon_entry}
Terminal=false
Categories={categories}
X-AppImage-Source={appimage_path}
X-AppImage-ID={app_id}
StartupNotify=true
"""

    try:
        with open(dest_file, "w", encoding="utf-8") as f:
            f.write(content)
        os.utime(dest_file, None)
        print(f"[AppImage Integrator] Registered: {name} ({appimage_path}) -> {dest_file}")
    except Exception as e:
        print(f"[AppImage Integrator] Error writing {dest_file}: {e}", file=sys.stderr)

def scan_all_appimages():
    """Recursively finds all AppImages under HOME and registers them."""
    found_paths = set()

    for root, dirs, files in os.walk(HOME):
        dirs[:] = [d for d in dirs if not d.startswith(".") and d not in EXCLUDE_DIRS]

        for f in files:
            if f.lower().endswith(".appimage"):
                full_path = os.path.abspath(os.path.join(root, f))
                found_paths.add(full_path)

    for path in found_paths:
        app_id = get_appimage_id(path)
        dest_file = os.path.join(APPS_DIR, f"appimage_{app_id}.desktop")
        if os.path.exists(dest_file):
            try:
                if os.path.getmtime(dest_file) >= os.path.getmtime(path):
                    continue
            except Exception:
                pass
        generate_desktop_entry(path)

    cleanup_orphaned_entries(found_paths)

def cleanup_orphaned_entries(existing_appimages=None):
    """Removes .desktop files for AppImages that no longer exist."""
    for f in glob.glob(os.path.join(APPS_DIR, "appimage_*.desktop")):
        try:
            with open(f, "r", encoding="utf-8", errors="ignore") as fp:
                content = fp.read()
            source_path = None
            app_id = None
            for line in content.splitlines():
                if line.startswith("X-AppImage-Source="):
                    source_path = line.split("=", 1)[1].strip()
                elif line.startswith("X-AppImage-ID="):
                    app_id = line.split("=", 1)[1].strip()

            if source_path:
                if not os.path.exists(source_path) or (existing_appimages is not None and source_path not in existing_appimages):
                    print(f"[AppImage Integrator] Removing deleted AppImage desktop entry: {f}")
                    os.remove(f)
                    if app_id:
                        for icon in glob.glob(os.path.join(ICONS_DIR, f"appimage_{app_id}.*")):
                            try:
                                os.remove(icon)
                            except Exception:
                                pass
        except Exception:
            pass

IN_CREATE = 0x00000100
IN_DELETE = 0x00000200
IN_MOVED_FROM = 0x00000040
IN_MOVED_TO = 0x00000080
IN_CLOSE_WRITE = 0x00000008
IN_ISDIR = 0x40000000

class InotifyWatcher:
    def __init__(self):
        try:
            self.libc = ctypes.CDLL("libc.so.6")
            self.fd = self.libc.inotify_init1(0x00000800)
        except Exception:
            self.fd = -1
        self.watches = {}
        self.paths = {}

    def add_watch(self, path):
        if self.fd < 0:
            return
        mask = IN_CREATE | IN_DELETE | IN_MOVED_FROM | IN_MOVED_TO | IN_CLOSE_WRITE
        wd = self.libc.inotify_add_watch(self.fd, path.encode("utf-8"), mask)
        if wd >= 0:
            self.watches[wd] = path
            self.paths[path] = wd

    def add_tree(self, root_dir):
        if not os.path.isdir(root_dir):
            return
        for root, dirs, _ in os.walk(root_dir):
            dirs[:] = [d for d in dirs if not d.startswith(".") and d not in EXCLUDE_DIRS]
            self.add_watch(root)

    def run_loop(self):
        scan_all_appimages()
        self.add_tree(HOME)

        last_full_scan = time.time()
        epoll = select.epoll()
        if self.fd >= 0:
            epoll.register(self.fd, select.EPOLLIN)

        print("[AppImage Integrator] Background watcher running...")
        while True:
            try:
                now = time.time()
                if now - last_full_scan > 60:
                    scan_all_appimages()
                    last_full_scan = now

                events = epoll.poll(timeout=2.0)
                if not events:
                    continue

                for _, event in events:
                    if event & select.EPOLLIN:
                        try:
                            buf = os.read(self.fd, 4096)
                        except BlockingIOError:
                            continue

                        offset = 0
                        while offset + 16 <= len(buf):
                            wd, mask, cookie, length = (
                                ctypes.c_int.from_buffer_copy(buf, offset).value,
                                ctypes.c_uint32.from_buffer_copy(buf, offset+4).value,
                                ctypes.c_uint32.from_buffer_copy(buf, offset+8).value,
                                ctypes.c_uint32.from_buffer_copy(buf, offset+12).value
                            )
                            offset += 16
                            name = buf[offset:offset+length].decode("utf-8", errors="ignore").rstrip("\x00")
                            offset += length

                            dir_path = self.watches.get(wd)
                            if not dir_path:
                                continue

                            full_path = os.path.join(dir_path, name)

                            if (mask & IN_ISDIR) and (mask & (IN_CREATE | IN_MOVED_TO)):
                                if not name.startswith(".") and name not in EXCLUDE_DIRS:
                                    self.add_tree(full_path)

                            if name.lower().endswith(".appimage"):
                                if mask & (IN_CREATE | IN_MOVED_TO | IN_CLOSE_WRITE):
                                    time.sleep(0.2)
                                    if os.path.exists(full_path):
                                        generate_desktop_entry(full_path)
                                elif mask & (IN_DELETE | IN_MOVED_FROM):
                                    cleanup_orphaned_entries()
            except KeyboardInterrupt:
                break
            except Exception:
                time.sleep(1)

def main():
    if "--sync" in sys.argv or "--scan" in sys.argv:
        scan_all_appimages()
    else:
        watcher = InotifyWatcher()
        watcher.run_loop()

if __name__ == "__main__":
    main()
