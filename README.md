# Hyprland & Quickshell Desktop Environment

A dynamic, OLED-black themed desktop environment powered by Hyprland and Quickshell on Arch Linux.

---

## Overview

- **Window Manager**: Hyprland (Wayland compositor)
- **Status Bar & UI Widgets**: Quickshell (QML-based bar, control center, notifications, overlays, and desktop clock)
- **Terminal**: Kitty with dynamic color scheme
- **Application Launcher & Clipboard**: Rofi (Wayland) with Cliphist
- **Screen Locker**: Hyprlock with dynamic wallpaper blur and styling
- **Idle Daemon**: Hypridle with media playback suppression and live timeout adjustment
- **Theme Generator**: Material You color extraction script (`color.py`) dynamically deriving palettes from active wallpapers

---

## Repository Structure

```
.
├── .config/
│   ├── hypr/            # hyprland lua config, hyprlock, hypridle, hyprpaper, and scripts
│   ├── quickshell/      # quickshell bar, widgets, services, panels, and settings
│   ├── kitty/           # terminal emulator configuration and color schemes
│   ├── rofi/            # application launcher, clipboard manager, and themes
│   ├── gtk-3.0/         # gtk3 theme and css
│   ├── gtk-4.0/         # gtk4 theme and css
│   ├── btop/            # btop system monitor theme
│   ├── fish/            # fish shell configuration
│   └── fontconfig/      # font rendering settings
├── install.sh           # automated installer script
└── README.md            # documentation and guide
```

---

## Keybindings

### Core Navigation
| Shortcut | Action |
| --- | --- |
| `Super` (tap) | Toggle application launcher (Rofi) |
| `Super + T` | Open Kitty terminal |
| `Super + Q` / `Super + C` | Close active window |
| `Super + E` | Open Thunar file manager |
| `Super + W` | Open web browser (Brave) |
| `Super + L` | Lock screen (Hyprlock) |
| `Super + V` | Open clipboard manager |
| `Alt + W` | Open wallpaper selector & theme generator |
| `Super + F` | Toggle fullscreen |
| `Super + Space` | Toggle floating window |
| `Super + Left/Right/Up/Down` | Move focus |
| `Super + [1-9]` | Switch to workspace 1-9 |
| `Super + Shift + [1-9]` | Move window to workspace 1-9 |
| `Super + Left Click Drag` | Move window |
| `Super + Right Click Drag` | Resize window |

### Media & Hardware
| Shortcut | Action |
| --- | --- |
| `Print` | Interactive screenshot (area select) |
| `Shift + Print` / `Super + Print` | Fullscreen screenshot |
| `XF86AudioRaiseVolume` | Volume up (+5%) |
| `XF86AudioLowerVolume` | Volume down (-5%) |
| `XF86AudioMute` | Toggle audio mute |
| `XF86AudioMicMute` | Toggle microphone mute |
| `XF86MonBrightnessUp` | Brightness up (+5%) |
| `XF86MonBrightnessDown` | Brightness down (-5%) |
| `XF86AudioPlay` / `Pause` | Toggle media playback |
| `XF86AudioNext` | Next media track |
| `XF86AudioPrev` | Previous media track |

---

## Quickshell Features & Architecture

### 1. Top Bar
- **Launcher Icon**: Left-click launches Rofi menu, right-click opens Power & Session menu.
- **Workspaces**: Real-time workspace indicators with active pill animations.
- **Active Window**: Shows current window title and icon.
- **Media Pill**: Music controls with track info, play/pause toggle, and hover popup.
- **Tray & Applets**: Bluetooth, OpenVPN, Wi-Fi, Volume, Brightness, Battery percentage, and Notification bell.
- **Clock**: Digital time with calendar popup on click.

### 2. Control Center
- Open via clicking battery, network, or notification bell applet.
- **Quick Toggles**: Wi-Fi, Sound, DND, Dark/Light mode, Screenshot, Bluetooth, Sleep, Lock.
- **Sleep Management**:
  - Left-click **Sleep** tile: cycles idle sleep timeout (`Off`, `5m`, `10m`, `15m`, `30m`, `45m`, `60m`).
  - Right-click **Sleep** tile: opens expandable chip selector.
- **Volume & Brightness Sliders**: Smooth interactive sliders with percentage indicators.
- **Notification Center**: Scrollable notification cards with clear action.

### 3. Dynamic Wallpaper Theming & Clock
- Uses `materialyoucolor` to extract tonal palettes from wallpapers.
- Automatically places the desktop clock widget in the least busy region of the wallpaper.
- Applies colors across Hyprland borders, Quickshell UI, Kitty terminal, Rofi launcher, and GTK themes.

### 4. Settings Persistence
- Preferences (such as DND state, theme mode, and idle sleep timeout) automatically save to `~/.config/quickshell/settings.json` and restore on startup.

---

## Installation

### 1. Clone & Run Installer
```bash
cd /path/to/hyprland
chmod +x install.sh
./install.sh
```

The installer will:
1. Check for `yay` or `paru` and prompt to install one if neither is found.
2. Install all official dependencies via `pacman`.
3. Install `quickshell-git` via the AUR helper.
4. Install required Python libraries (`materialyoucolor`, `pillow`).
5. Deploy all configuration directories to `~/.config/`.

---

## Post-Install Steps

1. **Enable System Services**:
   ```bash
   sudo systemctl enable --now NetworkManager
   sudo systemctl enable --now bluetooth
   systemctl --user enable --now pipewire wireplumber
   ```

2. **Add Wallpapers**:
   Place your wallpapers in `~/wallpapers/` or `~/wallpapers/desktop/`.

3. **Generate Initial Theme**:
   Press `Alt + W` in Hyprland or run:
   ```bash
   bash ~/.config/hypr/scripts/wall.sh --startup
   ```

4. **Launch Hyprland**:
   Log in through your display manager (e.g., `ly`, `sddm`, `gdm`) or run `Hyprland` from a TTY.
