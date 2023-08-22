if iterm then return end

iterm = {}

-- XXX:
-- * Figure out a good way to not mess with the "Short Term Session Warning" modal dialog
-- * Apply the rules on a per-screen basis.

-- Automagically place the iTerm windows on a self-adjusting grid, as windows
-- are created and destroyed:

local wf = hs.window.filter

-- It seems the app now calls itself iTerm2, not iTerm?
iterm.filter = wf.new('iTerm2')

iterm.adjust_grid = function (filter)
	local list = filter:getWindows(wf.sortByCreated)
	local total = 0
	for i, w in ipairs(list) do
--		hs.alert.show("iTerm window "..tostring(w).." with desktop "..tostring(w.desktop()).."?", 5)
		total = i
	end
	if total < 1 then
		return
	end
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

iterm.filter:subscribe(wf.windowVisible, function (element, event)
	iterm.adjust_grid(iterm.filter)
end)

iterm.filter:subscribe(wf.windowNotVisible, function (element, event)
	iterm.adjust_grid(iterm.filter)
end)
