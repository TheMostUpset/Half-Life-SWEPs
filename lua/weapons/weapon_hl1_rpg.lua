
if CLIENT then

	SWEP.PrintName			= "RPG"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 0
	SWEP.CrosshairXY		= {24, 48}
	SWEP.WepSelectIcon		= surface.GetTextureID("hl1/icons/rpg")
	
	SWEP.ViewModelOffset = {
		PosForward = -1.25,
		PosRight = 0,
		PosUp = 0,
		
		AngForward = 0,
		AngRight = 0,
		AngUp = 0
	}

end

SWEP.Base 				= "weapon_hl1_base"
SWEP.Weight				= 20
SWEP.HoldType			= "rpg"
SWEP.TPReloadAnim		= ACT_HL2MP_GESTURE_RELOAD_SMG1

SWEP.Category			= "Half-Life"
SWEP.Spawnable			= true

SWEP.PlayerModel		= Model("models/hl1/p_rpg.mdl")
SWEP.EntModel			= Model("models/w_rpg.mdl")

SWEP.CModel				= Model("models/hl1/c_rpg.mdl")
SWEP.VModel				= Model("models/v_rpg.mdl")

SWEP.ViewModel			= SWEP.CModel
SWEP.WorldModel			= SWEP.PlayerModel

SWEP.ReloadTime			= 2
SWEP.UnloadTime			= 2
SWEP.UnloadAnimSpeed	= -.75

SWEP.NoOnRemoveCall		= true

SWEP.Primary.Sound			= Sound("weapons/rocketfire1.wav")
SWEP.Primary.Recoil			= -5
SWEP.Primary.Delay			= 1.5
SWEP.Primary.ClipSize 		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.MaxAmmo		= 5
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "RPG_Round"

SWEP.Secondary.Delay		= 1
SWEP.Secondary.Automatic	= true

function SWEP:SpecialDT()
	self:NetworkVar("Entity", 0, "RocketEntity")
	self:NetworkVar("Entity", 1, "SpotEntity")
end

function SWEP:Reload()
	if self:Clip1() >= 1 or self:rgAmmo() <= 0 then
		return
	end
	
	self:SetNextPrimaryFire(CurTime() + .5)
	
	if self:IsRocketActive() && self:IsSpotActive() then
		return
	end
	
	if self:IsSpotActive() then
		if SERVER then self:GetSpotEntity():Suspend(2.1) end
		self:SetNextSecondaryFire(CurTime() + 2.1)
	end
	
	local iResult
	
	if self:Clip1() == 0 then
		iResult = self:DefReload()
	end

	if iResult then
		self:SetWeaponIdleTime(CurTime() + math.Rand(10, 15))
	end
end

function SWEP:SpecialDeploy()
	if self:Clip1() <= 0 then
		self:SendWeaponAnim(ACT_RPG_DRAW_UNLOADED)
	end
end

function SWEP:IsSpotActive()
	local spotEnt = self:GetSpotEntity()
	return spotEnt && IsValid(spotEnt) && spotEnt.GetDrawLaser && spotEnt:GetDrawLaser()
end

function SWEP:IsRocketActive()
	local rocketEnt = self:GetRocketEntity()
	return IsValid(rocketEnt) && !rocketEnt.didHit
end

function SWEP:CanHolster()
	return !(self:IsRocketActive() && self:IsSpotActive())
end

function SWEP:SpecialHolster()
	local spotEnt = self:GetSpotEntity()
	if IsFirstTimePredicted() and IsValid(spotEnt) then
		spotEnt:SetNoDraw(true)
	end
end

function SWEP:OnRemove()
	local spotEnt = self:GetSpotEntity()
	if SERVER and IsValid(spotEnt) then
		spotEnt:Remove()
	end
end

function SWEP:OnDrop()
	self:OnRemove()
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end

	if self:Clip1() > 0 then		
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		self.Owner:SetAnimation(PLAYER_ATTACK1)
		self:WeaponSound()
		
		local ang = self.Owner:GetAimVector():Angle()
		local vecSrc = self.Owner:GetShootPos() + ang:Forward() * 16 + ang:Right() * 8 - ang:Up() * 8

		if SERVER then
			self:SetRocketEntity(ents.Create("ent_hl1_rpg_rocket"))
			local pRocket = self:GetRocketEntity()
			if IsValid(pRocket) then
				pRocket:SetPos(vecSrc)
				pRocket:SetAngles(ang)
				pRocket:Spawn()
				pRocket.pLauncher = self
				//pRocket.pLauncher.m_cActiveRockets = m_cActiveRockets + 1
				pRocket:SetOwner(self.Owner)
				pRocket:SetLocalVelocity(pRocket:GetVelocity() + self.Owner:GetForward() * self.Owner:GetVelocity():Dot(self.Owner:GetForward()))
			end
		end
		
		self:SendRecoil()
		self:TakeClipPrimary()
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		self:SetWeaponIdleTime(CurTime() + 1.5)
	else
		self:PlayEmptySound()
	end
end

function SWEP:SecondaryAttack()
	if !self:CanPrimaryAttack() then return end
	
	local spotEnt = self:GetSpotEntity()
	if !IsValid(spotEnt) then
		self:UpdateSpot()
	elseif IsFirstTimePredicted() then
		if spotEnt:GetDrawLaser() then
			spotEnt:SetDrawLaser(false)
		else
			spotEnt:SetDrawLaser(true)
			spotEnt:SetPos(self.Owner:GetEyeTrace().HitPos)
		end
	end
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
end

function SWEP:UpdateSpot()
	if !IsValid(self:GetSpotEntity()) then
		if SERVER then self:SetSpotEntity(ents.Create("ent_hl1_laser_spot")) end
		local spotEnt = self:GetSpotEntity()
		if IsValid(spotEnt) then
			spotEnt:SetPos(self.Owner:GetEyeTrace().HitPos)
			spotEnt:SetOwner(self.Owner)
			spotEnt:Spawn()
			spotEnt:SetDrawLaser(true)
		end
	end
	if SERVER and IsValid(self:GetSpotEntity()) and self:GetSpotEntity():GetDrawLaser() then
		self:GetSpotEntity():SetNoDraw(false)
		self:GetSpotEntity():SetPos(self.Owner:GetEyeTrace().HitPos)
	end
end

function SWEP:SpecialThink()
	self:UpdateSpot()
	self:ResetEmptySound()
end

function SWEP:WeaponIdle()
	local iAnim
	local flRand = util.SharedRandom("flRand", 0, 1)
	if flRand <= 0.75 || self:IsSpotActive() then
		if self:Clip1() <= 0 then
			iAnim = ACT_RPG_IDLE_UNLOADED
		else
			iAnim = ACT_VM_IDLE
		end
	else
		if self:Clip1() <= 0 then
			iAnim = ACT_RPG_FIDGET_UNLOADED
		else
			iAnim = ACT_VM_FIDGET
		end
	end
	self:SendWeaponAnim(iAnim)
	self:SetWeaponIdleTime(CurTime() + 6)
end

if SERVER then
	
	function SWEP:GetNPCBulletSpread()
		return 2
	end
	
end