#!/bin/bash

CONF_FILE="$HOME/.config/hypr/hyprpaper.conf"
SCRIPT_DIR="$HOME/.config/hypr/scripts"
WALLPAPER_DIR="$HOME/wallpapers/desktop"

# --- STARTUP MODE ---
if [ "$1" == "--startup" ]; then
    if [ -f "$CONF_FILE" ]; then
        LAST_WALL=$(grep '^\$wall =' "$CONF_FILE" | cut -d'=' -f2 | xargs)
    fi

    if [ -z "$LAST_WALL" ] || [ ! -f "$LAST_WALL" ]; then
        LAST_WALL="$HOME/wallpapers/desktop/wallpaper (78).jpg"
        if [ ! -f "$LAST_WALL" ]; then
            LAST_WALL="$HOME/wallpapers/wallpaper (78).jpg"
        fi
    fi

    if [ -f "$LAST_WALL" ]; then
        cat << EOCONF > "$CONF_FILE"
\$wall = $LAST_WALL
preload = \$wall
wallpaper = eDP-1,\$wall
splash = 0
EOCONF
        quickshell ipc call wallpaper reload >/dev/null 2>&1 || true
        "$SCRIPT_DIR/colr.sh" "$LAST_WALL"
    fi
    exit 0
fi

# --- DETECT INPUT FILE (Handles spaces with or without quotes) ---
TARGET_FILE=""

# 1. Direct single argument
if [ -n "$1" ] && [ -f "$1" ]; then
    TARGET_FILE="$1"
fi

# 2. Recombine arguments if spaces were split
if [ -z "$TARGET_FILE" ] && [ -n "$*" ]; then
    ALL_ARGS="$*"
    if [ -f "$ALL_ARGS" ]; then
        TARGET_FILE="$ALL_ARGS"
    fi
fi

# 3. Check individual arguments
if [ -z "$TARGET_FILE" ] && [ $# -gt 0 ]; then
    for arg in "$@"; do
        if [ -f "$arg" ]; then
            TARGET_FILE="$arg"
            break
        fi
    done
fi

# --- IF TARGET FILE FOUND: APPLY AS WALLPAPER ---
if [ -n "$TARGET_FILE" ] && [ -f "$TARGET_FILE" ]; then
    NEW_WALLPAPER=$(realpath "$TARGET_FILE")

    mkdir -p "$(dirname "$CONF_FILE")"
    cat << EOCONF > "$CONF_FILE"
\$wall = $NEW_WALLPAPER
preload = \$wall
wallpaper = eDP-1,\$wall
splash = 0
EOCONF

    # Refresh Quickshell background window instantly
    quickshell ipc call wallpaper reload >/dev/null 2>&1 || true

    # Extract dynamic colors and generate themes for Kitty, Hyprland, Quickshell, Rofi
    "$SCRIPT_DIR/colr.sh" "$NEW_WALLPAPER"

    # Send desktop alert
    notify-send "Wallpaper & Theme Updated" "Set to: $(basename "$NEW_WALLPAPER")"
    exit 0
fi

# --- IF NO ARGUMENTS: LAUNCH THUNAR AT WALLPAPERS FOLDER ---
notify-send "Wallpaper Selector" "Right-click any image in Thunar and choose 'Set as Wallpaper & Theme'"
thunar "$WALLPAPER_DIR" &
