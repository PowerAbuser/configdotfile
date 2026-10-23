--------------------------------------------------------------------
-- LOOK AND FEEL
--------------------------------------------------------------------
-- confs/decoration.lua supplies the palette: Catppuccin Mocha or Latte,
-- following the quickshell dark/light mode (confs/theme_mode.lua).

local cfg = require("confs.configs")

local M = {}

--- Apply a theme.
--- @param theme table  active, inactive, icon, gtk, scheme
function M.apply(theme)
    -- Formerly `exec = ...` lines, i.e. re-run on every config reload
    -- (not just at startup), which is what keeps GTK in sync after a
    -- theme switch + `hyprctl reload`.
    hl.exec_cmd("gsettings set org.gnome.desktop.interface icon-theme "   .. theme.icon)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme "    .. theme.gtk)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme " .. theme.scheme)

    hl.config({
        general = {
            layout      = "dwindle",
            gaps_in     = cfg.inner_gap,
            gaps_out    = cfg.outer_gap,
            border_size = cfg.border,

            col = {
                active_border   = theme.active,
                inactive_border = theme.inactive,
            },

            resize_on_border = false,
            allow_tearing    = false,
        },

        decoration = {
            rounding       = cfg.rounding,
            rounding_power = 2,

            -- active_opacity / inactive_opacity are deliberately left unset,
            -- as in the original -- per-window opacity is done with window
            -- rules in confs/windowrules.lua instead.
            -- active_opacity   = cfg.opacity_act,
            -- inactive_opacity = cfg.opacity_deact,
            fullscreen_opacity = 1.0,

            -- dim_inactive stays off, as in the original
            -- dim_inactive = true,
            dim_strength = 0.1,
            dim_special  = 0.8,

            shadow = {
                enabled        = true,
                range          = cfg.shadow_range,
                render_power   = 4,
                color          = theme.active,
                color_inactive = theme.inactive,
            },

            blur = {
                enabled           = true,
                size              = cfg.blur_size,
                passes            = cfg.blur_pass,
                ignore_opacity    = true,
                new_optimizations = true,
                special           = true,
                popups            = true,
            },
        },
    })

    return theme
end

return M
