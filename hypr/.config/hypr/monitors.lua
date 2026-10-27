-- desc: instead of DP-n: connector names differ from X and follow the cable.
local iiyama = "desc:iiyama Corporation PL2792Q 1152194803166"
local g7     = "desc:Samsung Electric Company Odyssey G7 H1AK500000"

hl.monitor({ output = iiyama, mode = "2560x1440@69.92", position = "0x0",    scale = 1 })
hl.monitor({ output = g7,     mode = "3840x2160@60",    position = "2560x0", scale = 1.5 })
hl.monitor({ output = "",     mode = "preferred",       position = "auto",   scale = "auto" })

hl.workspace_rule({ workspace = "1", monitor = iiyama, default = true })
hl.workspace_rule({ workspace = "2", monitor = iiyama })
hl.workspace_rule({ workspace = "3", monitor = g7, default = true })
hl.workspace_rule({ workspace = "4", monitor = g7 })

-- No "primary" in Hyprland: it starts on monitor ID 0, which is the G7 (DP-2 enumerates first).
hl.on("hyprland.start", function()
    hl.dispatch(hl.dsp.focus({ monitor = iiyama }))
end)
