--------------------------------------------------------------------
-- SETTINGS
--------------------------------------------------------------------
-- Formerly confs/settings.conf. All the `section { key = value }` blocks
-- collapse into one nested hl.config() table.

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        repeat_rate  = 50,
        repeat_delay = 300,

        numlock_by_default         = true,
        left_handed                = false,
        float_switch_override_focus = 1,

        follow_mouse = 0,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            disable_while_typing   = true,
            natural_scroll         = true,
            clickfinger_behavior   = false,
            middle_button_emulation = true,
            -- NOTE: hyprlang spelled this `tap-to-click`; the Lua config
            -- uses the underscored name.
            tap_to_click           = true,
            drag_lock              = false,
        },
    },

    misc = {
        disable_hyprland_logo      = true,
        disable_splash_rendering   = true,
        -- vfr                     = true,
        vrr                        = 0,
        mouse_move_enables_dpms    = true,
        enable_swallow             = true,
        swallow_regex              = "^(kitty)$",
        -- true so clicking a notification actually raises the sending app.
        -- Google Chat's notifications carry only a "default"/Activate action;
        -- activating it is the only way the conversation opens (and thus gets
        -- marked read). With this false, Hyprland ignored Chrome's activation
        -- request and the click did nothing. Trade-off: any app may now raise
        -- itself via xdg-activation.
        focus_on_activate          = true,
        initial_workspace_tracking = 0,
        middle_click_paste         = false,
        mouse_move_focuses_monitor = true,
    },

    -- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/
    dwindle = {
        preserve_split = true, -- you probably want this
    },

    -- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/
    master = {
        new_status = "master",
    },

    binds = {
        workspace_back_and_forth = true,
        allow_workspace_cycles   = true,
        pass_mouse_when_bound    = false,
    },

    -- Can help when scaling, to avoid pixelating XWayland apps
    xwayland = {
        enabled            = true,
        force_zero_scaling = true,
    },

    render = {
        -- explicit_sync     = 2,
        -- explicit_sync_kms = 2,
        direct_scanout = false,
    },

    cursor = {
        sync_gsettings_theme     = true,
        no_hardware_cursors      = 2,
        enable_hyprcursor        = true,
        warp_on_change_workspace = 2,
        no_warps                 = false,
    },
})

-- `gesture = 3, horizontal, workspace` -- three-finger horizontal swipe
-- switches workspaces.
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})
