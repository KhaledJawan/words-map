#!/usr/bin/env python3
"""Makes every app icon file from tools/branding/icon.svg.

    python3 tools/branding/make_icons.py

The SVG is a square: a full-size background rectangle, then the logo drawn with rects and
polygons. From it this script writes:
  * res/drawable/ic_launcher_foreground.xml  the logo as a vector, for the adaptive icon and
                                            the splash screen
  * res/drawable/ic_launcher_monochrome.xml  the logo in one color, for themed icons
  * res/values/colors.xml                    ic_launcher_background and splash_background
  * res/mipmap-*/ic_launcher(_round).webp    icons for Android 7.0 and 7.1
  * tools/branding/play_store_icon_512.png   the icon for the Play Store listing
  * shared/.../drawable/splash_logo.xml      the logo of the iOS splash, as the Android one
  * iosApp/iosApp/Assets.xcassets            the iOS app icon, launch logo and launch color
"""
import json
import re
import xml.etree.ElementTree as ET
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
RES = ROOT / "app/src/main/res"
SHARED_DRAWABLES = ROOT / "shared/src/commonMain/composeResources/drawable"
IOS_ASSETS = ROOT / "iosApp/iosApp/Assets.xcassets"
SVG = Path(__file__).with_name("icon.svg")
NS = "{http://www.w3.org/2000/svg}"


def read_svg():
    root = ET.parse(SVG).getroot()
    size = float(root.attrib["viewBox"].split()[2])
    styles = dict(re.findall(r"\.(cls-\d+)\s*\{\s*fill:\s*(#[0-9a-fA-F]+)", root.findtext(f".//{NS}style") or ""))
    shapes = []  # (color, [(x, y), ...]) in drawing order
    for el in root.iter():
        tag = el.tag.replace(NS, "")
        color = styles.get(el.attrib.get("class"), "#000")
        if tag == "rect":
            x, y = float(el.attrib.get("x", 0)), float(el.attrib.get("y", 0))
            w, h = float(el.attrib["width"]), float(el.attrib["height"])
            shapes.append((color, [(x, y), (x + w, y), (x + w, y + h), (x, y + h)]))
        elif tag == "polygon":
            nums = [float(n) for n in el.attrib["points"].split()]
            shapes.append((color, list(zip(nums[0::2], nums[1::2]))))
    background, logo = shapes[0], shapes[1:]
    return size, background[0], logo


def argb(color):
    color = color.lstrip("#")
    if len(color) == 3:
        color = "".join(c * 2 for c in color)
    return "#FF" + color.upper()


def vector(size, shapes, single_color=None):
    # Adaptive icons are 108dp; launchers show the middle 72dp, so the SVG square goes there.
    scale = 72 / size
    paths = "\n".join(
        f'        <path\n            android:fillColor="{single_color or argb(color)}"\n'
        f'            android:pathData="M{" L".join(f"{x:g},{y:g}" for x, y in points)} Z" />'
        for color, points in shapes
    )
    return f'''<?xml version="1.0" encoding="utf-8"?>
<!-- Made by tools/branding/make_icons.py from tools/branding/icon.svg. -->
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="108"
    android:viewportHeight="108">
    <group
        android:scaleX="{scale:.6f}"
        android:scaleY="{scale:.6f}"
        android:translateX="18"
        android:translateY="18">
{paths}
    </group>
</vector>
'''


def render(size, background, shapes, pixels, round_icon=False, rounded=False):
    big = pixels * 4  # drawn large, then scaled down for smooth edges
    image = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    art = Image.new("RGBA", (big, big), background)
    draw = ImageDraw.Draw(art)
    for color, points in shapes:
        draw.polygon([(x * big / size, y * big / size) for x, y in points], fill=color)
    mask = Image.new("L", (big, big), 0)
    shape = ImageDraw.Draw(mask)
    if round_icon:
        shape.ellipse((0, 0, big - 1, big - 1), fill=255)
    elif rounded:
        shape.rounded_rectangle((0, 0, big - 1, big - 1), radius=big // 6, fill=255)
    else:
        shape.rectangle((0, 0, big, big), fill=255)
    image.paste(art, (0, 0), mask)
    return image.resize((pixels, pixels), Image.LANCZOS)


def render_logo(size, shapes, pixels):
    """The logo on a clear square, placed as the adaptive icon places it: the SVG square fills the middle two thirds."""
    big = pixels * 4
    image = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    scale, offset = big * 72 / 108 / size, big * 18 / 108
    for color, points in shapes:
        draw.polygon([(offset + x * scale, offset + y * scale) for x, y in points], fill=color)
    return image.resize((pixels, pixels), Image.LANCZOS)


def ios_assets(size, background, logo):
    # App Store icons are full squares without transparency; iOS rounds the corners itself.
    render(size, background, logo, 1024).convert("RGB").save(IOS_ASSETS / "AppIcon.appiconset/AppIcon-1024.png")
    # Android shows the splash logo at 288dp, so the launch logo is 288 points.
    for scale in (1, 2, 3):
        suffix = "" if scale == 1 else f"@{scale}x"
        render_logo(size, logo, 288 * scale).save(IOS_ASSETS / f"LaunchLogo.imageset/LaunchLogo{suffix}.png")
    rgb = argb(background)[3:]
    components = {c: f"0x{rgb[i:i + 2]}" for c, i in (("red", 0), ("green", 2), ("blue", 4))}
    color_set = {
        "colors": [{"color": {"color-space": "srgb", "components": {**components, "alpha": "1.000"}}, "idiom": "universal"}],
        "info": {"author": "xcode", "version": 1},
    }
    (IOS_ASSETS / "LaunchBackground.colorset/Contents.json").write_text(json.dumps(color_set, indent=2) + "\n", encoding="utf-8")


def main():
    size, background, logo = read_svg()
    drawable = RES / "drawable"
    (drawable / "ic_launcher_foreground.xml").write_text(vector(size, logo), encoding="utf-8")
    (SHARED_DRAWABLES / "splash_logo.xml").write_text(vector(size, logo), encoding="utf-8")
    # Themed icons use only the shape; the dark box behind the letters would be a solid block.
    letters = [shape for shape in logo if shape[0] != "#000"]
    (drawable / "ic_launcher_monochrome.xml").write_text(vector(size, letters, "#FFFFFFFF"), encoding="utf-8")

    colors = RES / "values/colors.xml"
    text = colors.read_text(encoding="utf-8")
    for name in ("ic_launcher_background", "splash_background"):
        text = re.sub(rf'(<color name="{name}">)[^<]*(</color>)', rf"\g<1>{argb(background)}\g<2>", text)
    colors.write_text(text, encoding="utf-8")

    for folder, pixels in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
        out = RES / f"mipmap-{folder}"
        render(size, background, logo, pixels, rounded=True).save(out / "ic_launcher.webp", lossless=True)
        render(size, background, logo, pixels, round_icon=True).save(out / "ic_launcher_round.webp", lossless=True)
        (out / "ic_launcher_foreground.png").unlink(missing_ok=True)
    # Play adds its own rounded corners, so the store icon is a full square.
    render(size, background, logo, 512).convert("RGB").save(Path(__file__).with_name("play_store_icon_512.png"))
    ios_assets(size, background, logo)
    print("icons written; background", argb(background))


if __name__ == "__main__":
    main()
