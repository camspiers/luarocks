local paths = require("rocks.paths")
local rocks = require("rocks.rocks")

return {
	setup = function(opts)
		package.path = package.path .. ";" .. paths.share
		package.cpath = package.cpath .. ";" .. paths.lib
		if opts.rocks then
			rocks.ensure(opts.rocks)
		end
	end,
}
