#!/usr/bin/env bash
set -e

# install cloudflare warp

AUR_HELPER=""
if command -v yay >/dev/null 2>&1; then
    AUR_HELPER="yay"
elif command -v paru >/dev/null 2>&1; then
    AUR_HELPER="paru"
fi

if ! command -v warp-cli >/dev/null 2>&1; then
    if [ -n "$AUR_HELPER" ]; then
        echo "installing cloudflare warp via $AUR_HELPER..."
        $AUR_HELPER -S --needed --noconfirm cloudflare-warp-bin
    else
        echo "no aur helper found to install cloudflare-warp-bin"
        exit 1
    fi
fi

# enable service
sudo systemctl enable --now warp-svc.service

# initialize registration
warp-cli registration new 2>/dev/null || true
warp-cli mode warp 2>/dev/null || true

# connect
warp-cli connect
sleep 2

warp-cli status
echo "warp setup complete"
echo "press enter to close"
read -r
