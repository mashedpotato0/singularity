#!/bin/bash

# set the temporary state file location
state_file="/tmp/hdmi_monitor_state"

# default to enabled if the file does not exist
if [ ! -f "$state_file" ]; then
    echo "enabled" > "$state_file"
fi

current_state=$(cat "$state_file")

# switch based on the previous state
if [ "$current_state" = "enabled" ]; then
    hyprctl keyword monitor HDMI-A-1,disable
    echo "disabled" > "$state_file"
    echo "hdmi disabled"
else
    hyprctl keyword monitor HDMI-A-1,1920x1080@60,1920x0,1
    echo "enabled" > "$state_file"
    echo "hdmi enabled"
fi
