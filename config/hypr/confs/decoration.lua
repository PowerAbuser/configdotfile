--------------------------------------------------------------------
-- THEME: border colours from the wallpaper (matugen), Catppuccin
-- (Mocha when dark, Latte when light) as the fallback and for GTK/icons
--------------------------------------------------------------------
-- Formerly a symlink into confs/themes/; Catppuccin is now the only theme.
-- Dark/light follows the quickshell hub (see confs/theme_mode.lua), and
-- utils/theme-mode.sh applies the same colours live on a switch.

local palettes = {
    dark = {
        active   = "rgba(b4befecc)",   -- mocha lavender
        inactive = "rgba(6c7086cc)",   -- mocha overlay0
        icon     = "Papirus-Dark",
        gtk      = "catppuccin-mocha-lavender-standard+default",
        scheme   = "prefer-dark",
    },
    light = {
        active   = "rgba(7287fdcc)",   -- latte lavender
        inactive = "rgba(9ca0b0cc)",   -- latte overlay0
        icon     = "Papirus-Light",
        gtk      = "catppuccin-latte-lavender-standard+default",
        scheme   = "prefer-light",
    },
}

local theme = palettes[require("confs.theme_mode")()]

-- Borders follow the wallpaper when matugen has run (quickshell/utils/
-- matugen-apply.sh writes matugen_colors.lua); Catppuccin otherwise. dofile
-- rather than require, so a reload never serves a cached palette.
local ok, wall = pcall(dofile, os.getenv("HOME") .. "/.config/hypr/confs/matugen_colors.lua")
if ok and type(wall) == "table" then
    theme.active   = wall.active   or theme.active
    theme.inactive = wall.inactive or theme.inactive
end

-- Night light (quickshell/utils/night-light.sh) survives reloads
local home = os.getenv("HOME")
local nl = io.open(home .. "/.cache/quickshell/night_light", "r")
if nl then
    if (nl:read("l") or ""):gsub("%s+", "") == "on" then
        hl.config({ decoration = { screen_shader = home .. "/.config/hypr/shaders/night_light.frag" } })
    end
    nl:close()
end

local applied = require("confs.decoration_common").apply(theme)

-- Settings > Windows in the quickshell hub (lib/WindowLook.qml) goes on top
local okw, look = pcall(dofile, home .. "/.config/hypr/confs/windowlook.lua")
if okw and type(look) == "table" then hl.config(look) end

return applied
