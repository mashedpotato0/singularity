pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../services"

Item {
    id: root
    visible: false

    property var colors: null

    FileView {
        id: colorsFile
        path: Quickshell.env("HOME") + "/.config/quickshell/colors.json"
        watchChanges: true
        onLoaded: root.reloadColors()
        onFileChanged: {
            colorsFile.reload();
            root.reloadColors();
        }
    }

    function reloadColors() {
        try {
            let txt = "";
            if (typeof colorsFile.text === "function") {
                txt = colorsFile.text();
            } else if (typeof colorsFile.text === "string") {
                txt = colorsFile.text;
            }
            if (txt && txt.length > 0) {
                root.colors = JSON.parse(txt);
            }
        } catch (e) {
            console.log("failed to parse colors.json", e);
        }
    }

    Component.onCompleted: {
        reloadColors();
    }

    readonly property bool isDark: (colors && colors.is_dark !== undefined) ? colors.is_dark : true

    // Surface & Background Colors (Pure Dark Mode Base)
    readonly property color bg: colors ? (colors.surface || "#0a0a0c") : "#0a0a0c"
    readonly property color bgDark: colors ? (colors.surface_container_lowest || "#050507") : "#050507"
    readonly property color bgAlpha: {
        if (!colors || !colors.surface) return "#e60a0a0c";
        let c = Qt.color(colors.surface);
        return Qt.rgba(c.r, c.g, c.b, 0.88);
    }
    readonly property color cardBg: colors ? (colors.surface_container || "#111116") : "#111116"
    readonly property color cardBgHover: colors ? (colors.surface_container_high || "#1a1a22") : "#1a1a22"
    readonly property color cardBgActive: colors ? (colors.surface_container_highest || "#24242f") : "#24242f"
    readonly property color cardBgDark: colors ? (colors.surface_container_lowest || "#050507") : "#050507"

    // Borders (Pure Dark Subtle Borders with Theme Active Border)
    readonly property color border: colors ? (colors.outline_variant || "#1e1e28") : "#1e1e28"
    readonly property color borderHover: colors ? (colors.outline || colors.primary || "#383848") : "#383848"
    readonly property color borderActive: colors ? colors.primary : accent

    // Accent Colors: Full takeover from wallpaper palette
    readonly property color accent: colors ? (colors.primary || "#c4c3ee") : "#c4c3ee"
    readonly property color accentCyan: colors ? (colors.accent_cyan || accent) : accent
    readonly property color accentSapphire: colors ? (colors.accent_sapphire || colors.secondary || accent) : accent
    readonly property color accentMauve: colors ? (colors.accent_mauve || colors.tertiary || accent) : accent
    readonly property color accentPeach: colors ? (colors.accent_peach || accent) : accent
    readonly property color accentGreen: colors ? (colors.accent_green || accent) : accent
    readonly property color accentYellow: colors ? (colors.accent_yellow || accent) : accent
    readonly property color accentRed: colors ? (colors.accent_red || colors.error || "#ff5555") : "#ff5555"

    // Foreground / Text Colors (Light & readable wallpaper tones)
    readonly property color fg: colors ? (colors.on_surface || "#e2e1ff") : "#e2e1ff"
    readonly property color fgSubtle: colors ? (colors.text_subtle || colors.secondary || "#c6c4dd") : "#c6c4dd"
    readonly property color fgMuted: colors ? (colors.text_muted || colors.tertiary || "#908fa5") : "#908fa5"
    readonly property color fgInverse: colors ? (colors.on_primary || (isDark ? "#050507" : "#ffffff")) : "#050507"

    // Typography
    readonly property string fontFamily: "Adwaita Sans, FreeSans, sans-serif"
    readonly property string fontMono: "Adwaita Mono, FreeMono, monospace"
    readonly property int fontSizeTiny: 10
    readonly property int fontSizeSmall: 11
    readonly property int fontSizeRegular: 13
    readonly property int fontSizeMedium: 15
    readonly property int fontSizeLarge: 18
    readonly property int fontSizeHuge: 24

    // Clock placement coordinates
    readonly property int clockX: colors ? (colors.suggested_clock_x || 60) : 60
    readonly property int clockY: colors ? (colors.suggested_clock_y || 60) : 60

    // Radii
    readonly property int radiusSmall: 6
    readonly property int radiusMedium: 10
    readonly property int radiusLarge: 14
    readonly property int radiusCard: 16
    readonly property int radiusPill: 999

    // Bar Sizing
    readonly property int barHeight: 38
    readonly property int barMarginTop: 0
    readonly property int barMarginSide: 0

    // Animations
    readonly property int animFast: 150
    readonly property int animNormal: 250
    readonly property int animSlow: 350

    function toggleDarkMode() {
        HyprlandService.execApp("bash ~/.config/hypr/scripts/colr.sh --toggle");
    }
}
