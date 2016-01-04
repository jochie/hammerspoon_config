-- Keep track of what network we're on, and trigger actions:
local previous_wifi_network

hs.wifi.watcher.new(function()
    if hs.wifi.currentNetwork() then
        previous_wifi_network = hs.wifi.currentNetwork()
        hs.alert.show("Joined Wi-Fi network: "..previous_wifi_network)
    else
	hs.alert.show("Left Wi-Fi network: "..(previous_wifi_network or "N/A"))
	previous_wifi_network = nil
    end
end):start()
