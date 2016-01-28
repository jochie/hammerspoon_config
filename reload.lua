if reload then return end

reload = {}

function reload.config(files)
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
reload.watcher = hs.pathwatcher.new(os.getenv("HOME").."/.hammerspoon/", reload.config):start()
