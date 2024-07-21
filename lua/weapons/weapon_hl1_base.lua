include("hl1_ai_translations.lua")

local weps = {
	{"weapon_hl1_crowbar", "crowbar"},
	{"weapon_hl1_glock", "glock"},
	{"weapon_hl1_357", "357"},
	{"weapon_hl1_mp5", "mp5"},
	{"weapon_hl1_shotgun", "shotgun"},
	{"weapon_hl1_crossbow", "crossbow"},
	{"weapon_hl1_rpg", "rpg"},
	{"weapon_hl1_gauss", "gauss"},
	{"weapon_hl1_egon", "egon"},
	{"weapon_hl1_hornetgun", "hgun"},
	{"weapon_hl1_handgrenade", "grenade"},
	{"weapon_hl1_satchel", "satchel"},
	{"weapon_hl1_tripmine", "tripmine"},
	{"weapon_hl1_snark", "snark"},
}

SWEP.IsHL1Base			= true

SWEP.Weight				= -1
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

if SERVER then

	local dmgCvars = {
		{"hl1_sk_plr_dmg_crowbar", 10},
		{"hl1_sk_plr_dmg_9mm_bullet", 8},
		{"hl1_sk_plr_dmg_357_bullet", 40},
		{"hl1_sk_plr_dmg_buckshot", 5},
		{"hl1_sk_plr_dmg_mp5_bullet", 5},
		{"hl1_sk_plr_dmg_mp5_grenade", 100},
		{"hl1_sk_plr_dmg_rpg", 100},
		{"hl1_sk_plr_dmg_xbow_bolt_plr", 10},
		{"hl1_sk_plr_dmg_xbow_bolt_npc", 50},
		{"hl1_sk_plr_dmg_egon_narrow", 6},
		{"hl1_sk_plr_dmg_egon_wide", 14},
		{"hl1_sk_plr_dmg_gauss", 20},
		{"hl1_sk_plr_dmg_grenade", 100},
		{"hl1_sk_plr_dmg_hornet", 7},
		{"hl1_sk_plr_dmg_tripmine", 150},
		{"hl1_sk_plr_dmg_satchel", 150}
	}
	for k, v in ipairs(dmgCvars) do
		CreateConVar(v[1], v[2], FCVAR_NOTIFY)
	end
	CreateConVar("hl1_sv_itemrespawntime", 23, FCVAR_NOTIFY, "Respawn time for items in Deathmatch", 0)
	CreateConVar("hl1_sv_mprules", 0, FCVAR_NOTIFY, "Deathmatch rules in singleplayer", 0, 1)
	local cvar_loadout = CreateConVar("hl1_sv_loadout", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Players spawn with HL weapons (1 - crowbar & pistol, 2 - full loadout)", 0, 2)
	CreateConVar("hl1_sv_gauss_tracebackwards", 1, FCVAR_NOTIFY, "", 0, 1)
	CreateConVar("hl1_sv_explosionshake", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Enable screen shake after explosions", 0, 1)
	
	hook.Add("PlayerLoadout", "HL1Loadout", function(ply)
		if cvar_loadout:GetInt() == 1 then
			ply:Give("weapon_hl1_glock")
			ply:Give("weapon_hl1_crowbar")
			timer.Simple(0, function()
				if IsValid(ply) then
					ply:GiveAmmo(68, "9mmRound", true)
				end
			end)
		elseif cvar_loadout:GetInt() == 2 then
			for k, v in pairs(weps) do
				ply:Give(v[1])
				timer.Simple(0, function()
					if IsValid(ply) then
						local entWep = ply:GetWeapon(v[1])
						if entWep.Primary.DefaultClip > 0 then ply:GiveAmmo(entWep.Primary.DefaultClip * 2, entWep:GetPrimaryAmmoType(), true) end
						if entWep.Secondary.DefaultClip > 0 then ply:GiveAmmo(entWep.Secondary.DefaultClip, entWep:GetSecondaryAmmoType(), true) end
					end
				end)
			end
		end
	end)	
	
	if game.SinglePlayer() then
		util.AddNetworkString("HL1punchangle")
	end
	util.AddNetworkString("HL1tpAnim")
	util.AddNetworkString("HL1toggleHD")
	
	concommand.Add("hl1_impulse101", function(ply, cmd, args)

		if ply and IsValid(ply) and (!ply:IsSuperAdmin() or !ply:Alive()) then return end
		
		if args[1] then
			for k, v in ipairs(player.GetAll()) do
				if v:Nick():lower() == args[1]:lower() then
					ply = v
					break
				end
			end
		end
	
		if !IsValid(ply) then return end
		
		for _, wep in pairs(weps) do
			ply:Give(wep[1])
			local entWep = ply:GetWeapon(wep[1])
			if entWep.Primary.MaxAmmo then ply:GiveAmmo(math.min(entWep.Primary.MaxAmmo - ply:GetAmmoCount(entWep:GetPrimaryAmmoType()), entWep.Primary.DefaultClip), entWep:GetPrimaryAmmoType()) end
			if entWep.Secondary.MaxAmmo then ply:GiveAmmo(math.min(entWep.Secondary.MaxAmmo - ply:GetAmmoCount(entWep:GetSecondaryAmmoType()), entWep.Secondary.DefaultClip), entWep:GetSecondaryAmmoType()) end
		end
		if ply:IsSuitEquipped() and ply:Armor() < 100 then
			ply:Give("item_battery")
		end

	end)

else

	SWEP.PrintName			= "HL1 Base"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 1
	SWEP.SlotPos			= 0
	SWEP.ViewModelFOV		= 90
	SWEP.HideWhenEmpty		= false
	SWEP.DrawCrosshair		= true
	--SWEP.CrosshairXY		= {0, 0}
	SWEP.CrosshairWH		= {24, 24}
	SWEP.CrosshairColor		= Color(255, 180, 0, 255) -- default value if GSRCHUD is disabled
	SWEP.WepSelectIcon		= surface.GetTextureID("hl1/icons/glock")

	SWEP.ViewModelOffset = {
		PosForward = 0,
		PosRight = 0,
		PosUp = 0,
		
		AngForward = 0,
		AngRight = 0,
		AngUp = 0
	}
	
	local killiconCol = Color(255, 150, 50, 255)
	for _, v in pairs(weps) do
		killicon.Add(v[1], "hl1/icons/"..v[2], killiconCol)
	end
	killicon.AddAlias("ent_hl1_crossbow_bolt", "weapon_hl1_crossbow")
	killicon.AddAlias("ent_hl1_hornet", "weapon_hl1_hornetgun")
	killicon.AddAlias("hornet", "ent_hl1_hornet")
	killicon.AddAlias("ent_hl1_rpg_rocket", "weapon_hl1_rpg")
	killicon.AddAlias("ent_hl1_grenade", "weapon_hl1_handgrenade")
	killicon.AddAlias("ent_hl1_cgrenade", "ent_hl1_grenade")
	killicon.AddAlias("hl1_monster_tripmine", "weapon_hl1_tripmine")
	killicon.AddAlias("monster_tripmine", "hl1_monster_tripmine")
	killicon.AddAlias("hl1_monster_satchel", "weapon_hl1_satchel")
	killicon.AddAlias("monster_satchel", "hl1_monster_satchel")
	killicon.AddAlias("monster_snark", "weapon_hl1_snark")
	
	CreateClientConVar("hl1_cl_firelight", 1, true, false, "Dynamic light from muzzle flash and explosion")
	CreateClientConVar("hl1_cl_muzzleflash", 1, true, false, "Muzzle flash effect")
	CreateClientConVar("hl1_cl_muzzlesmoke", 1, true, false, "Muzzle smoke effect")
	CreateClientConVar("hl1_cl_ejectshells", 1, true, false, "Eject shells")
	
	net.Receive("HL1toggleHD", function()
		local enable, wep = net.ReadBool(), net.ReadEntity()
		if IsValid(wep) then
			if enable then
				wep:ApplyHDViewModel()
				wep:ResetViewModelOffset()
				wep:ApplyHDPlayerModel()
				wep:ApplyHDEntModel()
			else
				wep:ApplySDViewModel()
				wep:ApplySDPlayerModel()
				wep:ApplySDEntModel()
			end
			if !IsValid(wep:GetOwner()) then
				wep:SetEntityWorldModel()
			end
		end
	end)
end

local cvar_hdmodels = CreateConVar("hl1_sv_hdmodels", 0, {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Enable HD models for HL weapons")
if SERVER then
	cvars.AddChangeCallback("hl1_sv_hdmodels", function(name, value_old, value_new)
		local b = tobool(value_new)
		for _, wep in ipairs(ents.FindByClass("weapon_*")) do
			if wep.Base == "weapon_hl1_base" then
				local owner = wep:GetOwner()
				if b then
					wep:ApplyHDViewModel()
					wep:ApplyHDPlayerModel()
					wep:ApplyHDEntModel()
				else
					wep:ApplySDViewModel()
					wep:ApplySDPlayerModel()
					wep:ApplySDEntModel()
				end
				if IsValid(owner) then
					if owner:IsPlayer() then
						local actwep = owner:GetActiveWeapon()
						if IsValid(actwep) and actwep == wep then
							local vm = owner:GetViewModel()
							if IsValid(vm) and vm:GetModel() != wep.ViewModel then
								vm:SetWeaponModel(wep.ViewModel, wep)
							end
						end
					end
					wep:SetPlayerWorldModel()
				else
					wep:SetEntityWorldModel()
				end
				net.Start("HL1toggleHD")
				net.WriteBool(b)
				net.WriteEntity(wep)
				net.Broadcast()
			end
		end
	end, "ToggleHD")
end

local cvar_cmodels = CreateConVar("hl1_sv_cmodels", 1, {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Enable c_ models for HL weapons")
SetGlobalBool("hl1_sv_cmodels", cvar_cmodels:GetBool())
cvars.AddChangeCallback("hl1_sv_cmodels", function(name, value_old, value_new)
	local b = tobool(value_new)
	SetGlobalBool("hl1_sv_cmodels", b)
end)

local cvar_clampammo = CreateConVar("hl1_sv_clampammo", 0, {FCVAR_NOTIFY, FCVAR_REPLICATED}, "Enable max ammo limit for HL weapons", 0, 1)
-- local cvar_sprules = CreateConVar("hl1_sv_sprules", 0, {FCVAR_NOTIFY, FCVAR_REPLICATED}, "Singleplayer rules in multiplayer", 0, 1)
local cvar_unlimitedclip = CreateConVar("hl1_sv_unlimitedclip", 0, {FCVAR_NOTIFY, FCVAR_REPLICATED}, "Unlimited clip for HL weapons", 0, 1)
local cvar_unlimitedammo = CreateConVar("hl1_sv_unlimitedammo", 0, {FCVAR_NOTIFY, FCVAR_REPLICATED}, "Unlimited ammo for HL weapons", 0, 1)

SWEP.HoldType			= "shotgun"

SWEP.Category			= "Half-Life"
SWEP.Spawnable			= false
SWEP.UseHands			= true

SWEP.Primary.Sound			= nil
SWEP.Primary.Damage			= 10
SWEP.Primary.Recoil			= 1
SWEP.Primary.RecoilRandom	= {0, 0}
SWEP.Primary.Cone			= 0
SWEP.Primary.NumShots		= 1
SWEP.Primary.Delay			= .5
SWEP.Primary.ClipSize 		= -1
SWEP.Primary.DefaultClip	= 100
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Automatic		= true

SWEP.Secondary.Recoil		= 0
SWEP.Secondary.RecoilRandom = {0, 0}
SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Ammo			= "none"
SWEP.Secondary.Automatic	= true

SWEP.AutoReload				= true
SWEP.ReloadSound			= ""
SWEP.ReloadTime				= 1

SWEP.UnloadAnimSpeed		= 1

SWEP.DrySound				= Sound("weapons/357_cock1.wav")
SWEP.AmmoPickupSound		= Sound("items/9mmclip1.wav")

SWEP.MuzzleEffect			= "hl1_mflash"
SWEP.MuzzleScale			= 1
SWEP.MuzzleSmoke			= false
SWEP.MuzzlePos				= Vector(9, 0, 4) -- thirdperson muzzle position

SWEP.CrouchAccuracyMul		= nil -- lower is better, e.g. 0.75

SWEP.RicochetSounds = {
	Sound("weapons/ric1.wav"),
	Sound("weapons/ric2.wav"),
	Sound("weapons/ric3.wav"),
	Sound("weapons/ric4.wav"),
	Sound("weapons/ric5.wav")
}

SWEP.GoldSrcRecoil			= true

function SWEP:IsBSPModel(ent)
	return ent:GetSolid() == SOLID_BSP || ent:GetMoveType() == MOVETYPE_PUSH --or walk?
end

function SWEP:KeyValue(k, v)
	if k == "respawnable" then
		self.rRespawnable = tobool(v)
	end
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "iPlayEmptySound")
	self:NetworkVar("Bool", 1, "InZoom")
	self:NetworkVar("Bool", 2, "BlockAutoReload")
	self:NetworkVar("Float", 0, "WeaponIdleTime")
	self:NetworkVar("Float", 1, "ReloadTime")
	self:NetworkVar("Float", 10, "UnloadTime")
	self:NetworkVar("Int", 0, "InAttack")
	self:SpecialDT()
end

function SWEP:SpecialDT()
end

function SWEP:CreatePhysics()
	local mins, maxs = self:GetModelBounds()
	self:PhysicsInitBox(mins - Vector(0,0,1), maxs)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMaterial("weapon")
		phys:SetMass(20)
		phys:Wake()
	end
	
	--[[self:SetMoveType(MOVETYPE_FLYGRAVITY)
	self:SetSolid(SOLID_NONE)
	self:SetTrigger(true)
	self:UseTriggerBounds(true, 24)]]--
end

function SWEP:ItemShouldRespawn()
	return self:CreatedByMap() and (self:IsMultiplayerRules() or (!game.SinglePlayer() and GAMEMODE.Cooperative)) or self.rRespawnable
end

function SWEP:CreatedFromBreakable()
	local owner = self:GetOwner()
	return IsValid(owner) and (owner:GetClass() == "func_breakable" or owner:GetClass() == "func_pushable" or owner:GetClass() == "func_physbox")
end

function SWEP:CreatedFromHL1NPC()
	local owner = self:GetOwner()
	return IsValid(owner) and owner:IsNPC() and owner:Health() <= 0 and !IsValid(owner:GetActiveWeapon())
end

function SWEP:Initialize()
	-- do you know how it feels when people complain that your addon doesn't work and you have no fucking idea why?
	-- then ACCIDENTALLY you find out that the reason is some very popular addon
	-- its shitty code completely breaks these and even official HLS weapons and items, so i have to do this
	-- and i don't give a fuck if it breaks something else, i had enough unsubs and dislikes from ppl who thought my addon was always broken
	hook.Remove("PlayerCanPickupWeapon", "VManip_PickupPCPW")
	hook.Remove("PlayerCanPickupItem", "VManip_PickupPCPI")

	local owner = self:GetOwner()
	if !owner or !IsValid(owner) or self:CreatedFromBreakable() then
		if self.EntModel then
			if self:IsHDEnabled() then
				self:ApplyHDEntModel()
			end
			self:SetEntityWorldModel()
		end
		if SERVER then
			self:PhysicsDestroy()
			self:SetMoveType(MOVETYPE_FLYGRAVITY)
			self:SetMoveCollide(MOVECOLLIDE_FLY_BOUNCE)
			self:SetTrigger(true)
			--self:SetCollisionBounds(Vector(-16, -16, 0), Vector(16, 16, 16))
			self:SetCollisionBounds(Vector(-2, -2, 0), Vector(2, 2, 16))
			self:UseTriggerBounds(true, 24)
			local tr = util.QuickTrace(self:GetPos(), Vector(0,0,1), self)
			self:SetPos(tr.HitPos)
			if self:ItemShouldRespawn() then
				self:SetSolid(SOLID_BSP)
				self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
				self.rClassName = self:GetClass()
				self.rSpawnPos = self:GetPos()
				self.rSpawnAng = self:GetAngles()
				self.rRespawnable = true
			end
		end
	end
	
	self:SetHoldType(self.HoldType)
	self:SpecialInit()
	self:ApplyViewModel()
	if self:IsHDEnabled() then
		self:ApplyHDPlayerModel()
		if IsValid(self.Owner) and self.Owner:IsNPC() then
			self:SetPlayerWorldModel()
		end
	end
	
	if self:CreatedFromHL1NPC() then
		self:SetModelScale(1.25)
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			if SERVER and self:IsHDEnabled() then
				self:SetModel(self.WorldModel)
			end
			phys:AddVelocity(owner:GetForward() * math.Rand(10, 100) + owner:GetUp() * math.Rand(20, 150))
			--phys:SetVelocity(Vector(math.Rand(-100, 100), math.Rand(-100, 100), math.Rand(200, 300)))
			--phys:AddAngleVelocity(Vector(0, math.Rand(200, 400), 0))
		end
		if SERVER then self:Activate() end
	end
end

function SWEP:IsCModelsEnabled()
	return GetGlobalBool("hl1_sv_cmodels", true)
end

function SWEP:IsHDEnabled()
	return cvar_hdmodels and cvar_hdmodels:GetBool() and self.Base == "weapon_hl1_base"
end

function SWEP:ApplyViewModel()
	if self:IsCModelsEnabled() then
		if self.CModel and self.ViewModel != self.CModel then
			self.ViewModel = self.CModel
		end
		if self.CModelSatchel and self.CModelRadio then
			self.ModelSatchelView = self.CModelSatchel
			self.ModelRadioView = self.CModelRadio
			if self.ViewModel == self.VModelSatchel then
				self.ViewModel = self.CModelSatchel
			end
			if self.ViewModel == self.VModelRadio then
				self.ViewModel = self.CModelRadio
			end
		end
		self.UseHands = true
	else
		if self.VModel and self.ViewModel != self.VModel then
			self.ViewModel = self.VModel
		end
		if self.VModelSatchel and self.VModelRadio then
			self.ModelSatchelView = self.VModelSatchel
			self.ModelRadioView = self.VModelRadio
			if self.ViewModel == self.CModelSatchel then
				self.ViewModel = self.VModelSatchel
			end
			if self.ViewModel == self.CModelRadio then
				self.ViewModel = self.VModelRadio
			end
		end
		self.UseHands = false
	end

	if self:IsHDEnabled() then
		self:ApplyHDViewModel()
	end
end

function SWEP:SaveOldViewModel()
	if self.ViewModel == self.CModel then
		if !self.CModelSD then self.CModelSD = self.ViewModel end
	else
		if !self.VModelSD then self.VModelSD = self.ViewModel end
	end
end

function SWEP:ApplyHDViewModel()
	if self.CModelHD and self.UseHands then
		if util.IsValidModel(self.CModelHD) then
			self:SaveOldViewModel()
			self.ViewModel = self.CModelHD
		end
	elseif self.VModelHD then
		if util.IsValidModel(self.VModelHD) then
			self:SaveOldViewModel()
			self.ViewModel = self.VModelHD
			self.UseHands = false
		end
	elseif string.find(self.ViewModel, "/hl1/c_") or string.find(self.ViewModel, "/hl1/v_") then
		local hdVMdl = string.gsub(self.ViewModel, "/hl1/", "/hl1/hd/")
		if self.ViewModel != hdVMdl then
			if util.IsValidModel(hdVMdl) then
				self.ViewModel = hdVMdl
			else
				-- try fallback to v_ model
				local hdVMdl = string.gsub(self.ViewModel, "/hl1/c_", "/hl1/hd/v_")
				if util.IsValidModel(hdVMdl) then
					self.ViewModel = hdVMdl
					self.UseHands = false
				end
			end
		end
	end
end

function SWEP:ApplySDViewModel()
	if self.CModelSD then
		self.ViewModel = self.CModelSD
		self.UseHands = true
	elseif self.VModelSD then
		self.ViewModel = self.VModelSD
		self.UseHands = false
	elseif string.find(self.ViewModel, "/hl1/hd/") then
		self.ViewModel = string.gsub(self.ViewModel, "/hl1/hd/", "/hl1/")
	end
end

function SWEP:ApplyHDEntModel()
	if self.EntModelHD and self.EntModel != self.EntModelHD and util.IsValidModel(self.EntModelHD) then
		if !self.EntModelSD then self.EntModelSD = self.EntModel end
		self.EntModel = self.EntModelHD
	end
end

function SWEP:ApplySDEntModel()
	if self.EntModelSD then
		self.EntModel = self.EntModelSD
	end
end

function SWEP:ApplyHDPlayerModel()
	if self.PlayerModelHD and self.PlayerModel != self.PlayerModelHD and util.IsValidModel(self.PlayerModelHD) then
		if !self.PlayerModelSD then self.PlayerModelSD = self.PlayerModel end
		self.PlayerModel = self.PlayerModelHD
	end
end

function SWEP:ApplySDPlayerModel()
	if self.PlayerModelSD then
		self.PlayerModel = self.PlayerModelSD
	end
end

function SWEP:SetPlayerWorldModel()
	if self.PlayerModel and self.WorldModel != self.PlayerModel then
		self.WorldModel = self.PlayerModel
	end
end

function SWEP:SetEntityWorldModel()
	self.WorldModel = self.EntModel
	self:SetModel(self.WorldModel)
end

function SWEP:EquipSpecial(ply)
end

function SWEP:Equip(ply)
	if IsValid(self.Owner) and self.Owner:IsPlayer() then
		self:CallOnClient("SetPlayerWorldModel")
	end
	
	self:EquipSpecial(ply)
	
	local ammotypeP = self:GetPrimaryAmmoType()
	local ammotypeS = self:GetSecondaryAmmoType()
	if IsValid(ply) and ply:IsPlayer() then
		if self.DroppedAmmo then
			ply:SetAmmo(ply:GetAmmoCount(ammotypeP) - self.Primary.DefaultClip + self.DroppedAmmo, ammotypeP)
		end
		if cvar_clampammo:GetBool() or ammotypeP == game.GetAmmoID("hornet") then
			local maxAmmoPrimary, maxAmmoSecondary = self.Primary.MaxAmmo, self.Secondary.MaxAmmo
			local maxAmmoMul = ply.HL1MaxAmmoMultiplier
			if maxAmmoMul then
				if maxAmmoPrimary then
					maxAmmoPrimary = math.Round(maxAmmoPrimary * maxAmmoMul)
				end
				if maxAmmoSecondary then
					maxAmmoSecondary = math.Round(maxAmmoSecondary * maxAmmoMul)
				end
			end
			if maxAmmoPrimary and ply:GetAmmoCount(ammotypeP) > maxAmmoPrimary then
				ply:SetAmmo(maxAmmoPrimary, ammotypeP)
			end
			if maxAmmoSecondary and ply:GetAmmoCount(ammotypeS) > maxAmmoSecondary then
				ply:SetAmmo(maxAmmoSecondary, ammotypeS)
			end
		end
	end

	if CLIENT or !self.rClassName or !self.rRespawnable or !self.rSpawnPos then return end
	self.rRespawnable = false
	local class = self.rClassName
	local pos = self.rSpawnPos
	local ang = self.rSpawnAng
	local respTime = self.RespawnTime or GAMEMODE.WeaponRespawnTime or cvars.Number("hl1_sv_itemrespawntime", 23)
	timer.Simple(respTime, function()
		if !class then return end
		local resp = ents.Create(class)
		if IsValid(resp) then
			resp:SetPos(pos)
			resp:SetAngles(ang)
			resp.rRespawnable = true
			resp:Spawn()
			sound.Play("items/suitchargeok1.wav", pos, 80, 150)
		end
	end)
end

function SWEP:EquipAmmo(ply)
	self:Equip(ply)
	if self.Primary.Ammo != "none" then
		ply:EmitSound(self.AmmoPickupSound, 75, 100, 1, CHAN_ITEM)
	end
end

function SWEP:SpecialInit()
end

function SWEP:Deploy()
	if IsValid(self.Owner) and self.Owner:IsPlayer() then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			if vm:GetModel() != self.ViewModel then
				vm:SetModel(self.ViewModel)
			end
		end
	end
	
	self:SendWeaponAnim(ACT_VM_DRAW)
	if self:GetNextPrimaryFire() - CurTime() < 0.5 then
		self:SetNextAttack(CurTime() + 0.5)
	end
	self:SetWeaponIdleTime(CurTime() + 1)
	self:SpecialDeploy()
	self:SetPlayerWorldModel()
	if CLIENT and self.MagBone and self:GetBlockAutoReload() then
		self:HideMagBone(true)
	end
	return true
end

function SWEP:SpecialDeploy()
end

function SWEP:Holster(wep)
	if CLIENT and IsValid(self.Owner) and self.Owner != LocalPlayer() then return end
	
	if self == wep or !self:CanHolster() then
		return
	end
	self:SetReloadTime(0)
	self:SpecialHolster()
	if !self.NoOnRemoveCall then self:OnRemove() end
	return true
end

function SWEP:OnRemove()
	if CLIENT and self.MagBone then
		self:ResetBones()
	end
end

function SWEP:SpecialHolster()
end

function SWEP:ResetBones()
	local owner = self:GetOwner()
	if IsValid(owner) and owner:IsPlayer() then
		local vm = owner:GetViewModel()
		if IsValid(vm) then
			for b = 0, vm:GetBoneCount() do
				vm:ManipulateBoneScale(b, Vector(1, 1, 1))
			end
		end
	end
end

function SWEP:SetNextAttack(t)
	self:SetNextPrimaryFire(t)
	self:SetNextSecondaryFire(t)
end

function SWEP:IsMultiplayerRules()
	return (!game.SinglePlayer() or cvars.Bool("hl1_sv_mprules")) and !(GAMEMODE.Cooperative and !cvars.Bool("hl1_sv_mprules"))
end

function SWEP:PlayEmptySound()
	if self:GetiPlayEmptySound() then
		self:EmitSound(self.DrySound, 75, 100)
		self:SetiPlayEmptySound(false)
	end
end

function SWEP:ResetEmptySound()
	if self:GetiPlayEmptySound() or self.Owner:KeyDown(IN_ATTACK) or self.Owner:KeyDown(IN_ATTACK2) then return end
	self:SetiPlayEmptySound(true)
end

function SWEP:rgAmmo()
	if !IsValid(self.Owner) then return -1 end
	if cvar_unlimitedammo:GetBool() or self.Owner:IsNPC() then
		return 99
	else
		return self:Ammo1()
	end
end

function SWEP:HEV_NoAmmo()
	gamemode.Call("HEV_NoAmmo", self, self.Owner)
end

function SWEP:TakeClipPrimary(num)
	num = num or 1

	if self.Owner:IsNPC() then
		if self.Primary.ClipSize > -1 then
			self:TakePrimaryAmmo(num)
		end
		return
	end

	if self.Primary.ClipSize > -1 then
		if !cvar_unlimitedclip:GetBool() then
			self:TakePrimaryAmmo(num)
		end
	else
		if !cvar_unlimitedammo:GetBool() then
			self:TakePrimaryAmmo(num)
		end
	end
end

function SWEP:TakeClipSecondary(num)
	num = num or 1
	if cvar_unlimitedammo:GetBool() then return end
	self:TakeSecondaryAmmo(num)
end

function SWEP:CanDeploy()
	return true
end

function SWEP:CanHolster()
	return true
end

function SWEP:GetNextBestWeapon(pPlayer, pCurrentWeapon)
	if SERVER and !game.SinglePlayer() then return end

	local iBestWeight = -1
	local pBest = NULL
	
	if !pCurrentWeapon:CanHolster() then
		// can't put this gun away right now, so can't switch.
		return false
	end
	
	for _, pCheck in ipairs(pPlayer:GetWeapons()) do
		if IsValid(pCheck) and pCheck:IsScripted() and pCheck.IsHL1Base then
			if pCheck.Weight > -1 && pCheck.Weight == pCurrentWeapon.Weight && pCheck != pCurrentWeapon then
				// this weapon is from the same category. 
				if pCheck:CanDeploy() then
					if self:SwitchWeapon(pCheck, pPlayer) then
						return true
					end
				end
			elseif pCheck.Weight > iBestWeight && pCheck != pCurrentWeapon then // don't reselect the weapon we're trying to get rid of
				if pCheck:CanDeploy() then
					// if this weapon is useable, flag it as the best
					iBestWeight = pCheck.Weight
					pBest = pCheck
				end
			end
		end
	end

	if !IsValid(pBest) then
		return false
	end

	self:SwitchWeapon(pBest, pPlayer)
	
	return true
end

function SWEP:SwitchWeapon(wep, ply)
	ply = ply or self.Owner
	if game.SinglePlayer() then
		ply:SelectWeapon(wep:GetClass())
	elseif CLIENT and IsFirstTimePredicted() then
		input.SelectWeapon(wep)
	end
end

function SWEP:RetireWeapon()
	if self:IsMultiplayerRules() then
		self:GetNextBestWeapon(self.Owner, self)
	end
end

function SWEP:SetPlayerAnimation(anim)
	if self.Owner:IsNPC() then return end
	if SERVER then
		net.Start("HL1tpAnim")
		net.WriteEntity(self.Owner)
		net.WriteInt(anim, 12)
		net.Broadcast()
	end
end

function SWEP:FireAnimationEvent(pos, ang, event, options)
	if event == 5001 then return true end
end

function SWEP:TraceFilter() -- used for crowbar, gauss, egon, snark traces
	return hl1_coop_sv_friendlyfire and !hl1_coop_sv_friendlyfire:GetBool() and player.GetAll() or self.Owner
end

function SWEP:CanPrimaryAttack()
	if self.Owner:IsNPC() and self:GetNextPrimaryFire() > CurTime() then return false end
	if self:GetReloadTime() >= CurTime() then return false end
	return true
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	
	if self.Owner:IsNPC() then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		self:WeaponSound()
		self:HL1MuzzleFlash()
		self:ShootBullet(self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone)
		self:TakePrimaryAmmo(1)
		return
	end
	
	if self.Owner:WaterLevel() == 3 then
		self:PlayEmptySound()
		self:SetNextPrimaryFire(CurTime() + 0.15)
		return
	end
	
	if self:Clip1() <= 0 then
		self:EmitSound(self.DrySound, 75)
		self:SetNextPrimaryFire(CurTime() + 0.15)
		return
	end

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:ShootBullet(cvars.Number(self.Primary.DamageCVar, self.Primary.Damage), self.Primary.NumShots, self.Primary.Cone)
	self:WeaponSound()
	self:TakeClipPrimary()
	self:HL1MuzzleFlash()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:SendRecoil()
	if self:Clip1() <= 0 and self:rgAmmo() <= 0 then
		self:HEV_NoAmmo()
	end
	self:SetWeaponIdleTime(CurTime() + math.Rand(10, 15))
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
	if self:rgAmmo() <= 0 then
		return
	end
	self:DefReload()
end

function SWEP:DefReload(anim, fDelay)
	anim = anim or ACT_VM_RELOAD
	fDelay = fDelay or self.ReloadTime
	if self.Owner:IsNPC() then
		self:DefaultReload(ACT_VM_RELOAD)
		self:SetClip1(self:Clip1() + self.Primary.ClipSize)
		return
	end
	if self:GetReloadTime() >= CurTime() or self:rgAmmo() <= 0 or self:Clip1() >= self.Primary.ClipSize then return end
	if self.Owner.HL1ReloadSpeed then fDelay = fDelay / self.Owner.HL1ReloadSpeed end
	self:SetReloadTime(CurTime() + fDelay)
	self:SendWeaponAnim(anim)
	if self.Owner.HL1ReloadSpeed then self.Owner:GetViewModel():SetPlaybackRate(1 * self.Owner.HL1ReloadSpeed) end
	if self.TPReloadAnim then
		self:SetPlayerAnimation(self.TPReloadAnim)
	else
		self.Owner:SetAnimation(PLAYER_RELOAD)
	end
	self:EmitSound(self.ReloadSound)
	self:SetWeaponIdleTime(CurTime() + 3)
	self:SetBlockAutoReload(false)
	return true
end

function SWEP:ReloadPreEnd()
end

function SWEP:ReloadEnd()
end

function SWEP:Unload()
	if self.UnloadTime and self:Clip1() > 0 then
		self:SetBlockAutoReload(true)
		self:SetWeaponIdleTime(0)
		self:SendWeaponAnim(ACT_VM_RELOAD)
		self.Owner:GetViewModel():SetPlaybackRate(self.UnloadAnimSpeed)
		self:SetNextAttack(CurTime() + self.UnloadTime)
		self:SetUnloadTime(CurTime() + self.UnloadTime)
	end
end

function SWEP:WeaponSound(snd, lvl, pitch)
	snd = snd or self.Primary.Sound or self.PrimarySounds[math.random(1, #self.PrimarySounds)]
	lvl = lvl or 100
	pitch = pitch or 100
	self:EmitSound(snd, lvl, pitch, 1)
	if lvl >= 100 and IsValid(self.Owner) and self.Owner:IsPlayer() then
		self:InsertSound(1, self.Owner:GetShootPos(), 600, 3)
	end
end

function SWEP:WeaponSoundHD(snd, lvl, pitch)
	local snd = self.Primary.SoundHD or self.PrimarySoundsHD[math.random(1, #self.PrimarySoundsHD)]
	self:WeaponSound(snd, lvl, pitch)
end

function SWEP:DoRicochetSound(pos)
	if (!game.SinglePlayer() and CLIENT and IsFirstTimePredicted()) or game.SinglePlayer() then
		sound.Play(self.RicochetSounds[math.random(1, 5)], pos, 80)
	end
end

function SWEP:ShootBullet(damage, num_bullets, aimcone)
	aimcone = isvector(aimcone) and aimcone or Vector(aimcone, aimcone, 0)
	local punchangle = self.Owner.punchangle or Angle()
	local ang = self.Owner:EyeAngles() + punchangle
	local dir = self.Owner:IsPlayer() and ang:Forward() or self.Owner:GetAimVector()
	if self.CrouchAccuracyMul and self.Owner:OnGround() and self.Owner:Crouching() then
		aimcone = aimcone * self.CrouchAccuracyMul
	end

	local bullet = {}
	bullet.Num 		= num_bullets
	bullet.Src 		= self.Owner:GetShootPos()
	bullet.Dir 		= dir
	bullet.Spread 	= aimcone
	bullet.Tracer	= 3
	bullet.Force	= self.Primary.BulletForce or 4
	bullet.Damage	= damage
	bullet.AmmoType = self.Primary.Ammo
	bullet.Callback = self.BulletCallback
	
	self.Owner:FireBullets(bullet)
end

function SWEP:BulletCallback(tr, dmginfo)
	-- adds DMG_NEVERGIB to every bullet damage
	if dmginfo:GetDamage() < 200 then
		dmginfo:SetDamageType(bit.bor(dmginfo:GetDamageType(), DMG_NEVERGIB))
	end
end

function SWEP:SendRecoil(angle)
	if !self.GoldSrcRecoil or self.Owner:IsNPC() then return end
	local recoilRand = util.SharedRandom("HL1RecoilRand", self.Primary.RecoilRandom[1], self.Primary.RecoilRandom[2])
	if angle == 1 then
		recoilRand = util.SharedRandom("HL1RecoilRand", self.Secondary.RecoilRandom[1], self.Secondary.RecoilRandom[2])
		angle = Angle(self.Secondary.Recoil + recoilRand, 0, 0)
	end
	angle = angle or Angle(self.Primary.Recoil + recoilRand, 0, 0)
	if self.CrouchAccuracyMul and self.Owner:OnGround() and self.Owner:Crouching() then
		angle = angle * self.CrouchAccuracyMul
	end
	if game.SinglePlayer() and SERVER then
		net.Start("HL1punchangle")
		net.WriteEntity(self.Owner)
		net.WriteAngle(angle)
		net.Send(self.Owner)
	end
	if CLIENT then
		if IsFirstTimePredicted() then
			self.Owner.punchangle = angle
		end
	else
		self.Owner.punchangle = angle
	end
end

local cvar_ejectshells = GetConVar("hl1_cl_ejectshells")
local shellType = {
	[1] = "ShotgunShellEject",
	[2] = "RifleShellEject",
	[3] = "HL1ShellEject"
}
function SWEP:EjectShell(ent, iType, flip, pos)
	iType = shellType[iType] or "ShellEject"
	
	if !IsFirstTimePredicted() or !IsValid(ent) then return end
	
	if CLIENT and cvar_ejectshells and !cvar_ejectshells:GetBool() then return end

	local angShellAngles = ent:EyeAngles()
	if SERVER or CLIENT and ent:ShouldDrawLocalPlayer() then
		angShellAngles = self:GetAngles()
	end
	
	local vecForward, vecRight, vecUp = angShellAngles:Forward(), angShellAngles:Right(), angShellAngles:Up()
	if flip then angShellAngles:RotateAroundAxis(vecRight, 180) end
	angShellAngles:RotateAroundAxis(vecUp, -60)
	
	local vecShellPosition = ent:GetShootPos()
	
	if pos then
		vecShellPosition = vecShellPosition + vecForward * pos[1]
		vecShellPosition = vecShellPosition + vecRight * pos[2]
		vecShellPosition = vecShellPosition + vecUp * pos[3]
	else	
		if iType == "ShellEject" then
			vecShellPosition = vecShellPosition + vecRight * 4
			vecShellPosition = vecShellPosition + vecUp * -12
			vecShellPosition = vecShellPosition + vecForward * 20
		else
			vecShellPosition = vecShellPosition + vecRight * 6
			vecShellPosition = vecShellPosition + vecUp * -12
			vecShellPosition = vecShellPosition + vecForward * 32
		end
	end
	
	local tr = util.TraceHull({
		start = ent:GetShootPos(),
		endpos = vecShellPosition,
		filter = ent,
		mins = Vector(-1, -1, -1),
		maxs = Vector(1, 1, 1),
	})
	
	local vecShellVelocity = ent:GetAbsVelocity()
	vecShellVelocity = vecShellVelocity + vecRight * math.Rand( 50, 70 );
	vecShellVelocity = vecShellVelocity + vecUp * math.Rand( 100, 150 );
	vecShellVelocity = vecShellVelocity + vecForward * 25;

	angShellAngles.x = 0;
	angShellAngles.z = 0;

	local data = EffectData()
	data:SetStart(vecShellVelocity)
	data:SetOrigin(tr.HitPos)
	data:SetAngles(angShellAngles)
	util.Effect(iType, data)
end

function SWEP:HL1MuzzleFlash(att, scale, effectName)
	att = att or 1
	scale = scale or self.MuzzleScale
	effectName = effectName or self.MuzzleEffect

	self.Owner:MuzzleFlash()
	if !IsFirstTimePredicted() or !IsValid(self.Owner) or self.Owner:WaterLevel() >= 3 then return end
	local fx = EffectData()
	fx:SetEntity(self)
	fx:SetOrigin(self.Owner:GetShootPos())
	fx:SetNormal(self.Owner:GetAimVector())
	fx:SetStart(self.MuzzlePos)
	fx:SetAttachment(att)
	fx:SetScale(scale)
	util.Effect(effectName, fx)
	if self.MuzzleSmoke then
		util.Effect("hl1_mflash_smoke", fx)
	end
end

function SWEP:Think()
	if game.SinglePlayer() and CLIENT then return end
	
	if SERVER then
		local PMpunchangle = self.Owner.punchangle
		if PMpunchangle and PMpunchangle != Angle() then
			HL1_DropPunchAngle(FrameTime(), PMpunchangle)
		end
	end	
	
	self:SpecialThink()

	local reload = self:GetReloadTime()
	if reload > 0 then
		if CLIENT and self.MagTime and reload - CurTime() < self.MagTime then
			self:HideMagBone(false)
		end
		if reload <= CurTime() then
			self:SetReloadTime(0)
			self:ReloadPreEnd()
			if self.UnlimitedAmmo or cvar_unlimitedammo:GetBool() then
				self:SetClip1(self.Primary.ClipSize)
			else
				local clip = self:Clip1()
				self:SetClip1(math.min((self:Ammo1() + clip), self.Primary.ClipSize))
				self.Owner:RemoveAmmo(self.Primary.ClipSize - clip, self.Primary.Ammo)
			end
			self:ReloadEnd()
		else
			return
		end
	end
	
	if self.AutoReload and !self:GetBlockAutoReload() and IsValid(self.Owner) and self.Owner:Alive() and self:Clip1() <= 0 and self:rgAmmo() > 0 and self:GetNextPrimaryFire() <= CurTime() and self.Primary.ClipSize > 0 then
		self:Reload()
	end
	
	local unload = self:GetUnloadTime()
	if unload > 0 and unload <= CurTime() then
		self:SetBlockAutoReload(true)
		local clip = self:Clip1()
		self:SetClip1(0)
		if SERVER then self.Owner:GiveAmmo(clip, self.Primary.Ammo, true) end
		self:SetUnloadTime(0)
		self:WeaponIdle(true)
		if CLIENT then
			self:HideMagBone(true)
		end
	end
	
	local idle = self:GetWeaponIdleTime()
	if idle > 0 and idle <= CurTime() then
		self:WeaponIdle()
	end
end

function SWEP:SpecialThink()
end

function SWEP:WeaponIdle()
end

function SWEP:InsertSound(sndtype, pos, volume, duration)
	if CLIENT then return end
	sndtype = sndtype or 1
	pos = pos or self.Owner:GetShootPos()
	volume = volume or 600
	duration = duration or 3

	if !IsValid(self.aiSoundEnt) then
		self.aiSoundEnt = ents.Create("ai_sound")
		local ent = self.aiSoundEnt
		ent:SetPos(pos)
		ent:Spawn()
		ent:SetKeyValue("soundtype", sndtype)
		ent:SetKeyValue("volume", volume)
		ent:SetKeyValue("duration", duration)
		ent:Activate()
		SafeRemoveEntityDelayed(ent, duration)
	end
	if IsValid(self.aiSoundEnt) then
		self.aiSoundEnt:SetPos(pos)
		self.aiSoundEnt:Fire("EmitAISound")
	end
end

if CLIENT then

local cvar_chair = CreateClientConVar("hl1_cl_crosshair", 1, true, false, "Draw crosshair")
local cvar_chair_scale = CreateClientConVar("hl1_cl_crosshair_scale", 1, true, false, "Crosshair scale")
local cvar_chair_col
if GSRCHUD then
	cvar_chair_col = CreateClientConVar("hl1_cl_crosshair_gsrchud", 1, true, false, "Use GSRCHUD theme color for crosshair")
end
-- local cvar_fixchrome = CreateClientConVar("hl1_cl_fixchrome", 1, true, false, "Fix chrome envmap lighting")
local cvar_hl2bob = CreateClientConVar("hl1_cl_hl2bob", 0, true, false, "Default HL2 (HL:S) bobbing")
local cvar_vmfov = CreateClientConVar("hl1_cl_viewmodelfov", 90, true, false, "Viewmodel FOV for HL weapons")

function SWEP:AdjustMouseSensitivity()
	if self:GetInZoom() then
		return self.Owner:GetFOV() / 80
	end
end

function SWEP:DrawEntityModel()
	self:DrawModel()
	if self.WorldModelSequence and self.WorldModelSequence > 0 then
		self:FrameAdvance()
		self:ResetSequence(self.WorldModelSequence)
	end
end

function SWEP:DrawPlayerModel()
	self:DrawModel()
end

function SWEP:DrawWorldModel()
	if !IsValid(self.Owner) or self:CreatedFromBreakable() then
		if self.EntModel then
			self:SetModel(self.WorldModel)
		end
		self:DrawEntityModel()
		return
	elseif self.PlayerModel and self.WorldModel != self.PlayerModel then
		self.WorldModel = self.PlayerModel
	end
	self:DrawPlayerModel()
end

function SWEP:ResetViewModelOffset()
	self.ViewModelOffset = nil
end

local cvar_bob = CreateClientConVar("hl1_cl_bob", 0.01, true, false)
local cvar_bobcycle = CreateClientConVar("hl1_cl_bobcycle", 0.8, true, false)
local cvar_bobup = CreateClientConVar("hl1_cl_bobup", 0.5, true, false)
local cvar_rollangle = CreateClientConVar("hl1_cl_rollangle", 2, true, false)
local cvar_rollspeed = CreateClientConVar("hl1_cl_rollspeed", 200, true, false)
local cvar_viewbob = CreateClientConVar("hl1_cl_viewbob", 1, true, false)
local cvar_bob_won = CreateClientConVar("hl1_cl_bob_won", 0, true, false)

function SWEP:CalcBob()
	local cl_bob = cvar_bob:GetFloat()
	local cl_bobcycle = math.max(cvar_bobcycle:GetFloat(), 0.1)
	local cl_bobup = cvar_bobup:GetFloat()
	
	local ply = LocalPlayer()
	
	if ply:ShouldDrawLocalPlayer() or ply:GetMoveType() == MOVETYPE_NOCLIP then return 0 end

	local cltime = CurTime()
	local cycle = cltime - math.floor(cltime/cl_bobcycle)*cl_bobcycle
	cycle = cycle / cl_bobcycle
	if (cycle < cl_bobup) then
		cycle = math.pi * cycle / cl_bobup
	else
		cycle = math.pi + math.pi*(cycle-cl_bobup)/(1.0 - cl_bobup)
	end

	local velocity = ply:GetVelocity()

	local bob = math.sqrt(velocity[1]*velocity[1] + velocity[2]*velocity[2]) * cl_bob
	bob = bob*0.3 + bob*0.7*math.sin(cycle)
	if (bob > 4) then
		bob = 4
	elseif (bob < -7) then
		bob = -7
	end
	
	return bob
end

local bob = 0
local lasttime = CurTime()
local bobtime = 0

function SWEP:CalcBobWON()
	local cl_bob = cvar_bob:GetFloat()
	local cl_bobcycle = math.max(cvar_bobcycle:GetFloat(), 0.1)
	local cl_bobup = cvar_bobup:GetFloat()

	if (!LocalPlayer():OnGround() || CurTime() == lasttime) then
		return bob
	end

	lasttime = CurTime()

	local FT = FrameTime()
	if !game.SinglePlayer() then
		if IsFirstTimePredicted() then
			bobtime = bobtime + FT
		end
	else
		bobtime = bobtime + FT		
	end
	local cycle = bobtime - math.floor(bobtime / cl_bobcycle) * cl_bobcycle
	cycle = cycle / cl_bobcycle
	
	if (cycle < cl_bobup) then
		cycle = math.pi * cycle / cl_bobup
	else
		cycle = math.pi + math.pi*(cycle-cl_bobup)/(1.0 - cl_bobup)
	end

	local vel = LocalPlayer():GetVelocity()
	bob = math.sqrt(vel[1]*vel[1] + vel[2]*vel[2]) * cl_bob
	bob = bob*0.3 + bob*0.7*math.sin(cycle)
	bob = math.Clamp(bob, -7, 4)

	return bob
end

function SWEP:CalcRoll(ply)
	if ply:GetMoveType() == MOVETYPE_NOCLIP then return 0 end

	local sign

	local cl_rollangle = cvar_rollangle:GetFloat()
	local cl_rollspeed = cvar_rollspeed:GetFloat()
	
	local side = ply:GetVelocity():Dot(ply:EyeAngles():Right())
	if side < 0 then
		sign = -1
	else
		sign = 1
	end
	side = math.abs(side)
	
	local value = cl_rollangle
	
	if (side < cl_rollspeed) then
		side = side * value / cl_rollspeed
	else
		side = value
	end
	
	return side * sign
end

function SWEP:CalcView(ply, pos, ang, fov)
	local punchangle = ply.punchangle
	if punchangle then
		HL1_VectorAdd(ang, punchangle, ang)
		HL1_DropPunchAngle(FrameTime(), punchangle)
	end
	
	if !cvar_hl2bob:GetBool() and ply:IsValid() and ply:Alive() and !ply:InVehicle() and !ply:ShouldDrawLocalPlayer() then
		local bob = self:CalcBob()
		--[[if cvar_bob_won:GetBool() then
			bob = self:CalcBobWON()
		else
			bob = self:CalcBob()
		end]]
		local roll = self:CalcRoll(ply)
		
		if cvar_viewbob:GetBool() then
			pos[3] = pos[3] + bob
		end
		ang.r = ang.r + roll
	end
	
	return pos, ang
end

function SWEP:CalcViewModelView(vm, oldPos, oldAng, pos, ang)	
	if cvar_hl2bob:GetBool() then 
		if self.HideWhenEmpty and self:rgAmmo() <= 0 then
			pos = self:ViewModelHide(pos, ang, vm)
		end
		return pos, ang
	end
	
	local bob = self:CalcBob()
	--[[if cvar_bob_won:GetBool() then
		bob = self:CalcBobWON()
	else
		bob = self:CalcBob()
	end]]
	
	if self.ViewModelOffset then
		oldPos = oldPos + oldAng:Forward() * self.ViewModelOffset.PosForward + oldAng:Right() * self.ViewModelOffset.PosRight + oldAng:Up() * self.ViewModelOffset.PosUp
		oldAng:RotateAroundAxis(oldAng:Forward(), self.ViewModelOffset.AngForward)
		oldAng:RotateAroundAxis(oldAng:Right(), self.ViewModelOffset.AngRight)
		oldAng:RotateAroundAxis(oldAng:Up(), self.ViewModelOffset.AngUp)
	end
	
	oldPos = oldPos + oldAng:Forward() * bob * .4 - Vector(0, 0, 1)
	if cvar_viewbob:GetBool() then
		oldPos[3] = oldPos[3] + bob
	end

	if cvar_bob_won:GetBool() then
		oldAng.y = oldAng.y - bob * 0.5
		oldAng.r = oldAng.r - bob * 1
		oldAng.p = oldAng.p + bob * 0.3
	end
	
	if self.HideWhenEmpty and self:rgAmmo() <= 0 then -- hide when no ammo left
		oldPos = self:ViewModelHide(oldPos, oldAng, vm)
	end
	
	self:SetViewModelFOV(cvar_vmfov:GetInt())

	return self:GetViewModelPosition(oldPos, oldAng)
end

function SWEP:GetViewModelPosition(pos, ang)
	return pos, ang
end

function SWEP:ViewModelHide(pos, ang)
	return pos - ang:Forward() * 40
end

function SWEP:SetViewModelFOV(fov)
	fov = fov or cvar_vmfov:GetInt() or 90
	if self.ViewModelFOVSpecial then
		local fov_new = 90 - self.ViewModelFOVSpecial
		self.ViewModelFOV = fov - fov_new
	else
		self.ViewModelFOV = fov
	end
end

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	surface.SetDrawColor(255, 240, 0, alpha)
	surface.SetTexture(self.WepSelectIcon)
	
	tall = tall * .75
	y = y + ScrH() / 55

	surface.DrawTexturedRect(x, y, wide, tall)
end

local crosshairs = surface.GetTextureID("hl1/sprites/crosshairs")
--[[function SWEP:DrawHUD()
	if self:GetPrimaryAmmoType() == -1 or !cvars.Bool("hl1_cl_crosshair") or !self.CrosshairXY then return end
	surface.SetDrawColor(255, 180, 0, 255)
	surface.SetTexture(crosshairs)
	
	local scale = cvars.Number("hl1_cl_crosshair_scale", 1)

	local w, h = self.CrosshairWH[1] * scale, self.CrosshairWH[2] * scale
	local tx, ty = self.CrosshairXY[1], self.CrosshairXY[2]
	local txsizew, txsizeh = surface.GetTextureSize(crosshairs)
	
	local x, y = (ScrW() - w + scale) / 2, (ScrH() - h + scale) / 2 + 1
	
	local tr = self.Owner:GetEyeTraceNoCursor()	
	if (self.Owner == LocalPlayer() && self.Owner:ShouldDrawLocalPlayer()) then
		local coords = tr.HitPos:ToScreen()
		x, y = coords.x, coords.y
	end

	surface.DrawTexturedRectUV(x, y, w, h, tx / txsizew, ty / txsizeh, (tx+self.CrosshairWH[1]) / txsizew, (ty+self.CrosshairWH[2]) / txsizeh)
end]]--

function SWEP:DoDrawCrosshair(x, y)
	if self:GetPrimaryAmmoType() == -1 or !cvar_chair:GetBool() or !self.CrosshairXY then return true end
	
	local chColor = self.CrosshairColor
	
	if GSRCHUD and GSRCHUD.isEnabled() and cvar_chair_col:GetBool() then
		chColor = GSRCHUD.getCurrentColour()
	end
	
	surface.SetDrawColor(chColor)
	surface.SetTexture(crosshairs)
	
	local scale = cvar_chair_scale:GetFloat()

	local w, h = self.CrosshairWH[1] * scale, self.CrosshairWH[2] * scale
	local tx, ty = self.CrosshairXY[1], self.CrosshairXY[2]
	local txsizew, txsizeh = surface.GetTextureSize(crosshairs)
	
	x, y = x - w / 2 + scale / 2, y - h / 2 + scale / 2 + 1
	
	if self.Owner == LocalPlayer() and self.Owner:ShouldDrawLocalPlayer() then
		local tr = self.Owner:GetEyeTraceNoCursor()	
		local coords = tr.HitPos:ToScreen()
		x, y = coords.x - 10, coords.y - 10
	end

	surface.DrawTexturedRectUV(x, y, w, h, tx / txsizew, ty / txsizeh, (tx+self.CrosshairWH[1]) / txsizew, (ty+self.CrosshairWH[2]) / txsizeh)
	return true
end

function SWEP:HideMagBone(b)
	if self.MagBone then
		local owner = self:GetOwner()
		if IsValid(owner) and owner:IsPlayer() then
			local vm = owner:GetViewModel()
			if IsValid(vm) then
				local magBone = vm:LookupBone(self.MagBone)
				if magBone then
					if b == true then
						vm:ManipulateBoneScale(magBone, Vector())
					else
						vm:ManipulateBoneScale(magBone, Vector(1, 1, 1))
					end
				end
			end
		end
	end
end

--[[function SWEP:PostDrawViewModel(vm, wep, ply)
	if cvar_fixchrome:GetBool() then
		local lightCol = render.GetLightColor(vm:GetPos() + Vector(0,0,2))
		local hdrScale = render.GetToneMappingScaleLinear()
		if hdrScale[1] != 1 then -- checking for HDR
			-- lightCol = (lightCol[1] + lightCol[2] + lightCol[3]) / 3
			-- lightCol = lightCol / 2 + .02
			-- lightCol = math.min(lightCol, .3)
			-- lightCol = Vector(lightCol, lightCol, lightCol)
			lightCol = lightCol * 1.75 + hdrScale / 28
		else
			lightCol = lightCol * 2
		end

		if !self.chromeMats then
			self.chromeMats = {}
			for k, v in pairs(vm:GetMaterials()) do
				if string.find(v, "chrome") then
					local mat = Material(v)
					if !mat:IsError() and mat:GetShader() == "VertexLitGeneric" and bit.band(mat:GetInt("$flags"), 131072) == 0 then
						table.insert(self.chromeMats, {vm:GetModel(), mat})
					end
				end
			end
		else
			for k, v in pairs(self.chromeMats) do
				if v[1] == vm:GetModel() then
					v[2]:SetVector("$envmaptint", lightCol)
				else
					self.chromeMats = nil
				end
			end
		end
	end
end]]

if game.SinglePlayer() then
	net.Receive("HL1punchangle", function()
		local ply = net.ReadEntity()
		ply.punchangle = net.ReadAngle()
	end)
end
net.Receive("HL1tpAnim", function()
	local ply = net.ReadEntity()
	local anim = net.ReadInt(12)
	if IsValid(ply) and ply:IsPlayer() then
		ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, anim, true)
	end
end)

end

function HL1_DropPunchAngle(frametime, punchangle)
	local len = HL1_VectorNormalize(punchangle)
	len = len - (10 + len * 0.5) * frametime
	len = math.max( len, 0 )
	HL1_VectorScale(punchangle, len, punchangle)
end

function HL1_VectorNormalize(v)
	local length
	local ilength
	
	length = v[1]*v[1] + v[2]*v[2] + v[3]*v[3]
	length = math.sqrt(length)
	
	if length != 0 then
		ilength = 1/length
		v[1] = v[1] * ilength
		v[2] = v[2] * ilength
		v[3] = v[3] * ilength
	end

	return length
end

function HL1_VectorScale(ina, scale, out)
	out[1] = ina[1]*scale
	out[2] = ina[2]*scale
	out[3] = ina[3]*scale
end

function HL1_VectorAdd(a, b, c)
	c[1] = a[1] + b[1]
	c[2] = a[2] + b[2]
	c[3] = a[3] + b[3]
end