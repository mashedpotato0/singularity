#!/usr/bin/env bash

# update hypridle configuration based on minutes
mins="${1:-15}"
conf_file="$HOME/.config/hypr/hypridle.conf"

if [ "$mins" -le 0 ]; then
    cat > "$conf_file" << 'EOF'
# hypridle configuration

general {
    lock_cmd = pidof hyprlock || hyprlock
    before_sleep_cmd = loginctl lock-session
    after_sleep_cmd = hyprctl dispatch dpms on
}
EOF
else
    suspend_sec=$((mins * 60))
    if [ "$suspend_sec" -gt 180 ]; then
        screen_off_sec=$((suspend_sec - 120))
    else
        screen_off_sec=$((suspend_sec * 8 / 10))
    fi
    if [ "$screen_off_sec" -gt 120 ]; then
        lock_sec=$((screen_off_sec - 60))
    else
        lock_sec=$((screen_off_sec * 8 / 10))
    fi

    cat > "$conf_file" << EOF
# hypridle configuration

general {
    lock_cmd = pidof hyprlock || hyprlock
    before_sleep_cmd = loginctl lock-session
    after_sleep_cmd = hyprctl dispatch dpms on
}

# screen lock timeout
listener {
    timeout = $lock_sec
    on-timeout = bash \$HOME/.config/hypr/scripts/idle_handler.sh lock
}

# screen off timeout
listener {
    timeout = $screen_off_sec
    on-timeout = bash \$HOME/.config/hypr/scripts/idle_handler.sh screen_off
    on-resume = hyprctl dispatch dpms on
}

# system suspend timeout
listener {
    timeout = $suspend_sec
    on-timeout = bash \$HOME/.config/hypr/scripts/idle_handler.sh suspend
}
EOF
fi

# restart hypridle to apply changes live
killall -q hypridle || true
if command -v hypridle >/dev/null 2>&1; then
    hypridle >/dev/null 2>&1 &
fi
