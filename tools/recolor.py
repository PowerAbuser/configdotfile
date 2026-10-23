#!/usr/bin/env python3
"""Map surface-dots' Everforest hexes to Catppuccin Mocha/Latte, in place.

usage: recolor.py {qml|css} FILE...
  qml : 8-digit hex is #AARRGGBB (Qt), so the colour is the last 6 digits
  css : 8-digit hex is #RRGGBBAA (CSS, rasi, hyprland rgba()), colour is the first 6
Prints every file it changed and any hex it did not recognise.
"""
import re
import sys

# Everforest (and friends) -> Catppuccin. Dark-mode sources map to Mocha,
# light-mode sources to Latte. Keys are lowercase 6-digit hex.
MAP = {
    # dark surfaces
    "141719": "11111b", "1e2326": "1e1e2e", "1e2327": "1e1e2e", "2d353b": "313244",
    "374145": "45475a", "232a2e": "11111b", "2b3033": "313244", "282c2d": "313244",
    "1a2020": "181825", "172022": "181825", "3f443c": "45475a", "283314": "11111b",
    "282828": "11111b", "444444": "45475a", "383838": "313244", "1a1a1a": "181825",
    "4a1b1b": "45273a", "293136": "11111b",
    # dark text
    "dde5df": "cdd6f4", "e5dfc5": "cdd6f4", "d3c6aa": "cdd6f4", "d5c9b2": "cdd6f4",
    "fffcf4": "cdd6f4", "e5e6c5": "cdd6f4", "f2f2f2": "b4befe",
    "9da9a0": "a6adc8", "859289": "9399b2", "7a8478": "7f849c",
    # accents (dark)
    "a7c080": "b4befe", "83c092": "b4befe", "759b61": "b4befe", "87b158": "b4befe",
    "859866": "b4befe", "7fb069": "b4befe", "7aa1a6": "89b4fa", "7fbbb3": "89b4fa",
    "e67e80": "f38ba8", "ff8888": "f38ba8", "dbbc7f": "f9e2af", "e3be5c": "f9e2af",
    "e69875": "fab387", "f1af97": "fab387", "d699b6": "f5c2e7", "595959": "6c7086",
    # light surfaces
    "f0ece6": "eff1f5", "e3ded6": "e6e9ef", "f3efe7": "eff1f5", "f2f0e5": "eff1f5",
    "ebe9de": "e6e9ef", "e2dfd3": "dce0e8", "d1cec0": "ccd0da", "f5f5f5": "eff1f5",
    "97a382": "ccd0da", "f3f5d9": "eff1f5", "fdf6e3": "eff1f5",
    # light text
    "252e33": "4c4f69", "3c4841": "4c4f69", "232a23": "5c5f77", "546670": "6c6f85",
    "5c6a72": "6c6f85", "4d6049": "6c6f85",
    # accents (light)
    "4a6b70": "7287fd", "4f6b5b": "7287fd", "6c8453": "7287fd", "576830": "40a02b",
    "a65046": "7287fd", "c74042": "d20f39", "f85552": "d20f39", "7a5b00": "df8e1d",
    "d4a017": "df8e1d", "d39984": "fe640b", "8da101": "40a02b", "35a77c": "179299",
    # second pass: one-offs found after the first run
    "435133": "7287fd", "a8c080": "b4befe", "333b26": "4c4f69", "a55524": "fe640b",
    "b13c3a": "d20f39", "5c7267": "1e66f5", "ff001e": "d20f39", "ff0004": "f38ba8",
    "e9e7e7": "e6e9ef", "829469": "b4befe", "7f9b58": "7287fd", "949689": "9ca0b0",
    "708154": "b4befe", "586a3c": "7287fd", "2a8650": "40a02b",
}

# Colours that are fine as they are: pure primaries/greys used for picker
# gradients and masks, and the Catppuccin values themselves.
KEEP = {"000000", "ffffff", "ff0000", "00ff00", "0000ff", "ffff00", "ff00ff",
        "00ffff"} | set(MAP.values()) | {
        "89b4fa", "1e66f5", "f5e0dc", "6c7086", "9ca0b0", "cba6f7", "8839ef"}

HEX = re.compile(r"#([0-9a-fA-F]{8}|[0-9a-fA-F]{6})\b")


def recolor(text, mode, unknown):
    def sub(m):
        h = m.group(1)
        if len(h) == 8:
            a, rgb = (h[:2], h[2:]) if mode == "qml" else (h[6:], h[:6])
        else:
            a, rgb = "", h
        key = rgb.lower()
        new = MAP.get(key)
        if new is None:
            if key not in KEEP:
                unknown.add(key)
            return m.group(0)
        if len(h) == 6:
            return "#" + new
        return "#" + (a + new if mode == "qml" else new + a)
    return HEX.sub(sub, text)


def main():
    mode, files = sys.argv[1], sys.argv[2:]
    assert mode in ("qml", "css")
    unknown = set()
    for f in files:
        with open(f, encoding="utf-8") as fh:
            old = fh.read()
        new = recolor(old, mode, unknown)
        if new != old:
            with open(f, "w", encoding="utf-8") as fh:
                fh.write(new)
            print("changed", f)
    if unknown:
        print("UNMAPPED:", " ".join(sorted(unknown)))


if __name__ == "__main__":
    main()
