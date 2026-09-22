#!/bin/bash
# Universal environment wrapper for KDE Connect commands in Hyprland

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    export HYPRLAND_INSTANCE_SIGNATURE=$(ls -td "$XDG_RUNTIME_DIR/hypr/"* 2>/dev/null | head -n1 | xargs -r basename)
fi

if [ -z "$WAYLAND_DISPLAY" ]; then
    export WAYLAND_DISPLAY="wayland-1"
fi

exec "$@"
