#!/bin/bash

state_file="/tmp/hdmi_monitor_state"
conf_file="$HOME/.config/hypr/hyprpaper.conf"

if [ ! -f "$state_file" ]; then
    echo "enabled" > "$state_file"
fi

current_state=$(cat "$state_file")

if [ "$current_state" = "enabled" ]; then
    hyprctl keyword monitor HDMI-A-1,disable
    echo "disabled" > "$state_file"
    echo "hdmi disabled"
else
    hyprctl keyword monitor HDMI-A-1,1920x1080@60,1920x0,1
    echo "enabled" > "$state_file"
    echo "hdmi enabled"
fi

sleep 0.5

# restart quickshell
killall quickshell
quickshell &
disown

# reapply wallpaper dynamically using ipc
last_wall=$(grep '^\$wall =' "$conf_file" | cut -d'=' -f2 | xargs)
hyprctl hyprpaper wallpaper ",$last_wall"
