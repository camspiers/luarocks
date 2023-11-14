local plugin = "rocks"

local function notify_info(message)
	local exists, notify = pcall(require, "notify")
	if exists then
		notify(message, vim.log.levels.INFO, { title = plugin, animate = false })
	else
		vim.notify(message, vim.log.levels.INFO)
	end
end

local function is_win()
	return vim.loop.os_uname().sysname == "Windows_NT"
end

local function is_darwin()
	return vim.loop.os_uname().sysname == "Darwin"
end

-- MACOSX_DEPLOYMENT_TARGET=10.6

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

local plugin_path = get_plugin_path()
local rocks_path = combine_paths(plugin_path, ".rocks")

local paths = {
	plugin = plugin_path,
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

local function ensure_python()
	notify_info("Checking python3 is installed")
	assert(vim.fn.executable("python3"), "[rocks] An external 'python3' command is required")
end

local function create_python_venv()
	notify_info("Creating python3 venv")
	local output = vim.system({ "python3", "-m", "venv", paths.rocks }):wait()
	assert(output.code == 0, "[rocks] Failed to create python3 venv\n" .. output.stderr)
end

local function install_hererocks()
	notify_info("Installing hererocks")
	local output = vim.system({ paths.pip, "install", "hererocks" }):wait()
	assert(output.code == 0, "[rocks] Failed to install hererocks\n" .. output.stderr)
end

local function build_lua()
	notify_info("Building LuaJIT")
	local opts = nil
	if is_darwin() then
		opts = {
			MACOSX_DEPLOYMENT_TARGET = "10.6",
		}
	end
	local output =
		vim.system({ paths.hererocks, "--builds", paths.build_cache, "-j2.1", "-rlatest", paths.rocks }, opts):wait()
	assert(output.code == 0, "[rocks] Failed to install lua\n" .. output.stderr)
end

local function build()
	notify_info("Starting build")
	ensure_python()
	create_python_venv()
	install_hererocks()
	build_lua()
	notify_info("Build complete")
end

local function install_rocks(rocks)
	local file, error = io.open(paths.rockspec, "w+")
	assert(file, "[rocks] Failed to write rockspec file " .. (error or ""))

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

local function ensure_rocks(rocks)
	local luarocks = io.open(paths.luarocks, "r")

	if luarocks then
		luarocks:close()
	else
		build()
	end

	local installed_output = vim.system({ paths.luarocks, "list", "--porcelain" }):wait()
	local installed_lines = vim.tbl_filter(function(line)
		return line ~= ""
	end, vim.split(installed_output.stdout, "\n"))
	local installed_rocks = vim.tbl_map(function(line)
		return vim.split(line, "\t")[1]
	end, installed_lines)

	local missing_rocks = {}
	for _, rock in ipairs(rocks) do
		if not vim.tbl_contains(installed_rocks, rock) then
			table.insert(missing_rocks, rock)
		end
	end

	if #missing_rocks ~= 0 then
		notify_info("Installing missing rocks: " .. table.concat(missing_rocks, ", "))
		install_rocks(rocks)
		notify_info("Rocks installed: " .. table.concat(missing_rocks, ", "))
	end
end

return {
	ensure_rocks = ensure_rocks,
	build = build,
	paths = paths,
}
