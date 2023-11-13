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

package.path = combine_paths(get_plugin_path(), "lua", "?.lua") .. ";" .. package.path

local luarocks = require("rocks.luarocks")

luarocks.build()
