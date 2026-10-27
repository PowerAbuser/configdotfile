--------------------------------------------------------------------
-- TAGS
--------------------------------------------------------------------
-- Formerly confs/tags.conf. Tags are applied first so that the rules in
-- confs/windowrules.lua can match on `tag = "browser*"` etc.
--
-- Every hl.window_rule() needs a unique `name`, so the names are generated
-- from the tag plus an index.

local tags = {
    -- Browsers
    { "browser", {
        "^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr|[Ff]irefox-bin)$",
        "^([Gg]oogle-chrome(-beta|-dev|-unstable|-stable)?)$",
        "^(chrome-.+-Default)$",                                   -- Chrome PWAs
        "^([Cc]hromium)$",
        "^([Mm]icrosoft-edge(-stable|-beta|-dev|-unstable))$",
        "^([Bb]rave-browser(-beta|-dev|-unstable)?)$",
        "^([Tt]horium-browser|[Cc]achy-browser)$",
    } },

    -- Terminals
    { "terminal", {
        "^(Alacritty|kitty|kitty-dropterm)$",
    } },

    -- File managers
    { "file-manager", {
        "^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt|[Dd]olphin)$",
    } },

    -- IDEs
    { "ide", {
        "^(codium|codium-url-handler|VSCodium)$",
        "^(VSCode|code-url-handler|code)$",
        "^(jetbrains-.+)$",                                        -- JetBrains IDEs
    } },
}

for _, entry in ipairs(tags) do
    local tag, classes = entry[1], entry[2]
    for i, class in ipairs(classes) do
        hl.window_rule({
            name  = "tag-" .. tag .. "-" .. i,
            match = { class = class },
            tag   = "+" .. tag,
        })
    end
end

-- Drop-down terminal floats
hl.window_rule({
    name  = "float-kitty-dropterm",
    match = { class = "^(kitty-dropterm)$" },
    float = true,
})

-- Drop-down Spotify (pypr "music" scratchpad, SUPER+O) floats
hl.window_rule({
    name  = "float-spotify-dropdown",
    match = { class = "^(spotify)$" },
    float = true,
})

-- Drop terminal (disabled in the original)
-- hl.window_rule({ name = "dropterm-ws",     match = { class = "^(kitty-dropterm)$" }, workspace = "special:S-term silent" })
-- hl.window_rule({ name = "dropterm-size",   match = { class = "^(kitty-dropterm)$" }, size = "75% 75%" })
-- hl.window_rule({ name = "dropterm-center", match = { class = "^(kitty-dropterm)$" }, center = true })
