#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
歴史図鑑 — 画像生成AIが焼き込んだ疑似的な背景（チェッカー柄 or なだらかなグラデーション）を
実際のアルファ透過に変換する後処理スクリプト。

Leonardo.ai は "transparent background" 指示を実アルファチャンネルとしてではなく、
チェッカー柄や色付きグラデーションとして描画してしまうことがあるため、
外周（境界）から隣接ピクセル同士の色差が閾値以下の領域を連結的に辿るBFS方式の
flood fillで背景領域を検出し、そこだけアルファ0にする。
（PIL標準のImageDraw.floodfillは「開始シードとの色差」でしか判定できず、
 なだらかなグラデーション背景を辿りきれないため、本スクリプトは自前でBFSを実装している）

使い方:
  python remove_bg.py mascot_standing.png era_jomon.png ...
"""
import sys
from collections import deque
from pathlib import Path
from PIL import Image

OUTPUT_DIR = Path(__file__).parent / "output"
TRANSPARENT_DIR = Path(__file__).parent / "output_transparent"

STEP_THRESH = 18  # 隣接ピクセル同士の色差許容値（大きいほど背景として辿りやすいが誤爆リスクも上がる）


def color_diff(a, b):
    return abs(a[0] - b[0]) + abs(a[1] - b[1]) + abs(a[2] - b[2])


def remove_bg(src_path: Path, dst_path: Path, step_thresh: int = STEP_THRESH):
    im = Image.open(src_path).convert("RGBA")
    w, h = im.size
    rgb = im.convert("RGB")
    px = rgb.load()

    visited = bytearray(w * h)  # 0=未訪問, 1=背景として確定
    queue = deque()

    def idx(x, y):
        return y * w + x

    # 外周ピクセル全てをシードにする（角だけでなく全辺）
    for x in range(w):
        for y in (0, h - 1):
            i = idx(x, y)
            if not visited[i]:
                visited[i] = 1
                queue.append((x, y))
    for y in range(h):
        for x in (0, w - 1):
            i = idx(x, y)
            if not visited[i]:
                visited[i] = 1
                queue.append((x, y))

    while queue:
        x, y = queue.popleft()
        c0 = px[x, y]
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nx, ny = x + dx, y + dy
            if 0 <= nx < w and 0 <= ny < h:
                ni = idx(nx, ny)
                if not visited[ni]:
                    c1 = px[nx, ny]
                    if color_diff(c0, c1) <= step_thresh:
                        visited[ni] = 1
                        queue.append((nx, ny))

    src_px = im.load()
    out = Image.new("RGBA", (w, h))
    out_px = out.load()
    for y in range(h):
        for x in range(w):
            r, g, b, a = src_px[x, y]
            if visited[idx(x, y)]:
                out_px[x, y] = (r, g, b, 0)
            else:
                out_px[x, y] = (r, g, b, a)

    dst_path.parent.mkdir(parents=True, exist_ok=True)
    out.save(dst_path)


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    thresh = STEP_THRESH
    for a in sys.argv[1:]:
        if a.startswith("--thresh="):
            thresh = int(a.split("=")[1])

    if not args:
        print("usage: python remove_bg.py <file1.png> [file2.png ...] [--thresh=18]")
        sys.exit(1)

    for name in args:
        src = OUTPUT_DIR / name
        if not src.exists():
            print(f"[NG] not found: {src}")
            continue
        dst = TRANSPARENT_DIR / name
        remove_bg(src, dst, thresh)
        print(f"[OK] {name} -> output_transparent/{name}")


if __name__ == "__main__":
    main()
