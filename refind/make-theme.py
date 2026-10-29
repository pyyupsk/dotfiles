#!/usr/bin/env python3
"""Draw the rEFInd theme: blurred Golden Gate background, macOS-style icons with
their names under them. Run after the fonts, wallpaper and theme steps.
Usage: make-theme.py <output dir>"""
import sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageFont

WALLPAPER = "/usr/local/share/backgrounds/27-Golden-Gate-Dark.png"
ICONS = Path.home() / ".local/share/icons/MacTahoeLiquidKde-Icons-Regular-Dark/apps/256"
FONT = "/usr/local/share/fonts/apple/SF-Pro-Display-Medium.otf"
SCREEN = (1920, 1080)
TILE = 256

out = Path(sys.argv[1])
out.mkdir(parents=True, exist_ok=True)

# Background: fill the screen, blur and dim it like the macOS startup picker
bg = Image.open(WALLPAPER).convert("RGB")
scale = max(SCREEN[0] / bg.width, SCREEN[1] / bg.height)
bg = bg.resize((round(bg.width * scale), round(bg.height * scale)), Image.LANCZOS)
left, top = (bg.width - SCREEN[0]) // 2, (bg.height - SCREEN[1]) // 2
bg = bg.crop((left, top, left + SCREEN[0], top + SCREEN[1])).filter(ImageFilter.GaussianBlur(28))
bg = Image.blend(bg, Image.new("RGB", SCREEN, (0, 0, 0)), 0.35)
bg.save(out / "background.png")

font = ImageFont.truetype(FONT, 26)


def tile(icon_name, label, path):
    t = Image.new("RGBA", (TILE, TILE))
    icon = Image.open(ICONS / icon_name).convert("RGBA").resize((168, 168), Image.LANCZOS)
    t.alpha_composite(icon, ((TILE - 168) // 2, 14))
    d = ImageDraw.Draw(t)
    w = d.textlength(label, font=font)
    d.text(((TILE - w) / 2 + 1, 202), label, font=font, fill=(0, 0, 0, 110))
    d.text(((TILE - w) / 2, 200), label, font=font, fill=(255, 255, 255, 255))
    t.save(path)


tile("distributor-logo-archlinux.png", "Arch Linux", out / "os_arch.png")
tile("distributor-logo-windows.png", "Windows", out / "os_win.png")
Image.open(ICONS / "system-settings.png").convert("RGBA").resize((96, 96), Image.LANCZOS).save(
    out / "func_firmware.png")


def glass(size, radius, path):
    g = Image.new("RGBA", (size, size))
    ImageDraw.Draw(g).rounded_rectangle((0, 0, size - 1, size - 1), radius,
                                        fill=(255, 255, 255, 46), outline=(255, 255, 255, 70), width=2)
    g.save(path)


glass(288, 44, out / "selection_big.png")
glass(112, 24, out / "selection_small.png")
