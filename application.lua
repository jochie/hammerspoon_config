hs.application.watcher.new(function(name, event, app)
    name = name or "Unknown"
    event_name = "Unknown"
    if     event == hs.application.watcher.activated then
        event_name = "Activated"
    elseif event == hs.application.watcher.deactivated then
        event_name = "Deactivated"
    elseif event == hs.application.watcher.hidden then
        event_name = "Hidden"
    elseif event == hs.application.watcher.launched then
        event_name = "Launched"
    elseif event == hs.application.watcher.launching then
        event_name = "Launching"
    elseif event == hs.application.watcher.terminated then
        event_name = "Terminated"
    elseif event == hs.application.watcher.unhidden then
        event_name = "Unhidden"
    end
    hs.alert.show("App Watcher: "..name..": "..event_name..".")
end):start()
