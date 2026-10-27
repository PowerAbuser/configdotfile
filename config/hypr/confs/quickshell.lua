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

-- Hub (d/l inside it switches dark/light)
bind(mod .. " + SPACE", hl.dsp.global("quickshell:hubToggle"))
-- SUPER+R (the rofi launcher / app drawer) removed at your request; SUPER+D is the app menu

-- Notes drawer (also peeks when the pointer rests on the bottom-centre edge)
bind(mod .. " + ALT + N", hl.dsp.global("quickshell:notesToggle"))

-- Power menu: the desktop theme's scene (desktoptheme/PowerMenu.qml, from
-- dhrruvsharma/shell), on the focused screen; pressed again, it closes.
local power_menu = hl.dsp.global("quickshell:powerMenu")
bind("ALT + F4",        power_menu)
bind(mod .. " + X",     power_menu)

-- Layer rules from surface-dots
hl.layer_rule({ name = "qs-anim-rofi",       match = { namespace = "rofi" },       animation = "slide" })
-- The power menu draws its own intro, from a grab of the desktop
hl.layer_rule({ name = "qs-noanim-power-menu", match = { namespace = "power-menu" }, no_anim = true })
hl.layer_rule({ name = "qs-noanim-lock-capture", match = { namespace = "quickshell:lock-capture" }, no_anim = true })

-- Full-screen shell layers that animate their own panels: Hyprland's
-- layersIn slide would move the whole surface too (the hub slid up as well
-- as in from the side)
for _, ns in ipairs({ "snes-hub", "notes-drawer", "notes-trigger", "desktop-theme" }) do
    hl.layer_rule({ name = "qs-noanim-" .. ns, match = { namespace = ns }, no_anim = true })
end
