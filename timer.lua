local log = hs.logger.new("timer", "debug")
log.i('Initializing')

local counter = 0
local tick = true
local start_time = os.time()

function timer_tick()
    counter = counter + 1
    log.df("T%sck .. #%d, going on %d seconds.", tick and "i" or "o", counter, os.time() - start_time)
    tick = not tick
end

-- Reminder of time passing
local timer_obj = hs.timer.doEvery(300, timer_tick)

timer_tick()

log.i('Initialization finished.')
