local ls =  require "luasnip"
ls.setup({
    enable_autosnippets = false,

})
require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/lua/snippets/" })
