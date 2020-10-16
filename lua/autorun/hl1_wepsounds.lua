local snds = {
	["Weapon_Glock.Special1"] = "items/9mmclip1.wav",
	["Weapon_Glock.Special2"] = "items/9mmclip2.wav",
	["Weapon_MP5.Special1"] = "items/cliprelease1.wav",
	["Weapon_MP5.Special2"] = "items/clipinsert1.wav",
}

for k,v in pairs(snds) do
	sound.Add({
		name = k,
		channel = CHAN_ITEM,
		volume = 1.0,
		level = 75,
		pitch = 100,
		sound = v
	})
	util.PrecacheSound(v)
end