--------------------------------------------------------------------
-- ENVIRONMENT VARIABLES
--------------------------------------------------------------------
-- Formerly confs/env.conf.
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

-- Cursor
-- This was spelled "HYRCURSOR_THEME" (missing the P in HYPR) for a long time,
-- so it never took effect; corrected below.
--
-- HEADS UP: "catppuccin-mocha-light-cursors" is not installed on this machine
-- -- there is no catppuccin cursor theme under ~/.icons, ~/.local/share/icons
-- or /usr/share/icons. Now that the variable name is correct, Hyprland will
-- look the theme up, fail to find it, and fall back to the default cursor.
-- Either install it (e.g. the catppuccin-cursors package / release tarball
-- into ~/.icons), or switch to the hyprcursor theme that *is* installed:
--
--     hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Ice")
-- hl.env("HYPRCURSOR_THEME", "catppuccin-mocha-light-cursors")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("HYPRCURSOR_SIZE", "24")

-- Toolkit backends
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")

-- Was set twice (qt5ct then qt6ct); the last assignment won, so qt6ct is what
-- has always actually been in effect. The redundant qt5ct line is now gone.
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

hl.env("QT_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")

-- Session identification
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")

-- grimblast screenshots: stops hyprpanel/hyprland crashing when screenshotting
hl.env("GRIMBLAST_HIDE_CURSOR", "0")

-- hl.env("XDG_MENU_PREFIX", "arch-")

-- Make Flatpak apps (e.g. Bambu Studio) appear in rofi/launchers.
-- Hyprland's session doesn't source /etc/profile.d/flatpak.sh, so XDG_DATA_DIRS
-- would otherwise miss the Flatpak export dirs and no flatpak app shows up.
hl.env(
	"XDG_DATA_DIRS",
	table.concat({
		os.getenv("HOME") .. "/.local/share/flatpak/exports/share",
		"/var/lib/flatpak/exports/share",
		"/usr/local/share",
		"/usr/share",
	}, ":")
)

-- Firefox
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- Electron >28 apps (may help)
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- xwayland apps scale fix (useful if you use monitor scaling)
-- see https://wiki.hypr.land/Configuring/XWayland/
-- hl.env("GDK_SCALE", "2")

--------------------------------------------------------------------
-- NVIDIA (all disabled, as in the original)
--------------------------------------------------------------------
-- hl.env("LIBVA_DRIVER_NAME", "nvidia")
-- hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
-- hl.env("GBM_BACKEND", "nvidia-drm")
-- hl.env("__NV_PRIME_RENDER_OFFLOAD", "1")
-- hl.env("__VK_LAYER_NV_optimus", "NVIDIA_only")
-- hl.env("WLR_DRM_NO_ATOMIC", "1")
-- hl.env("NVD_BACKEND", "direct")

-- For VMs and possibly NVIDIA
-- hl.env("WLR_NO_HARDWARE_CURSORS", "1")
-- hl.env("WLR_RENDERER_ALLOW_SOFTWARE", "1")

-- nvidia firefox (hardware acceleration on FF)
-- https://github.com/elFarto/nvidia-vaapi-driver#configuration
-- hl.env("MOZ_DISABLE_RDD_SANDBOX", "1")
-- hl.env("EGL_PLATFORM", "wayland")

--------------------------------------------------------------------
-- NOTE: env.conf also carried two `blurls = ...` lines (code-oss, waybar).
-- `blurls` was removed from Hyprland long ago -- the string doesn't even
-- appear in the 0.55.4 binary, so those lines have been dead for a while.
-- The modern equivalent is a layer rule; uncomment to actually enable it:
--
-- hl.layer_rule({ name = "blur-code-oss", match = { namespace = "code-oss" }, blur = true })
-- hl.layer_rule({ name = "blur-waybar",   match = { namespace = "waybar" },   blur = true })
