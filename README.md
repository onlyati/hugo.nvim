# Hugo Neovim plugin

This plugin integrate [hugo](https://gohugo.io) command into Neovim. If a
`hugo.[toml|json|yaml|yml]` is present in the root and `auto_start` is set to
`true`, then hugo server automatically started.

By this plugin, commands can be used to work with hugo:

- `:HugoStart`: Start server
- `:HugoStop`: Stop server

Plugin has been made due to learning purposes.

## Configuration

If you use LazyVim then create `~/.config/nvim/lua/plugins/hugo-server.lua` file
then edit is based on your preferences. This is a starter configuration.

```lua
return {
    "onlyati/hugo.nvim",
    name = "hugo-server",
    init = function()
        local cwd = vim.fn.getcwd()
        for _, filename in ipairs({
            "hugo.toml",
            "hugo.json",
            "hugo.yaml",
            "hugo.yml",
        }) do
            if vim.fn.filereadable(cwd .. "/" .. filename) == 1 then
                require("lazy").load({ plugins = { "hugo-server" } })
                return
            end
        end
    end,
    config = function()
        require("hugo-server").setup({
            hugo_cmd = "hugo",
            args = {
                "server",
                "--disableFastRender",
                "-D",
                "--bind",
                "127.0.0.1"
            },
            auto_start = true,
        })
    end,
    cmd = { "HugoStart", "HugoStop" },
    keys = {
        { "<leader>hs", "<cmd>HugoStart<cr>", desc = "Hugo Start" },
        { "<leader>hp", "<cmd>HugoStop<cr>", desc = "Hugo Stop" },
        { "<leader>h", desc = "+hugo" },
    },
}
```
