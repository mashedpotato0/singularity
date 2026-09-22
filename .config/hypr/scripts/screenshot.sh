#!/bin/bash

export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
FILENAME="$SCREENSHOT_DIR/Screenshot_${TIMESTAMP}.png"
TEMP_FILE="/tmp/screenshot_${TIMESTAMP}.png"

MODE="${1:-area}"

if [ "$MODE" == "full" ]; then
    grim "$TEMP_FILE"
else
    GEOM=$(slurp 2>/dev/null)
    if [ -z "$GEOM" ]; then
        exit 0
    fi
    grim -g "$GEOM" "$TEMP_FILE"
fi

if [ -f "$TEMP_FILE" ]; then
    cp "$TEMP_FILE" "$FILENAME"
    wl-copy -t image/png < "$TEMP_FILE"
    if command -v cliphist >/dev/null 2>&1; then
        cliphist store < "$TEMP_FILE"
    fi
    notify-send -i "$FILENAME" "Screenshot Taken" "Saved to $(basename "$FILENAME") and copied to clipboard"
    rm -f "$TEMP_FILE"
fi
