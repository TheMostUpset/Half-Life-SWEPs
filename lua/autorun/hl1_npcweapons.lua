local weapons = {
	["weapon_hl1_357"] = "HL1 .357 Magnum",
	["weapon_hl1_glock"] = "HL1 Glock",
	["weapon_hl1_hornetgun"] = "HL1 Hivehand",
	["weapon_hl1_mp5"] = "HL1 MP5",
	["weapon_hl1_shotgun"] = "HL1 Shotgun",
	["weapon_hl1_rpg"] = "HL1 RPG",
	["weapon_hl1_gauss"] = "HL1 Tau Cannon"
}

for wep, name in SortedPairs(weapons) do
	list.Add("NPCUsableWeapons", {class = wep, title = name})
end