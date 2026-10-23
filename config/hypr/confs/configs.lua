--------------------------------------------------------------------
-- SHARED KNOBS
--------------------------------------------------------------------
-- Formerly confs/configs.conf, which declared these as $variables and
-- was `source`d by both decoration.conf and windowrules.conf.
--
-- hyprlang $variables are textual substitutions with global scope; Lua
-- has no equivalent, so this file returns a table instead and consumers
-- pull it in with:
--
--     local cfg = require("confs.configs")

return {
	opacity_act = 1,
	opacity_deact = 0.95,

	blur_size = 5,
	blur_pass = 3,

	shadow_range = 0,

	rounding = 5,
	border = 1,

	outer_gap = 0,
	inner_gap = 3,
}
