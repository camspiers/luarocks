package.page = "./lua/?.lua;" .. package.path

local build = require("rocks.build")

vim.schedule(function()
	if not build.is_prepared() then
		build.build()
	end
end)
