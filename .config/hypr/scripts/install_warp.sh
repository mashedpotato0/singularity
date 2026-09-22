#!/bin/bash
set -e
echo "============================================="
echo "   Installing Cloudflare WARP (Bypasses Blocks)"
echo "============================================="

PKG="/home/mash/.cache/yay/warp-cli/warp-cli-2025.8.779.0-1-x86_64.pkg.tar.zst"

if [ -f "$PKG" ]; then
    echo "Installing cached warp-cli package with pacman..."
    sudo pacman -U --noconfirm "$PKG"
elif command -v yay >/dev/null 2>&1; then
    echo "Installing via yay..."
    yay -S --noconfirm cloudflare-warp-bin
fi

echo "Starting warp-svc daemon..."
sudo systemctl enable --now warp-svc.service

echo "Initializing registration..."
warp-cli registration new 2>/dev/null || true
warp-cli mode warp 2>/dev/null || true

echo "Connecting to Cloudflare WARP..."
warp-cli connect
sleep 2

warp-cli status
echo ""
echo "✓ WARP is connected! Check your IP at https://ifconfig.me"
echo "Press Enter to close."
read -r
