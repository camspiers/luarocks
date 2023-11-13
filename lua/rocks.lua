local luarocks = require("rocks.luarocks")

return {
	setup = function(opts)
		pcall(function()
			package.path = package.path .. ";" .. luarocks.paths.share
			package.cpath = package.cpath .. ";" .. luarocks.paths.lib
		end)
		if opts.rocks then
			luarocks.ensure_rocks(opts.rocks)
		end
	end,
}
