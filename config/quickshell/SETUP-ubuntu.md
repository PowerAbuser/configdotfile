# surface-dots shell on Ubuntu 26.04 (Catppuccin)

This is the Quickshell shell from [snes19xx/surface-dots](https://github.com/snes19xx/surface-dots), recoloured to Catppuccin: Mocha when dark, Latte when light, with a lavender accent. It runs on top of the Hyprland Lua config in `config/hypr`.

## Packages

1. Install the apt packages:

   ```bash
   sudo apt install dunst khal fonts-inter fonts-cmu qt6-svg-plugins \
     qt6-style-kvantum qml6-module-qt5compat-graphicaleffects
   ```

2. Build Quickshell from source (see its `BUILD.md`) with `-DVENDOR_CPPTRACE=ON`. Its build needs these headers:

   ```bash
   sudo apt install qt6-declarative-private-dev libjemalloc-dev \
     libpolkit-agent-1-dev libunwind-dev libdwarf-dev libzstd-dev
   ```

## Not in git

These are downloaded upstream themes and fonts, not dotfiles:

| What | Where it goes | Source |
|---|---|---|
| GTK themes `catppuccin-{mocha,latte}-lavender-standard+default` | `~/.themes` | catppuccin/gtk releases |
| Kvantum themes `catppuccin-{mocha,latte}-lavender` | `~/.config/Kvantum` | catppuccin/kvantum |
| qt6ct colours `catppuccin-{mocha,latte}-lavender.conf` | `~/.config/qt6ct/colors` | catppuccin/qt5ct |
| Cursors `catppuccin-mocha-dark-cursors`, `catppuccin-latte-light-cursors` | `~/.icons` | catppuccin/cursors releases |
| Fonts: Manrope, Newsreader, DM Mono, EB Garamond | `~/.local/share/fonts` | google/fonts |
| Font: Symbols Nerd Font | `~/.local/share/fonts` | ryanoasis/nerd-fonts `NerdFontsSymbolsOnly` |
| `bin/` (`papel` wallpaper backend, `now_playing`) | `~/.config/quickshell/bin` | prebuilt x86-64, copied from surface-dots `.config/quickshell/bin`; gitignored |

## Colours

The Everforest → Catppuccin mapping is in `tools/recolor.py`.

- Re-run it after pulling a newer surface-dots:
  - `qml` mode for QML/JS files, where 8-digit hex is `#AARRGGBB`
  - `css` mode for rasi/CSS files, where it is `#RRGGBBAA`
- `tools/leftovers.py` lists any hex value that isn't Catppuccin.

## Dark / light

The hub switches modes: `d` / `l`, or Settings → Theme. Both run `utils/theme-mode.sh`, which does the following:

1. Writes `~/.cache/quickshell/theme_mode`.
2. Switches GTK, the icons, the cursor, Qt/Kvantum, dunst, the kitty colour link (`kitty/theme.conf`) and the rofi colour link (`rofi/themes/rofi-colors.rasi`).
3. Reloads Hyprland. `hypr/confs/decoration.lua` picks Mocha or Latte borders from `confs/theme_mode.lua`.

Wallpapers don't change with the mode. To make them change, set `WALLPAPER_DARK` / `WALLPAPER_LIGHT` in `~/.config/surface-dots/wallpapers.conf`.

## Weather

`lib/weather.sh` needs an OpenWeatherMap API key in `API_KEY`. Without one, the weather card and the lock-screen weather line stay blank.
