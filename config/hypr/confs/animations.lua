--------------------------------------------------------------------
-- ANIMATIONS
--------------------------------------------------------------------
-- Formerly confs/animations.conf.
-- `bezier = NAME,x1,y1,x2,y2` is now hl.curve() with explicit control
-- points, and `animation = LEAF,ENABLED,SPEED,CURVE[,STYLE]` is now
-- hl.animation() with named fields.

hl.config({ animations = { enabled = true } })

-- Bezier curves. Points are the two control points of a cubic bezier.
local curves = {
    overshot = { { 0.13, 0.99 }, { 0.29, 1.15  } },
    win      = { { 0.15, 0.90 }, { 0.25, 1.2   } },
    wind     = { { 0.05, 0.90 }, { 0.10, 1.05  } },
    winIn    = { { 0.10, 1.10 }, { 0.10, 1.10  } },
    winOut   = { { 0.30, -0.30 }, { 0.00, 1.00 } },
    liner    = { { 1.00, 1.00 }, { 1.00, 1.00  } },
}

for name, points in pairs(curves) do
    hl.curve(name, { type = "bezier", points = points })
end

-- Animation leaves. `style` is optional.
-- NOTE: `win`, `winIn` and `winOut` above are defined but unused, exactly as
-- in the original config -- they're here for the commented-out `windows` leaf.
local animations = {
    -- { leaf,           speed, curve,     style }
    -- { "windows",      6,     "wind",    "slide" },
    { "windowsIn",       5,     "overshot", "slide" },
    { "windowsOut",      5,     "overshot", "slide" },
    { "windowsMove",     5,     "wind",     "slide" },
    { "border",          1,     "liner"             },
    { "fade",           10,     "default"           },
    { "workspaces",      5,     "overshot", "slide" },
    { "layersIn",        4,     "overshot", "slide" },
    { "layersOut",       7,     "overshot", "slide 10%" },
}

for _, a in ipairs(animations) do
    hl.animation({
        leaf    = a[1],
        enabled = true,
        speed   = a[2],
        bezier  = a[3],
        style   = a[4], -- nil when omitted, which hl.animation treats as unset
    })
end
