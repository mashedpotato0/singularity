#!/bin/bash
# ==============================================================================
#           Interactive Terminal VPN Manager (TUI Edition)
# ==============================================================================

CONFIG_DIR="/home/mash/Downloads/vpn"
if [ ! -d "$CONFIG_DIR" ] && [ -d "$HOME/vpn" ]; then
    CONFIG_DIR="$HOME/vpn"
fi

PID_FILE="/tmp/openvpn_manager.pid"
LOG_FILE="/tmp/openvpn.log"
STATUS_FILE="/tmp/openvpn_manager_status.txt"

export PATH="/home/mash/.local/bin:$PATH"
export LD_LIBRARY_PATH="/home/mash/.local/lib:$LD_LIBRARY_PATH"
OPENVPN_CMD="/home/mash/.local/bin/openvpn"

# --- UI Tool Detection ---
if command -v dialog &> /dev/null; then
    GUI_CMD="dialog"
    export DIALOGOPTS="--colors"
elif command -v whiptail &> /dev/null; then
    GUI_CMD="whiptail"
else
    echo "Error: Neither 'dialog' nor 'whiptail' is installed."
    exit 1
fi

function clean_name() {
    local raw="$1"
    local base=$(echo "$raw" | sed -E 's/\.(protonvpn|ovpn|tcp|udp).*//g')
    echo "$base" | sed 's/-free-/-/'
}

# --- Helper: Get Status String ---
function get_status_string() {
    # Check if a tun interface actually exists
    if ip -br link show 2>/dev/null | grep -q "^tun"; then
        local config_name=$(cat "$STATUS_FILE" 2>/dev/null || echo "VPN")
        local display_name=$(clean_name "$config_name")
        if [ "$GUI_CMD" == "dialog" ]; then
            echo "\Z2CONNECTED\Zn to \Z4$display_name\Zn"
        else
            echo "CONNECTED to $display_name"
        fi
        return
    fi

    # Stale files cleanup
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE" 2>/dev/null)
        if [ -z "$pid" ] || ! ps -p "$pid" > /dev/null 2>&1; then
            rm -f "$PID_FILE" "$STATUS_FILE"
        fi
    fi

    echo "DISCONNECTED"
}

# --- Action: Connect ---
function connect_vpn() {
    local config_path="$1"
    local config_name=$(basename "$config_path" .ovpn)

    # Disconnect any existing session
    disconnect_silent

    # Prepare log and status
    > "$LOG_FILE"
    chmod 666 "$LOG_FILE" 2>/dev/null || true
    rm -f "$PID_FILE" "$STATUS_FILE"

    # Prepare Cloudflare WARP based on protocol (UDP uses full WARP tunnel, TCP uses SOCKS5 proxy)
    if command -v warp-cli &>/dev/null; then
        if [[ "$config_path" == *".udp."* ]]; then
            warp-cli mode warp 2>/dev/null || true
            warp-cli connect 2>/dev/null || true
        else
            warp-cli mode proxy 2>/dev/null || true
            warp-cli connect 2>/dev/null || true
        fi
        sleep 1
    fi

    # Start OpenVPN daemon
    setsid "$OPENVPN_CMD" --config "$config_path" --daemon --log "$LOG_FILE" --writepid "$PID_FILE"

    local connected=false
    local total_steps=12

    for ((i = 1 ; i <= total_steps ; i++)); do
        sleep 1
        local pct=$(( i * 100 / total_steps ))
        echo $pct

        # Check for REAL connection completion
        if grep -q "Initialization Sequence Completed" "$LOG_FILE" 2>/dev/null; then
            connected=true
            break
        fi

        # Early break if process died
        if [ -f "$PID_FILE" ]; then
            local pid=$(cat "$PID_FILE" 2>/dev/null)
            if [ -n "$pid" ] && ! ps -p "$pid" > /dev/null 2>&1; then
                break
            fi
        fi

        # Early detect connection reset loop
        local reset_count=$(grep -c "Connection reset" "$LOG_FILE" 2>/dev/null || echo 0)
        if [ "$reset_count" -ge 3 ]; then
            break
        fi
    done | $GUI_CMD --gauge "Connecting to $(clean_name "$config_name")...\nVerifying handshake & routing tunnel..." 7 60 0

    # Also verify tun interface
    if [ "$connected" = true ] || ip -br link show 2>/dev/null | grep -q "^tun"; then
        echo "$config_name" > "$STATUS_FILE"
        chmod 666 "$STATUS_FILE" 2>/dev/null || true
        chmod 666 "$PID_FILE" 2>/dev/null || true
        $GUI_CMD --title "Success" --infobox "✓ Connected to $(clean_name "$config_name")!\nTunnel is active and traffic is encrypted." 6 55
        sleep 2
    else
        # Kill the failed process
        disconnect_silent

        local failure_reason="Handshake timed out. No encrypted tunnel was created."
        if grep -q "Connection reset" "$LOG_FILE" 2>/dev/null; then
            failure_reason="ISP / Network DPI blocked connection (TCP Reset received)."
        elif grep -q "AUTH_FAILED" "$LOG_FILE" 2>/dev/null; then
            failure_reason="Authentication failed. Invalid username or password."
        elif grep -q "TLS Error" "$LOG_FILE" 2>/dev/null; then
            failure_reason="TLS handshake failed or packets dropped by firewall."
        fi

        local log_tail=""
        if [ -s "$LOG_FILE" ]; then
            log_tail="\n\nRecent logs:\n$(tail -n 6 "$LOG_FILE")"
        fi

        $GUI_CMD --title "Connection Failed" --msgbox "Failed to connect to $(clean_name "$config_name").\n\nReason: $failure_reason$log_tail" 16 68
    fi
}

function disconnect_silent() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE" 2>/dev/null)
        if [ -n "$pid" ]; then
            kill "$pid" &>/dev/null || true
        fi
    fi
    pkill -f "openvpn.*Downloads/vpn" &>/dev/null || true
    pkill -f "openvpn.bin.*Downloads/vpn" &>/dev/null || true
    rm -f "$PID_FILE" "$STATUS_FILE"
}

# --- Action: Disconnect ---
function disconnect_vpn() {
    if ! ip -br link show 2>/dev/null | grep -q "^tun" && [ ! -f "$PID_FILE" ]; then
        $GUI_CMD --title "Info" --msgbox "Not currently connected." 8 45
        return
    fi

    disconnect_silent
    $GUI_CMD --infobox "Disconnected." 5 30
    sleep 1
}

# --- Menu: Server Selection ---
function server_menu() {
    local protocol="$1"
    local country_code="$2"
    local server_files=()
    local menu_items=()

    while IFS= read -r file; do
        [ -e "$file" ] && server_files+=("$file")
    done < <(find "$CONFIG_DIR" -name "*${country_code,,}*.$protocol.ovpn" | sort)

    if [ ${#server_files[@]} -eq 0 ]; then
        $GUI_CMD --title "Error" --msgbox "No config files found in $CONFIG_DIR." 8 50
        return
    fi

    menu_items+=("RANDOM" "Connect to a random server")
    for i in "${!server_files[@]}"; do
        local name=$(basename "${server_files[$i]}" .ovpn)
        local display=$(clean_name "$name")
        menu_items+=("$i" "$display")
    done

    while true; do
        local status=$(get_status_string)
        local choice=$($GUI_CMD --title "Servers: ${country_code^^} ($protocol)" \
            --menu "Current Status: $status\n\nSelect a server:" 22 65 12 \
            "${menu_items[@]}" 3>&1 1>&2 2>&3)

        if [ $? -eq 0 ]; then
            if [ "$choice" == "RANDOM" ]; then
                local rand=$(( RANDOM % ${#server_files[@]} ))
                connect_vpn "${server_files[$rand]}"
                return 10
            else
                connect_vpn "${server_files[$choice]}"
                return 10
            fi
        else
            return 0
        fi
    done
}

# --- Menu: Country Selection ---
function country_menu() {
    local protocol="$1"
    local countries=()
    local menu_items=()

    while IFS= read -r line; do
        countries+=("$line")
    done < <(find "$CONFIG_DIR" -name "*.$protocol.ovpn" -printf "%f\n" | cut -d'-' -f1 | sort -u | tr 'a-z' 'A-Z')

    if [ ${#countries[@]} -eq 0 ]; then
        $GUI_CMD --title "Error" --msgbox "No .$protocol.ovpn files found in $CONFIG_DIR." 8 50
        return
    fi

    for c in "${countries[@]}"; do
        menu_items+=("$c" "Servers")
    done

    while true; do
        local status=$(get_status_string)
        local choice=$($GUI_CMD --title "Country Selection ($protocol)" \
            --menu "Current Status: $status\n\nSelect a Region:" 22 60 12 \
            "${menu_items[@]}" 3>&1 1>&2 2>&3)

        if [ $? -eq 0 ]; then
            server_menu "$protocol" "$choice"
            if [ $? -eq 10 ]; then return; fi
        else
            return
        fi
    done
}

# --- Main Menu ---
function main_menu() {
    while true; do
        local status=$(get_status_string)
        local choice=$($GUI_CMD --title "VPN Manager (WARP Bypass)" \
            --menu "Current Status: $status\n\nChoose an option:" 20 65 6 \
            "UDP" "UDP Servers (Fastest - Chained via WARP Tunnel)" \
            "TCP" "TCP Servers (Chained via WARP SOCKS5 Proxy)" \
            "Disconnect" "Terminate connection" \
            "Quit" "Exit Manager" 3>&1 1>&2 2>&3)

        if [ $? -ne 0 ]; then exit 0; fi

        case "$choice" in
            "UDP") country_menu "udp" ;;
            "TCP") country_menu "tcp" ;;
            "Disconnect") disconnect_vpn ;;
            "Quit") exit 0 ;;
        esac
    done
}

if [ "$EUID" -ne 0 ]; then
    echo "Error: Please run with sudo."
    exit 1
fi

main_menu
