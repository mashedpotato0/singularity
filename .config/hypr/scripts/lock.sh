#!/usr/bin/env bash
# Screen Lock

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    export HYPRLAND_INSTANCE_SIGNATURE=$(ls -td "$XDG_RUNTIME_DIR/hypr/"* 2>/dev/null | head -n1 | xargs -r basename)
fi

if [ -z "$WAYLAND_DISPLAY" ]; then
    export WAYLAND_DISPLAY="wayland-1"
fi

if command -v hyprlock >/dev/null 2>&1; then
    exec hyprlock
elif command -v swaylock >/dev/null 2>&1; then
    exec swaylock -f
elif command -v gtklock >/dev/null 2>&1; then
    exec gtklock
elif command -v waylock >/dev/null 2>&1; then
    exec waylock
else
    hyprctl dispatch dpms off
    loginctl lock-session 2>/dev/null || true
fi
