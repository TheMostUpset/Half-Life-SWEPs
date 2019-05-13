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
	for k, v in pairs(dmgCvars) do
		CreateConVar(v[1], v[2], {FCVAR_NOTIFY, FCVAR_ARCHIVE})
	end
	CreateConVar("hl1_sv_itemrespawntime", 23, FCVAR_NOTIFY, "Respawn time for items in Deathmatch")
	CreateConVar("hl1_sv_mprules", 0, FCVAR_NOTIFY, "Deathmatch rules in singleplayer")
	CreateConVar("hl1_sv_loadout", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Players spawn with HL weapons")
	CreateConVar("hl1_sv_gauss_tracebackwards", 1, FCVAR_NOTIFY, "")
	
	hook.Add("PlayerLoadout", "HL1Loadout", function(ply)
		if cvars.Bool("hl1_sv_loadout") then
			ply:Give("weapon_hl1_glock")
			ply:Give("weapon_hl1_crowbar")
			ply:SetAmmo(68, "9mmRound")
		end
	end)	
	
	if game.SinglePlayer() then
		util.AddNetworkString("HL1punchangle")
	end
	util.AddNetworkString("HL1tpAnim")
	
	concommand.Add("hl1_impulse101", function(ply, cmd, args)

		if ply and IsValid(ply) and (!ply:IsSuperAdmin() or !ply:Alive()) then return end
		
		if args[1] then
			for k, v in pairs(player.GetAll()) do
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
	killicon.Add("hornet", "hl1/icons/hgun", killiconCol)
	killicon.Add("ent_hl1_hornet", "hl1/icons/hgun", killiconCol)
	killicon.Add("ent_hl1_rpg_rocket", "hl1/icons/rpg", killiconCol)
	killicon.Add("ent_hl1_cgrenade", "hl1/icons/grenade", killiconCol)
	killicon.Add("ent_hl1_grenade", "hl1/icons/grenade", killiconCol)
	killicon.Add("monster_tripmine", "hl1/icons/tripmine", killiconCol)
	killicon.Add("monster_satchel", "hl1/icons/satchel", killiconCol)
	killicon.Add("monster_snark", "hl1/icons/snark", killiconCol)
	
	CreateClientConVar("hl1_cl_firelight", 1, true, false, "Muzzleflash and explosion dynamic light")
	
end

local cvar_cmodels = CreateConVar("hl1_sv_cmodels", 1, {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Enable c_ models for HL weapons")
SetGlobalBool("hl1_sv_cmodels", cvar_cmodels:GetBool())
cvars.AddChangeCallback("hl1_sv_cmodels", function(name, value_old, value_new)
	local b = tobool(value_new)
	SetGlobalBool("hl1_sv_cmodels", b)
end)

CreateConVar("hl1_sv_clampammo", 0, {FCVAR_NOTIFY, FCVAR_REPLICATED}, "Enable max ammo limit for HL weapons")
CreateConVar("hl1_sv_unlimitedclip", 0, {FCVAR_NOTIFY, FCVAR_REPLICATED}, "Unlimited clip for HL weapons")
CreateConVar("hl1_sv_unlimitedammo", 0, {FCVAR_NOTIFY, FCVAR_REPLICATED}, "Unlimited ammo for HL weapons")

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

SWEP.DrySound				= Sound("weapons/357_cock1.wav")

SWEP.MuzzleEffect			= "hl1_mflash"
SWEP.MuzzleScale			= 1
SWEP.MuzzleSmoke			= false
SWEP.MuzzlePos				= Vector(9, 0, 4) -- thirdperson muzzle position

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

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "iPlayEmptySound")
	self:NetworkVar("Bool", 1, "InZoom")
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

function SWEP:Initialize()
	if !self:GetOwner() or !IsValid(self:GetOwner()) then
		if self.EntModel then
			self.WorldModel = self.EntModel
			self:SetModel(self.WorldModel)
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
	
	-- detecting weapon drop by HLS NPCs
	local owner = self:GetOwner()
	if IsValid(owner) and owner:IsNPC() and !IsValid(owner:GetActiveWeapon()) then
		self:SetModelScale(1.25)
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:AddVelocity(owner:GetForward() * math.Rand(10, 100) + owner:GetUp() * math.Rand(20, 150))
			--phys:SetVelocity(Vector(math.Rand(-100, 100), math.Rand(-100, 100), math.Rand(200, 300)))
			--phys:AddAngleVelocity(Vector(0, math.Rand(200, 400), 0))
		end
	end
	
	self:SetHoldType(self.HoldType)
	self:SpecialInit()
	self:ApplyViewModel()
end
	
function SWEP:ApplyViewModel()
	if GetGlobalBool("hl1_sv_cmodels", true) then
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
end

function SWEP:SetPlayerWorldModel()
	if self.PlayerModel and self.WorldModel != self.PlayerModel then
		self.WorldModel = self.PlayerModel
	end
end

function SWEP:Equip(ply)
	if IsValid(self.Owner) and self.Owner:IsPlayer() then
		self:CallOnClient("SetPlayerWorldModel")
	end
	
	local ammotypeP = self:GetPrimaryAmmoType()
	local ammotypeS = self:GetSecondaryAmmoType()
	if IsValid(ply) and ply:IsPlayer() and (cvars.Bool("hl1_sv_clampammo") or ammotypeP == game.GetAmmoID("hornet")) then
		if self.Primary.MaxAmmo and ply:GetAmmoCount(ammotypeP) > self.Primary.MaxAmmo then
			ply:SetAmmo(self.Primary.MaxAmmo, ammotypeP)
		end
		if self.Secondary.MaxAmmo and ply:GetAmmoCount(ammotypeS) > self.Secondary.MaxAmmo then
			ply:SetAmmo(self.Secondary.MaxAmmo, ammotypeS)
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
end

function SWEP:SpecialInit()
end

function SWEP:Deploy()
	--self:ApplyViewModel()
	if IsValid(self.Owner) then
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
	return true
end

function SWEP:SpecialDeploy()
end

function SWEP:Holster(wep)
	if CLIENT and IsValid(self.Owner) and self.Owner != LocalPlayer() then return end
	
	if self == wep then
		return
	end
	self:SetReloadTime(0)
	self:SpecialHolster()
	self:OnRemove()
	return true
end

function SWEP:OnRemove()
end

function SWEP:SpecialHolster()
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
	if cvars.Bool("hl1_sv_unlimitedammo") or self.Owner:IsNPC() then
		return 99
	else
		return self:Ammo1()
	end
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
		if !cvars.Bool("hl1_sv_unlimitedclip") then
			self:TakePrimaryAmmo(num)
		end
	else
		if !cvars.Bool("hl1_sv_unlimitedammo") then
			self:TakePrimaryAmmo(num)
		end
	end
end

function SWEP:TakeClipSecondary(num)
	num = num or 1
	if cvars.Bool("hl1_sv_unlimitedammo") then return end
	self:TakeSecondaryAmmo(num)
end

function SWEP:CanDeploy()
	return true
end

function SWEP:CanHolster()
	return true
end

function SWEP:GetNextBestWeapon(pPlayer, pCurrentWeapon)
	local iBestWeight = -1
	local pBest = NULL
	
	if !pCurrentWeapon:CanHolster() then
		// can't put this gun away right now, so can't switch.
		return false
	end
	
	for _, pCheck in ipairs(pPlayer:GetWeapons()) do
		if IsValid(pCheck) and pCheck:IsScripted() and pCheck.Base == "weapon_hl1_base" then
			print(pCheck, pCheck.Weight)
			if pCheck.Weight > -1 && pCheck.Weight == pCurrentWeapon.Weight && pCheck != pCurrentWeapon then
				// this weapon is from the same category. 
				if pCheck:CanDeploy() then
					//if pPlayer->SwitchWeapon( pCheck ) then
						//return true
					//end
				end
			elseif pCheck.Weight > iBestWeight && pCheck != pCurrentWeapon then // don't reselect the weapon we're trying to get rid of
				if pCheck:CanDeploy() then
					// if this weapon is useable, flag it as the best
					iBestWeight = pCheck.Weight
					pBest = pCheck
					//break
				end
			end
		end
	end

	if !pBest then
		return false
	end
	
	self.Owner:SelectWeapon(pBest:GetClass())
	
	return true
end

function SWEP:RetireWeapon()
	-- this should work only in MP
	//self:GetNextBestWeapon(self.Owner, self)
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
	self:SetReloadTime(CurTime() + fDelay)
	self:SendWeaponAnim(anim)
	if self.TPReloadAnim then
		self:SetPlayerAnimation(self.TPReloadAnim)
	else
		self.Owner:SetAnimation(PLAYER_RELOAD)
	end
	self:EmitSound(self.ReloadSound)
	self:SetWeaponIdleTime(CurTime() + 3)
	return true
end

function SWEP:Unload()
	if self.UnloadTime and self:Clip1() > 0 then
		self:SendWeaponAnim(ACT_VM_IDLE)
		self.AutoReload = false
		self:SetWeaponIdleTime(0)
		self:SendWeaponAnim(ACT_VM_RELOAD)
		self:SetUnloadTime(CurTime() + self.UnloadTime)
	end
end

function SWEP:WeaponSound(snd, lvl, pitch)
	snd = snd or self.Primary.Sound or self.PrimarySounds[math.random(1, #self.PrimarySounds)]
	lvl = lvl or 100
	pitch = pitch or 100
	self:EmitSound(snd, lvl, pitch, 1)
	if lvl >= 100 then
		self:InsertSound(1, self.Owner:GetShootPos(), 600, 3)
	end
end

function SWEP:DoRicochetSound(pos)
	if (!game.SinglePlayer() and CLIENT and IsFirstTimePredicted()) or game.SinglePlayer() then
		sound.Play(self.RicochetSounds[math.random(1, 5)], pos, 80)
	end
end

function SWEP:ShootBullet(damage, num_bullets, aimcone)
	aimcone = isvector(aimcone) and aimcone or Vector(aimcone, aimcone, 0)
	local punchangle = self.Owner.punchangle and Angle(self.Owner.punchangle[1], 0, 0) or Angle()
	local ang = self.Owner:EyeAngles() + punchangle

	local bullet = {}
	bullet.Num 		= num_bullets
	bullet.Src 		= self.Owner:GetShootPos()
	bullet.Dir 		= ang:Forward()
	bullet.Spread 	= aimcone
	bullet.Tracer	= 3
	bullet.Force	= 4
	bullet.Damage	= damage
	bullet.AmmoType = "Pistol"
	
	self.Owner:FireBullets(bullet)
end

function SWEP:SendRecoil(angle)
	if !self.GoldSrcRecoil or self.Owner:IsNPC() then return end
	if angle == 1 then angle = Angle(self.Secondary.Recoil + math.Rand(self.Secondary.RecoilRandom[1], self.Secondary.RecoilRandom[2]), 0, 0) end
	angle = angle or Angle(self.Primary.Recoil + math.Rand(self.Primary.RecoilRandom[1], self.Primary.RecoilRandom[2]), 0, 0)
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

function SWEP:EjectShell(ent, iType)
	iType = iType == 1 and "ShotgunShellEject" or "ShellEject"
	
	if !IsFirstTimePredicted() then return end

	local angShellAngles = ent:EyeAngles()
	
	local vecForward, vecRight, vecUp = angShellAngles:Forward(), angShellAngles:Right(), angShellAngles:Up()
	angShellAngles:RotateAroundAxis(vecUp, -60)
	
	local vecShellPosition = ent:GetShootPos()
	
	if iType == 0 then
		vecShellPosition = vecShellPosition + vecRight * 4
		vecShellPosition = vecShellPosition + vecUp * -12;
		vecShellPosition = vecShellPosition + vecForward * 20;
	else
		vecShellPosition = vecShellPosition + vecRight * 6;
		vecShellPosition = vecShellPosition + vecUp * -12;
		vecShellPosition = vecShellPosition + vecForward * 32;
	end
	
	local vecShellVelocity = ent:GetAbsVelocity()
	vecShellVelocity = vecShellVelocity + vecRight * math.Rand( 50, 70 );
	vecShellVelocity = vecShellVelocity + vecUp * math.Rand( 100, 150 );
	vecShellVelocity = vecShellVelocity + vecForward * 25;

	angShellAngles.x = 0;
	angShellAngles.z = 0;

	local data = EffectData()
	data:SetStart(vecShellVelocity)
	data:SetOrigin(vecShellPosition)
	data:SetAngles(angShellAngles)
	util.Effect(iType, data)
end

function SWEP:HL1MuzzleFlash()
	self.Owner:MuzzleFlash()
	if !IsFirstTimePredicted() or !IsValid(self.Owner) or self.Owner:WaterLevel() >= 3 then return end
	local fx = EffectData()
	fx:SetEntity(self)
	fx:SetOrigin(self.Owner:GetShootPos())
	fx:SetNormal(self.Owner:GetAimVector())
	fx:SetStart(self.MuzzlePos)
	fx:SetAttachment(1)
	fx:SetScale(self.MuzzleScale)
	util.Effect(self.MuzzleEffect, fx)
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
		if reload <= CurTime() then
			self:SetReloadTime(0)
			if cvars.Bool("hl1_sv_unlimitedammo") then
				self:SetClip1(self.Primary.ClipSize)
			else
				local clip = self:Clip1()
				self:SetClip1(math.min((self:Ammo1() + clip), self.Primary.ClipSize))
				self.Owner:RemoveAmmo(self.Primary.ClipSize - clip, self.Primary.Ammo)
			end
		else
			return
		end
	end
	
	if self.AutoReload and IsValid(self.Owner) and self.Owner:Alive() and self:Clip1() <= 0 and self:rgAmmo() > 0 and self:GetNextPrimaryFire() <= CurTime() and self.Primary.ClipSize > 0 then
		self:Reload()
	end
	
	local unload = self:GetUnloadTime()
	if unload > 0 and unload <= CurTime() then
		self.AutoReload = false
		local clip = self:Clip1()
		self:SetClip1(0)
		if SERVER then self.Owner:GiveAmmo(clip, self.Primary.Ammo, true) end
		self:SetUnloadTime(0)
		self:WeaponIdle(true)
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
local cvar_fixchrome = CreateClientConVar("hl1_cl_fixchrome", 1, true, false, "Fix chrome envmap lighting")
local cvar_hl2bob = CreateClientConVar("hl1_cl_hl2bob", 0, true, false, "Default HL2 (HL:S) bobbing")
local cvar_vmfov = CreateClientConVar("hl1_cl_viewmodelfov", 90, true, false, "Viewmodel FOV for HL weapons")

function SWEP:AdjustMouseSensitivity()
	if self:GetInZoom() then
		return self.Owner:GetFOV() / 80
	end
end

function SWEP:DrawWorldModel()
	if !IsValid(self.Owner) then
		if self.EntModel then
			self:SetModel(self.WorldModel)
		end
		self:DrawModel()
		return
	elseif self.PlayerModel and self.WorldModel != self.PlayerModel then
		self.WorldModel = self.PlayerModel
	end
	self:DrawModel()
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

function SWEP:CalcView(ply, pos, ang, fov)
	local punchangle = ply.punchangle
	if punchangle then
		ang[1] = ang[1] + punchangle[1]
		HL1_DropPunchAngle(FrameTime(), punchangle)
	end
	
	if !cvar_hl2bob:GetBool() and ply:IsValid() and ply:Alive() and !ply:InVehicle() and !ply:ShouldDrawLocalPlayer() then

		//calcroll
		
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
		
		local bob
		if cvar_bob_won:GetBool() then
			bob = self:CalcBobWON()
		else
			bob = self:CalcBob()
		end
		
		if cvar_viewbob:GetBool() then
			pos[3] = pos[3] + bob
		end
		ang.r = ang.r + side * sign
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
	
	local bob
	if cvar_bob_won:GetBool() then
		bob = self:CalcBobWON()
	else
		bob = self:CalcBob()
	end
	
	oldPos = oldPos + oldAng:Forward() * self.ViewModelOffset.PosForward + oldAng:Right() * self.ViewModelOffset.PosRight + oldAng:Up() * self.ViewModelOffset.PosUp
	oldAng:RotateAroundAxis(oldAng:Forward(), self.ViewModelOffset.AngForward)
	oldAng:RotateAroundAxis(oldAng:Right(), self.ViewModelOffset.AngRight)
	oldAng:RotateAroundAxis(oldAng:Up(), self.ViewModelOffset.AngUp)
	
	oldPos = oldPos + oldAng:Forward() * bob * .4 - Vector(0, 0, 1)
	if cvar_viewbob:GetBool() then
		oldPos[3] = oldPos[3] + bob
	end

	if cvar_bob_won:GetBool() then
		oldAng.p = oldAng.p - bob * 0.3
		oldAng.y = oldAng.y - bob * 0.5
		oldAng.r = oldAng.r - bob * 1.0
	end
	
	if self.HideWhenEmpty and self:rgAmmo() <= 0 then -- hide when no ammo left
		oldPos = self:ViewModelHide(oldPos, oldAng, vm)
	end
	
	self:SetViewModelFOV(cvar_vmfov:GetInt())

	return oldPos, oldAng
end

function SWEP:ViewModelHide(pos, ang)
	return pos - ang:Forward() * 40
end

function SWEP:SetViewModelFOV(fov)
	fov = fov or cvar_vmfov:GetInt() or 90
	self.ViewModelFOV = fov
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
	surface.SetDrawColor(255, 180, 0, 255)
	surface.SetTexture(crosshairs)
	
	local scale = cvar_chair:GetFloat()

	local w, h = self.CrosshairWH[1] * scale, self.CrosshairWH[2] * scale
	local tx, ty = self.CrosshairXY[1], self.CrosshairXY[2]
	local txsizew, txsizeh = surface.GetTextureSize(crosshairs)
	
	x, y = x - w / 2 + scale / 2, y - h / 2 + scale / 2 + 1
	
	local tr = self.Owner:GetEyeTraceNoCursor()	
	if (self.Owner == LocalPlayer() && self.Owner:ShouldDrawLocalPlayer()) then
		local coords = tr.HitPos:ToScreen()
		x, y = coords.x - 10, coords.y - 10
	end

	surface.DrawTexturedRectUV(x, y, w, h, tx / txsizew, ty / txsizeh, (tx+self.CrosshairWH[1]) / txsizew, (ty+self.CrosshairWH[2]) / txsizeh)
	return true
end

function SWEP:PostDrawViewModel(vm, wep, ply)
	if cvar_fixchrome:GetBool() then
		local lightCol = render.GetLightColor(vm:GetPos() + Vector(0,0,2))
		if render.GetToneMappingScaleLinear()[1] != 1 then -- checking for HDR
			lightCol = (lightCol[1] + lightCol[2] + lightCol[3]) / 3
			lightCol = lightCol / 2 + .02
			lightCol = math.min(lightCol, .3)
			lightCol = Vector(lightCol, lightCol, lightCol)
		else
			lightCol = lightCol * 2
		end

		if !self.chromeMats then
			self.chromeMats = {}
			for k, v in pairs(vm:GetMaterials()) do
				if string.find(v, "chrome") then
					local mat = Material(v)
					if !mat:IsError() and mat:GetShader() == "VertexLitGeneric" then
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
end

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
		v[2] = v[1] * ilength -- actually should be v[2]
		v[3] = v[1] * ilength -- and v[3], but currently it looks even better
	end

	return length
end

function HL1_VectorScale(ina, scale, out)
	out[1] = ina[1]*scale
	out[2] = ina[2]*scale
	out[3] = ina[3]*scale
end