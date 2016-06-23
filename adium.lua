if adium then return end

adium = {}

adium.adium_status = 0
adium.gotomeeting_status = 0
adium.joinme_status = 0
adium.zoom_status = 0

-- Hang on to these so they're not garbage-collected after a while (usually hours):

adium.log = hs.logger.new("adium", 'debug')
adium.log.i('Initializing')

function adium.count_adium_not_status(str)
    local code = [[
        local total
        set total to 0
	tell application "Adium"
	    repeat with acct in accounts
	        set my_title to title of status of acct
		if my_title is not equal to "]]..str..[[" and my_title is not equal to "Offline" then
		    set total to total + 1
		end if
	    end repeat
	end tell
        return total
    ]]
    local err, result = hs.applescript.applescript(code)
    return err, result
end

function adium.switch_adium_status(old, new)
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
    local err, result = hs.applescript.applescript(code)
    return err, result
end

function adium.update_adium_status()
    if adium.adium_status == 0 then
        return
    end
    if adium.gotomeeting_status > 0 or adium.joinme_status > 0 or adium.zoom_status > 0 then
        local err, result = adium.switch_adium_status("Available", "Conference Call")
        if result > 0 then
            hs.alert.show("Switched Adium to Conference Call status for "..result.." accounts.")
        end
    else
        local err, result = adium.switch_adium_status("Conference Call", "Available")
        if result > 0 then
            hs.alert.show("Switched Adium to Available status for "..result.." accounts.")
        end
    end
end

function adium.adium_time_status()
    -- Avoid this code if Adium isn't running. The applescript snippets will
    -- actually cause it to be launched.
    if adium.adium_status == 0 then
        return
    end
    local date = os.date("*t", os.time())
    if date.wday == 1 or date.wday == 7 then
        local err, result = adium.count_adium_not_status("Home. Enjoy your weekend!")
        if result > 0 then
            adium.log.df('adium_time_status - date.wday = %d, date.hour = %d', date.wday, date.hour)
	    adium.log.df('adium_time_status: Intend to switch adium from "Away" to "Home. Enjoy your weekend!".')
	    local err, result = adium.switch_adium_status("Away", "Home. Enjoy your weekend!")
	    if result > 0 then
		hs.alert.show("WEEKEND: Switched Adium to Weekend (from Away) status for "..result.." accounts.")
                adium.log.df('adium_time_status: Succeeded for %d accounts.', result)
            else
                adium.log.d('adium_time_status: Succeeded for zero accounts.')
	    end
        end
    else
        if date.hour < 8 or date.hour >= 17 then
            local err, result = adium.count_adium_not_status("Gone for the day.")
            if result > 0 then
                adium.log.df('adium_time_status - date.wday = %d, date.hour = %d', date.wday, date.hour)
		adium.log.df('adium_time_status: Intend to switch adium from "Away" to "Gone for the day".')
		local err, result = adium.switch_adium_status("Away", "Gone for the day.")
		if result > 0 then
		    hs.alert.show("EVENING: Switched Adium to Evening (from Away) status for "..result.." accounts.")
		    adium.log.df('adium_time_status: Succeeded for %d accounts.', result)
		else
		    adium.log.d('adium_time_status: Succeeded for zero accounts.')
		end
            end
        elseif date.hour >= 12 and date.hour < 14 then
            local err, result = adium.count_adium_not_status("AFK/Out for lunch")
            if result > 0 then
                adium.log.df('adium_time_status - date.wday = %d, date.hour = %d', date.wday, date.hour)
		adium.log.df('adium_time_status: Intend to switch adium from "Away" to "AFK/Out for lunch".')
		local err, result = adium.switch_adium_status("Away", "AFK/Out for lunch")
		if result > 0 then
		    hs.alert.show("EVENING: Switched Adium to Lunch status for "..result.." accounts.")
		    adium.log.df('adium_time_status: Succeeded for %d accounts.', result)
		else
		    adium.log.d('adium_time_status: Succeeded for zero accounts.')
		end
            end
        else
	    -- It should now be a weekday and the time is [ 8:00, 12:00 >, or [ 14:00, 17:00 >
            local err, result = adium.count_adium_not_status("Available")
            if result > 0 then
		-- How to check if the screen is (un)locked? Use helper script for now:
		local result = hs.task.new(os.getenv("HOME").."/.hammerspoon/lock_test.py", function(exitCode, stdOut, stdErr)
                    adium.log.df('adium_time_status - date.wday = %d, date.hour = %d', date.wday, date.hour)
		    adium.log.df('adium_time_status - lock_test.py result: %d', exitCode)
		    if exitCode == 1 then
			local err, result = adium.switch_adium_status("Gone for the day.", "Available")
			if result > 0 then
			    hs.alert.show("EVENING: Switched Adium to Available (from Evening) status for "..result.." accounts.")
			    adium.log.df('adium_time_status: Succeeded for %d accounts.', result)
			else
			    -- adium.log.d('adium_time_status: Succeeded for zero accounts.')
			end
			local err, result = adium.switch_adium_status("Home. Enjoy your weekend!", "Available")
			if result > 0 then
			    hs.alert.show("EVENING: Switched Adium to Available (from Weekend) status for "..result.." accounts.")
			    adium.log.df('adium_time_status: Succeeded for %d accounts.', result)
			else
			    adium.log.d('adium_time_status: Succeeded for zero accounts.')
			end
			local err, result = adium.switch_adium_status("AFK/Out for lunch", "Available")
			if result > 0 then
			    hs.alert.show("EVENING: Switched Adium to Available (from Lunch) status for "..result.." accounts.")
			    adium.log.df('adium_time_status: Succeeded for %d accounts.', result)
			else
			    adium.log.d('adium_time_status: Succeeded for zero accounts.')
			end
                    end
		end):start()
		if not result then
		    hs.alert.show("Error starting LOCK CHECK?")
		end
            end
        end
    end
end

function adium.log_update(var, orig, diff)
    adium.log.df("adium: App %s changed from %d to %d", var, orig, orig + diff)
    return orig + diff
end

-- Do this asynchronously, to avoid holding up the config (re)load:
adium.startup = hs.timer.doAfter(1, function()
    adium.watcher = hs.application.watcher.new(function(name, event, app)
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
            adium.adium_status = adium.log_update("adium", adium.adium_status, new_status)
	    if adium.adium_status < 0 then
	        adium.log.wf("adium_status somehow managed to be %d. Corrected.", adium_status)
		adium.adium_status = 0
	    end
	elseif string.find(name, "GoToMeeting") then
	    adium.gotomeeting_status = adium.log_update("gotomeeting", adium.gotomeeting_status, new_status)
	    if adium.gotomeeting_status < 0 then
	        adium.log.wf("gotomeeting_status somehow managed to be %d. Corrected.", adium.gotomeeting_status)
		adium.gotomeeting_status = 0
	    end
	elseif name == "join.me" then
	    adium.joinme_status = adium.log_update("join.me", adium.joinme_status, new_status)
	    if adium.joinme_status < 0 then
	        adium.log.wf("joinme_status somehow managed to be %d. Corrected.", adium.joinme_status)
		adium.joinme_status = 0
	    end
	elseif name == "zoom.us" then
	    adium.zoom_status = adium.log_update("zoom.us", adium.zoom_status, new_status)
	    if adium.zoom_status < 0 then
	        adium.log.wf("zoom_status somehow managed to be %d. Corrected.", adium.zoom_status)
		adium.zoom_status = 0
	    end
	else
	    return
	end
	if new_status > 0 then
	    hs.alert.show(name.." is now running")
	elseif new_status < 0 then
	    hs.alert.show(name.." is no longer running")
	end
	adium.update_adium_status()
    end):start()

    -- Check status of GoToMeeting:
    local app = hs.application.find("GoToMeeting")
    if app then
	hs.alert.show("GoToMeeting is running")
	adium.gotomeeting_status = adium.log_update("gotomeeting", adium.gotomeeting_status, 1)
    else
	hs.alert.show("GoToMeeting is not running")
    end

    -- Check status of Join.me:
    app = hs.application.get("join.me")
    if app then
	hs.alert.show("join.me is running")
	adium.joinme_status = adium.log_update("join.me", adium.joinme_status, 1)
    else
	hs.alert.show("join.me is not running")
    end

    -- Check status of Adium:
    local app = hs.application.get("Adium")
    if app then
	hs.alert.show("Adium is running")
	adium.adium_status = adium.log_update("adium", adium.adium_status, 1)
    else
	hs.alert.show("Adium is not running")
    end

    -- Check status of Zoom:
    local app = hs.application.get("zoom.us")
    if app then
	hs.alert.show("Zoom is running")
	adium.zoom_status = adium.log_update("zoom", adium.zoom_status, 1)
    else
	hs.alert.show("Zoom is not running")
    end

    adium.update_adium_status()

    adium.adium_time_status()
    adium.timer = hs.timer.doEvery(60, adium.adium_time_status)
end)

adium.log.i('Initialization finished.')
