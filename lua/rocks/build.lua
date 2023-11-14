local paths = require("rocks.paths")
local notify = require("rocks.notify")

local function is_darwin()
	return vim.loop.os_uname().sysname == "Darwin"
end

local function is_prepared()
	local file = io.open(paths.luarocks, "r")
	if file then
		file:close()
		return true
	end
	return false
end

local steps = {
	{
		description = "Checking python3 exists",
		task = function()
			assert(vim.fn.executable("python3"), "An external 'python3' command is required")
		end,
	},
	{
		description = "Creating python3 virtual environment",
		task = function()
			local output = vim.system({ "python3", "-m", "venv", paths.rocks }):wait()
			assert(output.code == 0, "Failed to create python3 venv\n" .. output.stderr)
		end,
	},
	{
		description = "Installing hererocks",
		task = function()
			local output = vim.system({ paths.pip, "install", "hererocks" }):wait()
			assert(output.code == 0, "Failed to install hererocks\n" .. output.stderr)
		end,
	},
	{
		description = "Installing LuaJIT",
		task = function()
			local opts = nil
			if is_darwin() then
				opts = {
					env = {
						MACOSX_DEPLOYMENT_TARGET = "10.6",
					},
				}
			end
			local output =
				vim.system({ paths.hererocks, "--builds", paths.build_cache, "-j2.1", "-rlatest", paths.rocks }, opts)
					:wait()
			assert(output.code == 0, "Failed to install LuaJIT\n" .. output.stderr)
		end,
	},
}

local function build()
	notify.info("Build started")
	for _, step in ipairs(steps) do
		notify.info(step.description)
		local ok, error = pcall(step.task)
		if not ok then
			notify.error("Build failed", error)
			return
		end
	end
	notify.info("Build completed")
end

return {
	build = build,
	is_prepared = is_prepared,
}
