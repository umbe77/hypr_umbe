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

-- Hidden windows are also made unfocusable: they overlap the visible one and
-- Hyprland's click hit-test would otherwise hand focus to a hidden window.
local function set_hidden(w, hidden)
	hl.dispatch(hl.dsp.window.set_prop({ prop = "opacity_inactive", value = hidden and 0.0 or 1.0, window = w }))
	hl.dispatch(hl.dsp.window.set_prop({ prop = "opacity_inactive_override", value = hidden and 1 or 0, window = w }))
	hl.dispatch(hl.dsp.window.set_prop({ prop = "no_focus", value = hidden and 1 or 0, window = w }))
end

-- Show `current`, hide every other tiled window on `ws`
local function refresh(ws, current)
	for _, w in ipairs(hl.get_workspace_windows(ws)) do
		if is_tiled(w) then
			set_hidden(w, current == nil or w.address ~= current.address)
		end
	end
	-- Tiled windows are hit-tested front-to-back ("top" moves a window to the END
	-- of the list): keep the visible one at the front so pointer events reach it.
	if current ~= nil then
		hl.dispatch(hl.dsp.window.alter_zorder({ mode = "bottom", window = current }))
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

-- Focus a (possibly hidden, hence no_focus) window: make it focusable first
function M.focus(w)
	if enabled then
		set_hidden(w, false)
	end
	hl.dispatch(hl.dsp.focus({ window = w }))
end

hl.on("window.active", function(w)
	if type(w) ~= "table" then
		w = hl.get_active_window()
	end
	if is_tiled(w) and w.workspace and enabled then
		refresh(w.workspace, w)
	end
end)

-- Closing the visible window: Hyprland's focus fallback skips the hidden
-- (no_focus) windows, so pick the next one on that workspace ourselves.
hl.on("window.close", function(closed)
	if not enabled or type(closed) ~= "table" or not is_tiled(closed) or closed.workspace == nil then
		return
	end
	local ws_id, closed_addr = closed.workspace.id, closed.address
	hl.timer(function()
		if not enabled then
			return
		end
		local active = hl.get_active_window()
		if is_tiled(active) and active.workspace and active.workspace.id == ws_id then
			return -- something on that workspace already got focus
		end
		for _, ws in ipairs(hl.get_workspaces()) do
			if ws.id == ws_id then
				local next_w = nil
				if is_tiled(ws.last_window) and ws.last_window.address ~= closed_addr then
					next_w = ws.last_window
				else
					for _, w in ipairs(hl.get_workspace_windows(ws)) do
						if is_tiled(w) and w.address ~= closed_addr then
							next_w = w
							break
						end
					end
				end
				if next_w then
					M.focus(next_w)
				end
				return
			end
		end
	end, { timeout = 50, type = "oneshot" })
end)

-- A reload resets general.layout to scrolling: make sure nothing stays hidden
hl.on("config.reloaded", M.disable)

return M
