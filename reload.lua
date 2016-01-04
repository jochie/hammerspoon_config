function reloadConfig(files)
    doReload = false
    for _, file in pairs(files) do
        if file:sub(-4) == ".lua" then
	    doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end

-- Set up path watcher:
hs.pathwatcher.new(os.getenv("HOME").."/.hammerspoon/", reloadConfig):start()
