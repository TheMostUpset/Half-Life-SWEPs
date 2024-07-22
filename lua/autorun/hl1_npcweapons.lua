local weapons = {
	["weapon_hl1_357"] = ".357 Magnum",
	["weapon_hl1_crossbow"] = "Crossbow",
	["weapon_hl1_glock"] = "Glock",
	["weapon_hl1_hornetgun"] = "Hivehand",
	["weapon_hl1_mp5"] = "MP5",
	["weapon_hl1_shotgun"] = "Shotgun",
	["weapon_hl1_rpg"] = "RPG",
	["weapon_hl1_gauss"] = "Tau Cannon"
}

for wep, name in SortedPairs(weapons) do
	list.Add("NPCUsableWeapons", {class = wep, title = "HL1 "..name})
end