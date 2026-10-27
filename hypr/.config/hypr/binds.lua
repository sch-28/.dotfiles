local mod = "SUPER"

-- dms/binds.lua loads first and binds many of the same keys; Hyprland would fire both.
local function bind(keys, dispatcher, opts)
    hl.unbind(keys)
    hl.bind(keys, dispatcher, opts)
end

local function dms(args) return hl.dsp.exec_cmd("dms ipc call " .. args) end
local scratchpad = require("scratchpad")

-- Dux defaults that would bite: screens off on a typo, and Super-less binds stealing app shortcuts.
hl.unbind(mod .. " + SHIFT + P")
hl.unbind("CTRL + SHIFT + R")
hl.unbind("ALT + space")

-- hjkl walks through grouped (tabbed) windows first, like i3 tabs.
hl.config({ binds = { movefocus_cycles_groupfirst = true } })

bind(mod .. " + Return",          hl.dsp.exec_cmd("kitty -e zsh -i -c tmux"))
bind(mod .. " + BackSpace",       hl.dsp.exec_cmd("kitty --single-instance"))
bind(mod .. " + SHIFT + Return",  hl.dsp.exec_cmd("firefox"))
bind(mod .. " + o",               hl.dsp.exec_cmd("dolphin"))
bind(mod .. " + space",           dms("spotlight toggle"))
bind(mod .. " + SHIFT + space",   hl.dsp.exec_cmd("rofi -show drun"))
-- Physical key (US ;): on de it is ö, and binds resolve on the first layout (de).
bind(mod .. " + code:47",         hl.dsp.exec_cmd("rofi -modi emoji -show emoji"))
bind(mod .. " + v",               dms("clipboard toggle"))
bind(mod .. " + SHIFT + s",       hl.dsp.exec_cmd("dms screenshot"))
bind("Print",                     hl.dsp.exec_cmd("dms screenshot full"))
bind(mod .. " + SHIFT + x",       hl.dsp.exec_cmd("dms color pick -a"))
bind(mod .. " + SHIFT + r",       hl.dsp.exec_cmd("~/.config/hypr/scripts/record.sh"))
bind(mod .. " + SHIFT + w",       dms("wallpaperCarousel toggle"))
bind(mod .. " + CTRL + w",        dms("wallpaper next"))
bind(mod .. " + p", function()
    if scratchpad.running("spotify") then
        hl.dispatch(hl.dsp.exec_cmd("playerctl --player=spotify play-pause"))
    else
        scratchpad.toggle("spotify", "hide")
    end
end)

bind(mod .. " + Tab",             dms("hypr toggleOverview"))
bind(mod .. " + c",               dms("control-center toggle"))
bind(mod .. " + a",               dms("dash toggle \"\""))
bind(mod .. " + comma",           dms("settings focusOrToggle"))
bind(mod .. " + F1",              dms("keybinds toggle hyprland"))
bind(mod .. " + n",               dms("notifications dismiss"))
bind(mod .. " + SHIFT + n",       dms("notifications dismissAllPopups"))
bind(mod .. " + ALT + n",         dms("notifications toggleDoNotDisturb"))
bind(mod .. " + Escape",          dms("lock lock"))
bind(mod .. " + SHIFT + e",       dms("powermenu toggle"))
bind("CTRL + SHIFT + Escape",     dms("processlist focusOrToggle"))

bind(mod .. " + q",               hl.dsp.window.close())
bind(mod .. " + SHIFT + q",       hl.dsp.window.kill())
bind(mod .. " + f",               hl.dsp.window.fullscreen())
bind(mod .. " + m",               hl.dsp.window.fullscreen({ mode = "maximized" }))
bind(mod .. " + g",               hl.dsp.window.float({ action = "toggle" }))
bind(mod .. " + y",               hl.dsp.window.pin())
bind(mod .. " + w",               hl.dsp.group.toggle())
bind(mod .. " + s",               hl.dsp.layout("preselect d"))
bind(mod .. " + SHIFT + v",       hl.dsp.layout("preselect r"))
bind(mod .. " + e",               hl.dsp.layout("togglesplit"))
bind("ALT + Tab",                 hl.dsp.focus({ last = true }))
bind("ALT + SHIFT + Tab",         hl.dsp.window.cycle_next())

-- i3 "focus mode_toggle": jump between the floating and the tiled layer.
bind(mod .. " + SHIFT + g", function()
    local w = hl.get_active_window()
    hl.dispatch(hl.dsp.window.cycle_next(w and w.floating and { tiled = true } or { floating = true }))
end)

bind(mod .. " + SHIFT + f", function()
    local w = hl.get_active_window()
    if w and w.floating then
        hl.dispatch(hl.dsp.window.float({ action = "disable" }))
        return
    end
    hl.dispatch(hl.dsp.window.float({ action = "enable" }))
    hl.dispatch(hl.dsp.window.resize({ x = 1200, y = 800 }))
    hl.dispatch(hl.dsp.window.center())
end)

local dirs = { h = "l", j = "d", k = "u", l = "r" }
for key, dir in pairs(dirs) do
    bind(mod .. " + " .. key,         hl.dsp.focus({ direction = dir }))
    bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = dir, group_aware = true }))
end
bind(mod .. " + CTRL + h",        hl.dsp.workspace.move({ monitor = "l" }))
bind(mod .. " + CTRL + l",        hl.dsp.workspace.move({ monitor = "r" }))

for i = 1, 10 do
    local key = i % 10
    bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = true }))
end
-- Physical key (US `, de ^), same reason as code:47.
bind(mod .. " + code:49",         hl.dsp.focus({ workspace = "previous" }))
bind(mod .. " + minus",           function() scratchpad.scratch() end)
bind(mod .. " + SHIFT + minus",   function() scratchpad.stash() end)

bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

bind("XF86AudioRaiseVolume", dms("audio increment 5"), { locked = true, repeating = true })
bind("XF86AudioLowerVolume", dms("audio decrement 5"), { locked = true, repeating = true })
bind("XF86AudioMute",        dms("audio mute"),        { locked = true })
bind("XF86AudioMicMute",     dms("audio micmute"),     { locked = true })
bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"),       { locked = true })
bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

bind(mod .. " + r", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    local step = 50
    for _, k in ipairs({ { "h", "left", -step, 0 }, { "j", "down", 0, step }, { "k", "up", 0, -step }, { "l", "right", step, 0 } }) do
        local d = hl.dsp.window.resize({ x = k[3], y = k[4], relative = true })
        hl.bind(k[1], d, { repeating = true })
        hl.bind(k[2], d, { repeating = true })
    end
    hl.bind("Escape", hl.dsp.submap("reset"))
    hl.bind("Return", hl.dsp.submap("reset"))
    hl.bind(mod .. " + r", hl.dsp.submap("reset"))
end)

local function leader(key, action)
    hl.bind(key, function()
        action()
        hl.dispatch(hl.dsp.submap("reset"))
    end)
end
bind(mod .. " + d", hl.dsp.submap("leader"))
hl.define_submap("leader", function()
    for key, name in pairs({ m = "spotify", n = "notes", v = "vol", s = "slack", b = "news" }) do
        leader(key, function() scratchpad.toggle(name) end)
    end
    leader("l", function() hl.dispatch(hl.dsp.exec_cmd("hyprctl switchxkblayout all next")) end)
    hl.bind("catchall", hl.dsp.submap("reset"))
end)
