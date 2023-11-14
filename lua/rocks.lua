local paths = require("rocks.paths")
local rocks = require("rocks.rocks")
local build = require("rocks.build")

return {
	setup = function(opts)
		package.path = package.path .. ";" .. paths.share
		package.cpath = package.cpath .. ";" .. paths.lib

		-- NOTE: This is highly synchronous, but async build steps
		-- don't seem to play well with lazy.nvim, and nor does
		-- build.lua (for lazy.nvim) seem to wait until it's complete
		-- before running setup()

		-- Check that the system is ready to install rocks
		if not build.is_prepared() then
			build.build()
		end

		-- We have requested rocks so ensure they are installed
		if opts.rocks and #opts.rocks > 0 then
			rocks.ensure(opts.rocks)
		end
	end,
}
