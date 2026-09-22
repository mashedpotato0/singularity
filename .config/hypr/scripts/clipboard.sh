#!/bin/bash

export PATH="$HOME/.local/bin:$PATH"

# Check if daemon is running — start it if not
if ! pgrep -x "cliphist" > /dev/null 2>&1; then
    wl-paste --type text --watch cliphist store &
fi

# Check if there's anything in history
COUNT=$(cliphist list 2>/dev/null | wc -l)
if [ "$COUNT" -eq 0 ]; then
    notify-send "Clipboard" "Clipboard history is empty. Copy something first!" -i edit-paste
    exit 0
fi

# Show rofi clipboard picker using style-7
SELECTION=$(cliphist list 2>/dev/null | rofi \
    -dmenu \
    -theme "$HOME/.config/rofi/style-7.rasi" \
    -p "📋 Clipboard" \
    -placeholder "Search clipboard history..." \
    -display-columns 2 \
    -display-column-separator $'\t')

if [ -n "$SELECTION" ]; then
    # Decode and copy the selected entry
    printf '%s' "$SELECTION" | cliphist decode | wl-copy
    notify-send "Clipboard" "Pasted to clipboard" -i edit-paste -t 2000
fi
