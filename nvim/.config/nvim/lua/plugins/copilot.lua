vim.g.copilot_enabled = false
vim.g.copilot_no_tab_map = true

local isSuggesting = false

local function copilot_suggest()
    if isSuggesting == true then
        isSuggesting = false
        return vim.fn["copilot#Accept"]()
    else
        isSuggesting = true
        return vim.fn["copilot#Suggest"]()
    end
end





return {
    copilot_suggest = copilot_suggest
}

