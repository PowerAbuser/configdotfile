--------------------------------------------------------------------
-- THEME MODE (dark = Catppuccin Mocha, light = Catppuccin Latte)
--------------------------------------------------------------------
-- The quickshell hub owns dark/light (d/l with the hub open); it writes
-- the mode to ~/.cache/quickshell/theme_mode via
-- ~/.config/quickshell/utils/theme-mode.sh. Modules that pick colours at
-- load time (decoration, env) read it here, so `hyprctl reload` keeps
-- the current mode instead of snapping back to dark.

return function()
    local f = io.open(os.getenv("HOME") .. "/.cache/quickshell/theme_mode", "r")
    if not f then return "dark" end
    local m = (f:read("l") or ""):gsub("%s+", "")
    f:close()
    return m == "light" and "light" or "dark"
end
