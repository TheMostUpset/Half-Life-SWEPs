
if CLIENT then

	SWEP.PrintName			= "9mm Pistol"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 1
	SWEP.SlotPos			= 0
	SWEP.CrosshairXY		= {24, -.5}
	SWEP.WepSelectIcon		= surface.GetTextureID("hl1/icons/glock")
	SWEP.AutoIconAngle		= Angle(90, -90, 0)

end

SWEP.Base 				= "weapon_hl1_base"
SWEP.Weight				= 10
SWEP.HoldType			= "revolver"
SWEP.TPReloadAnim		= ACT_HL2MP_GESTURE_RELOAD_PISTOL

SWEP.Category			= "Half-Life"
SWEP.Spawnable			= true

SWEP.PlayerModel		= Model("models/hl1/p_9mmhandgun.mdl")
SWEP.EntModel			= Model("models/w_9mmhandgun.mdl")

SWEP.CModel				= Model("models/hl1/c_9mmhandgun.mdl")
SWEP.VModel				= Model("models/v_9mmhandgun.mdl")

SWEP.ViewModel			= SWEP.CModel
SWEP.WorldModel			= SWEP.PlayerModel

SWEP.Primary.Sound		= Sound("weapons/pl_gun3.wav")

SWEP.ReloadTime			= 1.5
SWEP.UnloadTime			= 1
SWEP.MagBone			= "Box02"
SWEP.MagTime			= 0.5

SWEP.Primary.Damage			= 8
SWEP.Primary.DamageCVar		= "hl1_sk_plr_dmg_9mm_bullet"
SWEP.Primary.Recoil			= -2.5
SWEP.Primary.Cone			= .01
SWEP.Primary.Delay			= .3
SWEP.Primary.ClipSize 		= 18
SWEP.Primary.DefaultClip	= 17
SWEP.Primary.MaxAmmo		= 250
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "9mmRound"

SWEP.Secondary.Cone			= .1
SWEP.Secondary.Delay		= .2
SWEP.Secondary.Automatic	= true

function SWEP:SecondaryAttack()
	self:GlockFire(self.Secondary.Cone, self.Secondary.Delay, false)
end

function SWEP:PrimaryAttack()
	self:GlockFire(self.Primary.Cone, self.Primary.Delay, true)
end

function SWEP:GlockFire(flSpread, flCycleTime, fUseAutoAim)
	if !self:CanPrimaryAttack() then return end
	if self:Clip1() <= 0 then
		self:PlayEmptySound()
		self:SetNextPrimaryFire(CurTime() + .2)
		return
	end
	self:SetNextPrimaryFire(CurTime() + flCycleTime)
	self:SetNextSecondaryFire(CurTime() + flCycleTime)
	self:ShootBullet(cvars.Number(self.Primary.DamageCVar, self.Primary.Damage), self.Primary.NumShots, flSpread)
	self:EjectShell(self.Owner, 0)
	self:TakeClipPrimary()
	self:HL1MuzzleFlash()
	if self:Clip1() != 0 then
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	else
		self:SendWeaponAnim(ACT_GLOCK_SHOOTEMPTY)
	end
	self:SetPlayerAnimation(ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL)
	self:SendRecoil()
	if self.Owner:IsNPC() then
		self:EmitSound("barney/ba_attack2.wav", 100)
	else
		self:WeaponSound()
	end
	if self:Clip1() <= 0 and self:rgAmmo() <= 0 then
		self:HEV_NoAmmo()
	end
	self:SetWeaponIdleTime(CurTime() + math.Rand(10, 15))
end

local cvar_extrabullet = CreateConVar("hl1_sv_glock_extrabullet", 1, {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Give one extra bullet for Glock after reloading when mag is not empty (like in early HL releases)")

function SWEP:Reload()
	local iResult
	if self:Clip1() == 0 then
		self.Primary.ClipSize = 17
		iResult = self:DefReload(ACT_GLOCK_SHOOT_RELOAD, self.ReloadTime)		
	else
		if cvar_extrabullet:GetBool() then
			self.Primary.ClipSize = 18
		else
			self.Primary.ClipSize = 17
		end
		iResult = self:DefReload(ACT_VM_RELOAD, self.ReloadTime)
	end
	if iResult then
		self:SetWeaponIdleTime(CurTime() + math.Rand(10, 15))
	end
end

function SWEP:SpecialThink()
	self:ResetEmptySound()
end

function SWEP:WeaponIdle(b)
	if self:Clip1() != 0 or b then
		local iAnim
		local flRand = util.SharedRandom("flRand", 0, 1)
		if (flRand <= 0.3 + 0 * 0.75) then		
			iAnim = self:LookupSequence("idle3")
			self:SetWeaponIdleTime(CurTime() + 49.0 / 16)		
		elseif (flRand <= 0.6 + 0 * 0.875) then		
			iAnim = self:LookupSequence("idle1")
			self:SetWeaponIdleTime(CurTime() + 60.0 / 16.0)		
		else		
			iAnim = self:LookupSequence("idle2")
			self:SetWeaponIdleTime(CurTime() + 40.0 / 16.0)
		end
		self.Owner:GetViewModel():SendViewModelMatchingSequence(iAnim)
	end
end

if SERVER then
	
	function SWEP:GetNPCBulletSpread()
		return 3
	end
	
end