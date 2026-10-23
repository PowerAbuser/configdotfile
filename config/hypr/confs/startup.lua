--------------------------------------------------------------------
-- STARTUP
--------------------------------------------------------------------
-- Formerly confs/startup.conf.
--
-- `exec-once = ...` becomes hl.exec_cmd() inside an hl.on("hyprland.start")
-- handler: the handler fires once when the compositor comes up, so these do
-- not re-run on `hyprctl reload` (which is exactly what exec-once meant).
--
-- Ordering within the handler is preserved -- the original comments about
-- what has to come first still apply.

local scripts = os.getenv("HOME") .. "/.config/hypr/scripts"

hl.on("hyprland.start", function()
    -- Environment FIRST -- before anything that needs Wayland
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_RUNTIME_DIR DBUS_SESSION_BUS_ADDRESS")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    -- Then startup scripts and portals
    hl.exec_cmd(scripts .. "/startup.sh")
    hl.exec_cmd("/usr/lib/xdg-desktop-portal-hyprland")
    -- hl.exec_cmd("/usr/lib/xdg-desktop-portal-wlr")

    -- Then everything else
    hl.exec_cmd("hypridle")
    hl.exec_cmd("waybar")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("blueman-applet & blueman-tray")
    hl.exec_cmd("solaar --window hide")
    hl.exec_cmd(scripts .. "/polkit.sh")
    hl.exec_cmd("wl-paste --type text  --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- pypr LAST -- after env is fully populated
    hl.exec_cmd("sleep 2 && " .. os.getenv("HOME") .. "/.local/bin/pypr")

    -- galaxybudsclient
    -- hl.exec_cmd("galaxybudsclient /StartMinimized")
end)
