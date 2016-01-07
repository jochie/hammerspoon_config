local log = hs.logger.new("timer", "debug")
log.i('Initializing')

local tick = true

-- Reminder of time passing
hs.timer.doEvery(300, function()
    log.i("T"..(tick and "i" or "o").."ck .. ")
    tick = not tick
end)

log.i('Initialization finished.')
