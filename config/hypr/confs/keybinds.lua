--------------------------------------------------------------------
-- KEYBINDS
--------------------------------------------------------------------
-- Formerly confs/keybinds.conf.
--
-- Translation notes:
--   bind   -> hl.bind(keys, dispatcher)
--   bindm  -> hl.bind(..., { mouse = true })
--   bindl  -> hl.bind(..., { locked = true })          -- works while locked
--   bindel -> hl.bind(..., { locked = true, repeating = true })
--
-- Keys are one string: "SUPER + SHIFT + Q" rather than "$mainMod SHIFT, Q".

local mod     = "SUPER"
local home    = os.getenv("HOME")
local scripts = home .. "/.config/hypr/scripts"

-- Programs
local terminal      = "kitty"
local file_man      = "nautilus"
local term_file_man = "yazi"
local pypr          = "/usr/bin/pypr-client"

-- Scripts referenced below
local wallpaper        = scripts .. "/Wallpaper.sh"
local wallpaper_select = scripts .. "/WallpaperSelect.sh"
local rofi_emoji       = scripts .. "/rofi-emoji.sh"
local help             = scripts .. "/keybinds.sh"

-- Declared in the original but not bound to anything; kept for reference.
-- local volume_ctrl = scripts .. "/volumecontrol.sh"
-- local apps        = scripts .. "/apps.sh"

local bind = hl.bind
local exec = hl.dsp.exec_cmd

-- Bind option presets
local LOCKED   = { locked = true }                       -- bindl
local REPEAT   = { locked = true, repeating = true }      -- bindel
local MOUSE    = { mouse  = true }                        -- bindm

--------------------------------------------------------------------
-- WALLPAPER
--------------------------------------------------------------------
bind(mod .. " + W",              exec(wallpaper))
bind(mod .. " + ALT + E",        exec(scripts .. "/change_wallpaper_engine.sh"))
bind(mod .. " + SHIFT + W",      exec(wallpaper_select .. " thm1"))
bind(mod .. " + CTRL + SHIFT + W", exec(wallpaper_select .. " thm2"))

--------------------------------------------------------------------
-- SCREENSHOT / HELP
--------------------------------------------------------------------
bind(mod .. " + S",                exec(scripts .. "/screenshot.sh"))
bind(mod .. " + CTRL + SHIFT + H", exec(help))

--------------------------------------------------------------------
-- CORE WINDOW / LAUNCHER BINDS
--------------------------------------------------------------------
bind(mod .. " + Return",         exec(terminal .. " --title=main"))
bind(mod .. " + SHIFT + Return", exec(terminal .. " --title=floating"))
bind(mod .. " + Q",              hl.dsp.window.close())
bind(mod .. " + SHIFT + M",      hl.dsp.exit())
bind(mod .. " + E",              exec(file_man))
-- open yazi in its own terminal
bind(mod .. " + SHIFT + E",      exec(terminal .. " --title " .. term_file_man .. " -e " .. term_file_man))
bind(mod .. " + V",              hl.dsp.window.float({ action = "toggle" }))
-- NOTE: this used to be `hyprctl dispatch workspaceopt allfloat`. Under a Lua
-- config `hyprctl dispatch` only accepts Lua expressions, and `workspaceopt` is
-- both deprecated in Hyprland 0.55.4 and absent from the hl.dsp table -- so
-- there is no equivalent to call. Left disabled rather than silently broken.
-- bind(mod .. " + ALT + V", ...)
bind(mod .. " + F",              hl.dsp.window.fullscreen())
bind(mod .. " + D",              exec(scripts .. "/menu.sh || pkill rofi"))
bind(mod .. " + ALT + C",        exec(scripts .. "/cliphist.sh c")) -- clipboard manager
bind(mod .. " + ALT + W",        exec(scripts .. "/cliphist.sh w")) -- clipboard wipe
bind(mod .. " + SHIFT + D",      exec(rofi_emoji))
bind(mod .. " + SHIFT + P",      hl.dsp.window.pseudo())
bind(mod .. " + P",              hl.dsp.window.pseudo())
bind(mod .. " + B",              exec(scripts .. "/browser.sh op")) -- open brave or chromium
-- bind(mod .. " + B", exec("systemd-run --user --slice=browser-memory.slice " .. scripts .. "/browser.sh op"))

-- NOTE: the original wrote these two as `$ALT` and `$CONTROL`, which were
-- never defined -- hyprlang left the literal text in place, so the modifier
-- was dropped. Translated to the evidently intended ALT / CTRL.
bind("ALT + B",     exec(scripts .. "/default_browser.sh --reset")) -- reset default browser
bind("CTRL + ESCAPE", exec(scripts .. "/waybar-reload.sh --reload")) -- reload waybar
-- bind("CTRL + ESCAPE",       exec("hyprpanel r"))
-- bind("CTRL + ALT + ESCAPE", exec(scripts .. "/waybar-reload.sh --toggle"))

-- bind(mod .. " + SHIFT + L", exec("hyprlock"))

-- NOTE: SUPER + ALT + S was bound twice in the original, so both scripts fire
-- on the same chord. Preserved as-is; drop one if that wasn't intended.
bind(mod .. " + ALT + S",  exec(scripts .. "/hyprlock.sh"))
bind(mod .. " + ALT + S",  exec(scripts .. "/toggle_dark_light.sh"))

bind(mod .. " + CTRL + W", exec(scripts .. "/WaybarLayout.sh"))
bind(mod .. " + CTRL + S", exec(scripts .. "/WaybarStyles.sh"))
-- bind(mod .. " + CTRL + E", exec(scripts .. "/edit-dotfiles.sh"))
bind(mod .. " + ALT + B",  exec(scripts .. "/shell.sh"))
bind(mod .. " + CTRL + R", exec('hyprctl reload && notify-send "Done" "Hyprland reload"'))
-- bind("CTRL + U", exec(scripts .. "/systemupdate.sh --update"))
bind(mod .. " + CTRL + U", exec('kitty --title browser sh -c "' .. scripts .. '/hyprconf-v2.sh"'))
bind(mod .. " + SHIFT + R", exec(scripts .. "/startup.sh &> /dev/null"))
-- bind(mod .. " + S", exec('kitty --title browser sh -c "' .. scripts .. '/settings.sh"'))
bind(mod .. " + ALT + U", exec('kitty sh -c "' .. scripts .. '/uninstall.sh"'))

-- re-generate colors if the ~/.cache/wal directory has been deleted
bind(mod .. " + CTRL + P", exec('notify-send "Colors" "Re-generating colors." && ' .. scripts .. "/pywal.sh"))

--------------------------------------------------------------------
-- WINDOW SWITCHING
--------------------------------------------------------------------
bind(mod .. " + Tab", exec("rofi -show window -theme " .. home .. "/.config/rofi/themes/rofi-window.rasi"))
-- bind(mod .. " + Tab", exec("hyprswitch gui --mod-key super --key tab --max-switch-offset 9 --hide-active-window-border"))

-- Cycle windows; if floating, bring to top. Both binds fire on the same chord.
bind("ALT + Tab", hl.dsp.window.cycle_next())
bind("ALT + Tab", hl.dsp.window.bring_to_top())

bind(mod .. " + G", hl.dsp.group.toggle())
bind(mod .. " + M", hl.dsp.layout("splitratio 0.3"))
-- bind(mod .. " + SHIFT + I", hl.dsp.layout("togglesplit")) -- dwindle only

--------------------------------------------------------------------
-- HYPRSUNSET / NIGHT LIGHT
--------------------------------------------------------------------
bind(mod .. " + F1", exec(scripts .. "/nightlight.sh --dec")) -- night light
bind(mod .. " + F2", exec(scripts .. "/nightlight.sh --inc")) -- day light
bind(mod .. " + F3", exec(scripts .. "/nightlight.sh --def")) -- default value

-- Keyboard/screen brightness via script (disabled in the original)
-- bind("F3", exec(scripts .. "/brightness.sh up"))
-- bind("F2", exec(scripts .. "/brightness.sh down"))

--------------------------------------------------------------------
-- MEDIA / BRIGHTNESS KEYS
--------------------------------------------------------------------
bind("XF86MonBrightnessDown", exec("brightnessctl set 5%-"), REPEAT)
bind("XF86MonBrightnessUp",   exec("brightnessctl set 5%+"), REPEAT)

bind("XF86AudioMute",        exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), LOCKED)
bind("XF86AudioLowerVolume", exec("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-"), REPEAT)
bind("XF86AudioRaiseVolume", exec("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), REPEAT)

bind("XF86AudioPlay", exec("playerctl play-pause"))
bind("XF86AudioPrev", exec("playerctl previous"))
bind("XF86AudioNext", exec("playerctl next"))

--------------------------------------------------------------------
-- FOCUS AND WINDOW MOVEMENT (vim keys)
--------------------------------------------------------------------
local directions = {
    { "H", "l" },
    { "J", "d" },
    { "K", "u" },
    { "L", "r" },
}

for _, d in ipairs(directions) do
    local key, dir = d[1], d[2]
    bind(mod .. " + " .. key, hl.dsp.focus({ direction = dir }))
    -- NOTE: the original wrote this as `$mainMod $CONTROL`, and `$CONTROL` was
    -- never defined -- so these collapsed onto plain SUPER + hjkl and collided
    -- with the focus binds above. Translated to the intended CTRL.
    bind(mod .. " + CTRL + " .. key, hl.dsp.window.move({ direction = dir }))
end

--------------------------------------------------------------------
-- WORKSPACES
--------------------------------------------------------------------
-- SUPER + N          -> switch to workspace N
-- SUPER + SHIFT + N  -> move active window to workspace N
-- SUPER + ALT + N    -> move active window there silently (movetoworkspacesilent)
for i = 1, 10 do
    local key = i % 10 -- workspace 10 lives on the "0" key
    bind(mod .. " + " .. key,           hl.dsp.focus({ workspace = i }))
    bind(mod .. " + SHIFT + " .. key,   hl.dsp.window.move({ workspace = i }))
    bind(mod .. " + ALT + " .. key,     hl.dsp.window.move({ workspace = i, silent = true }))
end

-- Move window to the workspace on the next/previous monitor-relative slot
bind(mod .. " + SHIFT + L", hl.dsp.window.move({ workspace = "r+1" }))
bind(mod .. " + SHIFT + H", hl.dsp.window.move({ workspace = "r-1" }))

-- Scroll through workspaces
bind(mod .. " + ALT + L",    hl.dsp.focus({ workspace = "r+1" }))
bind(mod .. " + ALT + H",    hl.dsp.focus({ workspace = "r-1" }))
-- REMOVED 2026-08-19: SUPER + scroll -> workspace e+1/e-1 was the cause of the
-- spontaneous rapid workspace switching.
--
-- Evidence: event traces (~/.cache/hypr-wsmon.log, bursts at 10:19, 10:23,
-- 11:00, 12:16) showed repeated `createworkspace>>4 / workspace>>4 /
-- workspace>>2 / destroyworkspace>>4` cycles. Empty workspaces can only be
-- conjured by a workspace-switch dispatcher, and `e+1` is the only bind that
-- resolves 2 -> 4 (skipping 3, which lives on DP-1). No `moveworkspace>>`
-- events appeared, which ruled out pyprland.
--
-- Trigger: the MX Master 3S has SmartShift, so a fast flick disengages the
-- ratchet and the wheel keeps emitting scroll events after you let go. With
-- SUPER held, each one switched workspace -- hence "without touching
-- anything". `binds:workspace_back_and_forth = true` turned it into a 2<->4
-- ping-pong.
--
-- Workspace switching is still available via SUPER + 1..0 and SUPER+ALT+H/L.
-- bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
-- bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- bind(mod .. " + Tab",         hl.dsp.focus({ workspace = "m+1" }))
-- bind(mod .. " + SHIFT + Tab", hl.dsp.focus({ workspace = "m-1" }))

--------------------------------------------------------------------
-- MOUSE DRAG / RESIZE
--------------------------------------------------------------------
bind(mod .. " + mouse:272", hl.dsp.window.drag(),   MOUSE)
bind(mod .. " + mouse:273", hl.dsp.window.resize(), MOUSE)

--------------------------------------------------------------------
-- PYPRLAND
--------------------------------------------------------------------
bind(mod .. " + A",         exec(pypr .. " toggle term"))            -- toggle the "term" scratchpad
bind(mod .. " + SHIFT + B", exec(pypr .. " expose"))                 -- expose every window, or jump to the focused one
-- These used `pypr change_workspace`, provided by pyprland's
-- workspaces_follow_focus plugin. That plugin was removed on 2026-08-19
-- because its focusedmon handler fed itself an infinite
-- focusedmon -> moveworkspace loop (see ~/.config/pypr/config.toml).
-- Repointed to the native monitor-relative equivalents, which is what
-- change_workspace approximated ("avoiding displayed workspaces").
bind(mod .. " + SHIFT + J", hl.dsp.focus({ workspace = "r-1" }))
bind(mod .. " + SHIFT + K", hl.dsp.focus({ workspace = "r+1" }))
bind(mod .. " + N",         exec(pypr .. " toggle_special minimized")) -- send window to/from "minimized"
bind(mod .. " + SHIFT + N", hl.dsp.workspace.toggle_special("minimized")) -- show/hide "minimized"
bind(mod .. " + SHIFT + O", exec(pypr .. " shift_monitors +1"))      -- swap workspaces between monitors
bind(mod .. " + SHIFT + Z", exec(pypr .. " zoom ++0.5"))             -- zoom in
bind(mod .. " + Z",         exec(pypr .. " zoom"))                   -- toggle zoom

--------------------------------------------------------------------
-- DESKTOP ZOOM / MAGNIFIER
--------------------------------------------------------------------
-- Doubles / halves cursor:zoom_factor, clamping at 1.
-- Uses `hyprctl eval` + hl.config: `hyprctl keyword` is rejected outright when
-- Hyprland runs a Lua config ("keyword can't work with non-legacy parsers").
bind(mod .. " + ALT + mouse_down", exec(
    [[hyprctl eval "hl.config({cursor={zoom_factor=$(hyprctl getoption cursor:zoom_factor | awk 'NR==1 {f = $2; if (f < 1) {f = 1}; print f * 2.0}')}})"]]
))
bind(mod .. " + ALT + mouse_up", exec(
    [[hyprctl eval "hl.config({cursor={zoom_factor=$(hyprctl getoption cursor:zoom_factor | awk 'NR==1 {f = $2; if (f < 1) {f = 1}; print f / 2.0}')}})"]]
))
