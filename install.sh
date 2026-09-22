#!/usr/bin/env bash
set -e

# script directory and paths
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$SRC_DIR/.config"
WALLPAPER_SRC="$SRC_DIR/wallpapers"
TARGET_DIR="$HOME/.config"
TARGET_WALLPAPER_DIR="$HOME/wallpapers"

# ansi color definitions
RED='\033[0;31m'
BOLD_RED='\033[1;31m'
NC='\033[0m'

echo "======================================================"
echo " hyprland and quickshell desktop environment installer"
echo "======================================================"
echo ""
echo "this script will install and configure:"
echo " - window manager: hyprland, hyprpaper, hyprlock, hypridle"
echo " - ui widgets: quickshell (top bar, control center, wallpaper clock)"
echo " - terminal and launcher: kitty, rofi-wayland, cliphist"
echo " - audio and brightness: pipewire, wireplumber, playerctl, brightnessctl"
echo " - network and vpn: networkmanager, openvpn, cloudflare warp"
echo " - file manager and tools: thunar, grim, slurp, libnotify"
echo " - dynamic theming: python materialyoucolor extraction"
echo " - configs: deployed to ~/.config (hypr, quickshell, kitty, rofi, etc)"
echo ""
read -rp "do you want to continue with the installation? [y/N]: " start_confirm
case "$start_confirm" in
    [yY]|[yY][eE][sS])
        echo "proceeding with installation..."
        ;;
    *)
        echo "installation aborted by user"
        exit 0
        ;;
esac

# detect aur helper
AUR_HELPER=""
if command -v yay >/dev/null 2>&1; then
    AUR_HELPER="yay"
elif command -v paru >/dev/null 2>&1; then
    AUR_HELPER="paru"
fi

# prompt to install aur helper if missing
if [ -z "$AUR_HELPER" ]; then
    echo ""
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
    cloudflare-warp-bin
)

# install pacman packages
if command -v pacman >/dev/null 2>&1; then
    echo "installing official repository packages..."
    sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}" || echo "warning some pacman packages could not be installed"
fi

# install aur packages
if [ -n "$AUR_HELPER" ]; then
    echo "installing aur packages with $AUR_HELPER..."
    $AUR_HELPER -S --needed --noconfirm "${AUR_PKGS[@]}" || echo "warning could not install aur packages"
else
    echo "note no aur helper found please ensure quickshell and warp are installed"
fi

# install python packages for color extraction
echo "installing python color extraction dependencies..."
pip install --break-system-packages materialyoucolor pillow || pip install --user materialyoucolor pillow || true

# backup configuration prompt
echo ""
echo "configuration deployment and backup options:"
echo "1) full backup of ~/.config"
echo "2) backup only affected folders (hypr, quickshell, kitty, rofi, etc)"
printf "${BOLD_RED}3) WARNING: completely replace configs without backup (deletes old configs)${NC}\n"
echo "4) cancel installation"
read -rp "enter choice [1-4]: " backup_choice

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

case "$backup_choice" in
    1)
        BACKUP_PATH="$HOME/.config.backup.$TIMESTAMP"
        echo "creating full backup of $TARGET_DIR to $BACKUP_PATH..."
        cp -a "$TARGET_DIR" "$BACKUP_PATH"
        echo "full backup saved to $BACKUP_PATH"
        ;;
    2)
        BACKUP_PATH="$HOME/.config-backup-$TIMESTAMP"
        echo "creating backup of affected folders to $BACKUP_PATH..."
        mkdir -p "$BACKUP_PATH"
        for item in "$CONFIG_SRC"/*; do
            if [ -e "$item" ]; then
                name="$(basename "$item")"
                if [ -e "$TARGET_DIR/$name" ]; then
                    echo " -> backing up $name"
                    cp -a "$TARGET_DIR/$name" "$BACKUP_PATH/"
                fi
            fi
        done
        echo "affected folders backed up to $BACKUP_PATH"
        ;;
    3)
        printf "${RED}proceeding without backup old configs will be deleted${NC}\n"
        ;;
    4|*)
        if [ "$backup_choice" != "4" ]; then
            echo "invalid choice cancelling installation"
        else
            echo "installation cancelled by user"
        fi
        exit 0
        ;;
esac

# deploy configuration files
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

# deploy default wallpapers
if [ -d "$WALLPAPER_SRC" ]; then
    echo "deploying default wallpapers to $TARGET_WALLPAPER_DIR..."
    mkdir -p "$TARGET_WALLPAPER_DIR"
    cp -rn "$WALLPAPER_SRC"/* "$TARGET_WALLPAPER_DIR/" 2>/dev/null || cp -r "$WALLPAPER_SRC"/* "$TARGET_WALLPAPER_DIR/" || true
fi

# ensure scripts are executable
if [ -d "$TARGET_DIR/hypr/scripts" ]; then
    chmod +x "$TARGET_DIR/hypr/scripts"/*.sh "$TARGET_DIR/hypr/scripts"/*.py 2>/dev/null || true
fi

# initialize wallpaper and theme
if [ -f "$TARGET_DIR/hypr/scripts/wall.sh" ]; then
    echo "initializing default wallpaper and dynamic theme..."
    bash "$TARGET_DIR/hypr/scripts/wall.sh" --startup 2>/dev/null || true
fi

echo "installation completed successfully"
