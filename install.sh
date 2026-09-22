#!/usr/bin/env bash
set -e

# script directory and paths
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$SRC_DIR/.config"
TARGET_DIR="$HOME/.config"

echo "=== Hyprland & Quickshell Desktop Environment Installer ==="

# detect aur helper
AUR_HELPER=""
if command -v yay >/dev/null 2>&1; then
    AUR_HELPER="yay"
elif command -v paru >/dev/null 2>&1; then
    AUR_HELPER="paru"
fi

# prompt to install aur helper if missing
if [ -z "$AUR_HELPER" ]; then
    echo "no aur helper detected"
    echo "select an aur helper to install:"
    echo "1) yay"
    echo "2) paru"
    echo "3) skip"
    read -rp "enter choice [1-3]: " aur_choice
    case "$aur_choice" in
        1)
            echo "installing yay..."
            sudo pacman -S --needed --noconfirm base-devel git
            git clone https://aur.archlinux.org/yay.git /tmp/yay-install
            (cd /tmp/yay-install && makepkg -si --noconfirm)
            rm -rf /tmp/yay-install
            AUR_HELPER="yay"
            ;;
        2)
            echo "installing paru..."
            sudo pacman -S --needed --noconfirm base-devel git
            git clone https://aur.archlinux.org/paru.git /tmp/paru-install
            (cd /tmp/paru-install && makepkg -si --noconfirm)
            rm -rf /tmp/paru-install
            AUR_HELPER="paru"
            ;;
        *)
            echo "skipping aur helper installation"
            ;;
    esac
fi

# list of core packages
PACMAN_PKGS=(
    hyprland
    hyprpaper
    hyprlock
    hypridle
    kitty
    rofi-wayland
    grim
    slurp
    cliphist
    wl-clipboard
    brightnessctl
    wireplumber
    pipewire
    pipewire-pulse
    playerctl
    libnotify
    networkmanager
    bluez
    bluez-utils
    python
    python-pillow
    python-pip
    ttf-font-awesome
    cantarell-fonts
    adwaita-icon-theme
    breeze-icons
    thunar
    openvpn
    dialog
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
)

AUR_PKGS=(
    quickshell-git
)

# install pacman packages
if command -v pacman >/dev/null 2>&1; then
    echo "installing official repository packages..."
    sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}" || echo "warning: some pacman packages could not be installed"
fi

# install aur packages
if [ -n "$AUR_HELPER" ]; then
    echo "installing aur packages with $AUR_HELPER..."
    $AUR_HELPER -S --needed --noconfirm "${AUR_PKGS[@]}" || echo "warning: could not install aur packages"
else
    echo "note: no aur helper found please ensure quickshell is installed"
fi

# install python packages for color extraction
echo "installing python color extraction dependencies..."
pip install --break-system-packages materialyoucolor pillow || pip install --user materialyoucolor pillow || true

# copy configuration files
echo "deploying configuration files to $TARGET_DIR..."
mkdir -p "$TARGET_DIR"

for item in "$CONFIG_SRC"/*; do
    if [ -e "$item" ]; then
        name="$(basename "$item")"
        echo " -> installing $name"
        rm -rf "$TARGET_DIR/$name"
        cp -a "$item" "$TARGET_DIR/"
    fi
done

# ensure scripts are executable
if [ -d "$TARGET_DIR/hypr/scripts" ]; then
    chmod +x "$TARGET_DIR/hypr/scripts"/*.sh "$TARGET_DIR/hypr/scripts"/*.py 2>/dev/null || true
fi

echo "=== installation completed successfully ==="
