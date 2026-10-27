-- No borders: i3's dark 4px borders were invisible on black; over a wallpaper they read as frames.
hl.config({
    general = {
        gaps_in     = 0,
        gaps_out    = 0,
        border_size = 0,
        layout      = "dwindle",
        resize_on_border = true,
        extend_border_grab_area = 25,
        snap = { enabled = true, window_gap = 40, monitor_gap = 40 },
    },
    decoration = {
        rounding    = 0,
        dim_special = 0.3,
        shadow      = { enabled = false },
        blur        = { enabled = true, size = 6, passes = 1 },
    },
    cursor     = { hide_on_key_press = true },
    -- Fullscreen games skip compositing; 2 = auto, only for content type "game" (no video/desktop glitches).
    render     = { direct_scanout = 2 },
    dwindle    = { preserve_split = true },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        background_color        = "rgb(000000)",
    },
})

-- Short (speed is in 100 ms units). Layers off: Dux animates its own bar/popups/island.
hl.curve("snappy", { type = "bezier", points = { {0.23, 1}, {0.32, 1} } })
hl.animation({ leaf = "windowsIn",         enabled = true,  speed = 2,   bezier = "snappy", style = "popin 90%" })
hl.animation({ leaf = "windowsOut",        enabled = true,  speed = 1.5, bezier = "snappy", style = "popin 90%" })
hl.animation({ leaf = "windowsMove",       enabled = true,  speed = 2,   bezier = "snappy" })
hl.animation({ leaf = "fade",              enabled = true,  speed = 2,   bezier = "snappy" })
hl.animation({ leaf = "workspaces",        enabled = true,  speed = 2.5, bezier = "snappy", style = "slide" })
hl.animation({ leaf = "specialWorkspace",  enabled = true,  speed = 2,   bezier = "snappy", style = "slidevert" })
hl.animation({ leaf = "layers",            enabled = false })
