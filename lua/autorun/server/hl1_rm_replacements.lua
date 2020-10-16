if engine.ActiveGamemode() != "sandbox" then return end

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
	["hls_hc"] = true
}
if resizedMaps[game.GetMap()] then
	local cvar = CreateConVar("hl1_sv_replaceitems", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Replace default items and weapons for Half-Life SWEPs on Resized Maps")
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
		["weapon_glock_hl1"] = "weapon_hl1_glock",
		["weapon_357"] = "weapon_hl1_357",
		["weapon_357_hl1"] = "weapon_hl1_357",
		["weapon_9mmAR"] = "weapon_hl1_mp5",
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
		["item_battery"] = "hl1_item_battery"
	}
	hook.Add("OnEntityCreated", "HL1SWEPs_Replacements", function(ent)
		if cvar:GetBool() then
			local replacement = entTable[ent:GetClass()]
			if replacement then
				timer.Simple(0, function()
					if IsValid(ent) then
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
		end
	end)
end