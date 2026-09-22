#!/bin/bash
set -e
echo "============================================="
echo " Restoring Previous Laptop NetworkManager VPN"
echo "============================================="

sudo pacman -S --needed --noconfirm networkmanager-openvpn openvpn

echo "Enabling systemd-resolved..."
sudo systemctl enable --now systemd-resolved.service || true

USER="fyC3sFCv_kkukUfKISc.QC8P"
PASS="6EcIad8V+wK/g9pyNIJ2VDYx"
CONFIG_DIR="/home/mash/Downloads/vpn"

echo "Importing VPN connections into NetworkManager..."
count=0
for f in "$CONFIG_DIR"/*.ovpn; do
    [ -e "$f" ] || continue
    NAME=$(basename "$f" .ovpn)
    if ! nmcli connection show "$NAME" >/dev/null 2>&1; then
        nmcli connection import type openvpn file "$f" >/dev/null 2>&1 || true
        nmcli connection modify "$NAME" vpn.user-name "$USER" >/dev/null 2>&1 || true
        nmcli connection modify "$NAME" vpn.secrets "password=$PASS" >/dev/null 2>&1 || true
        count=$((count + 1))
        echo "Imported: $NAME"
    fi
done

echo "Successfully imported $count VPN profiles into NetworkManager!"
echo "Press Enter to close."
read -r
