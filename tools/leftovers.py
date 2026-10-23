#!/usr/bin/env python3
"""List hex colours that are not Catppuccin Mocha/Latte (or plain primaries).

usage: leftovers.py {qml|css} FILE...
"""
import re
import sys

MOCHA = """f5e0dc f2cdcd f5c2e7 cba6f7 f38ba8 eba0ac fab387 f9e2af a6e3a1 94e2d5
89dceb 74c7ec 89b4fa b4befe cdd6f4 bac2de a6adc8 9399b2 7f849c 6c7086 585b70
45475a 313244 1e1e2e 181825 11111b"""
LATTE = """dc8a78 dd7878 ea76cb 8839ef d20f39 e64553 fe640b df8e1d 40a02b 179299
04a5e5 209fb5 1e66f5 7287fd 4c4f69 5c5f77 6c6f85 7c7f93 8c8fa1 9ca0b0 acb0be
bcc0cc ccd0da dce0e8 e6e9ef eff1f5"""
OK = set(MOCHA.split()) | set(LATTE.split()) | {
    "000000", "ffffff", "ff0000", "00ff00", "0000ff", "ffff00", "ff00ff", "00ffff",
    "45273a"}  # 45273a: red-tinted surface for a hover, mixed by hand

HEX = re.compile(r"#([0-9a-fA-F]{8}|[0-9a-fA-F]{6})\b")
mode, files = sys.argv[1], sys.argv[2:]
bad = 0
for f in files:
    for n, line in enumerate(open(f, encoding="utf-8", errors="replace"), 1):
        for m in HEX.finditer(line):
            h = m.group(1).lower()
            rgb = h if len(h) == 6 else (h[2:] if mode == "qml" else h[:6])
            if rgb not in OK:
                bad += 1
                print(f"{f}:{n}: #{h}  {line.strip()[:110]}")
print(f"{bad} leftover(s)")
