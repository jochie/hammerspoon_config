local adium_status = 0
local gotomeeting_status = 0
local joinme_status = 0

function switch_adium_status(old, new)
    -- https://trac.adium.im/ticket/10326
    local code = [[
        local total
        set total to 0
	tell application "Adium"
	    repeat with acct in accounts
		    if title of status of acct is equal to "]]..old..[[" then
			set status of acct to the status id (id of first status where title = "]]..new..[[")
                        set total to total + 1
		    end if
		end repeat
	    end tell
            return total
    ]]
    -- hs.alert.show("Code = "..code)
    local err, result = hs.applescript.applescript(code)
    return err, result
end

function update_adium_status()
    if adium_status == 0 then
        return
    end
    if gotomeeting_status > 0 or joinme_status > 0 then
        local err, result = switch_adium_status("Available", "Conference Call")
        if result > 0 then
            hs.alert.show("Switched Adium to Conference Call status for "..result.." accounts.")
        end
    else
        local err, result = switch_adium_status("Conference Call", "Available")
        if result > 0 then
            hs.alert.show("Switched Adium to Available status for "..result.." accounts.")
        end
    end
end

function adium_time_status()
    -- Avoid this code if Adium isn't running. The applescript snippets will
    -- actually cause it to be launched.
    if adium_status == 0 then
        return
    end
    local date = os.date("*t", os.time())
    if date.wday == 1 or date.wday == 7 then
        local err, result = switch_adium_status("Away", "Home. Enjoy your weekend!")
        if result > 0 then
            hs.alert.show("WEEKEND: Switched Adium to Weekend (from Away) status for "..result.." accounts.")
        end
    else
        if date.hour < 8 or date.hour > 17 then
	    local err, result = switch_adium_status("Away", "Gone for the day.")
	    if result > 0 then
		hs.alert.show("EVENING: Switched Adium to Evening (from Away) status for "..result.." accounts.")
	    end
        elseif date.hour >= 12 and date.hour <= 14 then
	    local err, result = switch_adium_status("Away", "AFK/Out for lunch")
	    if result > 0 then
		hs.alert.show("EVENING: Switched Adium to Lunch status for "..result.." accounts.")
	    end
        else
	    -- How to check if the screen is (un)locked? Use helper script for now:
            local result = hs.task.new(os.getenv("HOME").."/.hammerspoon/lock_test.py", function(exitCode, stdOut, stdErr)
                if exitCode == 1 then
		    local err, result = switch_adium_status("Gone for the day.", "Available")
		    if result > 0 then
			hs.alert.show("EVENING: Switched Adium to Available (from Evening) status for "..result.." accounts.")
		    end
		    local err, result = switch_adium_status("Home. Enjoy your weekend!", "Available")
		    if result > 0 then
			hs.alert.show("EVENING: Switched Adium to Available (from Weekend) status for "..result.." accounts.")
		    end
		end
            end, { path }):start()
	    if not result then
	        hs.alert.show("Error starting LOCK CHECK?")
	    end
        end
    end
end

-- Do this asynchronously, to avoid holding up the config (re)load:
hs.timer.doAfter(1, function()
    hs.application.watcher.new(function(name, event, app)
	local new_status = 0

	if     event == hs.application.watcher.terminated then
	    new_status = -1
	elseif event == hs.application.watcher.launched then
	    new_status = 1
	end
	if new_status == 0 then
	    return
	end
	if name == "Adium" then
	    adium_status = adium_status + new_status
	elseif string.find(name, "GoToMeeting") then
	    gotomeeting_status = gotomeeting_status + new_status
	elseif name == "join.me" then
	    joinme_status = joinme_status + new_status
	else
	    return
	end
	if new_status > 0 then
	    hs.alert.show(name.." is now running")
	elseif new_status < 0 then
	    hs.alert.show(name.." is no longer running")
	end
	update_adium_status()
    end):start()

    local app = hs.application.find("GoToMeeting")
    if app then
	hs.alert.show("GoToMeeting is running")
	gotomeeting_status = 1
    else
	hs.alert.show("GoToMeeting is not running")
	gotomeeting_status = 0
    end

    app = hs.application.get("join.me")
    if app then
	hs.alert.show("join.me is running")
	joinme_status = 1
    else
	hs.alert.show("join.me is not running")
	joinme_status = 0
    end

    local app = hs.application.get("Adium")
    if app then
	hs.alert.show("Adium is running")
	adium_status = 1
    else
	hs.alert.show("Adium is not running")
	adium_status = 0
    end

    update_adium_status()

    adium_time_status()
    hs.timer.doEvery(60, adium_time_status)
end)
