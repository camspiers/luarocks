local plugin = "rocks"

local function notify_info(message)
	local ok, notify = pcall(require, "nvim-notify")
	if ok then
		notify(message, vim.log.levels.INFO, { title = plugin, animate = false })
	end
end

local function is_win()
	return vim.loop.os_uname().sysname == "Windows_NT"
end

local function get_path_separator()
	if is_win() then
		return "\\"
	end
	return "/"
end

local function combine_paths(...)
	return table.concat({ ... }, get_path_separator())
end

local function get_plugin_path()
	local str = debug.getinfo(2, "S").source:sub(2)
	if is_win() then
		str = str:gsub("/", "\\")
	end
	return vim.fn.fnamemodify(str:match("(.*" .. get_path_separator() .. ")"), ":h:h:h")
end

local rocks_path = combine_paths(get_plugin_path(), ".rocks")

local paths = {
	rocks = rocks_path,
	bin = combine_paths(rocks_path, "bin"),
	luarocks = combine_paths(rocks_path, "bin", "luarocks"),
	pip = combine_paths(rocks_path, "bin", "pip3"),
	hererocks = combine_paths(rocks_path, "bin", "hererocks"),
	build_cache = combine_paths(rocks_path, "builds"),
	share = combine_paths(rocks_path, "share", "lua", "5.1", "?.lua"),
	lib = combine_paths(rocks_path, "lib", "lua", "5.1", "?.so"),
	rockspec = combine_paths(rocks_path, "neovim-rocks-user-rockspec-0.0-0.rockspec"),
}

local function ensure_rocks(rocks)
	local file = io.open(paths.rockspec, "w")

	assert(file, "[rocks] Failed to write rockspec file")

	file:write(string.format(
		[[
package = "neovim-rocks-user-rockspec"
version = "0.0-0"
source = { url = "some-fake-url" }
dependencies = %s
build = {
  type = "builtin"
}
]],
		vim.inspect(rocks)
	))

	file:close()

	local output = vim.system({ paths.luarocks, "install", "--deps-only", paths.rockspec }):wait()

	assert(output.code == 0, "[rocks] Failed to install from rockspec\n" .. output.stderr)
end

local function ensure_python()
	notify_info("Ensuring python3 is installed")
	assert(vim.fn.executable("python3"), "[rocks] An external 'python3' command is required")
end

local function create_python_venv(on_done)
	notify_info("Creating python3 venv")
	vim.system({ "python3", "-m", "venv", paths.rocks }, nil, function(output)
		assert(output.code == 0, "[rocks] Failed to create python3 venv\n" .. output.stderr)
		on_done()
	end)
end

local function install_hererocks(on_done)
	notify_info("Installing hererocks")
	vim.system({ paths.pip, "install", "hererocks" }, nil, function(output)
		assert(output.code == 0, "[rocks] Failed to install hererocks\n" .. output.stderr)
		on_done()
	end)
end

local function build_lua(on_done)
	notify_info("Building LuaJIT")
	vim.system(
		{ paths.hererocks, "--builds", paths.build_cache, "-j2.1", "-rlatest", paths.rocks },
		nil,
		function(output)
			assert(output.code == 0, "[rocks] Failed to install lua\n" .. output.stderr)
			on_done()
		end
	)
end

local function build()
	ensure_python()
	create_python_venv(function()
		install_hererocks(function()
			build_lua(function()
				-- finished
			end)
		end)
	end)
end

return {
	ensure_rocks = ensure_rocks,
	build = build,
	paths = paths,
}
