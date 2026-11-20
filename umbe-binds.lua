local hs = require("hyprsplit")
local monocle = require("monocle")

local fileManager = "thunar"

local function bind_key(key, action, opts)
	hl.unbind(key) -- Unbind the key first to avoid conflicts
	hl.bind(key, action, opts)
end

local MONOCLE = monocle.LAYOUT -- custom layout registered in monocle.lua
local DEFAULT_LAYOUT = "scrolling"

-- Name of the tiled layout on the active workspace (e.g. "scrolling", "lua:monocle")
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

-- Focus the next (step = 1) / previous (step = -1) tiled window on the active workspace, wrapping around.
local function cycle_tiled_focus(step)
	return function()
		local ws = hl.get_active_workspace()
		if ws == nil then
			return
		end
		local tiled = {}
		local current = 0
		local active = hl.get_active_window()
		for _, w in ipairs(hl.get_workspace_windows(ws)) do
			if w.mapped and not w.floating then
				table.insert(tiled, w)
				if active and w.address == active.address then
					current = #tiled
				end
			end
		end
		if #tiled < 2 then
			return
		end
		local target = ((current - 1 + step) % #tiled) + 1
		monocle.focus(tiled[target]) -- clears no_focus on hidden monocle windows
	end
end

local main_mod = "SUPER" -- Sets "Windows" key as main modifier

bind_key("ALT + P", hl.dsp.exec_cmd("~/.scripts/home-dashboard"))

bind_key(main_mod .. " + E", hl.dsp.exec_cmd(fileManager))

-- Toggle the global layout between scrolling and monocle
bind_key(main_mod .. " + SHIFT + M", function()
	local next_layout = current_layout() == MONOCLE and DEFAULT_LAYOUT or MONOCLE
	hl.config({ general = { layout = next_layout } })
	hl.dispatch(hl.dsp.event("hyprlayout," .. next_layout)) -- notify the DMS layout widget
	if next_layout == MONOCLE then
		monocle.enable()
	else
		monocle.disable()
	end
	hl.notification.create({ text = "Layout: " .. next_layout, duration = "1500" })
end)

-- h/l: move between columns in scrolling, cycle focus in monocle
bind_key(main_mod .. " + h", per_layout({ [MONOCLE] = cycle_tiled_focus(-1), default = hl.dsp.layout("move -col") }))
bind_key(main_mod .. " + l", per_layout({ [MONOCLE] = cycle_tiled_focus(1), default = hl.dsp.layout("move +col") }))

-- SHIFT + h/l: resize columns in scrolling, nothing in monocle
bind_key(main_mod .. " + SHIFT + h", per_layout({ default = hl.dsp.layout("colresize -0.2") }))
bind_key(main_mod .. " + SHIFT + l", per_layout({ default = hl.dsp.layout("colresize +0.2") }))
bind_key(main_mod .. " + SHIFT + a", hl.dsp.layout("fit active"))

-- Move between monitors
bind_key(main_mod .. " + period", hl.dsp.focus({ monitor = "+1" }))
bind_key(main_mod .. " + comma", hl.dsp.focus({ monitor = "-1" }))

bind_key(main_mod .. " + SHIFT + period", hl.dsp.window.move({ monitor = "+1" }))
bind_key(main_mod .. " + SHIFT + comma", hl.dsp.window.move({ monitor = "-1" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]

for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	bind_key(main_mod .. " + " .. key, hs.dsp.focus({ workspace = i }))
	bind_key(main_mod .. " + SHIFT + " .. key, hs.dsp.window.move({ workspace = i }))
end

-- Scroll through existing workspaces with mainMod + scroll
bind_key(main_mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
bind_key(main_mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
bind_key(main_mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
bind_key(main_mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
bind_key(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
bind_key(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
bind_key(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
bind_key(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
bind_key("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
bind_key("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl
bind_key("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
bind_key("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
bind_key("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
bind_key("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
