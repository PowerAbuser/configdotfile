--------------------------------------------------------------------
-- THEME: Everforest
--------------------------------------------------------------------
-- Formerly confs/themes/Everforest.conf.
-- Symlink confs/decoration.lua at this file to activate it; that is what
-- scripts/theme_select.sh does.

return require("confs.decoration_common").apply({
    active   = "rgba(b4b9bcFF)",
    inactive = "rgba(928C7AFF)",
    icon     = "Everforest",
    gtk      = "Everforest",
    scheme   = "perfect-dark",
})
