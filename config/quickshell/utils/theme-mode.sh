#!/bin/bash
set -e
# =============================================================================
# GLOBAL THEME SWITCHER (dark / light)
# =============================================================================
# Called by the hub (d / l) through lib/ThemeState.qml. Switches:
# - the shell itself (via the state file it watches)
# - Hyprland borders + gsettings (hyprctl reload; confs/decoration.lua reads
#   the same state file)
# - GTK 3/4, icons, cursor
# - Qt (Kvantum)
# - Dunst, Kitty, Rofi, borders: wallpaper colours via matugen-apply.sh,
#   Catppuccin when matugen is unavailable
# Wallpapers are left alone unless ~/.config/surface-dots/wallpapers.conf
# sets WALLPAPER_DARK / WALLPAPER_LIGHT.
# =============================================================================
# THEMES
THEME_DARK="catppuccin-mocha-lavender-standard+default"
THEME_LIGHT="catppuccin-latte-lavender-standard+default"
ICONS_DARK="Papirus-Dark"
ICONS_LIGHT="Papirus-Light"
KVANTUM_DARK="catppuccin-mocha-lavender"
KVANTUM_LIGHT="catppuccin-latte-lavender"
# CURSORS
CURSOR_DARK="catppuccin-mocha-dark-cursors"
CURSOR_LIGHT="catppuccin-latte-light-cursors"
CURSOR_SIZE="24"
# WALLPAPERS (opt-in, see above)
WALLPAPER_DARK=""
WALLPAPER_LIGHT=""
[[ -f "$HOME/.config/surface-dots/wallpapers.conf" ]] && . "$HOME/.config/surface-dots/wallpapers.conf"
# PATHS
GTK3_CONF="$HOME/.config/gtk-3.0"
GTK3_SETTINGS="$GTK3_CONF/settings.ini"
GTK4_CONF="$HOME/.config/gtk-4.0"
STATE_FILE="$HOME/.cache/quickshell/theme_mode"
KITTY_THEME="$HOME/.config/kitty/theme.conf"
ROFI_COLORS="$HOME/.config/rofi/themes/rofi-colors.rasi"
DUNST_CONF="$HOME/.config/dunst/dunstrc"
[[ "$*" == *"--quiet"* ]] && QUIET=1 || QUIET=0
# reading_mode handles its own wallpapers
[[ "$*" == *"--no-wallpaper"* ]] && NO_WALLPAPER=1 || NO_WALLPAPER=0
mkdir -p "$GTK3_CONF" "$GTK4_CONF" "$(dirname "$STATE_FILE")"
# HELPER FUNCTIONS
# Make sure GTK3 settings file exists with proper structure
ensure_gtk3_ini() {
  if [ ! -f "$GTK3_SETTINGS" ]; then
    printf "[Settings]\ngtk-theme-name=\ngtk-icon-theme-name=\ngtk-application-prefer-dark-theme=0\n" > "$GTK3_SETTINGS"
  elif ! grep -q '^\[Settings\]' "$GTK3_SETTINGS"; then
    sed -i '1i [Settings]' "$GTK3_SETTINGS"
  fi
}
# Update INI file
update_ini_key() {
  local file="$1"
  local key="$2"
  local value="$3"

  if grep -q "^${key}=" "$file"; then
    sed -i "s|^${key}=.*|${key}=${value}|" "$file"
  else
    sed -i "/^\[Settings\]/a ${key}=${value}" "$file"
  fi
}
# GTK4 uses symlinks to theme files instead of a config file
update_gtk4_links() {
  local theme="$1"
  local theme_path="$HOME/.themes/$theme/gtk-4.0"
  [ -d "$theme_path" ] || return 0

  rm -f "$GTK4_CONF/assets" "$GTK4_CONF/gtk.css" "$GTK4_CONF/gtk-dark.css"
  ln -sf "$theme_path/assets"  "$GTK4_CONF/assets"
  ln -sf "$theme_path/gtk.css" "$GTK4_CONF/gtk.css"
  [ -f "$theme_path/gtk-dark.css" ] && ln -sf "$theme_path/gtk-dark.css" "$GTK4_CONF/gtk-dark.css"
}
# Update the mouse cursor theme.
update_cursor() {
  local theme="$1"
  local size="$2"

  if [[ ! -d "$HOME/.icons/$theme" && ! -d "$HOME/.local/share/icons/$theme" && ! -d "/usr/share/icons/$theme" ]]; then
    return 0
  fi

  # GTK 3 -- same ini as the rest of the GTK settings
  update_ini_key "$GTK3_SETTINGS" "gtk-cursor-theme-name" "$theme"
  update_ini_key "$GTK3_SETTINGS" "gtk-cursor-theme-size" "$size"

  # GTK 4 / anything reading the GNOME schema
  if command -v gsettings &>/dev/null; then
    gsettings set org.gnome.desktop.interface cursor-theme "$theme" || true
    gsettings set org.gnome.desktop.interface cursor-size "$size" || true
  fi

  # The XDG "default" theme is the last-resort fallback (XWayland apps)
  local def="$HOME/.icons/default"
  mkdir -p "$def"
  printf '[Icon Theme]\nName=default\nComment=Managed by theme-mode.sh\nInherits=%s\n' \
    "$theme" > "$def/index.theme"

  # Hyprland live
  if command -v hyprctl &>/dev/null; then
    hyprctl setcursor "$theme" "$size" >/dev/null 2>&1 || true
  fi
}
# Kitty: re-point the include in kitty.conf, then live-reload every kitty
update_kitty() {
  ln -sf "$HOME/.config/kitty/colors/$1" "$KITTY_THEME"
  kill -SIGUSR1 $(pidof kitty) 2>/dev/null || true
}
# Rofi reads its colours fresh on every launch, so the link is enough
update_rofi() {
  ln -sf "$HOME/.config/rofi/colors/$1" "$ROFI_COLORS"
}
# Update Dunst notification theme
update_dunst() {
  local source_conf="$1"
  [ -f "$HOME/.config/dunst/$source_conf" ] || return 0
  # cp instead of symlinks
  cp -f "$HOME/.config/dunst/$source_conf" "$DUNST_CONF"

  # Safely restart the daemon to prevent D-Bus locks
  if systemctl --user is-active --quiet dunst.service; then
    systemctl --user restart dunst.service
  elif command -v dunst &>/dev/null; then
    killall dunst 2>/dev/null || true
    sleep 0.2
    dunst >/dev/null 2>&1 &
    disown
  fi
}
# Qt: qt6ct hands styling to Kvantum; the Kvantum theme carries the palette
update_qt() {
  local kvantum="$1"
  local icons="$2"
  local qt6ct="$HOME/.config/qt6ct/qt6ct.conf"
  mkdir -p "$(dirname "$qt6ct")" "$HOME/.config/Kvantum"
  [ -f "$qt6ct" ] || printf '[Appearance]\n' > "$qt6ct"
  sed -i '/^style=/d; /^icon_theme=/d; /^custom_palette=/d' "$qt6ct"
  sed -i "/^\[Appearance\]/a style=kvantum\nicon_theme=${icons}\ncustom_palette=false" "$qt6ct"
  if command -v kvantummanager &>/dev/null; then
    kvantummanager --set "$kvantum" >/dev/null 2>&1 || true
  else
    printf '[General]\ntheme=%s\n' "$kvantum" > "$HOME/.config/Kvantum/kvantum.kvconfig"
  fi
}
# MAIN THEME FUNCTION
apply_theme() {
  local mode="$1"              # "light" or "dark"
  local theme_gtk="$2"         # GTK theme name
  local theme_icon="$3"        # Icon theme name
  local theme_kvantum="$4"     # Kvantum theme name
  local wallpaper="$5"         # Wallpaper path (may be empty)
  local kitty_conf="$6"        # Kitty colours file name
  local rofi_conf="$7"         # Rofi colours file name
  local dunst_conf="$8"        # Dunst config file name
  local prefer_dark_bool="$9"  # "true" or "false"
  local gnome_scheme="${10}"   # "prefer-dark" or "prefer-light"

  local prefer_dark_int=0
  [ "$prefer_dark_bool" == "true" ] && prefer_dark_int=1

  echo "Switching to $mode mode..."
  # Write atomically to trigger file watchers
  echo "$mode" > "${STATE_FILE}.tmp" && mv -f "${STATE_FILE}.tmp" "$STATE_FILE"
  if [[ "$QUIET" != "1" ]]; then
    echo "$mode" > "${HOME}/.cache/quickshell/theme_osd"
  fi

  # GTK 3
  ensure_gtk3_ini
  update_ini_key "$GTK3_SETTINGS" "gtk-theme-name" "$theme_gtk"
  update_ini_key "$GTK3_SETTINGS" "gtk-icon-theme-name" "$theme_icon"
  update_ini_key "$GTK3_SETTINGS" "gtk-application-prefer-dark-theme" "$prefer_dark_int"
  touch "$GTK3_SETTINGS"  # Force timestamp update so apps notice the change

  # GTK 4
  update_gtk4_links "$theme_gtk"

  # Cursor
  if [ "$mode" == "light" ]; then
    update_cursor "$CURSOR_LIGHT" "$CURSOR_SIZE"
  else
    update_cursor "$CURSOR_DARK" "$CURSOR_SIZE"
  fi

  # gsettings (GTK apps that check it, libadwaita dark/light)
  if command -v gsettings &>/dev/null; then
    gsettings set org.gnome.desktop.interface color-scheme "$gnome_scheme" || true
    gsettings set org.gnome.desktop.interface icon-theme "$theme_icon" || true
    gsettings set org.gnome.desktop.interface gtk-theme "$theme_gtk" || true
  fi

  update_qt "$theme_kvantum" "$theme_icon"

  # Hyprland borders: confs/decoration.lua picks Mocha/Latte from the state
  # file, so a reload is all it takes (and keeps one source of truth)
  command -v hyprctl &>/dev/null && hyprctl reload >/dev/null 2>&1 || true

  # Wallpaper (opt-in)
  if [[ "$NO_WALLPAPER" != "1" && -n "$wallpaper" && -f "$wallpaper" ]]; then
    command -v awww &>/dev/null && awww img "$wallpaper" \
        --transition-type wipe \
        --transition-pos center \
        --transition-step 90 \
        --transition-duration 1.2
  fi

  # Kitty, Rofi, Dunst and the borders take the wallpaper's colours in the new
  # mode; the Catppuccin files are the fallback when matugen can't run
  if ! "$HOME/.config/quickshell/utils/matugen-apply.sh"; then
    update_dunst "$dunst_conf"
    update_kitty "$kitty_conf"
    update_rofi "$rofi_conf"
  fi
}
# SCRIPT EXECUTION
if [ "$1" == "light" ]; then
  apply_theme "light" \
    "$THEME_LIGHT" \
    "$ICONS_LIGHT" \
    "$KVANTUM_LIGHT" \
    "$WALLPAPER_LIGHT" \
    "catppuccin-latte.conf" \
    "CatppuccinLatte.rasi" \
    "dunstrc_light" \
    "false" \
    "prefer-light"
else
  # Default to dark
  apply_theme "dark" \
    "$THEME_DARK" \
    "$ICONS_DARK" \
    "$KVANTUM_DARK" \
    "$WALLPAPER_DARK" \
    "catppuccin-mocha.conf" \
    "Catppuccin.rasi" \
    "dunstrc_dark" \
    "true" \
    "prefer-dark"
fi
