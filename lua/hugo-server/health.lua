local M = {}
M.check = function()
    local plugin_ok, plugin = pcall(require, "hugo-server")
    if not plugin_ok then
        vim.health.error("Failed to load hugo-server plugin")
        return
    end

    vim.health.start("Looking for binary '" .. plugin.opts.hugo_cmd .. "'")
    -- make sure setup function parameters are ok
    if vim.fn.executable(plugin.opts.hugo_cmd) == 1 then
        vim.health.ok("Binary has been found")
    else
        vim.health.error("Binary is missing")
    end
    -- do some more checking
    -- ...
end
return M
