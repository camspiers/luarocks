local plugin = "rocks"

local function info(message)
	local exists, notify = pcall(require, "notify")
	if exists then
		notify(message, vim.log.levels.INFO, { title = plugin, animate = false })
	else
		vim.notify(message, vim.log.levels.INFO)
	end
end

local function error(message, err)
	local exists, notify = pcall(require, "notify")
	if exists then
		notify({ message, err }, vim.log.levels.ERROR, { title = plugin, animate = false })
	else
		vim.notify(message, vim.log.levels.INFO)
	end
end

return {
	info = info,
	error = error,
}
