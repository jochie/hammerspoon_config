--[[
	Just testing some basic Hammerspoon concepts
]]

if timer then return end

timer = {}

timer.log = hs.logger.new("timer", "debug")
timer.log.i('Initializing')

timer.counter = 0
timer.tick = true
timer.start_time = os.time()

function timer.tick()
    timer.counter = timer.counter + 1
    timer.log.df("T%sck .. #%d, going on %d seconds.", timer.tick and "i" or "o", timer.counter, os.time() - timer.start_time)
    timer.tick = not timer.tick
end

-- Reminder of time passing
timer.obj = hs.timer.doEvery(300, timer.tick)

timer.tick()

timer.log.i('Initialization finished.')
