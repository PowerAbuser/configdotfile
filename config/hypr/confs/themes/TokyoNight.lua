--------------------------------------------------------------------
-- THEME: TokyoNight
--------------------------------------------------------------------
-- Formerly confs/themes/TokyoNight.conf.
-- Symlink confs/decoration.lua at this file to activate it; that is what
-- scripts/theme_select.sh does.

return require("confs.decoration_common").apply({
    active   = "rgba(8cc6c8FF)",
    inactive = "rgba(9C5759FF)",
    icon     = "TokyoNight",
    gtk      = "TokyoNight",
    scheme   = "perfect-dark",
})
