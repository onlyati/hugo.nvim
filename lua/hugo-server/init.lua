---@class HugoOptions
---@field hugo_cmd? string
---@field args string[]
---@field auto_start boolean

local M = {}

---@type uv.uv_process_t|nil
local handle = nil

---@type uv.uv_pipe_t|nil
local stdout = nil

---@type uv.uv_pipe_t|nil
local stderr = nil

local uv = vim.uv

--- Setup function for the plugin
---@param opts HugoOptions|nil
function M.setup(opts)
	M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
	vim.api.nvim_create_user_command("HugoStart", M.start, {})
	vim.api.nvim_create_user_command("HugoStop", M.stop, {})

	vim.api.nvim_create_autocmd("VimLeavePre", {
		callback = function()
			if handle then
				handle:kill("sigterm")
			end
		end,
	})

	if M.opts.auto_start and M.is_it_hugo_project() then
		M.notify("Detected Hugo project", vim.log.levels.WARN)
		M.start()
	end
end

--- Check if current directoy is a Hugo project
---@return boolean
function M.is_it_hugo_project()
	return #vim.fs.find({ "hugo.toml", "hugo.yaml", "hugo.json", "hugo.yml" }, { upward = true, limit = 1 }) > 0
end

--- Wrapper around vim.notify
---@param msg string
---@param level integer|nil
function M.notify(msg, level)
	vim.notify(msg, level, {
		title = "Hugo server",
		timeout = 3000,
	})
end

--- Hugo default options
---@type HugoOptions
M.opts = {
	hugo_cmd = "hugo",
	args = { "server", "-D", "--noHTTPCache" },
	auto_start = false,
}

--- Start Hugo server
function M.start()
	if handle then
		M.notify("Hugo server is already running", vim.log.levels.WARN)
		return
	end

	stdout = uv.new_pipe(false)
	stderr = uv.new_pipe(false)
	local pid = nil

	---@diagnostic disable-next-line
	handle, pid = uv.spawn(M.opts.hugo_cmd, {
		args = M.opts.args,
		stdio = { nil, stdout, stderr },
	}, function(code, signal)
		vim.schedule(function()
			M.notify(string.format("Hugo exited (code: %d, signal: %d)", code, signal), vim.log.levels.INFO)
		end)
		handle = nil
	end)

	if not handle then
		M.notify("[hugo] failed to start", vim.log.levels.ERROR)
		return
	end

	M.notify("[hugo] started, pid: " .. pid, vim.log.levels.INFO)

	-- Read stdout
	if stdout ~= nil then
		stdout:read_start(function(err, data)
			assert(not err, err)
			if data and vim.trim(data) ~= "" then
				vim.schedule(function()
					M.notify("[hugo] " .. data, vim.log.levels.INFO)
				end)
			end
		end)
	end

	-- Read stderr
	if stderr ~= nil then
		stderr:read_start(function(err, data)
			assert(not err, err)
			if data and vim.trim(data) ~= "" then
				vim.schedule(function()
					M.notify("[hugo error] " .. data, vim.log.levels.ERROR)
				end)
			end
		end)
	end
end

--- Stop Hugo server
function M.stop()
	if not handle then
		M.notify("Hugo server is not running", vim.log.levels.WARN)
		return
	end

	handle:kill("sigterm")
	handle = nil
	M.notify("Hugo server stopped", vim.log.levels.INFO)
end

--- Return with the module
return M
