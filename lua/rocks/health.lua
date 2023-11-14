local build = require("rocks.build")

return {
	check = function()
		vim.health.start("rocks")
		if build.is_prepared() then
			vim.health.ok("rocks system is prepared and ready to install luarocks")
		else
			vim.health.info("rocks system is not prepared")
			if vim.fn.executable("python3") then
				vim.health.ok("python3 is available on PATH, and rocks system is ready to be built")
			else
				vim.health.error("python3 is not available on PATH")
			end
		end
	end,
}
