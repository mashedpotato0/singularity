#!/bin/bash
if pgrep -x rofi >/dev/null 2>&1; then
    killall -9 rofi
else
    # Ensure Flatpak export directories are in XDG_DATA_DIRS
    export XDG_DATA_DIRS="${HOME}/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
    rofi -show drun
fi
