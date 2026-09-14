#!/usr/bin/env python3
"""Generate the app icon: a white open book centred on a calm green field.

Original artwork defined here as geometry (no third-party assets). Outputs:
  assets/icon/app_icon.svg              vector source (full-bleed)
  assets/icon/app_icon_1024.png         full-bleed, opaque (iOS / legacy Android)
  assets/icon/adaptive_foreground.png   transparent, book inside the adaptive safe zone
  assets/icon/adaptive_monochrome.png   same shape for Android 13 themed icons
  docs/images/icon_mask_preview.png     circle / squircle / rounded-square check

Usage: python3 tool/icon/generate_icon.py
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
GREEN = (27, 94, 70)  # #1B5E46
WHITE = (255, 255, 255)
SS = 4  # supersampling factor


def qbez(p0, p1, p2, n=64):
    return [
        (
            (1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t**2 * p2[0],
            (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t**2 * p2[1],
        )
        for t in (i / n for i in range(n + 1))
    ]


def book_shapes(cx: float, cy: float, width: float):
    """Return (left page, right page, cover) as quadratic-Bezier outlines.

    Each outline is a list of segments ((p0, control, p2) or straight
    (p0, None, p2)); coordinates are absolute. ``width`` is the book width.
    """
    w = width / 2
    h = width * 0.62 / 2  # half height of a page
    g = width * 0.018  # half gap at the spine
    d = width * 0.075  # dip of the page edges towards the spine
    shapes = []
    for s in (-1, 1):  # left, right
        spine_top = (cx + s * g, cy - h + d)
        outer_top = (cx + s * w, cy - h)
        outer_bot = (cx + s * w, cy + h - d)
        spine_bot = (cx + s * g, cy + h)
        shapes.append(
            [
                (spine_top, (cx + s * w * 0.42, cy - h - d * 0.35), outer_top),
                (outer_top, None, outer_bot),
                (outer_bot, (cx + s * w * 0.42, cy + h - d * 1.25), spine_bot),
                (spine_bot, None, spine_top),
            ]
        )
    # Cover: a band under both pages, slightly wider, following the page curve.
    t = width * 0.045  # band thickness
    gap = width * 0.035  # green gap between pages and cover
    wc = w + width * 0.035
    y_out = cy + h - d + gap
    y_mid = cy + h + gap
    cover = [
        ((cx - wc, y_out), (cx - wc * 0.42, y_out + d * 0.25 - d * 1.25 + d), (cx, y_mid)),
        ((cx, y_mid), (cx + wc * 0.42, y_out + d * 0.25 - d * 1.25 + d), (cx + wc, y_out)),
        ((cx + wc, y_out), None, (cx + wc, y_out + t)),
        ((cx + wc, y_out + t), (cx + wc * 0.42, y_out + t + d * 0.25), (cx, y_mid + t)),
        ((cx, y_mid + t), (cx - wc * 0.42, y_out + t + d * 0.25), (cx - wc, y_out + t)),
        ((cx - wc, y_out + t), None, (cx - wc, y_out)),
    ]
    shapes.append(cover)
    return shapes


def outline_points(shape):
    pts = []
    for p0, c, p2 in shape:
        seg = [p0, p2] if c is None else qbez(p0, c, p2)
        pts += seg if not pts else seg[1:]
    return pts


def svg_path(shape) -> str:
    p0 = shape[0][0]
    parts = [f"M{p0[0]:.2f},{p0[1]:.2f}"]
    for _, c, p2 in shape:
        parts.append(f"L{p2[0]:.2f},{p2[1]:.2f}" if c is None else f"Q{c[0]:.2f},{c[1]:.2f} {p2[0]:.2f},{p2[1]:.2f}")
    return " ".join(parts) + " Z"


def render(size: int, book_width_ratio: float, background, colour=WHITE, cy_ratio=0.5) -> Image.Image:
    big = size * SS
    mode = "RGB" if background else "RGBA"
    im = Image.new(mode, (big, big), background or (0, 0, 0, 0))
    dr = ImageDraw.Draw(im)
    fill = colour if background else colour + (255,)
    shapes = book_shapes(big / 2, big * cy_ratio, big * book_width_ratio)
    for shape in shapes:
        dr.polygon(outline_points(shape), fill=fill)
    return im.resize((size, size), Image.LANCZOS)


def optical_cy(width_ratio: float) -> float:
    """Vertical centre that puts the visual centre of book+cover at 0.5."""
    shapes = book_shapes(0.0, 0.0, width_ratio)
    ys = [p[1] for s in shapes for p in outline_points(s)]
    return 0.5 - (min(ys) + max(ys)) / 2


def main() -> None:
    icon_dir = ROOT / "assets" / "icon"
    icon_dir.mkdir(parents=True, exist_ok=True)
    (ROOT / "docs" / "images").mkdir(parents=True, exist_ok=True)

    full_ratio = 0.60  # book width relative to the full-bleed icon
    # Adaptive icons: 108dp canvas, guaranteed-visible circle of 66dp diameter.
    # Keep the whole book (with cover) inside a 60dp circle for a margin.
    adaptive_ratio = 0.44

    full_cy, adaptive_cy = optical_cy(full_ratio), optical_cy(adaptive_ratio)
    render(1024, full_ratio, GREEN, cy_ratio=full_cy).save(icon_dir / "app_icon_1024.png")
    render(1024, adaptive_ratio, None, cy_ratio=adaptive_cy).save(icon_dir / "adaptive_foreground.png")
    render(1024, adaptive_ratio, None, cy_ratio=adaptive_cy).save(icon_dir / "adaptive_monochrome.png")

    size = 1024
    shapes = book_shapes(size / 2, size * full_cy, size * full_ratio)
    paths = "\n".join(f'  <path d="{svg_path(s)}" fill="#FFFFFF"/>' for s in shapes)
    (icon_dir / "app_icon.svg").write_text(
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {size} {size}" width="{size}" height="{size}">\n'
        f'  <rect width="{size}" height="{size}" fill="#{GREEN[0]:02X}{GREEN[1]:02X}{GREEN[2]:02X}"/>\n'
        f"{paths}\n</svg>\n",
        encoding="utf-8",
    )

    # Safe-zone check: every foreground pixel must lie inside the 66/108 circle.
    fg = Image.open(icon_dir / "adaptive_foreground.png")
    alpha = fg.getchannel("A")
    r_safe = 1024 * 33 / 108
    worst = 0.0
    px = alpha.load()
    for y in range(0, 1024, 2):
        for x in range(0, 1024, 2):
            if px[x, y] > 8:
                worst = max(worst, ((x - 512) ** 2 + (y - 512) ** 2) ** 0.5)
    print(f"adaptive foreground max radius {worst:.1f}px, safe radius {r_safe:.1f}px -> "
          f"{'OK' if worst <= r_safe else 'OUTSIDE SAFE ZONE'}")

    # Mask preview: circle, squircle, rounded square, as a launcher would crop.
    tile = 360
    preview = Image.new("RGB", (tile * 4 + 50, tile + 20), (238, 238, 238))
    layer = Image.new("RGBA", (1024, 1024), GREEN + (255,))
    layer.alpha_composite(fg)
    # Launchers show the central 72/108 of the adaptive canvas.
    crop = 1024 * 18 // 108
    shown = layer.crop((crop, crop, 1024 - crop, 1024 - crop)).resize((tile, tile), Image.LANCZOS)
    masks = []
    for kind in ("circle", "squircle", "rounded"):
        m = Image.new("L", (tile * SS, tile * SS), 0)
        md = ImageDraw.Draw(m)
        T = tile * SS
        if kind == "circle":
            md.ellipse((0, 0, T - 1, T - 1), fill=255)
        elif kind == "rounded":
            md.rounded_rectangle((0, 0, T - 1, T - 1), radius=int(T * 0.18), fill=255)
        else:
            pts = []
            import math

            for i in range(720):
                a = 2 * math.pi * i / 720
                c, s = math.cos(a), math.sin(a)
                n = 4.0
                pts.append((T / 2 + T / 2 * (abs(c) ** (2 / n)) * (1 if c >= 0 else -1),
                            T / 2 + T / 2 * (abs(s) ** (2 / n)) * (1 if s >= 0 else -1)))
            md.polygon(pts, fill=255)
        masks.append(m.resize((tile, tile), Image.LANCZOS))
    full = Image.open(icon_dir / "app_icon_1024.png").resize((tile, tile), Image.LANCZOS)
    preview.paste(full, (10, 10))
    for i, m in enumerate(masks, start=1):
        preview.paste(shown, (10 + i * (tile + 10), 10), m)
    preview.save(ROOT / "docs" / "images" / "icon_mask_preview.png")
    print("wrote icons and preview")


if __name__ == "__main__":
    main()
