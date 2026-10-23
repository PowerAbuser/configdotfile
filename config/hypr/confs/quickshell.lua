--------------------------------------------------------------------
-- QUICKSHELL (surface-dots shell, Catppuccin)
--------------------------------------------------------------------
-- The bar, hub, drawer and power menu live in ~/.config/quickshell.
-- This module starts the shell and binds its global shortcuts; it
-- replaces waybar + swaync from confs/startup.lua.
--
-- Rollback: comment out require("confs.quickshell") in hyprland.lua,
-- put waybar back in confs/startup.lua, and
-- `systemctl --user enable --now swaync`.

local mod  = "SUPER"
local bind = hl.bind
local exec = hl.dsp.exec_cmd

hl.on("hyprland.start", function()
    hl.exec_cmd("qs")
    -- the hub's notification card talks to dunst (dunstctl)
    hl.exec_cmd("dunst")
end)

-- Hub (d/l inside it switches Mocha/Latte) and app drawer
bind(mod .. " + SPACE", hl.dsp.global("quickshell:hubToggle"))
bind(mod .. " + R",     hl.dsp.global("quickshell:drawerToggle"))

-- Power menu: its own quickshell instance, skipped if already open
bind("ALT + F4", exec("hyprctl layers | grep -q power-menu || quickshell -p ~/.config/quickshell/utils/PowerMenu.qml"))

-- Layer rules from surface-dots
hl.layer_rule({ name = "qs-anim-rofi",       match = { namespace = "rofi" },       animation = "slide" })
hl.layer_rule({ name = "qs-anim-power-menu", match = { namespace = "power-menu" }, animation = "popin" })
hl.layer_rule({ name = "qs-dim-power-menu",  match = { namespace = "power-menu" }, dim_around = true })
