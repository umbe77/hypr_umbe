local h = require("helper")
local hs = require("plugins.hyprsplit")

hs.config({
	number_of_monitors = 10,
	persistent_workspaces = true,
})

local main_mod = "SUPER"

for i = 1, 10 do
	local key = i % 10
	h.bind_key(main_mod .. " + " .. key, hs.dsp.focus({ workspace = i }))
	h.bind_key(main_mod .. " + SHIFT + " .. key, hs.dsp.window.move({ workspace = i }))
end

h.bind_key(main_mod .. " + SHIFT + G", hs.dsp.grab_rogue_windows())
