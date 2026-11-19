-- Custom monocle layout: every tiled window fills the whole work area.
-- Referenced by Hyprland as "lua:monocle".
--
-- Crossfade effect: while monocle is active, every tiled window except the
-- "current" one of its workspace gets an inactive opacity of 0 (override).
-- On focus change the new window becomes active (fades 0 -> 1) and the old
-- one becomes inactive (fades 1 -> 0), animated by the "fadeSwitch" leaf.
local M = {
	LAYOUT = "lua:monocle",
}

hl.layout.register("monocle", {
	recalculate = function(ctx)
		for _, target in ipairs(ctx.targets) do
			target:place(ctx.area)
		end
	end,
})

local function is_tiled(w)
	return w ~= nil and w.mapped and not w.floating
end

local function set_hidden(w, hidden)
	hl.dispatch(hl.dsp.window.set_prop({ prop = "opacity_inactive", value = hidden and 0.0 or 1.0, window = w }))
	hl.dispatch(hl.dsp.window.set_prop({ prop = "opacity_inactive_override", value = hidden and 1 or 0, window = w }))
end

-- Show `current`, hide every other tiled window on `ws`
local function refresh(ws, current)
	for _, w in ipairs(hl.get_workspace_windows(ws)) do
		if is_tiled(w) then
			set_hidden(w, current == nil or w.address ~= current.address)
		end
	end
	-- Hidden windows still take pointer input: keep the visible one on top of
	-- the stack, otherwise follow_mouse focuses whatever window sits above it.
	if current ~= nil then
		hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top", window = current }))
	end
end

-- Explicit state: tiled_layout lags one tick behind hl.config(), which would
-- let a focus event fired during the switch re-hide windows after disable().
local enabled = false

function M.enable()
	enabled = true
	local active = hl.get_active_window()
	for _, ws in ipairs(hl.get_workspaces()) do
		if not ws.special and ws.windows > 0 then
			local current = nil
			if is_tiled(active) and active.workspace and active.workspace.id == ws.id then
				current = active
			elseif is_tiled(ws.last_window) then
				current = ws.last_window
			else
				for _, w in ipairs(hl.get_workspace_windows(ws)) do
					if is_tiled(w) then
						current = w
						break
					end
				end
			end
			refresh(ws, current)
		end
	end
end

function M.disable()
	enabled = false
	for _, w in ipairs(hl.get_windows()) do
		if w.mapped then
			set_hidden(w, false)
		end
	end
end

hl.on("window.active", function(w)
	if type(w) ~= "table" then
		w = hl.get_active_window()
	end
	if is_tiled(w) and w.workspace and enabled then
		refresh(w.workspace, w)
	end
end)

-- A reload resets general.layout to scrolling: make sure nothing stays hidden
hl.on("config.reloaded", M.disable)

return M
