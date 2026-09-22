# Quickshell Hyprland Configuration

An integrated, user-friendly desktop shell and widget suite built with [Quickshell](https://quickshell.org) tailored for **Hyprland** on Arch Linux, integrating designs and features from `~/old/quickshell`.

## ✨ Features & Architecture

### 1. Docked Modern Top Bar
- **Edge Docking**: Docked flush to the top edge of the monitor (`margins: 0`) with a subtle 1px bottom border.
- **Tightly Calibrated Exclusion Zone**: Calibrated `exclusiveZone: 20` to account for Hyprland's `gaps_out: 20`, eliminating unwanted gaps between the bar and application windows (like Kitty terminal).
- **Multi-Monitor Support**: Dynamically instantiates the bar, panels, toasts, and OSD overlays across all connected screens (`Quickshell.screens`).

### 2. Bar Applets (Top Bar)
- **🚀 Launcher Pill** (`bar/LauncherApplet.qml`): Left-click launches Rofi (`rofi -show drun`); right-click toggles Session & Power panel.
- **🔢 Workspaces Applet** (`bar/WorkspacesApplet.qml`): Live workspace indicators with cyan highlight on active workspace.
- **🪟 Active Window Applet** (`bar/ActiveWindowApplet.qml`): Displays active window title/class (inspired by `ActiveTopLevel.qml`); click toggles Windows switcher panel.
- **🎵 Media Pill** (`bar/MediaBarApplet.qml`): Live MPRIS tracking (Brave, Spotify, VLC) with inline Play/Pause; click toggles full Media player card.
- **🖥️ Refined System Tray / App Tray** (`bar/SystemTrayApplet.qml`):
  - Directly derived from `~/old/quickshell/modules/bar/widgets/SystemTray.qml`.
  - Full StatusNotifierItem (SNI) support for active tray apps (Blueman, Discord, Steam, NetworkManager, etc.).
  - Proper icon resolution handling `?path=` image URLs.
  - **Left-Click**: Native application activation (`activate`).
  - **Right-Click**: Opens native DBus context menu popup (`QsMenuOpener`) with menu items and separators.
- **🔷 Bluetooth / Blueman Applet** (`bar/BluetoothApplet.qml`):
  - Real-time Bluetooth status tracking.
  - **Left-Click**: Toggles Bluetooth panel (power toggle switch, Blueman tools).
  - **Right-Click**: Launches **Blueman Manager** (`blueman-manager`).
  - **Middle-Click**: Quick toggles Bluetooth radio.
- **📶 Wi-Fi Applet** (`bar/WifiApplet.qml`):
  - Displays Wi-Fi status and current SSID.
  - **Left-Click**: Toggles Wi-Fi & Networks panel.
  - **Right-Click**: Toggles Wi-Fi radio on/off.
- **🔊 Audio Applet** (`bar/AudioApplet.qml`):
  - Dynamic volume icon and volume percentage readout.
  - **Scroll Wheel**: Adjust volume up or down by ±5%.
  - **Middle-Click**: Quick mute toggle.
  - **Left-Click**: Toggles the Audio Control Panel with Output Sink Switcher.
- **🔋 Battery Applet** (`bar/BatteryApplet.qml`): Real-time battery charge level and charging indicator.
- **🔔 Notification Bell** (`bar/NotificationApplet.qml`): Bell icon with unread count badge.
- **🕒 Clock & Date** (`bar/ClockApplet.qml`): Digital time and date; click toggles Calendar panel.

---

### 3. Dedicated Control Panels & Overlays

- **🎵 Media Control Panel (`panels/MediaControlPanel.qml`)**: Album artwork, track title, artist, album, scrubber slider with timestamps, and full playback controls.
- **🪟 Windows Switcher Panel (`panels/WindowsControlPanel.qml`)**: Complete overview of all open windows across all workspaces with click-to-focus and close buttons.
- **🔊 Audio Control Panel (`panels/AudioControlPanel.qml`)**:
  - Sink output description (`Ryzen HD Audio Controller Speaker`).
  - Interactive volume slider and presets (Mute, 25%, 50%, 75%, 100%).
  - **Output Device Selector**: Displays all available audio sinks with one-click switching.
  - Microphone mute toggle.
- **📶 Wi-Fi & Networks Panel (`panels/WifiPanel.qml`)**:
  - Wi-Fi radio power switch (`nmcli radio wifi on/off`).
  - Active connection details (SSID, signal, security, connection type).
  - Live scan list of nearby available Wi-Fi networks with signal % and connect button.
  - Shortcut to `nmtui`.
- **🔷 Bluetooth Panel (`panels/BluetoothPanel.qml`)**:
  - Bluetooth radio toggle switch.
  - Quick action to open **Blueman Manager** (`blueman-manager`).
  - Quick action to start **Blueman Tray Applet** (`blueman-applet`).
- **🎛️ Notification Center & Quick Settings (`panels/NotificationCenter.qml`)**:
  - Quick settings grid, volume/brightness sliders, notification history with urgency badges, and session power controls.
- **📅 Calendar Panel (`panels/CalendarPanel.qml`)**: Large digital clock, date, and monthly calendar grid.
- **🔔 Toast Notifications (`toasts/NotificationToasts.qml`)**: Floating on-screen alerts in top-right corner.
- **📺 On-Screen Display (OSD) Overlays (`overlays/VolumeOsd.qml`, `overlays/BrightnessOsd.qml`)**:
  - Floating centered overlays (inspired by `~/old/quickshell/modules/overlays/`).
  - Automatically pops up for 1.8 seconds on volume or brightness changes.

---

## 🛠️ Audio & System Configuration

### Realtek ALC245 / AMD Ryzen Audio Fix
Configured at `~/.config/wireplumber/wireplumber.conf.d/50-alsa-config.conf` to automatically activate the `HiFi (Mic1, Mic2, Speaker)` profile:
```conf
monitor.alsa.rules = [
  {
    matches = [ { device.name = "alsa_card.pci-0000_06_00.6" } ]
    actions = { update-props = { device.profile = "HiFi (Mic1, Mic2, Speaker)" } }
  }
]
```

---

## 🚀 Running & IPC Commands

- **Restart Quickshell**:
  ```bash
  quickshell kill; quickshell -d -n
  ```
- **CLI / Keybinding Panel Toggles**:
  ```bash
  quickshell ipc call panel toggle wifi
  quickshell ipc call panel toggle bluetooth
  quickshell ipc call panel toggle audio
  quickshell ipc call panel toggle media
  quickshell ipc call panel toggle windows
  quickshell ipc call panel toggle notifications
  quickshell ipc call panel toggle calendar
  quickshell ipc call panel toggle power
  quickshell ipc call panel close
  ```
