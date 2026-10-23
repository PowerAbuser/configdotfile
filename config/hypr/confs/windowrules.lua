--------------------------------------------------------------------
-- WINDOW RULES
--------------------------------------------------------------------
-- Formerly confs/windowrules.conf.
--
-- Translation notes:
--   * `match:class X match:title Y`  -> match = { class = "X", title = "Y" }
--   * `match:title negative:Y`       -> match = { title = "negative:Y" }
--   * `float on` / `center on`       -> float = true / center = true
--   * every rule needs a unique `name`
--
-- Rule order still matters (later rules win), so this file keeps the original
-- ordering: floats, then sizes, then positions, then opacity.

local cfg = require("confs.configs")

-- Tags must exist before anything matches on them.
require("confs.tags")

local function rule(name, match, effects)
	effects = effects or {}
	effects.name = name
	effects.match = match
	hl.window_rule(effects)
end

--------------------------------------------------------------------
-- FLOATING
--------------------------------------------------------------------

local float_classes = {
	"^(org.kde.polkit-kde-authentication-agent-1)$",
	"^(pavucontrol|org.pulseaudio.pavucontrol)$",
	"^(nwg-look|qt5ct|qt6ct|mpv)$",
	"^(file-roller|org.gnome.FileRoller)",
	"^([Kk]vantummanager)$",
	"^([Ll]xappearance)$",
	"^([dD]olphin)$",
	"^(yad)$",
	"^(eog)$",
	"^([Tt]hunar)$",
	"^([Gg]nome-disks)$",
	"org.gnome.Calculator",
	"^(com.obsproject.Studio)$",
	"^(org.telegram.desktop)$",
	"(codium|codium-url-handler|VSCodium)",
	"(xdg-desktop-portal-gtk)",
}

for i, class in ipairs(float_classes) do
	rule("float-class-" .. i, { class = class }, { float = true })
end

-- Float by tag
rule("float-tag-file-manager", { tag = "file-manager" }, { float = true })

-- Kitty windows we launch with a specific --title should float
for i, title in ipairs({ "(update)", "(yazi)", "(monitor)", "(browser)", "(floating)" }) do
	rule("float-kitty-" .. i, { class = "^(kitty)$", title = title }, { float = true })
end

-- Float by title
-- NOTE: the original listed "Authentication Required" twice; deduplicated here.
rule("float-auth-required", { title = "^(Authentication Required)$" }, { float = true })
rule("float-add-folder-title", { title = "^(Add Folder to Workspace)$" }, { float = true })
rule("float-open-files", { initial_title = "(Open Files)" }, { float = true })

-- Dialogs that only float in a specific context
rule("float-thunar-replace", { class = "([Tt]hunar)", title = "(Confirm to replace files)" }, { float = true })
rule("float-electron-addfolder", { class = "(electron)", title = "(Add Folder to Workspace)" }, { float = true })

-- Float the app's secondary windows but not its main window
rule(
	"float-heroic-secondary",
	{ class = "^(com.heroicgameslauncher.hgl)$", title = "negative:(Heroic Games Launcher)" },
	{ float = true }
)
rule("float-steam-secondary", { class = "^([Ss]team)$", title = "negative:^([Ss]team)$" }, { float = true })
rule("float-thunar-secondary", { class = "([Tt]hunar)", title = "negative:(.*[Tt]hunar.*)" }, { float = true })

-- Browser popups
rule("float-browser-wants-to-open", { tag = "browser*", initial_title = "^(wants to open)$" }, { float = true })
-- Chrome devtools (undocked inspect window)
rule("float-browser-devtools", { tag = "browser*", title = "^(DevTools)" }, { float = true })

--------------------------------------------------------------------
-- SIZE
--------------------------------------------------------------------

local sizes = {
	{ "60% 80%", "^([Kk]vantummanager)$" },
	{ "60% 80%", "^([Ll]xappearance)$" },
	{ "60% 80%", "^(nwg-look)$" },
	{ "60% 80%", "^(eog)$" },
	{ "70% 70%", "^(xdg-desktop-portal-gtk)$" },
	{ "60% 70%", "^(nwg-look|qt5ct|qt6ct|mpv)$" },
	{ "60% 70%", "^(pavucontrol|org.pulseaudio.pavucontrol)$" },
	{ "50% 80%", "^(com.obsproject.Studio)$" },
	{ "60% 80%", "^(org.telegram.desktop)$" },
	-- "<550 <800" means "at most 550 wide, at most 800 tall"
	{ "<550 <800", "org.gnome.Calculator" },
}

for i, s in ipairs(sizes) do
	rule("size-" .. i, { class = s[2] }, { size = s[1] })
end

rule("size-kvantum-title", { title = "(Kvantum Manager)" }, { size = "60% 70%" })

--------------------------------------------------------------------
-- POSITION
--------------------------------------------------------------------

-- NOTE: the original listed ([Tt]hunar) twice here; deduplicated.
for i, class in ipairs({ "([Tt]hunar)", "^(nwg-look)$", "^(qt5ct)$", "^(lxappearance)$", "^(yad)$" }) do
	rule("center-" .. i, { class = class }, { center = true })
end

rule("center-kitty-utility", { class = "^(kitty)$", title = "(yazi|update|browser)" }, { center = true })

--------------------------------------------------------------------
-- JETBRAINS POPUPS
--------------------------------------------------------------------

rule("jetbrains-no-focus", { class = "^jetbrains-" }, {
	no_initial_focus = true,
	float = true,
})

-- Centre the popups. An empty `title` match means "has a title property at
-- all", which is how the original `match:title` with no value behaved.
rule("jetbrains-popup-move", { class = "^jetbrains-(?!toolbox)", title = "" }, {
	move = "30% 30%",
	float = true,
})

rule("jetbrains-popup-size", { class = "^jetbrains-(?!toolbox)", title = "negative:^(win.*)" }, {
	size = "40% 40%",
	float = true,
})

--------------------------------------------------------------------
-- OPACITY
--------------------------------------------------------------------
-- `opacity ACTIVE INACTIVE` is a single space-separated string.

local function opacity(active, inactive)
	return string.format("%s %s", active, inactive)
end

-- rule("opacity-ide", { tag = "ide*" }, { opacity = opacity(cfg.opacity_act, cfg.opacity_deact) })
rule("opacity-terminal", { tag = "terminal*" }, { opacity = opacity(cfg.opacity_act, cfg.opacity_deact) })
rule("opacity-file-manager", { tag = "file-manager*" }, { opacity = opacity(cfg.opacity_act, cfg.opacity_deact) })
rule("opacity-browser", { tag = "browser*" }, { opacity = opacity(1.0, cfg.opacity_deact) })

--------------------------------------------------------------------
-- OPEN IN WORKSPACES (all disabled in the original)
--------------------------------------------------------------------
-- rule("ws-kitty-main", { class = "^(kitty)$", title = "(main)" }, { workspace = 1 })
-- rule("ws-terminal",   { tag = "terminal*" }, { workspace = 1 })
-- rule("ws-browser",    { tag = "browser*"  }, { workspace = 2 })
-- rule("ws-ide",        { tag = "ide*"      }, { workspace = 3 })
-- rule("ws-obs",        { class = "^(com.obsproject.Studio)$" }, { workspace = 3 })

-- hl.workspace_rule({ workspace = "special:exposed", gaps_out = 60, gaps_in = 30, border_size = 5, border = true, shadow = false })

--------------------------------------------------------------------
-- LAYER RULES
--------------------------------------------------------------------

for i, ns in ipairs({
	"notifications",
	"rofi",
	"logout_dialog",
	-- swaync blur removed on request.
	-- swaync keeps its layer surfaces mapped permanently (slid offscreen when
	-- closed), and with layer-shell-cover-screen:true in swaync's config.json
	-- the control-center surface + its blank-window on every other monitor
	-- span the FULL screen. Blurring that namespace therefore blurred the
	-- entire desktop, not just the 650px panel.
	-- "swaync-control-center",
	-- "swaync-notification-window",
}) do
	hl.layer_rule({ name = "blur-" .. i, match = { namespace = ns }, blur = true })
end

-- Disabled in the original
-- hl.layer_rule({ name = "ia-rofi",   match = { namespace = "rofi" },                       ignore_alpha = 0.5 })
-- hl.layer_rule({ name = "ia-swaync", match = { namespace = "swaync-control-center" },      ignore_alpha = 0.5 })

-- NOTE: windowrules.conf also had `blurls = code`. `blurls` no longer exists
-- in Hyprland (it isn't even a string in the 0.55.4 binary), so that line was
-- already doing nothing. The modern equivalent, should you want it:
-- hl.layer_rule({ name = "blur-code", match = { namespace = "code" }, blur = true })
--
--
--
--GAME RULES
rule("float-easy-survivors", { class = "^(easy_survivors)$" }, { float = true })
-- rule("size-easy-survivors", { class = "^(easy_survivors)$" }, { size = "1280 720" })
rule("center-easy-survivors", { class = "^(easy_survivors)$" }, { center = true })
