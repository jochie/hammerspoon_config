--[[
	Automagically place the iTerm windows on a self-adjusting grid, as
	windows are created, hidden, unhidden, or closed.

	Still looking for a definitive way to sanely exclude any and all non-
	terminal iTerm windows, though isStandard() seems to get close.
]]

if iterm then return end

iterm = {}

iterm.log = hs.logger.new("iterm", "debug")

local wf = hs.window.filter

iterm.filter = wf.new('iTerm2')

iterm.analyze_windows = function (list, element)
	local per_screen = {}
	local seen = {}

	if element then
		table.insert(list, element)
	end

	for i, w in ipairs(list) do
		if not seen[w] then
			seen[w] = true
			if w:isVisible() and w:isStandard() then
				local sid = w:screen():id()
				iterm.log.df("iTerm window %d: %s on screen %s", i, w:title(), sid)
				local slist = {}
				if not per_screen[sid] then
					per_screen[sid] = {}
				end
				slist = per_screen[sid]
				table.insert(slist, w)
			end
		end
	end
	return per_screen
end

iterm.adjust_grid = function (element, filter)
	if element and element:title() == "Preferences" then
		iterm.preference_window = element
		return
	end
	if element and element == iterm.preference_window then
		return
	end
	local per_screen = { }

	local seen = {}
	local list = filter:getWindows(wf.sortByCreated)
	per_screen = iterm.analyze_windows(list, element)

	-- Loop over the screens that have iTerm windows on them:
	for sid, list in pairs(per_screen) do
		total = #list
		-- hs.alert.show(total.." iTerm windows on "..sid)
		if total >= 1 then
			local r = 1
			local c = 1
			while r * c < total do
				r = r + 1
				c = c + 1
			end
			if total <= (r - 1) * c then
				r = r - 1
			end
			-- hs.alert.show("Fit "..total.." window(s) into a "..r.."x"..c.." grid?")
			local cur_r, cur_c
			cur_r = 0
			cur_c = 0
			for i, w in ipairs(list) do
				local rect = hs.geometry.new(cur_c / c, cur_r / r, 1 / c, 1 / r)
				w:move(rect, nil, nil, 0)
				cur_c = cur_c + 1
				if cur_c == c then
					cur_c = 0
					cur_r = cur_r + 1
				end
			end
		end
	end
end

iterm.filter:subscribe(wf.windowVisible, function (element, event)
	iterm.adjust_grid(element, iterm.filter)
end)

iterm.filter:subscribe(wf.windowNotVisible, function (element, event)
	iterm.adjust_grid(element, iterm.filter)
end)

-- Manually trigger the grid adjustment, no automatic adjustments:
hs.hotkey.bind("control option command", "T", nil, function ()
	iterm.adjust_grid(nil, iterm.filter)
end)
