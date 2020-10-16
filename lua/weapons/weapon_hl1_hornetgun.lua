
if CLIENT then

	SWEP.PrintName			= "Hivehand"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 3
	SWEP.CrosshairXY		= {72, 24}
	SWEP.WepSelectIcon		= surface.GetTextureID("hl1/icons/hgun")

end

SWEP.Base 				= "weapon_hl1_base"
SWEP.Weight				= 10
SWEP.HoldType			= "slam"

SWEP.Category			= "Half-Life"
SWEP.Spawnable			= true
SWEP.UseHands			= false

SWEP.PlayerModel		= Model("models/hl1/p_hgun.mdl")
SWEP.EntModel			= Model("models/w_hgun.mdl")

SWEP.ViewModel			= Model("models/v_hgun.mdl")
SWEP.WorldModel			= SWEP.PlayerModel

SWEP.PrimarySounds = {
	Sound("agrunt/ag_fire1.wav"),
	Sound("agrunt/ag_fire2.wav"),
	Sound("agrunt/ag_fire3.wav")
}

SWEP.Primary.Damage			= 7
SWEP.Primary.Recoil			= 0
SWEP.Primary.RecoilRandom	= {0, 2}
SWEP.Primary.Delay			= 0.25
SWEP.Primary.ClipSize 		= -1
SWEP.Primary.DefaultClip	= 8
SWEP.Primary.MaxAmmo		= 8
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "Hornet"

SWEP.Secondary.Delay		= .1
SWEP.Secondary.Automatic	= true

function SWEP:SpecialDT()
	self:NetworkVar("Int", 1, "FirePhase")
	self:NetworkVar("Float", 2, "RechargeTime")
end

function SWEP:EquipSpecial(owner)
	if IsValid(owner) and self:rgAmmo() <= 0 then
		owner:SetAmmo(1, self.Primary.Ammo)
		self:SetRechargeTime(CurTime() + 0.5)
	end
end

function SWEP:SpecialHolster()
	if self:rgAmmo() <= 0 then
		self.Owner:SetAmmo(1, self.Primary.Ammo)
	end
end

function SWEP:PrimaryAttack()
	if self:rgAmmo() <= 0 then return end
	self:SendRecoil()

	if SERVER then
		local pos = self.Owner:GetShootPos()
		local ang = self.Owner:GetAimVector():Angle()
		pos = pos + ang:Forward() * 16 + ang:Right() * 8 + ang:Up() * -12
		local pHornet = ents.Create("hornet")
		if IsValid(pHornet) then
			pHornet:SetPos(pos)
			pHornet:SetAngles(ang)
			pHornet:SetOwner(self.Owner)
			pHornet:SetVelocity(ang:Forward() * 300)
			pHornet:Spawn()
			pHornet:AddEntityRelationship(self.Owner, D_NU, 1)
			pHornet:SetSaveValue("m_flDamage", cvars.Number("hl1_sk_plr_dmg_hornet", self.Primary.Damage))
		end
	end
	
	self:SetRechargeTime(CurTime() + 0.5)
	self:TakeClipPrimary()
	self:WeaponSound()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:SetPlayerAnimation(ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self:SetWeaponIdleTime(CurTime() + math.Rand(10, 15))
end

function SWEP:SecondaryAttack()
	if self:rgAmmo() <= 0 then return end
	self:SendRecoil()
	
	local vecSrc = self.Owner:GetShootPos()
	local ang = self.Owner:GetAimVector():Angle()
	vecSrc = vecSrc + ang:Forward() * 16 + ang:Right() * 8 + ang:Up() * -12	
	
	local iFirePhase = self:GetFirePhase()
	self:SetFirePhase(iFirePhase + 1)
	if iFirePhase == 1 then
		vecSrc = vecSrc + ang:Up() * 8
	elseif iFirePhase == 2 then
		vecSrc = vecSrc + ang:Up() * 8
		vecSrc = vecSrc + ang:Right() * 8
	elseif iFirePhase == 3 then
		vecSrc = vecSrc + ang:Right() * 8
	elseif iFirePhase == 4 then
		vecSrc = vecSrc + ang:Up() * -8
		vecSrc = vecSrc + ang:Right() * 8
	elseif iFirePhase == 5 then
		vecSrc = vecSrc + ang:Up() * -8
	elseif iFirePhase == 6 then
		vecSrc = vecSrc + ang:Up() * -8
		vecSrc = vecSrc + ang:Right() * -8
	elseif iFirePhase == 7 then
		vecSrc = vecSrc + ang:Right() * -8
	elseif iFirePhase == 8 then
		vecSrc = vecSrc + ang:Up() * 8
		vecSrc = vecSrc + ang:Right() * -8
		self:SetFirePhase(1)
	end

	if SERVER then
		local pHornet = ents.Create("ent_hl1_hornet")
		if IsValid(pHornet) then
			pHornet:SetPos(vecSrc)
			pHornet:SetAngles(ang)
			pHornet:SetOwner(self.Owner)
			pHornet:SetVelocity(ang:Forward() * 1200)
			pHornet:Spawn()
		end
	end
	
	self:SetRechargeTime(CurTime() + 0.5)
	self:TakeClipPrimary()
	self:WeaponSound()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:SetPlayerAnimation(ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL)
	self:SetNextPrimaryFire(CurTime() + self.Secondary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
	self:SetWeaponIdleTime(CurTime() + math.Rand(10, 15))
end

function SWEP:SpecialThink()
	if self:Ammo1() < self.Primary.MaxAmmo and self:GetRechargeTime() < CurTime() then
		self.Owner:SetAmmo(self:Ammo1() + 1, self.Primary.Ammo)
		self:SetRechargeTime(self:GetRechargeTime() + 0.5)
	end
end

function SWEP:WeaponIdle()
	local iAnim
	local flRand = util.SharedRandom("flRand", 0, 1)
	if flRand <= 0.75 then		
		iAnim = self:LookupSequence("idle1")
		self:SetWeaponIdleTime(CurTime() + 30.0 / 16 * (2))
	elseif flRand <= 0.875 then		
		iAnim = self:LookupSequence("fidgetSway")
		self:SetWeaponIdleTime(CurTime() + 40.0 / 16.0)
	else		
		iAnim = self:LookupSequence("fidgetShake")
		self:SetWeaponIdleTime(CurTime() + 35.0 / 16.0)
	end
	self.Owner:GetViewModel():SendViewModelMatchingSequence(iAnim)
end

if SERVER then
	function SWEP:NPCShoot_Primary(ShootPos, ShootDir)
		if !IsValid(self.Owner) then return end
		self:PrimaryAttack()
		timer.Simple(self.Primary.Delay, function()
			if !IsValid(self) or !IsValid(self.Owner) then return end
			self:PrimaryAttack()
		end)
	end
end