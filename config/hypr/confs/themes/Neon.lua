--------------------------------------------------------------------
-- THEME: Neon
--------------------------------------------------------------------
-- Formerly confs/themes/Neon.conf.
-- Symlink confs/decoration.lua at this file to activate it; that is what
-- scripts/theme_select.sh does.

return require("confs.decoration_common").apply({
    active   = "rgba(e1c5e1FF)",
    inactive = "rgba(E25ECFFF)",
    icon     = "candy-icons",
    gtk      = "Catppuccin",
    scheme   = "perfect-dark",
})
