#!/usr/bin/env python3
"""
generate_app_icon.py — Generate a placeholder 1024x1024 app icon for CribbageApp.

Creates a dark green felt background with gold border, simplified cribbage board
outline, colored pegs, and "Cribbage" text.

Requirements: Pillow (pip install Pillow)

Usage:
    python3 scripts/generate_app_icon.py
"""

import math
import os
import sys

from PIL import Image, ImageDraw, ImageFont

SIZE = 1024
OUTPUT_DIR = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    "CribbageApp", "Assets.xcassets", "AppIcon.appiconset",
)
OUTPUT_PATH = os.path.join(OUTPUT_DIR, "AppIcon.png")

# Brand colors (from CribbageTheme)
FELT_GREEN_DARK = (20, 60, 30)
FELT_GREEN = (34, 100, 50)
GOLD = (205, 175, 100)
GOLD_BORDER = (180, 150, 75)
WHITE = (255, 255, 255)
IVORY = (235, 225, 200)
BOARD_BROWN = (110, 70, 40)
BOARD_BROWN_LIGHT = (140, 95, 55)
PEG_GOLD = (218, 185, 110)
PEG_RED = (180, 50, 50)


def radial_gradient(size, center_color, edge_color):
    """Create a radial gradient image."""
    img = Image.new("RGB", (size, size))
    cx, cy = size // 2, size // 2
    max_dist = math.sqrt(cx**2 + cy**2)
    pixels = img.load()
    for y in range(size):
        for x in range(size):
            dist = math.sqrt((x - cx) ** 2 + (y - cy) ** 2)
            t = min(dist / max_dist, 1.0)
            r = int(center_color[0] + (edge_color[0] - center_color[0]) * t)
            g = int(center_color[1] + (edge_color[1] - center_color[1]) * t)
            b = int(center_color[2] + (edge_color[2] - center_color[2]) * t)
            pixels[x, y] = (r, g, b)
    return img


def draw_rounded_rect(draw, bbox, radius, fill=None, outline=None, width=1):
    """Draw a rounded rectangle."""
    x0, y0, x1, y1 = bbox
    draw.rounded_rectangle(bbox, radius=radius, fill=fill, outline=outline, width=width)


def draw_peg_holes(draw, cx, cy, count, spacing, vertical=True):
    """Draw a row/column of peg holes."""
    for i in range(count):
        if vertical:
            px, py = cx, cy + i * spacing
        else:
            px, py = cx + i * spacing, cy
        draw.ellipse(
            [px - 4, py - 4, px + 4, py + 4],
            fill=(80, 50, 25),
            outline=(60, 35, 15),
        )


def draw_peg(draw, x, y, color, glow_color, radius=10):
    """Draw a peg with glow effect."""
    # Glow
    for i in range(3, 0, -1):
        alpha_r = radius + i * 4
        glow = tuple(min(255, c + 40) for c in glow_color)
        draw.ellipse(
            [x - alpha_r, y - alpha_r, x + alpha_r, y + alpha_r],
            fill=None,
            outline=glow,
            width=2,
        )
    # Peg body
    draw.ellipse(
        [x - radius, y - radius, x + radius, y + radius],
        fill=color,
        outline=tuple(max(0, c - 30) for c in color),
        width=2,
    )
    # Highlight
    draw.ellipse(
        [x - radius // 2, y - radius // 2, x, y],
        fill=tuple(min(255, c + 60) for c in color),
    )


def main():
    # Background: radial gradient felt
    img = radial_gradient(SIZE, FELT_GREEN, FELT_GREEN_DARK)
    draw = ImageDraw.Draw(img)

    # Gold border frame
    border_width = 18
    corner_radius = 100
    draw_rounded_rect(
        draw,
        [40, 40, SIZE - 40, SIZE - 40],
        radius=corner_radius,
        outline=GOLD,
        width=border_width,
    )
    # Inner border accent
    draw_rounded_rect(
        draw,
        [58, 58, SIZE - 58, SIZE - 58],
        radius=corner_radius - 12,
        outline=GOLD_BORDER,
        width=3,
    )

    # Cribbage board (simplified, centered)
    board_x = SIZE // 2 - 80
    board_y = 200
    board_w = 160
    board_h = 520

    # Board body
    draw_rounded_rect(
        draw,
        [board_x, board_y, board_x + board_w, board_y + board_h],
        radius=25,
        fill=BOARD_BROWN,
        outline=BOARD_BROWN_LIGHT,
        width=4,
    )

    # Board inner groove
    draw_rounded_rect(
        draw,
        [board_x + 15, board_y + 15, board_x + board_w - 15, board_y + board_h - 15],
        radius=15,
        outline=(90, 55, 30),
        width=2,
    )

    # Peg hole tracks (3 columns)
    track_spacing = 36
    hole_spacing = 22
    start_x = board_x + 38
    start_y = board_y + 50
    num_holes = 20

    for col in range(3):
        cx = start_x + col * track_spacing
        draw_peg_holes(draw, cx, start_y, num_holes, hole_spacing, vertical=True)

    # Pegs — player gold peg at hole 12, opponent red peg at hole 8
    peg1_x = start_x  # First track
    peg1_y = start_y + 11 * hole_spacing  # Hole 12 (0-indexed 11)
    draw_peg(draw, peg1_x, peg1_y, PEG_GOLD, PEG_GOLD, radius=11)

    peg2_x = start_x + track_spacing  # Second track
    peg2_y = start_y + 7 * hole_spacing  # Hole 8
    draw_peg(draw, peg2_x, peg2_y, PEG_RED, PEG_RED, radius=11)

    # "Cribbage" text
    text = "Cribbage"
    # Try to use a nice font, fall back to default
    font_size = 90
    font = None
    font_paths = [
        "/System/Library/Fonts/Supplemental/Georgia Bold.ttf",
        "/System/Library/Fonts/Supplemental/Times New Roman Bold.ttf",
        "/System/Library/Fonts/NewYork.ttf",
        "/Library/Fonts/Georgia Bold.ttf",
    ]
    for path in font_paths:
        if os.path.exists(path):
            try:
                font = ImageFont.truetype(path, font_size)
                break
            except OSError:
                continue
    if font is None:
        try:
            font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", font_size)
        except OSError:
            font = ImageFont.load_default()

    # Text shadow
    text_bbox = draw.textbbox((0, 0), text, font=font)
    text_w = text_bbox[2] - text_bbox[0]
    text_x = (SIZE - text_w) // 2
    text_y = 800
    draw.text((text_x + 3, text_y + 3), text, fill=(0, 0, 0), font=font)
    draw.text((text_x, text_y), text, fill=WHITE, font=font)

    # Subtitle
    subtitle = "Classic Card Game"
    sub_size = 32
    sub_font = None
    try:
        for path in font_paths:
            if os.path.exists(path):
                sub_font = ImageFont.truetype(path.replace(" Bold", "").replace("Bold", ""), sub_size)
                break
    except OSError:
        pass
    if sub_font is None:
        try:
            sub_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", sub_size)
        except OSError:
            sub_font = ImageFont.load_default()

    sub_bbox = draw.textbbox((0, 0), subtitle, font=sub_font)
    sub_w = sub_bbox[2] - sub_bbox[0]
    sub_x = (SIZE - sub_w) // 2
    sub_y = text_y + 95
    draw.text((sub_x, sub_y), subtitle, fill=IVORY, font=sub_font)

    # Save
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    img.save(OUTPUT_PATH, "PNG")
    print(f"App icon saved to {OUTPUT_PATH}")
    print(f"Size: {img.size[0]}x{img.size[1]}")


if __name__ == "__main__":
    main()
