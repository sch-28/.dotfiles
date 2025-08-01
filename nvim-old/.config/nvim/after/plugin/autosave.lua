
-- Variable to keep track of autosave status
local autosave_enabled = true

-- Function to generate a random number between min and max
local function random_time(min, max)
    return math.random(min, max)
end

-- Function to save the buffer
local function save_buffer()
    vim.cmd("w")
end

-- Function to setup autosave
local function setup_autosave()
    if not autosave_enabled then return end

    local interval = random_time(10, 200)
    vim.defer_fn(function()
        save_buffer()
        setup_autosave()
    end, interval * 1000)
end

-- Command to toggle autosave on and off
vim.cmd[[command! ToggleAutoSave lua toggle_autosave()]]

-- Function to toggle autosave
function toggle_autosave()
    autosave_enabled = not autosave_enabled
    if autosave_enabled then
        setup_autosave()
        print("Autosave enabled")
    else
        print("Autosave disabled")
    end
end

