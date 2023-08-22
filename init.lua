--[[

Hammerspoon entrance point

]]

-- React to wifi changes:
require "wifi"

-- -- Do things based on timing:
require "timer"

-- Automatically reload the hammerspoon config if any of the *.lua files
-- in the ~/.hammerspoon/ directory changed:
require "reload"

-- require "application"

-- require "adium"
require "slate"
require "iterm"
-- require "zoom"

-- Indicate we're done loading the configuration file.
hs.alert.show("Config (re)loaded")
