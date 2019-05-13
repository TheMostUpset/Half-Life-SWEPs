
if CLIENT then

	SWEP.PrintName			= "MP5"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 2
	SWEP.SlotPos			= 0
	SWEP.CrosshairXY		= {0, 48}
	SWEP.WepSelectIcon		= surface.GetTextureID("hl1/icons/mp5")

end

SWEP.Base 				= "weapon_hl1_base"
SWEP.Weight				= 15
SWEP.HoldType			= "ar2"

SWEP.Category			= "Half-Life"
SWEP.Spawnable			= true

SWEP.PlayerModel		= Model("models/hl1/p_9mmAR.mdl")
SWEP.EntModel			= Model("models/w_9mmAR.mdl")

SWEP.CModel				= Model("models/hl1/c_9mmAR.mdl")
SWEP.VModel				= Model("models/v_9mmAR.mdl")

SWEP.ViewModel			= SWEP.CModel
SWEP.WorldModel			= SWEP.PlayerModel

SWEP.PrimarySounds = {
	Sound("weapons/hks1.wav"),
	Sound("weapons/hks2.wav"),
	Sound("weapons/hks3.wav")
}

SWEP.ReloadTime = 1.5
SWEP.UnloadTime = .7

SWEP.Primary.Damage			= 5
SWEP.Primary.DamageCVar		= "hl1_sk_plr_dmg_mp5_bullet"
SWEP.Primary.Recoil			= 0
SWEP.Primary.RecoilRandom	= {-2, 2}
SWEP.Primary.Cone			= 0.05234
SWEP.Primary.Delay			= 0.1
SWEP.Primary.ClipSize 		= 50
SWEP.Primary.DefaultClip	= 25
SWEP.Primary.MaxAmmo		= 250
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "9mmRound"

SWEP.SecondarySounds = {
	Sound("weapons/glauncher.wav"),
	Sound("weapons/glauncher2.wav")
}
SWEP.Secondary.Recoil		= -10
SWEP.Secondary.Delay		= 1
SWEP.Secondary.DefaultClip	= 2
SWEP.Secondary.MaxAmmo		= 10
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "MP5_Grenade"

SWEP.MuzzleEffect			= "hl1_mflash_mp5"
SWEP.MuzzleSmoke			= false
SWEP.MuzzlePos				= Vector(15,1,7)

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	
	if self:Clip1() <= 0 or self.Owner:WaterLevel() == 3 then
		self:PlayEmptySound()
		self:SetNextPrimaryFire(CurTime() + 0.15)
		return
	end

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	if self:IsMultiplayerRules() then
		self.Primary.Cone = 0.02618
	else
		self.Primary.Cone = 0.05234
	end
	self:ShootBullet(cvars.Number(self.Primary.DamageCVar, self.Primary.Damage), self.Primary.NumShots, self.Primary.Cone)
	self:EjectShell(self.Owner, 0)
	self:WeaponSound()
	self:TakeClipPrimary()
	self:HL1MuzzleFlash()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:SendRecoil()
	self:SetWeaponIdleTime(CurTime() + math.Rand(10, 15))
end

function SWEP:SecondaryAttack()
	if !self:CanPrimaryAttack() then return end

	if self.Owner:WaterLevel() == 3 then
		self:PlayEmptySound()
		self:SetNextPrimaryFire(CurTime() + 0.15)
		return
	end
	if self:Ammo2() <= 0 then
		self:PlayEmptySound()
		return
	end
	self:SetNextPrimaryFire(CurTime() + self.Secondary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
	self:WeaponSound(self.SecondarySounds[math.random(1, 2)])
	self:TakeClipSecondary()
	self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	self:SetPlayerAnimation(ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW)
	self:SendRecoil(1)
	self:SetWeaponIdleTime(CurTime() + 5)
	
	if SERVER then
		local pos = self.Owner:GetShootPos()
		local ang = self.Owner:GetAimVector():Angle()
		pos = pos + ang:Forward() * 16
		local ent = ents.Create("ent_hl1_cgrenade")
		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:SetOwner(self.Owner)
		ent:Spawn()
		ent:Activate()
		local vel = ang:Forward() * 800
		ent:SetVelocity(vel)
		ent:SetLocalAngularVelocity(Angle(-math.Rand(-100, -500), 0, 0))
	end
end

function SWEP:SpecialThink()
	self:ResetEmptySound()
end

function SWEP:WeaponIdle()
	local iAnim
	if IsFirstTimePredicted() then
		self.flRand = math.random(0, 1)
	end
	local flRand = self.flRand
	if flRand == 0 then		
		iAnim = self:LookupSequence("longidle")
	else
		iAnim = self:LookupSequence("idle1")
	end
	self.Owner:GetViewModel():SendViewModelMatchingSequence(iAnim)
	self:SetWeaponIdleTime(CurTime() + math.Rand(10, 15))
end

if SERVER then
	function SWEP:NPCShoot_Primary(ShootPos, ShootDir)
		if !IsValid(self.Owner) then return end
		self:PrimaryAttack()
		timer.Create("HL1_MP5_NPCPrimaryAttack"..self.Owner:EntIndex(), self.Primary.Delay, 2, function()
			if !IsValid(self) or !IsValid(self.Owner) then return end
			self:PrimaryAttack()
		end)
	end
end