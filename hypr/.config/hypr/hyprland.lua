-- cardN swaps between boots; udev gives the dGPU a stable name (gpu/etc/udev). Only
-- where that rule is installed: a missing device here would stop Hyprland starting.
local dgpu = io.open("/dev/dri/rx9070", "r")
if dgpu then
    dgpu:close()
    hl.env("AQ_DRM_DEVICES", "/dev/dri/rx9070")
end

-- Dux-owned (dms setup / Dux Settings), not in git; ours load after so they win.
-- Missing ones (binds-user until Settings writes it) are fine; broken ones should show.
for _, m in ipairs({ "colors", "layout", "cursor", "binds", "binds-user", "windowrules" }) do
    local ok, err = pcall(require, "dms." .. m)
    if not ok and not tostring(err):find("not found", 1, true) then
        hl.notification.create({ text = "dms/" .. m .. ".lua: " .. tostring(err), timeout = 10000 })
    end
end

require("monitors")
require("input")
require("look")
require("rules")
require("binds")
require("autostart")
