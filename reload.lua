--[[
	Watch for modified *.lua files in ~/.hammerspoon/ and automatically
	trigger a reload of Hammerspoon itself if one is detected.
]]

if reload then return end

reload = {}
reload.log = hs.logger.new("reload", "debug")

function reload.config(files)
	doReload = false
	for _, file in pairs(files) do
		local basename = string.gsub(file, "(.*/)(.*)", "%2")
		-- Ignore the ".../.#*" files
		if basename:sub(1, 2) ~= ".#" and basename:sub(-4) == ".lua" then
			doReload = true
			reload.log.df("Configuration reload triggered by '%s'", basename)
		else
			reload.log.df("Ignoring change for '%s'", basename)
		end
	end
	if doReload then
		hs.reload()
	end
end

-- Set up path watcher:
reload.watcher = hs.pathwatcher.new(os.getenv("HOME").."/.hammerspoon/", reload.config):start()
