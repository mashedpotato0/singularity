import os
import re
import math
from PIL import Image, ImageDraw, ImageFont
from materialyoucolor.quantize import QuantizeCelebi
from materialyoucolor.score.score import Score
from materialyoucolor.scheme.scheme_tonal_spot import SchemeTonalSpot
from materialyoucolor.hct.hct import Hct
from materialyoucolor.palettes.tonal_palette import TonalPalette

HYPRPAPER_CONF = os.path.expanduser("~/.config/hypr/hyprpaper.conf")
OUTPUT_IMAGE = os.path.expanduser("~/.config/hypr/scripts/palette.png")

def get_wallpaper_path(conf_path):
    if not os.path.exists(conf_path):
        print(f"Error: Config file not found at {conf_path}")
        return None

    with open(conf_path, 'r') as f:
        lines = f.readlines()

    pattern = re.compile(r'^\s*wallpaper\s*=\s*[^,]*,\s*(.*)$')

    for line in lines:
        if line[:5] == "$wall":
            image_path = line[8:].strip()
            return os.path.expanduser(image_path)


    print("Error: No wallpaper definition found in hyprpaper.conf")
    return None

def get_rgb_tuple(value):
    if isinstance(value, list):
        if len(value) >= 3:
            return (int(value[0]), int(value[1]), int(value[2]))

    if isinstance(value, int):
        rgb = value & 0xFFFFFF
        r = (rgb >> 16) & 0xFF
        g = (rgb >> 8) & 0xFF
        b = rgb & 0xFF
        return (r, g, b)

    return (0, 0, 0)

def get_hex_string(rgb_tuple):
    return f"#{rgb_tuple[0]:02x}{rgb_tuple[1]:02x}{rgb_tuple[2]:02x}"

def get_contrasting_text_color(rgb_tuple):

    r, g, b = rgb_tuple
    lum = (0.299 * r + 0.587 * g + 0.114 * b) / 255
    if lum > 0.5:
        return (0, 0, 0)
    else:
        return (255, 255, 255)

def render_palette_image(image_path):
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
        scheme = SchemeTonalSpot(hct, True, 0.0)

        p_primary = getattr(scheme, 'primary_palette', None)
        p_secondary = getattr(scheme, 'secondary_palette', None)

        p_tertiary = p_primary

        p_neutral = getattr(scheme, 'neutral_palette', None)
        p_neutral_variant = getattr(scheme, 'neutral_variant_palette', None)
        p_error = TonalPalette.from_int(0xFFB3261E)

        if not p_primary:
            print("Error: Could not access palettes.")
            return

        palette_data = {
            "Source": get_rgb_tuple(source_color_int),
            "Primary": get_rgb_tuple(p_primary.tone(80)),
            "On Primary": get_rgb_tuple(p_primary.tone(20)),
            "Primary Cont.": get_rgb_tuple(p_primary.tone(30)),
            "Secondary": get_rgb_tuple(p_secondary.tone(80)),
            "On Secondary": get_rgb_tuple(p_secondary.tone(20)),
            "Secondary Cont.": get_rgb_tuple(p_secondary.tone(30)),
            "Tertiary": get_rgb_tuple(p_tertiary.tone(80)),
            "On Tertiary": get_rgb_tuple(p_tertiary.tone(20)),
            "Tertiary Cont.": get_rgb_tuple(p_tertiary.tone(30)),
            "Background": get_rgb_tuple(p_neutral.tone(6)),
            "On Background": get_rgb_tuple(p_neutral.tone(90)),
            "Surface": get_rgb_tuple(p_neutral.tone(6)),
            "On Surface": get_rgb_tuple(p_neutral.tone(90)),
            "Surface Var": get_rgb_tuple(p_neutral_variant.tone(30)),
            "Outline": get_rgb_tuple(p_neutral_variant.tone(60)),
            "Error": get_rgb_tuple(p_error.tone(80)),
        }

        items = sorted(palette_data.items())
        count = len(items)

        cols = 4
        rows = math.ceil(count / cols)

        cell_width = 250
        cell_height = 120
        padding = 20

        img_width = (cols * cell_width) + ((cols + 1) * padding)
        img_height = (rows * cell_height) + ((rows + 1) * padding)

        out_img = Image.new('RGB', (img_width, img_height), color=(18, 18, 18))
        draw = ImageDraw.Draw(out_img)

        try:
            font_path = "/usr/share/fonts/TTF/DejaVuSans-Bold.ttf"
            if not os.path.exists(font_path):
                font_path = "/usr/share/fonts/noto/NotoSans-Bold.ttf"
            font = ImageFont.truetype(font_path, 18)
            small_font = ImageFont.truetype(font_path, 14)
        except:
            font = ImageFont.load_default()
            small_font = ImageFont.load_default()

        for i, (name, rgb) in enumerate(items):
            col = i % cols
            row = i // cols

            x = padding + (col * (cell_width + padding))
            y = padding + (row * (cell_height + padding))

            draw.rectangle(
                [x, y, x + cell_width, y + cell_height],
                fill=rgb,
                outline=None
            )


            hex_code = get_hex_string(rgb)
            text_color = get_contrasting_text_color(rgb)

            draw.text((x + 15, y + 35), name, font=font, fill=text_color)
            draw.text((x + 15, y + 65), hex_code, font=small_font, fill=text_color)

        os.makedirs(os.path.dirname(OUTPUT_IMAGE), exist_ok=True)
        out_img.save(OUTPUT_IMAGE)
        print(f"Success! Palette image rendered to: {OUTPUT_IMAGE}")

    except Exception as e:
        print(f"Error rendering image: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    wp_path = get_wallpaper_path(HYPRPAPER_CONF)
    if wp_path:
        render_palette_image(wp_path)
