if zoom then return end

zoom = {}

if true then return end

-- XXX:
-- * Automatically move the Zoom windows to the right-most display, if they aren't there yet.
-- * 

-- Concept: Automatically resize the Zoom windows if there are exactly two.

local wf = hs.window.filter
zoom.filter = wf.new('zoom.us', 'zoomusLauncher')

zoom.adjust_grid = function (filter, element)
	local list = filter:getWindows(wf.sortByCreated)
	local participant_window
	local shared_window
	for i, w in ipairs(list) do
		hs.alert.show("Zoom window "..i.." = "..tostring(w), 60)
	end

	-- Do we have a multi-display situation? If so, we want the two
	-- relevant windows on the right-most display.

	local screens = hs.screen.screenPositions()
	local total = 0
	local rightMostScreen = nil
	local rightMostOffset = nil
	for s, t in pairs(screens) do
		if not rightMostScreen or t.x > rightMostOffset then
			rightMostScreen = s
			rightMostOffset = t.x
		end
		total = total + 1
	end
	-- hs.alert.show("We have "..total.." screens? Right most at "..rightMostOffset.." is "..tostring(rightMostScreen), 10)

	if total > 1 then
		-- Move all Zoom windows to the most-right screen
	end

--	if not participant_window or not shared_window then
--		return
--	end

	if element then
		-- See if we can figure out if this is a case of the user
		-- resizing/moving the window or the app erratically moving
		-- the shared window to another display.
	end
end

zoom.filter:subscribe(wf.windowVisible, function (element, event)
	hs.alert.show("windowVisible trigger for "..tostring(element), 10)
	zoom.adjust_grid(zoom.filter)
end)

zoom.filter:subscribe(wf.windowNotVisible, function (element, event)
	hs.alert.show("windowNotVisible trigger for "..tostring(element), 10)
	zoom.adjust_grid(zoom.filter)
end)

zoom.filter:subscribe(wf.windowMoved, function (element, event)
	hs.alert.show("windowMoved trigger for "..tostring(element), 10)
	zoom.adjust_grid(zoom.filter, element)
end)
