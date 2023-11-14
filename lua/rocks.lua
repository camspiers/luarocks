local paths = require("rocks.paths")
local rocks = require("rocks.rocks")
local build = require("rocks.build")

return {
	setup = function(opts)
		package.path = package.path .. ";" .. paths.share
		package.cpath = package.cpath .. ";" .. paths.lib

		-- There are not rocks requests
		if not opts.rocks or #opts.rocks == 0 then
			return
		end

		-- Check that the system is ready to install rocks
		if build.is_prepared() then
			-- We have requested rocks so ensure they are installed
			rocks.ensure(opts.rocks)
		else
			-- We haven't built yet so register the rocks
			-- to be installed after build finishes
			build.ensure_rocks_after_build(opts.rocks)
		end
	end,
}
