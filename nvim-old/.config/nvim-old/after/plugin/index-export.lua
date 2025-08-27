-- get all files of directory the buffer is in
-- add them all to the file in the format of 'export * from "./file-name"'

local function get_files_in_dir(dir)
    local files = {}
    for _, file in ipairs(vim.fn.readdir(dir)) do
        -- if vim.fn.isdirectory(dir .. "/" .. file) == 0 then
            table.insert(files, file)
        -- end
    end
    return files
end

local function get_files_in_buffer_dir()
    local dir = vim.fn.expand("%:p:h")
    return get_files_in_dir(dir)
end

local function get_export_line(file)
    return "export * from \"./" .. file .. "\";"
end

local function get_export_lines(files)
    local lines = {}
    for _, file in ipairs(files) do
        table.insert(lines, get_export_line(file))
    end
    return lines
end

local function write_export_lines(lines)
    local lines_to_write = table.concat(lines, "\n")
    vim.api.nvim_put({ lines_to_write }, "l", true, true)
end


function Index_Export()
    local files = get_files_in_buffer_dir()
    local export_lines = get_export_lines(files)
    write_export_lines(export_lines)
end

-- register function as command
vim.cmd("command! IndexExport lua Index_Export()")
