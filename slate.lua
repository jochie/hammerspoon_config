-- My Slate replacement.
--
-- Keyboard shortcuts for moving windows is all I used it for anyway.

if slate then return end

slate = {}

-- Convenience function:

slate.refocus = function (rect)
	local w = hs.window.focusedWindow()
	if w then w:move(rect, nil, nil, 0.0) end
end

-- Take up the entire screen:

local slate_moves = {
	-- Go full screen:
	{ "control option command", "/",     "0.0 0.0 1.0 1.0" },

	-- Take up half the sreen:
	{ "control command",        "up",    "0.0 0.0 1.0 0.5" },
	{ "control command",        "right", "0.5 0.0 1.0 1.0" },
	{ "control command",        "down",  "0.0 0.5 1.0 1.0" },
	{ "control command",        "left",  "0.0 0.0 0.5 1.0" },

	-- Take up a quarter of the screen, around the screen clock wise:
	{ "control option command", "up",    "0.0 0.0 0.5 0.5" },
	{ "control option command", "right", "0.5 0.0 1.0 0.5" },
	{ "control option command", "down",  "0.5 0.5 1.0 1.0" },
	{ "control option command", "left",  "0.0 0.5 0.5 1.0" },
}

for i, d in ipairs(slate_moves) do
	slate["m_"..i] = hs.hotkey.bind(d[1], d[2], nil, function () slate.refocus(d[3]) end)
end
