--------------------------------------------------------------------
-- THEME: Catppuccin
--------------------------------------------------------------------
-- Formerly confs/themes/Catppuccin.conf.
-- Symlink confs/decoration.lua at this file to activate it; that is what
-- scripts/theme_select.sh does.

return require("confs.decoration_common").apply({
    active   = "rgba(b4befecc)",
    inactive = "rgba(6c7086cc)",
    icon     = "Papirus-Dark",
    gtk      = "catppuccin-mocha-blue-standard+default",
    scheme   = "perfect-dark",
})
