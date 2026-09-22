import os
import sys
from PIL import Image

from materialyoucolor.quantize import QuantizeCelebi
from materialyoucolor.score.score import Score
from materialyoucolor.scheme.scheme_tonal_spot import SchemeTonalSpot
from materialyoucolor.hct.hct import Hct

HYPRPAPER_CONF = os.path.expanduser("~/.config/hypr/hyprpaper.conf")
ROFI_THEME_FILE = os.path.expanduser("~/.config/rofi/theme.rasi")

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

    print("Error: No wallpaper definition ($wall) found in hyprpaper.conf")
    return None

def rofi_hex(argb, alpha_val="FF"):

    r, g, b = 0, 0, 0
    if isinstance(argb, (list, tuple)):
        if len(argb) >= 3:
            r, g, b = argb[0], argb[1], argb[2]
    else:
        r = (argb >> 16) & 0xFF
        g = (argb >> 8) & 0xFF
        b = argb & 0xFF

    return f"#{int(r):02x}{int(g):02x}{int(b):02x}{alpha_val}"

def generate_rofi_theme(image_path, is_dark=True):
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
            print("Error: Could not extract colors.")
            return

        source_color_int = top_colors[0]
        hct = Hct.from_int(source_color_int)
        scheme = SchemeTonalSpot(hct, is_dark, 0.0)

        p_primary = scheme.primary_palette
        p_secondary = scheme.secondary_palette
        p_neutral = scheme.neutral_palette
        p_neutral_variant = scheme.neutral_variant_palette
        p_error = scheme.error_palette

        if is_dark:
            bg_col = rofi_hex(p_neutral.tone(3), "F5")
            fg_col = rofi_hex(p_primary.tone(85))
            sel_bg = rofi_hex(p_primary.tone(80))
            sel_fg = rofi_hex(p_primary.tone(15))
            active_fg = rofi_hex(p_secondary.tone(80))
            urgent_fg = rofi_hex(p_error.tone(80))
            border_col = rofi_hex(p_primary.tone(45))
            sep_col = rofi_hex(p_primary.tone(20))
            bg_alt = rofi_hex(p_neutral.tone(6))
        else:
            bg_col = rofi_hex(p_neutral.tone(98), "F2")
            fg_col = rofi_hex(p_neutral.tone(10))
            sel_bg = rofi_hex(p_primary.tone(40))
            sel_fg = rofi_hex(p_primary.tone(100))
            active_fg = rofi_hex(p_secondary.tone(40))
            urgent_fg = rofi_hex(p_error.tone(40))
            border_col = rofi_hex(p_neutral_variant.tone(50))
            sep_col = rofi_hex(p_neutral_variant.tone(80))
            bg_alt = rofi_hex(p_neutral.tone(92))

        rofi_content = f"""

* {{
    /* Base Colors */
    background:                  {bg_col};
    foreground:                  {fg_col};

    /* Normal Items */
    normal-background:           rgba ( 0, 0, 0, 0 % );
    normal-foreground:           @foreground;
    alternate-normal-background: rgba ( 0, 0, 0, 0 % );
    alternate-normal-foreground: @foreground;

    /* Selected Items */
    selected-normal-background:  {sel_bg};
    selected-normal-foreground:  {sel_fg};

    /* Active Items (Apps currently running) */
    active-background:           rgba ( 0, 0, 0, 0 % );
    active-foreground:           {active_fg};
    alternate-active-background: rgba ( 0, 0, 0, 0 % );
    alternate-active-foreground: @active-foreground;
    selected-active-background:  @selected-normal-background;
    selected-active-foreground:  @selected-normal-foreground;

    /* Urgent Items */
    urgent-background:           rgba ( 0, 0, 0, 0 % );
    urgent-foreground:           {urgent_fg};
    alternate-urgent-background: rgba ( 0, 0, 0, 0 % );
    alternate-urgent-foreground: @urgent-foreground;
    selected-urgent-background:  @urgent-foreground;
    selected-urgent-foreground:  @background;

    /* Borders and Separators */
    border-color:                {border_col};
    separatorcolor:              {sep_col};
    spacing:                     2;
    background-color:            rgba ( 0, 0, 0, 0 % );
}}

"""
        os.makedirs(os.path.dirname(ROFI_THEME_FILE), exist_ok=True)
        with open(ROFI_THEME_FILE, "w") as f:
            f.write(rofi_content)

        shared_colors_file = os.path.expanduser("~/.config/rofi/shared/colors.rasi")
        os.makedirs(os.path.dirname(shared_colors_file), exist_ok=True)
        bg_alt = rofi_hex(p_neutral.tone(15))
        with open(shared_colors_file, "w") as f:
            f.write(f"* {{\n    background:     {bg_col};\n    background-alt: {bg_alt};\n    foreground:     {fg_col};\n    selected:       {sel_bg};\n    active:         {active_fg};\n    urgent:         {urgent_fg};\n}}\n")

        print(f"Success! Rofi theme written to {ROFI_THEME_FILE} and {shared_colors_file}")

    except Exception as e:
        print(f"Error processing image: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    wp_path = None
    if len(sys.argv) > 1 and os.path.exists(sys.argv[1]):
        wp_path = os.path.abspath(sys.argv[1])
    else:
        wp_path = get_wallpaper_path(HYPRPAPER_CONF)

    if wp_path and os.path.exists(wp_path):
        generate_rofi_theme(wp_path)
    else:
        print(f"Error: No valid wallpaper found. Checked {wp_path} and {HYPRPAPER_CONF}")
