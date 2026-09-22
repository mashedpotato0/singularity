#!/bin/bash
PID_FILE="/tmp/openvpn_manager.pid"
STATUS_FILE="/tmp/openvpn_manager_status.txt"
LOG_FILE="/tmp/openvpn.log"

function clean_name() {
    local raw="$1"
    local base=$(echo "$raw" | sed -E 's/\.(protonvpn|ovpn|tcp|udp).*//g')
    echo "$base" | sed 's/-free-/-/'
}

# Only report CONNECTED if:
# 1. A tun device actually exists (tun0, etc.)
# 2. OR Initialization Sequence Completed is in the log AND openvpn is running
if ip -br link show 2>/dev/null | grep -q "^tun"; then
    NAME=$(cat "$STATUS_FILE" 2>/dev/null || echo "VPN")
    echo "CONNECTED:$(clean_name "$NAME")"
    exit 0
fi

if [ -f "$PID_FILE" ] && ps -p "$(cat "$PID_FILE" 2>/dev/null)" > /dev/null 2>&1; then
    if grep -q "Initialization Sequence Completed" "$LOG_FILE" 2>/dev/null; then
        NAME=$(cat "$STATUS_FILE" 2>/dev/null || echo "VPN")
        echo "CONNECTED:$(clean_name "$NAME")"
        exit 0
    fi
fi

echo "DISCONNECTED"
