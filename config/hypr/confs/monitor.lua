--------------------------------------------------------------------
-- MONITOR CONFIG
--------------------------------------------------------------------
-- Formerly confs/monitor.conf.
-- `monitor = NAME, MODE, POSITION, SCALE [, mirror, SOURCE]` becomes a
-- table, so the positional-argument guessing goes away.

hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })

-- External monitors
hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "-1920x0", scale = 1 })
hl.monitor({ output = "DP-1", mode = "preferred", position = "0x0", scale = 1 })

-- Home monitors (swap with the pair above when docked at home)
-- hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "0x0", scale = 1 })
-- hl.monitor({ output = "DP-1", mode = "preferred", position = "-1920x0", scale = 1 })

-- Catch-all for any monitor not named above: mirror the laptop panel.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1, mirror = "eDP-1" })
-- ...or give unknown outputs their own space instead of mirroring:
-- hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
