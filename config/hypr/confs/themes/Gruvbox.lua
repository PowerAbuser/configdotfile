--------------------------------------------------------------------
-- THEME: Gruvbox
--------------------------------------------------------------------
-- Formerly confs/themes/Gruvbox.conf.
-- Symlink confs/decoration.lua at this file to activate it; that is what
-- scripts/theme_select.sh does.

return require("confs.decoration_common").apply({
    active   = "rgba(c6b79fFF)",
    inactive = "rgba(93774CFF)",
    icon     = "Gruvbox-Plus-Dark",
    gtk      = "Gruvbox",
    scheme   = "perfect-dark",
})
