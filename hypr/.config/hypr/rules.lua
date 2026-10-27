-- Scratchpad apps, driven by scratchpad.lua. class/skip_title double as Lua patterns
-- there, so keep them plain. overlay = shown as a special workspace (on top, rest
-- dimmed) instead of fetched onto the current workspace. Floating comes from
-- float-by-default below.
local scratchpads = {
    vol     = { class = "^vol$",     cmd = "kitty --class vol -e pulsemixer",                      size = { 1400, 800 } },
    notes   = { class = "^notes$",   cmd = 'kitty --class notes -1 -e zsh -lic "nvim ~/notes.md"', size = { 1400, 800 } },
    news    = { class = "^news$",    cmd = "kitty --class news -e newsboat",                       size = { 1400, 800 } },
    spotify = { class = "^Spotify$", cmd = "spotify-launcher", overlay = true },
    -- Huddle / mini windows share the class; the main window is the scratchpad.
    slack   = { class = "^Slack$",   cmd = "slack",                                                size = { 1600, 1000 }, skip_title = "[Hh]uddle" },
}

for name, s in pairs(scratchpads) do
    if s.overlay then
        hl.workspace_rule({ workspace = "special:" .. name, on_created_empty = s.cmd })
    end
    hl.window_rule({
        name = "scratchpad-" .. name,
        match = { class = s.class, title = s.skip_title and ("negative:.*" .. s.skip_title .. ".*") or nil },
        workspace = s.overlay and ("special:" .. name .. " silent") or nil,
        size = s.size,
    })
end

-- Spotify sets its class only after mapping, so the static rule above never matches it.
hl.on("window.class", function(w)
    if w and w.class == "Spotify" and not (w.workspace and w.workspace.name == "special:spotify") then
        hl.dispatch(hl.dsp.window.move({ workspace = "special:spotify", follow = false, window = w }))
        hl.dispatch(hl.dsp.window.float({ action = "enable", window = w }))
    end
end)

-- i3 ignored client maximize requests. Apps send them on open (kitty, Slack restoring
-- its state) and would cover the workspace or drop out of floating; Super+m still maximizes.
hl.window_rule({ name = "suppress-maximize", match = { class = ".*" }, suppress_event = "maximize" })

-- i3: everything floats except terminals and the browser (any firefox build).
hl.window_rule({
    name = "float-by-default",
    match = { class = "negative:^(kitty|firefox.*)$" },
    float = true,
    center = true,
    persistent_size = true,
})

hl.window_rule({ name = "nvim-float", match = { class = "^nvim-float$" }, float = true, size = { 1400, 900 }, center = true })

return scratchpads
