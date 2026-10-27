-- Dry-run ~/.config/hypr/hyprland.lua against a stand-in `hl` that accepts
-- any call: catches runtime errors (nil values, bad requires) without
-- touching Hyprland. Used by safe-reload.sh.
--     lua ~/.config/hypr/scripts/check-config.lua   -> exit 0 if it runs clean
local function any()
  return setmetatable({}, {
    __index = function(t, k) local v = any(); rawset(t, k, v); return v end,
    __call = function() return any() end,
    __concat = function(a, b) return tostring(a) .. tostring(b) end,
    __tostring = function() return "<hl>" end,
  })
end
hl = any()
local cfg = os.getenv("HOME") .. "/.config/hypr/"
package.path = cfg .. "?.lua;" .. cfg .. "?/init.lua;" .. package.path
local ok, err = pcall(dofile, cfg .. "hyprland.lua")
if not ok then io.stderr:write("hypr config error: " .. tostring(err) .. "\n"); os.exit(1) end
