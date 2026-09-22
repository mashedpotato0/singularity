# Singularity - Hyprland & Quickshell Desktop Environment

A dynamic, OLED-black themed desktop environment powered by Hyprland and Quickshell on Arch Linux.

---

> [!NOTE]
> **Hardware & Display Scaling**
> This configuration was created and tuned for my personal laptop featuring a 16" 2560x1600 240Hz display scaled at `1.667`.
> If you have a different monitor resolution or experience scaling issues, you can easily adjust your display settings:
> - Open [`~/.config/hypr/hyprland.lua`](file:///home/mash/.config/hypr/hyprland.lua)
> - Edit the `hl.monitor` block at the top of the file:
>   ```lua
>   hl.monitor({
>       output   = "",          -- leave empty or specify your output from 'hyprctl monitors'
>       mode     = "preferred", -- e.g. "1920x1080@60" or "preferred"
>       position = "0x0",
>       scale    = 1.0,         -- adjust scale factor (1.0 for 100%, 1.25, 1.5, 2.0, etc.)
>   })
>   ```
> - Reload with `hyprctl reload` or press `Super + M` to restart.

---

## Overview

- **Window Manager**: Hyprland (Wayland compositor)
- **Status Bar & UI Widgets**: Quickshell (QML-based top bar, control center, notification toasts, overlays, and wallpaper clock)
- **Terminal**: Kitty with dynamic color scheme
- **Application Launcher & Clipboard**: Rofi (Wayland) with Cliphist
- **File Manager**: Thunar with custom actions
- **Screen Locker**: Hyprlock with dynamic wallpaper blur and styling
- **Idle Daemon**: Hypridle with media playback suppression and live timeout adjustment
- **VPN Manager**: Integrated OpenVPN interactive manager and top-bar applet
- **Theme Generator**: Material You color extraction script (`color.py`) dynamically deriving palettes from active wallpapers
- **Default Wallpaper**: [Black Clover: The Reincarnation Arc by ury-deviantart](https://www.deviantart.com/ury-deviantart/art/Black-Clover-The-Reincarnation-Arc-821199253)

---

## Repository Structure

```
.
├── .config/
│   ├── hypr/            # hyprland lua config, hyprlock, hypridle, hyprpaper, and scripts
│   ├── quickshell/      # quickshell bar, widgets, services, panels, and settings
│   ├── kitty/           # terminal emulator configuration and color schemes
│   ├── rofi/            # application launcher, clipboard manager, and themes
│   ├── Thunar/          # thunar custom actions (set wallpaper, terminal)
│   ├── gtk-3.0/         # gtk3 theme and css
│   ├── gtk-4.0/         # gtk4 theme and css
│   ├── btop/            # btop system monitor theme
│   ├── fish/            # fish shell configuration
│   └── fontconfig/      # font rendering settings
├── wallpapers/          # default wallpaper collection
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

### Media & Hardware (Laptop Fn Keys)
> [!TIP]
> The `XF86` shortcuts below correspond to your laptop's standard **Fn** function keys (e.g. `Fn + F1` through `Fn + F12` or dedicated media/volume keys).

| Shortcut | Action |
| --- | --- |
| `Print` | Interactive screenshot (area select) |
| `Shift + Print` / `Super + Print` | Fullscreen screenshot |
| `XF86AudioRaiseVolume` (`Fn + Vol+`) | Volume up (+5%) |
| `XF86AudioLowerVolume` (`Fn + Vol-`) | Volume down (-5%) |
| `XF86AudioMute` (`Fn + Mute`) | Toggle audio mute |
| `XF86AudioMicMute` (`Fn + MicMute`) | Toggle microphone mute |
| `XF86MonBrightnessUp` (`Fn + Bright+`) | Brightness up (+5%) |
| `XF86MonBrightnessDown` (`Fn + Bright-`) | Brightness down (-5%) |
| `XF86AudioPlay` / `Pause` | Toggle media playback |
| `XF86AudioNext` | Next media track |
| `XF86AudioPrev` | Previous media track |

---

## Quickshell Features & Architecture

### 1. Top Bar
- **Launcher Icon**: Left-click launches Rofi menu, right-click opens Power & Session menu.
- **Workspaces**: Real-time workspace indicators with active pill animations.
- **Active Window**: Displays current window title and icon.
- **Media Pill**: Music controls with track info, play/pause toggle, and hover popup.
- **Applets**: OpenVPN, Wi-Fi, Volume, Brightness, Battery percentage, and Notification bell.
- **Clock**: Digital time with calendar popup on click.

### 2. Control Center
- Open by clicking the battery, network, or notification bell applet.
- **Quick Toggles**: Wi-Fi, Sound, DND, Dark/Light mode, Screenshot, Cloudflare WARP, Sleep, Lock.
- **Sleep & Idle Management**:
  - Left-click **Sleep** tile: cycles idle sleep timeout (`Off`, `5m`, `10m`, `15m`, `30m`, `45m`, `60m`).
  - Right-click **Sleep** tile: opens expandable chip selector.
  - Automatically suppresses sleep/lock if audio or video is actively playing.
- **Sliders**: Smooth interactive volume and brightness sliders.
- **Notifications**: Scrollable notifications list with clear button.

### 3. Dynamic Wallpaper Theming & Clock
- Uses `materialyoucolor` to extract tonal palettes from wallpapers.
- Automatically places the desktop clock widget in the least busy region of the wallpaper.
- Applies colors across Hyprland borders, Quickshell UI, Kitty terminal, Rofi launcher, and GTK themes.
- **Changing Wallpaper**:
  - Press `Alt + W` to select a wallpaper from `~/wallpapers/`.
  - In **Thunar file manager**: simply **right-click on any image** (`.png`, `.jpg`, `.jpeg`, `.webp`, `.bmp`) and choose **"Set as Wallpaper & Theme"** to apply it instantly.

### 4. Settings Persistence
- Preferences (such as DND state, theme mode, and idle sleep timeout) automatically save to `~/.config/quickshell/settings.json` and restore on startup.

---

## Wallpaper Source

- **Default Wallpaper**: [Black Clover: The Reincarnation Arc by ury-deviantart](https://www.deviantart.com/ury-deviantart/art/Black-Clover-The-Reincarnation-Arc-821199253)
- Located in `wallpapers/` within this repository and automatically deployed to `~/wallpapers/` by the installer.

---

## VPN & Proxy Setup Guide

### 1. Cloudflare WARP (Quick Toggle)
The desktop includes an integrated Cloudflare WARP toggle in the Control Center:
- **Toggle**: Click the **WARP** tile in the Control Center to connect/disconnect.
- **Initial Setup**: If `warp-cli` is not installed or configured, clicking the tile launches the setup assistant script (`~/.config/hypr/scripts/install_warp.sh`).
- **Service**: Ensure the daemon is running:
  ```bash
  sudo systemctl enable --now warp-svc.service
  warp-cli registration new
  warp-cli mode warp
  ```

### 2. OpenVPN Manager (Top Bar)
The top bar includes a dedicated OpenVPN interactive manager and live status indicator:
1. **Save Config Files**:
   Create the directory and copy your `.ovpn` files:
   ```bash
   mkdir -p ~/Downloads/vpn
   # or
   mkdir -p ~/vpn
   ```
   Place all your `.ovpn` files inside `~/Downloads/vpn/` (or `~/vpn/`).

2. **Connecting & Disconnecting**:
   - **Connect / Switch Server**: Click the **VPN** applet in the top bar. A terminal window with an interactive menu will appear allowing you to select and connect to any server.
   - **Disconnect**: **Right-click** the **VPN** applet in the top bar to disconnect immediately.

---

## Installation

### 1. Clone & Run Installer
```bash
git clone git@github.com:mashedpotato0/singularity.git ~/singularity
cd ~/singularity
chmod +x install.sh
./install.sh
```

*(Or via HTTPS: `git clone https://github.com/mashedpotato0/singularity.git ~/singularity`)*

The installer will:
1. Check for `yay` or `paru` and prompt to install one if neither is found.
2. Install all official dependencies via `pacman` (Hyprland, Kitty, Rofi, OpenVPN, Dialog, etc.).
3. Install `quickshell-git` and `cloudflare-warp-bin` via the AUR helper.
4. Install required Python libraries (`materialyoucolor`, `pillow`).
5. **Configuration Backup & Deployment Prompt**:
   - **Option 1**: Full backup of `~/.config` to `~/.config.backup.<timestamp>`.
   - **Option 2**: Backup only affected directories to `~/.config-backup-<timestamp>`.
   - **Option 3 (Warning)**: Completely replace configs without backup (deletes old configurations).
   - **Option 4**: Cancel installation.
6. Deploy configuration directories to `~/.config/`.
7. Deploy default wallpapers to `~/wallpapers/` and initialize the dynamic theme.

---

## Post-Install Steps

1. **Enable System Services**:
   ```bash
   sudo systemctl enable --now NetworkManager
   sudo systemctl enable --now bluetooth
   sudo systemctl enable --now warp-svc.service
   systemctl --user enable --now pipewire wireplumber
   ```

2. **Add Wallpapers**:
   Place additional wallpapers in `~/wallpapers/` or `~/wallpapers/desktop/`.

3. **Generate Initial Theme**:
   Press `Alt + W` in Hyprland or run:
   ```bash
   bash ~/.config/hypr/scripts/wall.sh --startup
   ```

4. **Launch Hyprland**:
   Log in through your display manager (e.g., `ly`, `sddm`, `gdm`) or run `Hyprland` from a TTY.
