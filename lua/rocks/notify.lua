local plugin = "rocks"

local function info(messages, replace)
	local exists, notify = pcall(require, "notify")
	local message = type(messages) == "table" and table.concat(messages, "\n") or messages
	if exists then
		return notify.notify(message, vim.log.levels.INFO, { replace = replace, title = plugin, animate = false })
	else
		vim.notify(message, vim.log.levels.INFO)
	end
end

local function error(messages)
	local exists, notify = pcall(require, "notify")
	local message = type(messages) == "table" and table.concat(messages, "\n") or messages
	if exists then
		notify(message, vim.log.levels.ERROR, { title = plugin, animate = false })
	else
		vim.notify(message, vim.log.levels.INFO)
	end
end

return {
	info = info,
	error = error,
}
