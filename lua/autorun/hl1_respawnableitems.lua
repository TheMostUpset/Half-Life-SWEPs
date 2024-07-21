local pickups = {
	["hl1_ammo_357"] = ".357 Ammo Box",
	["hl1_ammo_9mmbox"] = "9mm Ammo Box",
	["hl1_ammo_9mmclip"] = "9mm Clip",
	["hl1_ammo_argrenades"] = "AR Grenades",
	["hl1_ammo_buckshot"] = "Buckshot",
	["hl1_ammo_crossbow"] = "Crossbow Bolts",
	["hl1_ammo_9mmar"] = "AR Clip",
	["hl1_ammo_rpgclip"] = "Rockets",
	["hl1_ammo_gaussclip"] = "Uranium",
	["hl1_item_healthkit"] = "Medkit",
	["hl1_item_battery"] = "Suit Battery"
}
local weapons = {
	["weapon_hl1_crowbar"] = "Crowbar",
	["weapon_hl1_glock"] = "Glock",
	["weapon_hl1_357"] = ".357 Magnum",
	["weapon_hl1_mp5"] = "MP5",
	["weapon_hl1_shotgun"] = "Shotgun",
	["weapon_hl1_crossbow"] = "Crossbow",
	["weapon_hl1_rpg"] = "RPG",
	["weapon_hl1_gauss"] = "Tau Cannon",
	["weapon_hl1_egon"] = "Gluon Gun",
	["weapon_hl1_hornetgun"] = "Hivehand",
	["weapon_hl1_handgrenade"] = "Hand Grenade",
	["weapon_hl1_satchel"] = "Satchel",
	["weapon_hl1_tripmine"] = "Tripmine",
	["weapon_hl1_snark"] = "Snarks"
}

for class, name in pairs(pickups) do
	list.Set("SpawnableEntities", class.."_respawnable", {
		PrintName = name.." (Respawnable)",
		ClassName = class,
		Category = "Half-Life Respawnable Items",
		IconOverride = "entities/"..class..".png",
		KeyValues = { respawnable = "1" }
	})
end

for class, name in pairs(weapons) do
	list.Set("SpawnableEntities", class.."_respawnable", {
		PrintName = name.." (Respawnable)",
		ClassName = class,
		Category = "Half-Life Respawnable Weapons",
		IconOverride = "entities/"..class..".png",
		KeyValues = { respawnable = "1" }
	})
end