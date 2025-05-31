# Hugo Neovim plugin

This plugin integrate [hugo](https://gohugo.io) command into Neovim. By this
plugin, commands can be used to work with hugo:

- `:HugoStart`: Start server
- `:HugoStop`: Stop server

## Configuration

If you use LazyVim then create `~/.config/nvim/lua/plugins/hugo-server.lua` file
then edit is based on your preferences. This is a started configuration.

```lua
return {
    "onlyati/hugo.nvim",
    name = "onlyati/hugo.nvim",
    config = function()
        require("hugo-server").setup({
            hugo_cmd = "hugo",
            args = { "server", "-D", "--noHTTPCache" },
        })
    end,
    keys = {
        { "<leader>hs", "<cmd>HugoStart<cr>", desc = "Hugo Start" },
        { "<leader>hp", "<cmd>HugoStop<cr>", desc = "Hugo Stop" },
        { "<leader>h", desc = "+hugo" },
    },
}
```
