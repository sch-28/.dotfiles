-- Scratchpad apps, driven by scratchpad.lua. class/skip_title double as Lua patterns
-- there, so keep them plain. overlay = shown as a special workspace (on top, rest
-- dimmed) instead of fetched onto the current workspace. Floating comes from
-- float-by-default below.
local scratchpads = {
    vol     = { class = "^vol$",     cmd = "kitty --class vol -e pulsemixer",                      size = { 1400, 800 } },
    notes   = { class = "^notes$",   cmd = 'kitty --class notes -1 -e zsh -lic "nvim ~/notes.md"', size = { 1400, 800 } },
    news    = { class = "^news$",    cmd = "kitty --class news -e newsboat",                       size = { 1400, 800 } },
    spotify = { class = "^spotify$", cmd = "spotify-launcher", overlay = true },
    -- Huddle / mini windows share the class; the main window is the scratchpad.
    slack   = { class = "^Slack$",   cmd = "slack",                                                size = { 1600, 1000 }, skip_title = "[Hh]uddle" },}

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

-- i3 ignored client maximize requests. Apps send them on open (kitty, Slack restoring
-- its state) and would cover the workspace or drop out of floating; Super+m still maximizes.
hl.window_rule({ name = "suppress-maximize", match = { class = ".*" }, suppress_event = "maximize" })

-- Not every game or player inhibits idle itself; no lock/screen-off while any window is fullscreen.
hl.window_rule({ name = "idle-fullscreen", match = { class = ".*" }, idle_inhibit = "fullscreen" })

-- i3: everything floats except terminals and the browser (any firefox build).
hl.window_rule({
    name = "float-by-default",
    match = { class = "negative:^(kitty|firefox.*)$" },
    float = true,
    center = true,
    persistent_size = true,
})

-- Proton games: most run "borderless windowed" and never ask for fullscreen, so they opened
-- as a screen-sized floating window under the bar. "game" also enables direct scanout (look.lua).
-- Launchers share the class but open smaller, so only a screen-sized window goes fullscreen.
hl.window_rule({ name = "steam-games", match = { class = "^steam_app_.*" }, content = "game" })
hl.on("window.open", function(w)
    if not (w and w.monitor and w.class:find("^steam_app_")) then return end
    local m = w.monitor
    if w.size.x >= m.width / m.scale and w.size.y >= m.height / m.scale * 0.9 then
        hl.dispatch(hl.dsp.window.fullscreen({ action = "set", window = w }))
    end
end)

-- Apps started via hl-exec. Hyprland's own initial_workspace_tracking moves only the first
-- window (Steam's login prompt, not its main window). The time limit keeps children started
-- much later, like games launched from Steam, from following.
hl.on("window.open", function(w)
    if not (w and w.pid and w.workspace) then return end
    local f = io.open("/proc/" .. w.pid .. "/environ")
    if not f then return end
    local env = f:read("a")
    f:close()
    local ws, at = env:match("HL_LAUNCH_WS=(%-?%d+)"), env:match("HL_LAUNCH_AT=(%d+)")
    if ws and os.time() - tonumber(at) < 120 and tonumber(ws) ~= w.workspace.id then
        hl.dispatch(hl.dsp.window.move({ workspace = tonumber(ws), follow = false, window = w }))
    end
end)

hl.window_rule({ name = "nvim-float", match = { class = "^nvim-float$" }, float = true, size = { 1400, 900 }, center = true })

return scratchpads
