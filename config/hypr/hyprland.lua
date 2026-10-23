--------------------------------------------------------------------
-- HYPRLAND CONFIG (Lua)
--------------------------------------------------------------------
-- Migrated from hyprland.conf + confs/*.conf.
--
-- Hyprland loads ~/.config/hypr/hyprland.lua in preference to
-- hyprland.conf. The old .conf files are still on disk untouched, so
-- renaming or deleting this file falls straight back to them.
--
-- `require` paths are relative to this directory, dot-separated:
-- confs/settings.lua is require("confs.settings").
--
-- Module load order matters and mirrors the original `source =` order:
-- window rules are order-sensitive (later rules win), and confs/tags.lua
-- must run before confs/windowrules.lua -- windowrules.lua requires it
-- itself, so that ordering is enforced rather than implied.

require("confs.settings")     -- input, misc, layouts, binds, xwayland, render, cursor
require("confs.decoration")   -- symlink -> confs/themes/<Theme>.lua
require("confs.startup")      -- exec-once handlers
require("confs.windowrules")  -- pulls in confs.tags and confs.configs
require("confs.keybinds")
require("confs.quickshell")   -- surface-dots shell: bar, hub, drawer, power menu
require("confs.env")
require("confs.monitor")
require("confs.animations")
