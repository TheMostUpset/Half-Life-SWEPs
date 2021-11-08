include('shared.lua')

net.Receive("HL1_HUDPickupMessage", function()
	local class = net.ReadString()
	-- class = string.gsub(class, "hl1_", "")
	hook.Call("HUDItemPickedUp", GAMEMODE, class)
end)