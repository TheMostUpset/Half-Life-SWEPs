local cvar = CreateConVar("hl1_sv_replaceitems", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Replace default items and weapons for Half-Life SWEPs counterparts on Resized Maps")

local resizedMaps = {
	["hls00amrl"] = true,
	["hls01amrl"] = true,
	["hls02amrl"] = true,
	["hls03amrl"] = true,
	["hls04amrl"] = true,
	["hls05amrl"] = true,
	["hls05bmrl"] = true,
	["hls06amrl"] = true,
	["hls07amrl"] = true,
	["hls07bmrl"] = true,
	["hls08amrl"] = true,
	["hls09amrl"] = true,
	["hls10amrl"] = true,
	["hls11amrl"] = true,
	["hls11bmrl"] = true,
	["hls11cmrl"] = true,
	["hls12amrl"] = true,
	["hls13amrl"] = true,
	["hls14amrl"] = true,
	["hls14bmrl"] = true,
	["hls14cmrl"] = true,
	["hls_hc"] = true,
	-- uplink extended
	["uplinkext1"] = true,
	["uplinkext2"] = true,
	["uplinkext3"] = true,
	["uplinkext4"] = true
}

function HL1_IsResizedMap(map)
	map = map or game.GetMap()
	return resizedMaps[map]
end

if engine.ActiveGamemode() != "sandbox" then return end

if HL1_IsResizedMap() then
	-- creating non-existing ents first, so we'll be able to replace them later
	local baseEnt = {Base = "base_entity", IsHL1Replacement = true}
	local dummyEnts = {
		"weapon_mp5",
		"weapon_9mmar",
		"weapon_9mmhandgun",
		"weapon_glock"
	}
	for k, v in ipairs(dummyEnts) do
		scripted_ents.Register(baseEnt, v)
	end
	--[[local entTable_hls = {
		["weapon_crowbar"] = "weapon_crowbar_hl1",
		["weapon_glock"] = "weapon_glock_hl1",
		["weapon_357"] = "weapon_357_hl1",
		["weapon_mp5"] = "weapon_mp5_hl1",
		["weapon_shotgun"] = "weapon_shotgun_hl1",
		["weapon_crossbow"] = "weapon_crossbow_hl1",
		["weapon_rpg"] = "weapon_rpg_hl1"
	}]]
	local entTable = {
		["weapon_crowbar"] = "weapon_hl1_crowbar",
		["weapon_crowbar_hl1"] = "weapon_hl1_crowbar",
		["weapon_9mmhandgun"] = "weapon_hl1_glock",
		["weapon_glock"] = "weapon_hl1_glock",
		["weapon_glock_hl1"] = "weapon_hl1_glock",
		["weapon_357"] = "weapon_hl1_357",
		["weapon_357_hl1"] = "weapon_hl1_357",
		["weapon_9mmAR"] = "weapon_hl1_mp5",
		["weapon_9mmar"] = "weapon_hl1_mp5",
		["weapon_mp5"] = "weapon_hl1_mp5",
		["weapon_mp5_hl1"] = "weapon_hl1_mp5",
		["weapon_shotgun"] = "weapon_hl1_shotgun",
		["weapon_shotgun_hl1"] = "weapon_hl1_shotgun",
		["weapon_crossbow"] = "weapon_hl1_crossbow",
		["weapon_crossbow_hl1"] = "weapon_hl1_crossbow",
		["weapon_rpg"] = "weapon_hl1_rpg",
		["weapon_rpg_hl1"] = "weapon_hl1_rpg",
		["weapon_gauss"] = "weapon_hl1_gauss",
		["weapon_egon"] = "weapon_hl1_egon",
		["weapon_hornetgun"] = "weapon_hl1_hornetgun",
		["weapon_handgrenade"] = "weapon_hl1_handgrenade",
		["weapon_satchel"] = "weapon_hl1_satchel",
		["weapon_tripmine"] = "weapon_hl1_tripmine",
		["weapon_snark"] = "weapon_hl1_snark",
		["item_healthkit"] = "hl1_item_healthkit",
		["item_battery"] = "hl1_item_battery",
		["ammo_9mmar"] = "hl1_ammo_9mmar",
		["ammo_9mmbox"] = "hl1_ammo_9mmbox",
		["ammo_9mmclip"] = "hl1_ammo_9mmclip",
		["ammo_357"] = "hl1_ammo_357",
		["ammo_argrenades"] = "hl1_ammo_argrenades",
		["ammo_buckshot"] = "hl1_ammo_buckshot",
		["ammo_crossbow"] = "hl1_ammo_crossbow",
		["ammo_gaussclip"] = "hl1_ammo_gaussclip",
		["ammo_rpgclip"] = "hl1_ammo_rpgclip",
		["ammo_mp5clip"] = "hl1_ammo_9mmar",
		["ammo_mp5grenades"] = "hl1_ammo_argrenades",
		["monster_tripmine"] = "hl1_monster_tripmine",
	}
	
	local replaceEntsInBoxes = {
		["item_ammo_pistol"] = "weapon_hl1_glock",
		["item_ammo_pistol_large"] = "hl1_ammo_9mmclip",
		["item_ammo_smg1"] = "weapon_hl1_mp5",
		["item_ammo_smg1_large"] = "hl1_ammo_9mmAR",
		["item_ammo_ar2"] = "hl1_ammo_ARgrenades",
		["item_ammo_ar2_large"] = "weapon_hl1_shotgun",
		["item_box_buckshot"] = "hl1_ammo_buckshot",
		["item_flare_round"] = "weapon_hl1_crossbow",
		["item_box_flare_rounds"] = "hl1_ammo_crossbow",
		["item_rpg_round"] = "weapon_hl1_357",
		["unused (item_smg1_grenade) 13"] = "hl1_ammo_357",
		["item_box_sniper_rounds"] = "weapon_hl1_rpg",
		["unused (???) 15"] = "hl1_ammo_rpgclip",
		["weapon_stunstick"] = "hl1_ammo_gaussclip",
		["unused (weapon_ar1) 17"] = "weapon_hl1_handgrenade",
		["weapon_ar2"] = "weapon_hl1_tripmine",
		["unused (???) 19"] = "weapon_hl1_satchel",
		["weapon_rpg"] = "weapon_hl1_snark",
		["weapon_smg1"] = "weapon_hl1_hornetgun",
		["weapon_9mmar"] = "weapon_hl1_mp5",
		["weapon_9mmAR"] = "weapon_hl1_mp5",
		["weapon_9mmhandgun"] = "weapon_hl1_glock",
		["item_battery"] = "hl1_item_battery",
		["item_healthkit"] = "hl1_item_battery",
		["ammo_9mmar"] = "hl1_ammo_9mmar",
		["ammo_9mmbox"] = "hl1_ammo_9mmbox",
		["ammo_9mmclip"] = "hl1_ammo_9mmclip",
		["ammo_357"] = "hl1_ammo_357",
		["ammo_argrenades"] = "hl1_ammo_argrenades",
		["ammo_buckshot"] = "hl1_ammo_buckshot",
		["ammo_crossbow"] = "hl1_ammo_crossbow",
		["ammo_gaussclip"] = "hl1_ammo_gaussclip",
		["ammo_rpgclip"] = "hl1_ammo_rpgclip",
		["ammo_mp5clip"] = "hl1_ammo_9mmar",
		["ammo_mp5grenades"] = "hl1_ammo_argrenades",
	}
	
	local function FixItemsFromBreakables()
		if cvar:GetBool() then
			local breakables = ents.FindByClass("func_breakable")
			table.Add(breakables, ents.FindByClass("func_pushable"))
			table.Add(breakables, ents.FindByClass("func_physbox"))
			for k, v in pairs(breakables) do
				local repl = replaceEntsInBoxes[v:GetSaveTable().m_iszSpawnObject]
				if repl then
					v:SetSaveValue("m_iszSpawnObject", repl)
				end
			end
		end
	end
	
	hook.Add("InitPostEntity", "HL1SWEPs_FixItems", FixItemsFromBreakables)
	
	hook.Add("PostCleanupMap", "HL1SWEPs_FixItems", function()
		FixItemsFromBreakables()
	end)
	
	local function CreatedFromHL1NPC(ent)
		local owner = ent:GetOwner()
		return IsValid(owner) and owner:IsNPC() and !IsValid(owner:GetActiveWeapon())
	end

	hook.Add("OnEntityCreated", "HL1SWEPs_Replacements", function(ent)
		-- if string.StartWith(ent:GetClass(), "weapon_") then print(ent) end
		if cvar:GetBool() then
			local replacement = entTable[ent:GetClass()]
			if replacement then
				timer.Simple(0, function()
					if IsValid(ent) and (ent:CreatedByMap() or CreatedFromHL1NPC(ent)) then
						local pos, ang, vel, owner = ent:GetPos(), ent:GetAngles(), ent:GetVelocity(), ent:GetOwner()
						if !owner:IsPlayer() or !IsValid(owner) then
							ent:Remove()
							ent = ents.Create(replacement)
							if IsValid(ent) then
								ent:SetPos(pos)
								ent:SetAngles(ang)
								ent:SetOwner(owner)
								ent:Spawn()
								local phys = ent:GetPhysicsObject()
								if IsValid(phys) then
									phys:SetVelocity(vel)
								else
									ent:SetVelocity(vel)
								end
							end
						end
					end
				end)
			end
		else
			if ent.IsHL1Replacement then ent:Remove() end
		end
	end)
end