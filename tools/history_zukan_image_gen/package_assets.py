#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
生成済み画像を用途別サイズにリサイズし、
H:\\マイドライブ\\images\\歴史図鑑\\ の該当フォルダへ配置する。

- 透過が必要なカテゴリ（mascot, era_icons）は output_transparent/ から取る
- それ以外（person_placeholders, gacha_frames, diagnosis_backgrounds）は output/ から取る
"""
from pathlib import Path
from PIL import Image

TOOLS_DIR = Path(__file__).parent
OUTPUT_DIR = TOOLS_DIR / "output"
TRANSPARENT_DIR = TOOLS_DIR / "output_transparent"
IMAGES_ROOT = Path(r"H:\マイドライブ\images\歴史図鑑")

# id -> (category, 出力先サブフォルダ, 最終サイズ(w,h), 透過が必要か)
ASSET_MAP = {
    # 人物プレースホルダー（400x300, 不透明でOK）
    "person_jp_ancient": ("person_placeholders", (400, 300), False),
    "person_jp_modern": ("person_placeholders", (400, 300), False),
    "person_jp_contemporary": ("person_placeholders", (400, 300), False),
    "person_world_ancient": ("person_placeholders", (400, 300), False),
    "person_world_renaissance": ("person_placeholders", (400, 300), False),
    "person_world_other": ("person_placeholders", (400, 300), False),
    # マスコット（500x500, 透過必須）
    "mascot_standing": ("mascot", (500, 500), True),
    "mascot_pointing": ("mascot", (500, 500), True),
    "mascot_thinking": ("mascot", (500, 500), True),
    "mascot_celebrating": ("mascot", (500, 500), True),
    # ガチャ枠（512x512, 中央は単色パネルなので不透明でOK）
    "gacha_frame_n": ("gacha_frames", (512, 512), False),
    "gacha_frame_r": ("gacha_frames", (512, 512), False),
    "gacha_frame_sr": ("gacha_frames", (512, 512), False),
    "gacha_frame_ssr": ("gacha_frames", (512, 512), False),
    # 時代アイコン（200x200, 透過必須）
    "era_jomon": ("era_icons", (200, 200), True),
    "era_yayoi": ("era_icons", (200, 200), True),
    "era_kofun": ("era_icons", (200, 200), True),
    "era_asuka": ("era_icons", (200, 200), True),
    "era_nara": ("era_icons", (200, 200), True),
    "era_heian": ("era_icons", (200, 200), True),
    "era_kamakura": ("era_icons", (200, 200), True),
    "era_muromachi": ("era_icons", (200, 200), True),
    "era_azuchi": ("era_icons", (200, 200), True),
    "era_edo": ("era_icons", (200, 200), True),
    "era_meiji": ("era_icons", (200, 200), True),
    "era_taisho": ("era_icons", (200, 200), True),
    "era_showa": ("era_icons", (200, 200), True),
    "era_heisei": ("era_icons", (200, 200), True),
    "era_reiwa": ("era_icons", (200, 200), True),
    # 診断テーマ背景（1080x600, 不透明でOK）
    "diagnosis_bg_sengoku": ("diagnosis_backgrounds", (1080, 600), False),
    "diagnosis_bg_philosopher": ("diagnosis_backgrounds", (1080, 600), False),
    "diagnosis_bg_leader": ("diagnosis_backgrounds", (1080, 600), False),
    "diagnosis_bg_artist": ("diagnosis_backgrounds", (1080, 600), False),
    "diagnosis_bg_inventor": ("diagnosis_backgrounds", (1080, 600), False),
}


def resize_cover(im: Image.Image, target: tuple[int, int]) -> Image.Image:
    """アスペクト比を保ちつつ target を満たすまで拡大し、中央でクロップ（cover方式）。"""
    tw, th = target
    sw, sh = im.size
    scale = max(tw / sw, th / sh)
    nw, nh = round(sw * scale), round(sh * scale)
    resized = im.resize((nw, nh), Image.LANCZOS)
    left = (nw - tw) // 2
    top = (nh - th) // 2
    return resized.crop((left, top, left + tw, top + th))


def main():
    ok, skipped = 0, 0
    for asset_id, (category, size, needs_alpha) in ASSET_MAP.items():
        src_dir = TRANSPARENT_DIR if needs_alpha else OUTPUT_DIR
        src = src_dir / f"{asset_id}.png"
        if not src.exists():
            print(f"[NG] not found: {src}")
            skipped += 1
            continue

        im = Image.open(src)
        im = im.convert("RGBA") if needs_alpha else im.convert("RGB")
        im = resize_cover(im, size)

        dst_dir = IMAGES_ROOT / category
        dst_dir.mkdir(parents=True, exist_ok=True)
        dst = dst_dir / f"{asset_id}.png"
        im.save(dst)
        print(f"[OK] {asset_id} -> {dst} ({size[0]}x{size[1]})")
        ok += 1

    print(f"\n完了: {ok}件配置 / {skipped}件スキップ")
    print(f"配置先: {IMAGES_ROOT}")


if __name__ == "__main__":
    main()
