import os
import re
import json
import subprocess
import sys
import math
import random  # Added for shuffling

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from PIL import Image
from materialyoucolor.quantize import QuantizeCelebi
from materialyoucolor.score.score import Score
from materialyoucolor.scheme.scheme_tonal_spot import SchemeTonalSpot
from materialyoucolor.hct.hct import Hct
from materialyoucolor.palettes.tonal_palette import TonalPalette
from rofi import *

try:
    from least_busy_region import find_least_busy_region
except ImportError:
    print("Error: 'least_busy_region.py' not found. Please ensure it is in the same directory as this script.")
    sys.exit(1)

HYPRPAPER_CONF = os.path.expanduser("~/.config/hypr/hyprpaper.conf")
HYPR_COLORS_FILE = os.path.expanduser("~/.config/hypr/conf/colors.conf")
HYPR_LUA_COLORS_FILE = os.path.expanduser("~/.config/hypr/conf/colors.lua")
QS_COLORS_FILE = os.path.expanduser("~/.config/quickshell/colors.json")
KITTY_COLORS_FILE = os.path.expanduser("~/.config/kitty/colors.conf")
ROFI_THEME_FILE = os.path.expanduser("~/.config/rofi/theme.rasi")
THEME_MODE_FILE = os.path.expanduser("~/.config/hypr/theme_mode")


def get_screen_resolution():
    try:
        output = subprocess.check_output(["hyprctl", "monitors", "-j"], text=True)
        monitors = json.loads(output)

        for m in monitors:
            if m.get("focused"):
                return m["width"], m["height"]

        if monitors:
            return monitors[0]["width"], monitors[0]["height"]

    except Exception as e:
        print(f"Warning: Could not detect screen resolution ({e}). Defaulting to 1920x1080.")

    return 1920, 1080

def get_wallpaper_path(conf_path):
    if not os.path.exists(conf_path):
        print(f"Error: Config file not found at {conf_path}")
        return None

    with open(conf_path, 'r') as f:
        lines = f.readlines()

    for line in lines:
        if line.strip().startswith("$wall"):
            parts = line.split("=")
            if len(parts) > 1:
                return os.path.expanduser(parts[1].strip())

    print("Error: No wallpaper definition found in hyprpaper.conf")
    return None

def hex_from_argb(argb, force_transparent=False):
    r, g, b = 0, 0, 0
    if isinstance(argb, (list, tuple)):
        if len(argb) >= 3:
            r, g, b = argb[0], argb[1], argb[2]
    else:
        # Assume int
        r = (argb >> 16) & 0xFF
        g = (argb >> 8) & 0xFF
        b = argb & 0xFF

    alpha = "00" if force_transparent else "ff"
    return f"rgba({int(r):02x}{int(g):02x}{int(b):02x}{alpha})"

def qt_hex_from_argb(argb, force_transparent=False):
    r, g, b = 0, 0, 0
    if isinstance(argb, (list, tuple)):
        if len(argb) >= 3:
            r, g, b = argb[0], argb[1], argb[2]
    else:
        # Assume int
        r = (argb >> 16) & 0xFF
        g = (argb >> 8) & 0xFF
        b = argb & 0xFF

    alpha_hex = "00" if force_transparent else "ff"
    return f"#{alpha_hex}{int(r):02x}{int(g):02x}{int(b):02x}"

def simple_hex_from_argb(argb):
    """Returns standard #RRGGBB format for terminals"""
    r, g, b = 0, 0, 0
    if isinstance(argb, (list, tuple)):
        if len(argb) >= 3:
            r, g, b = argb[0], argb[1], argb[2]
    else:
        # Assume int
        r = (argb >> 16) & 0xFF
        g = (argb >> 8) & 0xFF
        b = argb & 0xFF
    return f"#{int(r):02x}{int(g):02x}{int(b):02x}"

def find_optimal_clock_position(image_path, widget_w=300, widget_h=150, padding=50):
    print("Analyzing wallpaper for optimal clock placement...")

    screen_w, screen_h = get_screen_resolution()
    print(f"Target Screen Resolution: {screen_w}x{screen_h}")

    try:
        coords, _ = find_least_busy_region(
            image_path,
            region_width=widget_w,
            region_height=widget_h,
            screen_width=screen_w,
            screen_height=screen_h,
            horizontal_padding=padding,
            vertical_padding=padding,
            verbose=True
        )

        print(f"Optimal Spot: X:{coords[0]}, Y:{coords[1]}")
        return coords[0], coords[1]

    except Exception as e:
        print(f"Error finding placement: {e}")
        return padding, padding

def generate_palette(image_path, is_dark=True):
    if not os.path.exists(image_path):
        print(f"Error: Image not found at {image_path}")
        return

    try:
        img = Image.open(image_path)
        img = img.convert("RGBA")
        img.thumbnail((128, 128))

        pixels = list(img.getdata())
        pixel_list = [list(p) for p in pixels]

        colors = QuantizeCelebi(pixel_list, 128)
        top_colors = Score.score(colors)

        if not top_colors:
            return

        source_color_int = top_colors[0]
        hct = Hct.from_int(source_color_int)
        scheme = SchemeTonalSpot(hct, is_dark, 0.0)

        clock_x, clock_y = find_optimal_clock_position(image_path)

        p_primary = getattr(scheme, 'primary_palette', None)
        p_secondary = getattr(scheme, 'secondary_palette', None)
        p_tertiary = getattr(scheme, 'tertiary_palette', None) or p_primary
        p_neutral = getattr(scheme, 'neutral_palette', None)
        p_neutral_variant = getattr(scheme, 'neutral_variant_palette', None)
        p_error = TonalPalette.from_int(0xFFB3261E)

        if not p_primary: return

        # Color harmony accents derived from wallpaper
        base_hue = hct.hue
        base_chroma = max(hct.chroma, 48.0)

        acc_cyan = Hct.from_hct((base_hue + 180) % 360, max(base_chroma, 50.0), 82 if is_dark else 40).to_int()
        acc_sapphire = Hct.from_hct((base_hue + 215) % 360, max(base_chroma, 50.0), 82 if is_dark else 40).to_int()
        acc_mauve = Hct.from_hct((base_hue + 290) % 360, max(base_chroma, 50.0), 82 if is_dark else 40).to_int()
        acc_peach = Hct.from_hct((base_hue + 35) % 360, max(base_chroma, 50.0), 82 if is_dark else 40).to_int()
        acc_yellow = Hct.from_hct((base_hue + 75) % 360, max(base_chroma, 50.0), 84 if is_dark else 42).to_int()
        acc_green = Hct.from_hct((base_hue + 130) % 360, max(base_chroma, 50.0), 82 if is_dark else 40).to_int()
        acc_red = Hct.from_hct(20.0, max(base_chroma, 52.0), 82 if is_dark else 40).to_int()

        if is_dark:
            palette = {
                "source_color": source_color_int,
                "is_dark": True,
                "primary": p_primary.tone(82),
                "on_primary": p_primary.tone(15),
                "primary_container": p_primary.tone(30),
                "on_primary_container": p_primary.tone(90),
                "inverse_primary": p_primary.tone(40),
                "primary_fixed": p_primary.tone(90),
                "primary_fixed_dim": p_primary.tone(82),
                "on_primary_fixed": p_primary.tone(10),
                "on_primary_fixed_variant": p_primary.tone(30),
                "secondary": p_secondary.tone(82),
                "on_secondary": p_secondary.tone(15),
                "secondary_container": p_secondary.tone(30),
                "on_secondary_container": p_secondary.tone(90),
                "secondary_fixed": p_secondary.tone(90),
                "secondary_fixed_dim": p_secondary.tone(82),
                "on_secondary_fixed": p_secondary.tone(10),
                "on_secondary_fixed_variant": p_secondary.tone(30),
                "tertiary": p_tertiary.tone(82),
                "on_tertiary": p_tertiary.tone(15),
                "tertiary_container": p_tertiary.tone(30),
                "on_tertiary_container": p_tertiary.tone(90),
                "tertiary_fixed": p_tertiary.tone(90),
                "tertiary_fixed_dim": p_tertiary.tone(82),
                "on_tertiary_fixed": p_tertiary.tone(10),
                "on_tertiary_fixed_variant": p_tertiary.tone(30),
                "error": p_error.tone(82),
                "on_error": p_error.tone(15),
                "error_container": p_error.tone(30),
                "on_error_container": p_error.tone(90),
                "accent_cyan": acc_cyan,
                "accent_sapphire": acc_sapphire,
                "accent_mauve": acc_mauve,
                "accent_peach": acc_peach,
                "accent_yellow": acc_yellow,
                "accent_green": acc_green,
                "accent_red": acc_red,
                "background": p_neutral.tone(2),
                "on_background": p_primary.tone(93),
                "surface": p_neutral.tone(3),
                "on_surface": p_primary.tone(93),
                "text_subtle": p_secondary.tone(84),
                "text_muted": p_tertiary.tone(70),
                "surface_dim": p_neutral.tone(2),
                "surface_bright": p_neutral.tone(15),
                "surface_container_lowest": p_neutral.tone(1),
                "surface_container_low": p_neutral.tone(4),
                "surface_container": p_neutral.tone(6),
                "surface_container_high": p_neutral.tone(9),
                "surface_container_highest": p_neutral.tone(12),
                "inverse_surface": p_primary.tone(82),
                "inverse_on_surface": p_neutral.tone(10),
                "surface_variant": p_primary.tone(15),
                "on_surface_variant": p_secondary.tone(70),
                "outline": p_tertiary.tone(60),
                "outline_variant": p_primary.tone(30),
                "shadow": p_neutral.tone(0),
                "scrim": p_neutral.tone(0),
                "surface_tint": p_primary.tone(82),
                "notif": p_neutral.tone(3),
            }
        else:
            palette = {
                "source_color": source_color_int,
                "is_dark": False,
                "primary": p_primary.tone(40),
                "on_primary": p_primary.tone(100),
                "primary_container": p_primary.tone(90),
                "on_primary_container": p_primary.tone(10),
                "inverse_primary": p_primary.tone(80),
                "primary_fixed": p_primary.tone(90),
                "primary_fixed_dim": p_primary.tone(80),
                "on_primary_fixed": p_primary.tone(10),
                "on_primary_fixed_variant": p_primary.tone(30),
                "secondary": p_secondary.tone(40),
                "on_secondary": p_secondary.tone(100),
                "secondary_container": p_secondary.tone(90),
                "on_secondary_container": p_secondary.tone(10),
                "secondary_fixed": p_secondary.tone(90),
                "secondary_fixed_dim": p_secondary.tone(80),
                "on_secondary_fixed": p_secondary.tone(10),
                "on_secondary_fixed_variant": p_secondary.tone(30),
                "tertiary": p_tertiary.tone(40),
                "on_tertiary": p_tertiary.tone(100),
                "tertiary_container": p_tertiary.tone(90),
                "on_tertiary_container": p_tertiary.tone(10),
                "tertiary_fixed": p_tertiary.tone(90),
                "tertiary_fixed_dim": p_tertiary.tone(80),
                "on_tertiary_fixed": p_tertiary.tone(10),
                "on_tertiary_fixed_variant": p_tertiary.tone(30),
                "error": p_error.tone(40),
                "on_error": p_error.tone(100),
                "error_container": p_error.tone(90),
                "on_error_container": p_error.tone(10),
                "accent_cyan": acc_cyan,
                "accent_sapphire": acc_sapphire,
                "accent_mauve": acc_mauve,
                "accent_peach": acc_peach,
                "accent_yellow": acc_yellow,
                "accent_green": acc_green,
                "accent_red": acc_red,
                "background": p_neutral.tone(98),
                "on_background": p_neutral.tone(10),
                "surface": p_neutral.tone(98),
                "on_surface": p_neutral.tone(10),
                "text_subtle": p_secondary.tone(30),
                "text_muted": p_tertiary.tone(45),
                "on_tertiary_fixed_variant": p_tertiary.tone(30),
                "error": p_error.tone(40),
                "on_error": p_error.tone(100),
                "error_container": p_error.tone(90),
                "on_error_container": p_error.tone(10),
                "background": p_neutral.tone(98),
                "on_background": p_neutral.tone(10),
                "surface": p_neutral.tone(98),
                "on_surface": p_neutral.tone(10),
                "surface_dim": p_neutral.tone(87),
                "surface_bright": p_neutral.tone(98),
                "surface_container_lowest": p_neutral.tone(100),
                "surface_container_low": p_neutral.tone(96),
                "surface_container": p_neutral.tone(94),
                "surface_container_high": p_neutral.tone(92),
                "surface_container_highest": p_neutral.tone(90),
                "inverse_surface": p_neutral.tone(20),
                "inverse_on_surface": p_neutral.tone(95),
                "surface_variant": p_neutral_variant.tone(90),
                "on_surface_variant": p_neutral_variant.tone(30),
                "outline": p_neutral_variant.tone(50),
                "outline_variant": p_neutral_variant.tone(80),
                "shadow": p_neutral.tone(0),
                "scrim": p_neutral.tone(0),
                "surface_tint": p_primary.tone(40),
                "notif": p_neutral.tone(98),
            }

        # --- Write Hyprland Colors ---
        os.makedirs(os.path.dirname(HYPR_COLORS_FILE), exist_ok=True)
        with open(HYPR_COLORS_FILE, "w") as f:
            f.write(f"$is_dark = {'true' if is_dark else 'false'}\n\n")
            for name, value in sorted(palette.items()):
                if name == "is_dark": continue
                make_transparent = (name == "background")
                color_str = hex_from_argb(value, force_transparent=make_transparent)
                f.write(f"$image = {image_path}\n")
                f.write(f"${name} = {color_str}\n")
                f.write("\n")
            f.write(f"$clock_x = {clock_x}\n")
            f.write(f"$clock_y = {clock_y}\n")

        # --- Write Hyprland Lua Colors ---
        with open(HYPR_LUA_COLORS_FILE, "w") as f:
            f.write("return {\n")
            f.write(f"    is_dark = {'true' if is_dark else 'false'},\n")
            for name, value in sorted(palette.items()):
                if name == "is_dark": continue
                color_str = hex_from_argb(value, force_transparent=False)
                f.write(f"    {name} = \"{color_str}\",\n")
            f.write("}\n")

        # --- Write Quickshell Colors ---
        os.makedirs(os.path.dirname(QS_COLORS_FILE), exist_ok=True)
        json_data = {}
        for name, value in palette.items():
            if name == "is_dark":
                json_data["is_dark"] = value
                continue
            make_transparent = (name == "background")
            json_data[name] = qt_hex_from_argb(value, force_transparent=make_transparent)

        json_data["suggested_clock_x"] = clock_x
        json_data["suggested_clock_y"] = clock_y

        with open(QS_COLORS_FILE, "w") as f:
            json.dump(json_data, f, indent=4)

        # --- Write Kitty Colors ---
        os.makedirs(os.path.dirname(KITTY_COLORS_FILE), exist_ok=True)

        extracted_hcts = [Hct.from_int(c) for c in top_colors]
        avg_chroma = sum([c.chroma for c in extracted_hcts]) / len(extracted_hcts) if extracted_hcts else 40.0
        theme_chroma = max(avg_chroma, 48.0)

        ansi_targets = [25.0, 140.0, 85.0, 260.0, 320.0, 195.0]

        generated_pairs = []
        kitty_tone = 80.0 if is_dark else 40.0
        kitty_bright_tone = 90.0 if is_dark else 30.0

        for target_hue in ansi_targets:
            best_match = None
            min_dist = 360.0

            for cand in extracted_hcts:
                dist = abs(cand.hue - target_hue)
                if dist > 180: dist = 360 - dist
                if dist < min_dist:
                    min_dist = dist
                    best_match = cand

            if best_match and min_dist < 45:
                acc = Hct.from_hct(best_match.hue, max(best_match.chroma, 40.0), kitty_tone).to_int()
                bright_acc = Hct.from_hct(best_match.hue, max(best_match.chroma, 40.0), kitty_bright_tone).to_int()
            else:
                acc = Hct.from_hct(target_hue, theme_chroma, kitty_tone).to_int()
                bright_acc = Hct.from_hct(target_hue, theme_chroma, kitty_bright_tone).to_int()

            generated_pairs.append((acc, bright_acc))

        random.shuffle(generated_pairs)

        kitty_map = {}
        kitty_map["background"] = palette["background"]
        kitty_map["foreground"] = palette["on_background"]
        kitty_map["selection_foreground"] = palette["on_primary"]
        kitty_map["selection_background"] = palette["primary_fixed_dim"]
        kitty_map["cursor"] = palette["primary"]
        kitty_map["cursor_text_color"] = palette["on_primary"]

        kitty_map["color0"] = palette["surface_container"]
        kitty_map["color7"] = palette["on_surface"]
        kitty_map["color8"] = palette["surface_variant"]
        kitty_map["color15"] = palette["inverse_surface"]

        for i in range(6):
            normal, bright = generated_pairs[i]
            kitty_map[f"color{i+1}"] = normal
            kitty_map[f"color{i+9}"] = bright

        with open(KITTY_COLORS_FILE, "w") as f:
            f.write("# Core Colors\n")
            for key in ["background", "foreground", "selection_foreground", "selection_background", "cursor", "cursor_text_color"]:
                f.write(f"{key:<21} {simple_hex_from_argb(kitty_map[key])}\n")

            f.write("\n# Regular Colors\n")
            for i in range(0, 8):
                key = f"color{i}"
                f.write(f"{key:<7} {simple_hex_from_argb(kitty_map[key])}\n")

            f.write("\n# Bright Colors\n")
            for i in range(8, 16):
                key = f"color{i}"
                f.write(f"{key:<7} {simple_hex_from_argb(kitty_map[key])}\n")

        generate_rofi_theme(image_path, is_dark=is_dark)
        generate_gtk_theme(palette, is_dark=is_dark)
        
        # Reload live components
        subprocess.run(["hyprctl", "reload"], check=False)
        subprocess.run(["killall", "-SIGUSR1", "kitty"], check=False)
        subprocess.run(["quickshell", "ipc", "call", "wallpaper", "reload"], check=False)
        
        print(f"Success! Mode: {'dark' if is_dark else 'light'}")

    except Exception as e:
        print(f"Error processing image: {e}")
        import traceback
        traceback.print_exc()

def generate_gtk_theme(palette, is_dark=True):
    GTK3_DIR = os.path.expanduser("~/.config/gtk-3.0")
    GTK4_DIR = os.path.expanduser("~/.config/gtk-4.0")
    os.makedirs(GTK3_DIR, exist_ok=True)
    os.makedirs(GTK4_DIR, exist_ok=True)

    try:
        color_scheme = "prefer-dark" if is_dark else "prefer-light"
        subprocess.run(["gsettings", "set", "org.gnome.desktop.interface", "color-scheme", color_scheme], check=False)
        subprocess.run(["gsettings", "set", "org.gnome.desktop.interface", "gtk-theme", "Adwaita"], check=False)
    except Exception:
        pass

    prefer_dark_val = "1" if is_dark else "0"
    icon_theme = "breeze-dark" if is_dark else "breeze"
    ini_content = f"""[Settings]
gtk-theme-name=Adwaita
gtk-application-prefer-dark-theme={prefer_dark_val}
gtk-icon-theme-name={icon_theme}
gtk-font-name=Cantarell 11
gtk-cursor-theme-name=Adwaita
gtk-cursor-theme-size=24
"""
    for d in [GTK3_DIR, GTK4_DIR]:
        with open(os.path.join(d, "settings.ini"), "w") as f:
            f.write(ini_content)

    bg_hex = simple_hex_from_argb(palette["surface"])
    base_hex = simple_hex_from_argb(palette["surface_container_lowest"])
    card_hex = simple_hex_from_argb(palette["surface_container"])
    hover_hex = simple_hex_from_argb(palette["surface_container_high"])
    active_hex = simple_hex_from_argb(palette["surface_container_highest"])
    fg_hex = simple_hex_from_argb(palette["on_surface"])
    primary_hex = simple_hex_from_argb(palette["primary"])
    on_primary_hex = simple_hex_from_argb(palette["on_primary"])
    border_hex = simple_hex_from_argb(palette["outline_variant"])

    gtk_css = f"""/* Generated GTK Material Theme */
@define-color theme_bg_color {bg_hex};
@define-color theme_fg_color {fg_hex};
@define-color theme_base_color {base_hex};
@define-color theme_text_color {fg_hex};
@define-color theme_selected_bg_color {primary_hex};
@define-color theme_selected_fg_color {on_primary_hex};
@define-color theme_view_hover_decoration_color {hover_hex};
@define-color theme_view_active_decoration_color {active_hex};
@define-color borders {border_hex};
@define-color unfocused_borders {border_hex};
@define-color headerbar_bg_color {bg_hex};
@define-color headerbar_fg_color {fg_hex};
@define-color headerbar_border_color {border_hex};
@define-color popover_bg_color {card_hex};
@define-color popover_fg_color {fg_hex};
@define-color view_bg_color {base_hex};
@define-color view_fg_color {fg_hex};
@define-color card_bg_color {card_hex};
@define-color card_fg_color {fg_hex};
@define-color sidebar_bg_color {base_hex};
@define-color sidebar_fg_color {fg_hex};
@define-color window_bg_color {bg_hex};
@define-color window_fg_color {fg_hex};

window, .background {{
    background-color: @theme_bg_color;
    color: @theme_fg_color;
}}

view, textview, treeview, iconview, .view {{
    background-color: @theme_base_color;
    color: @theme_text_color;
}}

headerbar, .titlebar {{
    background-color: @headerbar_bg_color;
    color: @headerbar_fg_color;
    border-color: @headerbar_border_color;
}}

.sidebar, .source-list, placessidebar {{
    background-color: @sidebar_bg_color;
    color: @sidebar_fg_color;
}}
"""
    for d in [GTK3_DIR, GTK4_DIR]:
        with open(os.path.join(d, "gtk.css"), "w") as f:
            f.write(gtk_css)

if __name__ == "__main__":
    wp_path = None
    mode = "dark"

    # Read existing theme mode
    if os.path.exists(THEME_MODE_FILE):
        try:
            with open(THEME_MODE_FILE, "r") as f:
                saved = f.read().strip().lower()
                if saved in ["dark", "light"]:
                    mode = saved
        except Exception:
            mode = "dark"

    # Parse arguments
    for arg in sys.argv[1:]:
        if arg == "--toggle":
            mode = "light" if mode == "dark" else "dark"
        elif arg == "--dark":
            mode = "dark"
        elif arg == "--light":
            mode = "light"
        elif os.path.exists(arg):
            wp_path = os.path.abspath(arg)

    # Save active mode
    os.makedirs(os.path.dirname(THEME_MODE_FILE), exist_ok=True)
    with open(THEME_MODE_FILE, "w") as f:
        f.write(mode + "\n")

    if not wp_path:
        wp_path = get_wallpaper_path(HYPRPAPER_CONF)

    if wp_path and os.path.exists(wp_path):
        generate_palette(wp_path, is_dark=(mode == "dark"))
    else:
        print(f"Error: No valid wallpaper found. Checked {wp_path} and {HYPRPAPER_CONF}")
