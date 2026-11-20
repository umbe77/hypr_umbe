-- Hyprland configuration (Lua) — https://wiki.hypr.land/configuring/

package.path = string.format("%s;./?.lua;./?/init.lua", package.path)

-- DMS_STARTUP_BEGIN
hl.on("hyprland.start", function()
	hl.exec_cmd("dbus-update-activation-environment --systemd --all")
	if not os.getenv("HYPRLAND_NO_SD_TARGET") then
		hl.exec_cmd("systemctl --user start hyprland-session.target")
	end
	hl.exec_cmd("hypridle")
end)
-- DMS_STARTUP_END

-- Start elecwhat 60s after Hyprland is up
local elecwhat_timer -- keep a reference so the timer isn't garbage-collected
hl.on("hyprland.start", function()
	elecwhat_timer = hl.timer(function()
		hl.exec_cmd("elecwhat")
	end, { timeout = 60000, type = "oneshot" })
end)

hl.config({
	input = {
		-- empty inherits XKB_DEFAULT_LAYOUT (libxkbcommon), falls back to "us"
		kb_layout = "",
		numlock_by_default = true,
		follow_mouse = 0,
		sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.
		-- dms/input.lua is required later and wins per key
		touchpad = {
			tap_to_click = true,
			natural_scroll = true,
		},
	},
	decoration = {
		rounding = 10,
		active_opacity = 1.0,
		inactive_opacity = 0.9,
		shadow = {
			enabled = false,
			range = 4,
			render_power = 3,
			color = "0xee1a1a1a",
		},
	},
	misc = {
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
	},
	cursor = {
		inactive_timeout = 2,
		hide_on_key_press = true,
	},
})

hl.animation({ leaf = "windowsIn", enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 3, bezier = "default" })

hl.window_rule({ match = { class = "^(org\\.wezfurlong\\.wezterm)$" }, tile = true })
hl.window_rule({ match = { class = "^(org\\.gnome\\.)" }, rounding = 12 })
hl.window_rule({ match = { class = "^(gnome-control-center)$" }, tile = true })
hl.window_rule({ match = { class = "^(pavucontrol)$" }, tile = true })
hl.window_rule({ match = { class = "^(nm-connection-editor)$" }, tile = true })
hl.window_rule({ match = { class = "^(org\\.gnome\\.Calculator)$" }, float = true })
hl.window_rule({ match = { class = "^(gnome-calculator)$" }, float = true })
hl.window_rule({ match = { class = "^(galculator)$" }, float = true })
hl.window_rule({ match = { class = "^(blueman-manager)$" }, float = true })
hl.window_rule({ match = { class = "^(xdg-desktop-portal)$" }, float = true })
hl.window_rule({
	match = { class = "^(steam)$", title = "^(notificationtoasts)" },
	no_initial_focus = true,
	pin = true,
})
hl.window_rule({
	match = { class = "^(firefox)$", title = "^(Picture-in-Picture)$" },
	float = true,
})
hl.window_rule({ match = { class = "^(zoom)$" }, float = true })
hl.layer_rule({ match = { namespace = "^(quickshell)$" }, no_anim = true })
hl.layer_rule({ match = { namespace = "^dms:.*" }, no_anim = true })

hl.window_rule({
	name = "Thunar",
	match = { class = "thunar" },
	float = true,
	size = { "(monitor_w*0.7)", "(monitor_h*0.8)" },
})

hl.window_rule({
	name = "Elecwhat",
	match = { class = "elecwhat" },
	float = true,
	size = { "(monitor_w*0.7)", "(monitor_h*0.7)" },
})

require("dms.colors")
require("dms.outputs")
require("dms.layout")
require("dms.cursor")
require("dms.input")
require("dms.binds")
require("dms.binds-user")
require("dms.windowrules")

require("umbe-layout") -- Load custom layout from umbe-layout.lua
require("umbe-binds") -- Load custom keybinds from umbe-binds.lua
require("umbe-split-workspace") -- Load custom workspace splitting from umbe-split-workspace.lua
