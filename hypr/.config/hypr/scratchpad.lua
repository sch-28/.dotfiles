-- i3-style scratchpads. special:<name> is only the hidden store; showing fetches the
-- window onto the current workspace as a normal floating window. (Shown as a special
-- workspace it would overlay and dim everything, and nothing else is usable meanwhile.)
local apps = require("rules")
local M = {}

-- Apps started from here, waiting for their window: name -> "show" | "hide".
-- Expires so a start that never produced a window can't grab one opened by hand later.
local pending = {}
local PENDING_MS = 10000

local function matches(w, app)
    return (w.class or ""):match(app.class) and not (app.skip_title and (w.title or ""):match(app.skip_title))
end

-- get_windows() lists mapped windows only, so Slack closed to its tray counts as not
-- running; its command brings the window back. Prefer a copy already in the store or here.
local function find(name)
    local app, store, ws = apps[name], "special:" .. name, hl.get_active_workspace()
    local first
    for _, w in ipairs(hl.get_windows()) do
        if matches(w, app) then
            local wsn = w.workspace and w.workspace.name
            if wsn == store or (ws and w.workspace and w.workspace.id == ws.id) then return w end
            first = first or w
        end
    end
    return first
end

local function here(w)
    local ws = hl.get_active_workspace()
    return w.workspace and ws and w.workspace.id == ws.id
end

local function tagged(w)
    for _, t in ipairs(type(w.tags) == "table" and w.tags or {}) do
        if t == "scratch" then return true end
    end
    return false
end

local function hide(w, store)
    hl.dispatch(hl.dsp.window.move({ workspace = "special:" .. store, follow = false, window = w }))
end

-- Float + size on every show: apps (Slack restoring "maximized") and the trip through
-- the store don't reliably keep what the open-time rule set. An open overlay (Spotify)
-- would cover the fetched window, so it closes first.
local function show(w, size)
    local ws = hl.get_active_workspace()
    if not ws then return end
    local special = hl.get_active_special_workspace()
    if special then hl.dispatch(hl.dsp.workspace.toggle_special((special.name:gsub("^special:", "")))) end
    hl.dispatch(hl.dsp.window.move({ workspace = ws.id, follow = false, window = w }))
    hl.dispatch(hl.dsp.window.float({ action = "enable", window = w }))
    if size then hl.dispatch(hl.dsp.window.resize({ x = size[1], y = size[2], window = w })) end
    hl.dispatch(hl.dsp.window.center({ window = w }))
    hl.dispatch(hl.dsp.focus({ window = w }))
end

local function start(name, mode)
    if pending[name] then return end
    pending[name] = mode
    hl.dispatch(hl.dsp.exec_cmd(apps[name].cmd))
    hl.timer(function() pending[name] = nil end, { timeout = PENDING_MS, type = "oneshot" })
end

-- mode "hide" starts the app straight into its store.
function M.toggle(name, mode)
    local app = apps[name]
    local w = find(name)
    if app.overlay then
        if not w then
            if mode == "hide" then start(name, "hide") else hl.dispatch(hl.dsp.workspace.toggle_special(name)) end
            return
        end
        if w.workspace and w.workspace.name ~= "special:" .. name then hide(w, name) end
        if mode ~= "hide" then hl.dispatch(hl.dsp.workspace.toggle_special(name)) end
        return
    end
    if not w then
        start(name, mode or "show")
    elseif here(w) then
        hide(w, name)
    else
        show(w, app.size)
    end
end

function M.running(name)
    return find(name) ~= nil
end

-- Super+minus: put a fetched scratch window back, else fetch the next stored one.
function M.scratch()
    local w = hl.get_active_window()
    if w and tagged(w) and here(w) then
        hide(w, "scratch")
        return
    end
    for _, s in ipairs(hl.get_windows()) do
        if s.workspace and s.workspace.name == "special:scratch" then
            show(s)
            return
        end
    end
end

-- Super+Shift+minus: stash the focused window, or release a fetched one for good.
function M.stash()
    local w = hl.get_active_window()
    if not w then return end
    if tagged(w) then
        hl.dispatch(hl.dsp.window.tag({ tag = "-scratch", window = w }))
        hl.dispatch(hl.dsp.window.float({ action = "disable", window = w }))
    else
        hl.dispatch(hl.dsp.window.tag({ tag = "+scratch", window = w }))
        hide(w, "scratch")
    end
end

local function adopt(w)
    if not w then return end
    for name, mode in pairs(pending) do
        if matches(w, apps[name]) then
            pending[name] = nil
            if mode == "hide" then hide(w, name) else show(w, apps[name].size) end
            return
        end
    end
end
hl.on("window.open", adopt)

return M
