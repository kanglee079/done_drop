#!/usr/bin/env python3
from __future__ import annotations

import math
import shutil
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "store_assets" / "google_play"
PHONE_OUT = OUT / "screenshots_phone"
SOURCE_OUT = OUT / "source_screenshots"
PHONE_OUT.mkdir(parents=True, exist_ok=True)
SOURCE_OUT.mkdir(parents=True, exist_ok=True)

COLORS = {
    "cobalt": "#1F56E0",
    "cobalt_dark": "#1739A5",
    "ember": "#EF6C39",
    "ember_dark": "#8A381A",
    "ink": "#1D1A17",
    "muted": "#645952",
    "cream": "#F8F5F0",
    "paper": "#FDFCFA",
    "line": "#D9CBC0",
    "secondary": "#ECE2D9",
    "primary_fixed": "#DCE7FF",
}

FONT_SANS = Path("/System/Library/Fonts/SFNS.ttf")
FONT_SANS_BOLD = Path("/System/Library/Fonts/SFNS.ttf")
FONT_SERIF = Path("/System/Library/Fonts/Supplemental/Georgia.ttf")
FONT_SERIF_BOLD = Path("/System/Library/Fonts/Supplemental/Georgia Bold.ttf")


def font(size: int, *, serif: bool = False, bold: bool = False) -> ImageFont.FreeTypeFont:
    if serif:
        return ImageFont.truetype(str(FONT_SERIF_BOLD if bold else FONT_SERIF), size)
    return ImageFont.truetype(str(FONT_SANS_BOLD if bold else FONT_SANS), size)


def hex_to_rgb(value: str) -> tuple[int, int, int]:
    value = value.lstrip("#")
    return tuple(int(value[i : i + 2], 16) for i in (0, 2, 4))


def rgba(value: str, alpha: int = 255) -> tuple[int, int, int, int]:
    return (*hex_to_rgb(value), alpha)


def gradient(size: tuple[int, int], colors: list[str], horizontal: bool = False) -> Image.Image:
    w, h = size
    img = Image.new("RGB", size)
    pix = img.load()
    stops = [hex_to_rgb(c) for c in colors]
    for y in range(h):
        for x in range(w):
            t = x / max(1, w - 1) if horizontal else (x * 0.35 + y) / max(1, h + w * 0.35 - 1)
            t = max(0.0, min(1.0, t))
            scaled = t * (len(stops) - 1)
            idx = min(len(stops) - 2, int(scaled))
            local = scaled - idx
            c0, c1 = stops[idx], stops[idx + 1]
            pix[x, y] = tuple(int(c0[i] + (c1[i] - c0[i]) * local) for i in range(3))
    return img


def rounded_rect(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], radius: int, fill, outline=None, width: int = 1) -> None:
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def cubic(p0, p1, p2, p3, steps=24):
    for i in range(steps + 1):
        t = i / steps
        mt = 1 - t
        yield (
            mt**3 * p0[0] + 3 * mt**2 * t * p1[0] + 3 * mt * t**2 * p2[0] + t**3 * p3[0],
            mt**3 * p0[1] + 3 * mt**2 * t * p1[1] + 3 * mt * t**2 * p2[1] + t**3 * p3[1],
        )


def droplet_points(box: tuple[int, int, int, int]) -> list[tuple[float, float]]:
    x0, y0, x1, y1 = box
    w, h = x1 - x0, y1 - y0
    cx = (x0 + x1) / 2
    top = y0
    bottom = y1
    pts = []
    a = (cx, top)
    b = (cx - w * 0.43, bottom - h * 0.38)
    c = (cx, bottom)
    d = (cx + w * 0.43, bottom - h * 0.38)
    pts += list(cubic(a, (cx - w * 0.18, top + h * 0.18), (cx - w * 0.43, bottom - h * 0.63), b))
    pts += list(cubic(b, (cx - w * 0.43, bottom - h * 0.14), (cx - w * 0.22, bottom), c))
    pts += list(cubic(c, (cx + w * 0.22, bottom), (cx + w * 0.43, bottom - h * 0.14), d))
    pts += list(cubic(d, (cx + w * 0.43, bottom - h * 0.63), (cx + w * 0.18, top + h * 0.18), a))
    return pts


def draw_droplet(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], fill: str) -> None:
    draw.polygon(droplet_points(box), fill=fill)


def draw_check(draw: ImageDraw.ImageDraw, points: list[tuple[int, int]], fill: str, width: int) -> None:
    draw.line(points, fill=fill, width=width, joint="curve")
    r = width // 2
    for x, y in points:
        draw.ellipse((x - r, y - r, x + r, y + r), fill=fill)


def app_mark(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int]) -> None:
    x0, y0, x1, y1 = box
    w, h = x1 - x0, y1 - y0
    draw_droplet(
        draw,
        (int(x0 + w * 0.29), int(y0 + h * 0.17), int(x0 + w * 0.63), int(y0 + h * 0.81)),
        COLORS["ember"],
    )
    pts = [
        (int(x0 + w * 0.25), int(y0 + h * 0.60)),
        (int(x0 + w * 0.42), int(y0 + h * 0.73)),
        (int(x0 + w * 0.76), int(y0 + h * 0.36)),
    ]
    draw_check(draw, pts, COLORS["cobalt_dark"], max(5, int(w * 0.12)))
    draw_check(draw, pts, "white", max(3, int(w * 0.065)))


def app_icon(size: int, alpha: bool) -> Image.Image:
    mode = "RGBA" if alpha else "RGB"
    img = Image.new(mode, (size, size), rgba(COLORS["cream"]) if alpha else hex_to_rgb(COLORS["cream"]))
    d = ImageDraw.Draw(img)
    s = size / 512
    rounded_rect(
        d,
        tuple(round(v * s) for v in (34, 34, 478, 478)),
        round(112 * s),
        fill=COLORS["paper"],
        outline=COLORS["line"],
        width=max(1, round(2 * s)),
    )
    d.ellipse(tuple(round(v * s) for v in (122, 122, 390, 390)), fill=rgba(COLORS["cobalt"], 30))
    draw_droplet(d, tuple(round(v * s) for v in (178, 134, 334, 358)), COLORS["ember"])
    draw_check(
        d,
        [(round(190 * s), round(262 * s)), (round(238 * s), round(308 * s)), (round(334 * s), round(196 * s))],
        COLORS["cobalt_dark"],
        max(2, round(38 * s)),
    )
    draw_check(
        d,
        [(round(191 * s), round(262 * s)), (round(238 * s), round(307 * s)), (round(334 * s), round(196 * s))],
        "white",
        max(2, round(20 * s)),
    )
    d.ellipse(tuple(round(v * s) for v in (346, 316, 392, 362)), fill=COLORS["cobalt"])
    return img


def paste_rounded(base: Image.Image, source: Image.Image, box: tuple[int, int, int, int], radius: int) -> None:
    x0, y0, x1, y1 = box
    w, h = x1 - x0, y1 - y0
    source = source.convert("RGB")
    scale = max(w / source.width, h / source.height)
    resized = source.resize((math.ceil(source.width * scale), math.ceil(source.height * scale)), Image.Resampling.LANCZOS)
    left = max(0, (resized.width - w) // 2)
    crop = resized.crop((left, 0, left + w, h))
    mask = Image.new("L", (w, h), 0)
    md = ImageDraw.Draw(mask)
    md.rounded_rectangle((0, 0, w, h), radius=radius, fill=255)
    base.paste(crop, (x0, y0), mask)


def wrap_text(draw: ImageDraw.ImageDraw, text: str, fnt: ImageFont.FreeTypeFont, max_width: int) -> list[str]:
    lines = []
    for paragraph in text.split("\n"):
        current = ""
        for word in paragraph.split():
            trial = f"{current} {word}".strip()
            if draw.textbbox((0, 0), trial, font=fnt)[2] <= max_width or not current:
                current = trial
            else:
                lines.append(current)
                current = word
        if current:
            lines.append(current)
    return lines


def draw_text(
    draw: ImageDraw.ImageDraw,
    xy: tuple[int, int],
    value: str,
    fnt: ImageFont.FreeTypeFont,
    fill,
    max_width: int,
    spacing: int = 8,
    align: str = "left",
) -> int:
    x, y = xy
    line_height = int(fnt.size * 1.18)
    for line in wrap_text(draw, value, fnt, max_width):
        bbox = draw.textbbox((0, 0), line, font=fnt)
        dx = 0
        if align == "center":
            dx = (max_width - (bbox[2] - bbox[0])) // 2
        draw.text((x + dx, y), line, font=fnt, fill=fill)
        y += line_height + spacing
    return y


def phone_screenshot(source: str, title: str, subtitle: str, file_name: str) -> None:
    img = gradient((1080, 1920), [COLORS["cream"], COLORS["secondary"], COLORS["primary_fixed"]])
    d = ImageDraw.Draw(img, "RGBA")
    draw_text(d, (72, 70), "DoneDrop", font(38, serif=True), COLORS["ember_dark"], 360)
    title_bottom = draw_text(d, (72, 150), title, font(64, serif=True, bold=True), COLORS["ink"], 735, spacing=2)
    draw_text(d, (76, max(315, title_bottom + 26)), subtitle, font(33), COLORS["muted"], 850)
    card = (62, 470, 1018, 1830)
    rounded_rect(d, (card[0], card[1] + 18, card[2], card[3] + 18), 78, fill=rgba("#000000", 23))
    rounded_rect(d, card, 78, fill=COLORS["paper"], outline=rgba("#FFFFFF", 160), width=2)
    screen = (card[0] + 38, card[1] + 42, card[2] - 38, card[3] - 42)
    rounded_rect(d, screen, 56, fill=COLORS["paper"])
    paste_rounded(img, Image.open(ROOT / source), screen, 56)
    mark = (832, 84, 962, 214)
    rounded_rect(d, mark, 42, fill=rgba("#FFFFFF", 215), outline=COLORS["line"], width=2)
    app_mark(d, (mark[0] + 18, mark[1] + 18, mark[2] - 18, mark[3] - 18))
    img.save(PHONE_OUT / file_name)


def feature_graphic() -> None:
    img = gradient((1024, 500), [COLORS["cobalt_dark"], COLORS["cobalt"], COLORS["primary_fixed"]], horizontal=True)
    d = ImageDraw.Draw(img, "RGBA")
    for i in range(14):
        x = i * 82 - 44
        y = (i * 47) % 430 - 32
        d.ellipse((x, y, x + 170, y + 170), fill=rgba("#FFFFFF", 18 if i % 2 == 0 else 12))
    left_card = (55, 82, 291, 442)
    rounded_rect(d, (55, 95, 291, 455), 46, fill=rgba("#000000", 45))
    rounded_rect(d, left_card, 46, fill=COLORS["paper"])
    paste_rounded(img, Image.open(ROOT / "stitch/home_today/screen.png"), (73, 100, 273, 424), 34)
    right_card = (745, 102, 953, 410)
    rounded_rect(d, (745, 115, 953, 423), 42, fill=rgba("#000000", 42))
    rounded_rect(d, right_card, 42, fill=COLORS["paper"])
    paste_rounded(img, Image.open(ROOT / "stitch/capture_preview_post/screen.png"), (761, 118, 937, 394), 30)
    draw_text(d, (352, 92), "DoneDrop", font(44, serif=True), "white", 330, align="center")
    draw_text(
        d,
        (310, 162),
        "Complete it.\nCapture it.\nShare the proof.",
        font(48, serif=True, bold=True),
        "white",
        420,
        spacing=0,
        align="center",
    )
    draw_text(
        d,
        (305, 364),
        "Private accountability for daily habits",
        font(22),
        rgba("#FFFFFF", 220),
        440,
        align="center",
    )
    img.convert("RGB").save(OUT / "feature_graphic_1024x500.png")


def copy_sources() -> None:
    for name in [
        "home_today",
        "capture_preview_post",
        "invite_to_circle",
        "moment_shared_success",
        "premium_upgrade",
        "settings",
    ]:
        shutil.copy2(ROOT / "stitch" / name / "screen.png", SOURCE_OUT / f"{name}.png")


def draw_qr(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int]) -> None:
    x0, y0, x1, y1 = box
    cell = (x1 - x0) // 23
    rounded_rect(draw, box, 28, fill="white", outline=COLORS["line"], width=2)
    for row in range(23):
        for col in range(23):
            finder = (
                (row < 7 and col < 7)
                or (row < 7 and col > 15)
                or (row > 15 and col < 7)
            )
            if finder:
                border = row in (0, 6) or col in (0, 6) or (
                    2 <= row % 16 <= 4 and 2 <= col % 16 <= 4
                )
                if border:
                    draw.rectangle(
                        (x0 + col * cell + 12, y0 + row * cell + 12, x0 + (col + 1) * cell + 10, y0 + (row + 1) * cell + 10),
                        fill=COLORS["ink"],
                    )
            elif (row * 7 + col * 11 + row * col) % 5 in (0, 2):
                draw.rounded_rectangle(
                    (x0 + col * cell + 14, y0 + row * cell + 14, x0 + (col + 1) * cell + 8, y0 + (row + 1) * cell + 8),
                    radius=3,
                    fill=COLORS["cobalt"],
                )


def make_buddy_qr_source() -> None:
    img = Image.new("RGB", (720, 1280), hex_to_rgb(COLORS["cream"]))
    d = ImageDraw.Draw(img, "RGBA")
    draw_text(d, (40, 44), "DoneDrop", font(34, serif=True), COLORS["ember_dark"], 280)
    rounded_rect(d, (580, 42, 660, 122), 24, fill="white", outline=COLORS["line"], width=2)
    draw_text(d, (42, 156), "Add buddy", font(58, serif=True, bold=True), COLORS["ink"], 560)
    draw_text(d, (44, 252), "Scan a QR code or share your private DoneDrop code.", font(26), COLORS["muted"], 610)
    rounded_rect(d, (44, 340, 676, 505), 34, fill="#FFFFFF", outline=COLORS["line"], width=2)
    rounded_rect(d, (72, 378, 156, 462), 22, fill=COLORS["primary_fixed"])
    draw_text(d, (184, 372), "Scan QR", font(31, bold=True), COLORS["ink"], 420)
    draw_text(d, (184, 420), "Use camera to accept a buddy invite.", font(23), COLORS["muted"], 420)
    rounded_rect(d, (44, 540, 676, 1064), 42, fill="#FFFFFF", outline=COLORS["line"], width=2)
    draw_text(d, (82, 584), "My buddy code", font(34, serif=True, bold=True), COLORS["ember_dark"], 520)
    draw_text(d, (82, 636), "Share this with someone you trust.", font(23), COLORS["muted"], 520)
    draw_qr(d, (196, 704, 524, 1032))
    rounded_rect(d, (172, 1092, 548, 1170), 28, fill=COLORS["cobalt"])
    draw_text(d, (218, 1112), "Share code", font(28, bold=True), "white", 290, align="center")
    img.save(SOURCE_OUT / "buddy_qr_mock.png")


def make_premium_source() -> None:
    img = Image.new("RGB", (720, 1280), hex_to_rgb(COLORS["cream"]))
    d = ImageDraw.Draw(img, "RGBA")
    draw_text(d, (40, 44), "DoneDrop", font(34, serif=True), COLORS["ember_dark"], 280)
    rounded_rect(d, (255, 124, 465, 172), 24, fill=COLORS["primary_fixed"])
    draw_text(d, (288, 136), "PREMIUM", font(18, bold=True), COLORS["cobalt_dark"], 160, align="center")
    draw_text(d, (66, 220), "Unlock unlimited buddies", font(54, serif=True, bold=True), COLORS["ink"], 590, align="center")
    draw_text(d, (86, 356), "Remove the free buddy cap and keep accountability flowing.", font(25), COLORS["muted"], 548, align="center")
    rounded_rect(d, (54, 470, 666, 1040), 46, fill="#FFFFFF", outline=COLORS["line"], width=2)
    benefits = [
        ("Unlimited buddies", "Connect with every accountability partner."),
        ("Memory wall filters", "Find proof moments by habit and person."),
        ("Monthly, yearly, lifetime", "One Premium entitlement across plans."),
    ]
    y = 536
    for title, desc in benefits:
        d.ellipse((86, y + 8, 124, y + 46), fill=COLORS["ember"])
        draw_check(d, [(96, y + 28), (106, y + 38), (122, y + 18)], "white", 5)
        draw_text(d, (150, y), title, font(29, bold=True), COLORS["ink"], 430)
        draw_text(d, (150, y + 40), desc, font(22), COLORS["muted"], 430)
        y += 135
    rounded_rect(d, (96, 910, 624, 990), 30, fill=COLORS["ember_dark"])
    draw_text(d, (148, 932), "Choose Premium", font(27, bold=True), "white", 420, align="center")
    draw_text(d, (84, 1094), "Restore purchases anytime from Settings.", font(23), COLORS["muted"], 560, align="center")
    img.save(SOURCE_OUT / "premium_current_mock.png")


def save_icons() -> None:
    app_icon(512, alpha=True).save(OUT / "app_icon_512.png")
    app_icon(1024, alpha=False).save(OUT / "app_icon_master_1024.png")
    sizes = [
        ("android/app/src/main/res/mipmap-mdpi/ic_launcher.png", 48),
        ("android/app/src/main/res/mipmap-hdpi/ic_launcher.png", 72),
        ("android/app/src/main/res/mipmap-xhdpi/ic_launcher.png", 96),
        ("android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png", 144),
        ("android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png", 192),
        ("web/favicon.png", 32),
        ("web/icons/Icon-192.png", 192),
        ("web/icons/Icon-512.png", 512),
        ("web/icons/Icon-maskable-192.png", 192),
        ("web/icons/Icon-maskable-512.png", 512),
    ]
    for rel, size in sizes:
        target = ROOT / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        app_icon(size, alpha=False).save(target)
    ios = [
        ("Icon-App-20x20@1x.png", 20),
        ("Icon-App-20x20@2x.png", 40),
        ("Icon-App-20x20@3x.png", 60),
        ("Icon-App-29x29@1x.png", 29),
        ("Icon-App-29x29@2x.png", 58),
        ("Icon-App-29x29@3x.png", 87),
        ("Icon-App-40x40@1x.png", 40),
        ("Icon-App-40x40@2x.png", 80),
        ("Icon-App-40x40@3x.png", 120),
        ("Icon-App-60x60@2x.png", 120),
        ("Icon-App-60x60@3x.png", 180),
        ("Icon-App-76x76@1x.png", 76),
        ("Icon-App-76x76@2x.png", 152),
        ("Icon-App-83.5x83.5@2x.png", 167),
        ("Icon-App-1024x1024@1x.png", 1024),
    ]
    ios_dir = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    for file_name, size in ios:
        app_icon(size, alpha=False).save(ios_dir / file_name)


def main() -> None:
    save_icons()
    feature_graphic()
    copy_sources()
    make_buddy_qr_source()
    make_premium_source()
    phone_screenshot(
        "stitch/home_today/screen.png",
        "Own today's focus",
        "Plan the habits that matter and keep your streak visible.",
        "01_today_focus_1080x1920.png",
    )
    phone_screenshot(
        "stitch/capture_preview_post/screen.png",
        "Capture proof moments",
        "Attach real evidence to the routines you complete.",
        "02_capture_proof_1080x1920.png",
    )
    phone_screenshot(
        "store_assets/google_play/source_screenshots/buddy_qr_mock.png",
        "Add accountability buddies",
        "Invite trusted friends with QR or private codes.",
        "03_buddy_invite_1080x1920.png",
    )
    phone_screenshot(
        "stitch/moment_shared_success/screen.png",
        "Share progress privately",
        "Choose who sees each moment before it reaches the feed.",
        "04_private_sharing_1080x1920.png",
    )
    phone_screenshot(
        "store_assets/google_play/source_screenshots/premium_current_mock.png",
        "Unlock deeper reflection",
        "Premium tools preserve more memories when you are ready.",
        "05_premium_1080x1920.png",
    )
    phone_screenshot(
        "stitch/settings/screen.png",
        "Control your account",
        "Manage profile, notifications, privacy, and subscription access.",
        "06_settings_1080x1920.png",
    )
    print(f"Generated store assets in {OUT}")


if __name__ == "__main__":
    main()
