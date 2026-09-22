//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "theme"
import "services"
import "components"
import "bar"
import "panels"
import "toasts"
import "overlays"
import "background"

ShellRoot {
    id: root

    // Process to ensure clean single notification daemon
    Process {
        command: ["bash", "-c", "killall -q dunst mako fnott swaync xfce4-notifyd || true"]
        running: true
    }

    // IPC Handler to control panels via CLI / Hyprland keybindings
    IpcHandler {
        target: "panel"

        function toggle(name: string) {
            PanelManager.toggle(name);
        }

        function open(name: string) {
            PanelManager.open(name);
        }

        function close() {
            PanelManager.close();
        }
    }

    // IPC Handler for wallpaper updates
    IpcHandler {
        target: "wallpaper"

        function reload() {
            WallpaperService.reload();
            Theme.reloadColors();
        }
    }

    // Generate wallpaper background, bar, panels, toasts, and overlays for every connected screen
    Variants {
        model: Quickshell.screens

        Scope {
            id: screenScope
            required property var modelData

            // Desktop Wallpaper Background
            Background {
                targetScreen: screenScope.modelData
            }

            // Top Status Bar - docked flush to top edge
            PanelWindow {
                id: barWindow
                screen: screenScope.modelData

                anchors {
                    top: true
                    left: true
                    right: true
                }

                margins {
                    top: Theme.barMarginTop
                    left: Theme.barMarginSide
                    right: Theme.barMarginSide
                }

                implicitHeight: Theme.barHeight
                color: "transparent"
                exclusionMode: HyprlandService.isFullscreen ? ExclusionMode.Ignore : ExclusionMode.Normal
                exclusiveZone: HyprlandService.isFullscreen ? 0 : (Theme.barHeight + Theme.barMarginTop)
                visible: !HyprlandService.isFullscreen
                WlrLayershell.namespace: "quickshell-bar"

                TopBar {
                    anchors.fill: parent
                }
            }

            // Interactive Control Panels & Outside-Click Backdrop
            ControlPanels {
                targetScreen: screenScope.modelData
            }

            // Notification Toast Popups
            NotificationToasts {
                targetScreen: screenScope.modelData
            }

            // Volume & Brightness OSD Overlays
            Overlays {
                targetScreen: screenScope.modelData
            }
        }
    }
}
