local tick = true

-- Reminder of time passing
hs.timer.doEvery(300, function()
    hs.alert.show("T"..(tick and "i" or "o").."ck .. ")
    tick = not tick
end)
