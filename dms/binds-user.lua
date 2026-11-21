-- Your keybinds. dms setup never overwrites this file.
-- Loaded after binds.lua: binding a stock key here replaces it, hl.unbind("SUPER + X") frees it.
-- Saving in the DMS keybind editor rewrites this file and keeps only hl.bind/hl.unbind lines.

hl.unbind("ALT + Alt_L")
hl.bind("ALT + Alt_L", hl.dsp.exec_cmd("dms ipc call windowSwitcher commit"), { release = true, transparent = true, description = "Window switcher commit" })
hl.unbind("ALT + SHIFT + Tab")
hl.bind("ALT + SHIFT + Tab", hl.dsp.exec_cmd("dms ipc call windowSwitcher prev"), { description = "Window switcher (back)" })
hl.unbind("ALT + Tab")
hl.bind("ALT + Tab", hl.dsp.exec_cmd("dms ipc call windowSwitcher next"), { description = "Window switcher" })
hl.unbind("CTRL + Control_L")
hl.bind("CTRL + Control_L", hl.dsp.exec_cmd("dms ipc call findPointer tap"), { release = true, description = "Find pointer" })
hl.unbind("SUPER + SHIFT + D")
hl.bind("SUPER + SHIFT + D", hl.dsp.exec_cmd("dms ipc call dockerStacks toggle"), { description = "Docker containers" })
hl.unbind("SUPER + H")
hl.unbind("SUPER + J")
hl.unbind("SUPER + K")
hl.unbind("SUPER + L")
hl.unbind("SUPER + left")
