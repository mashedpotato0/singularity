#!/usr/bin/env bash

# check if audio or media playback is active
is_media_playing() {
    if command -v playerctl >/dev/null 2>&1; then
        if playerctl -a status 2>/dev/null | grep -qi "playing"; then
            return 0
        fi
    fi
    if command -v pactl >/dev/null 2>&1; then
        if pactl list sink-inputs 2>/dev/null | grep -qi "state: RUNNING"; then
            return 0
        fi
    fi
    return 1
}

action="$1"

case "$action" in
    lock)
        if ! is_media_playing; then
            loginctl lock-session
        fi
        ;;
    screen_off)
        if ! is_media_playing; then
            hyprctl dispatch dpms off
        fi
        ;;
    suspend)
        if ! is_media_playing; then
            systemctl suspend
        fi
        ;;
    *)
        exit 1
        ;;
esac
