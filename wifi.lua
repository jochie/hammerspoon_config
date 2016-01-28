if wifi then return end
wifi = {}

-- Keep track of what network we're on, and trigger actions:
wifi.previous_wifi_network = nil

wifi.watcher = hs.wifi.watcher.new(function()
    if hs.wifi.currentNetwork() then
        wifi.previous_wifi_network = hs.wifi.currentNetwork()
        hs.alert.show("Joined Wi-Fi network: "..wifi.previous_wifi_network)
    else
	hs.alert.show("Left Wi-Fi network: "..(wifi.previous_wifi_network or "N/A"))
	wifi.previous_wifi_network = nil
    end
end):start()
