local luarocks = require("rocks.luarocks")

return {
	setup = function(opts)
		package.path = package.path .. ";" .. luarocks.paths.share
		package.cpath = package.cpath .. ";" .. luarocks.paths.lib

		if opts.rocks then
			luarocks.ensure_rocks(opts.rocks)
		end
	end,
}
