--[[

From the hello world section: http://www.hammerspoon.org/go/#helloworld

]]

-- React to wifi changes:
require "wifi"

-- -- Do things based on timing:
-- require "timer"

-- Automatically reload the hammerspoon config if any of the *.lua files
-- in the ~/.hammerspoon/ directory changed:
require "reload"

-- require "application"

require "adium"

-- Indicate we're done loading the configuration file.
hs.alert.show("Config (re)loaded")
