--------------------------------------------------------------------
-- THEME: Catppuccin (Mocha when dark, Latte when light)
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

return require("confs.decoration_common").apply(palettes[require("confs.theme_mode")()])
