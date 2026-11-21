local h = require("helper")
local fileManager = "thunar"

local MONOCLE = "monocle" -- Hyprland's native monocle layout
local DEFAULT_LAYOUT = "scrolling"

-- Name of the tiled layout on the active workspace (e.g. "scrolling", "monocle")
local function current_layout()
	local ws = hl.get_active_workspace()
	if ws and ws.tiled_layout and ws.tiled_layout ~= "" then
		return ws.tiled_layout
	end
	return hl.get_config("general.layout")
end

-- Build a bind action that dispatches differently depending on the active layout.
-- actions: { [layout_name] = dispatcher, default = dispatcher }
local function per_layout(actions)
	return function()
		local layout = current_layout()
		local dispatcher = actions[layout]
		if dispatcher == nil and layout ~= MONOCLE then
			dispatcher = actions.default
		end
		if dispatcher then
			hl.dispatch(dispatcher)
		end
	end
end

local main_mod = "SUPER" -- Sets "Windows" key as main modifier

h.bind_key("ALT + P", hl.dsp.exec_cmd("~/.scripts/home-dashboard"))

h.bind_key(main_mod .. " + E", hl.dsp.exec_cmd(fileManager))

-- Toggle the global layout between scrolling and monocle
h.bind_key(main_mod .. " + SHIFT + M", function()
	local next_layout = current_layout() == MONOCLE and DEFAULT_LAYOUT or MONOCLE
	hl.config({ general = { layout = next_layout } })
	hl.dispatch(hl.dsp.event("hyprlayout," .. next_layout)) -- notify the DMS layout widget
end)

-- h/l: move between columns in scrolling, cycle focus in monocle
h.bind_key(
	main_mod .. " + h",
	per_layout({ [MONOCLE] = hl.dsp.layout("cycleprev"), default = hl.dsp.layout("move -col") })
)
h.bind_key(
	main_mod .. " + l",
	per_layout({ [MONOCLE] = hl.dsp.layout("cyclenext"), default = hl.dsp.layout("move +col") })
)

-- SHIFT + h/l: resize columns in scrolling, nothing in monocle
h.bind_key(main_mod .. " + SHIFT + h", per_layout({ default = hl.dsp.layout("colresize -0.2") }))
h.bind_key(main_mod .. " + SHIFT + l", per_layout({ default = hl.dsp.layout("colresize +0.2") }))
h.bind_key(main_mod .. " + SHIFT + a", hl.dsp.layout("fit active"))

-- Move between monitors
h.bind_key(main_mod .. " + period", hl.dsp.focus({ monitor = "+1" }))
h.bind_key(main_mod .. " + comma", hl.dsp.focus({ monitor = "-1" }))

h.bind_key(main_mod .. " + SHIFT + period", hl.dsp.window.move({ monitor = "+1" }))
h.bind_key(main_mod .. " + SHIFT + comma", hl.dsp.window.move({ monitor = "-1" }))

-- Scroll through existing workspaces with mainMod + scroll
h.bind_key(main_mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
h.bind_key(main_mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
h.bind_key(main_mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
h.bind_key(main_mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
h.bind_key(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
h.bind_key(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
h.bind_key(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
h.bind_key(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
h.bind_key("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
h.bind_key(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),
	{ locked = true, repeating = true }
)

-- Requires playerctl
h.bind_key("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
h.bind_key("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
h.bind_key("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
h.bind_key("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
