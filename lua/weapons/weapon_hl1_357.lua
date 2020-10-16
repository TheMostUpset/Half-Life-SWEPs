
if CLIENT then

	SWEP.PrintName			= ".357 Magnum"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 1
	SWEP.SlotPos			= 1
	SWEP.CrosshairXY		= {48, -.5}
	SWEP.WepSelectIcon		= surface.GetTextureID("hl1/icons/357")

end

SWEP.Base 				= "weapon_hl1_base"
SWEP.Weight				= 15
SWEP.HoldType			= "pistol"
SWEP.TPReloadAnim		= ACT_HL2MP_GESTURE_RELOAD_REVOLVER

SWEP.Category			= "Half-Life"
SWEP.Spawnable			= true

SWEP.PlayerModel		= Model("models/hl1/p_357.mdl")
SWEP.EntModel			= Model("models/w_357.mdl")

SWEP.CModel				= Model("models/hl1/c_357.mdl")
SWEP.VModel				= Model("models/v_357.mdl")

SWEP.ViewModel			= SWEP.CModel
SWEP.WorldModel			= SWEP.PlayerModel

SWEP.PrimarySounds = {
	Sound("weapons/357_shot1.wav"),
	Sound("weapons/357_shot2.wav")	
}

SWEP.ReloadTime = 2

SWEP.Primary.Damage			= 40
SWEP.Primary.DamageCVar		= "hl1_sk_plr_dmg_357_bullet"
SWEP.Primary.Recoil			= -10
SWEP.Primary.Cone			= .01
SWEP.Primary.Delay			= 0.75
SWEP.Primary.ClipSize 		= 6
SWEP.Primary.DefaultClip	= 6
SWEP.Primary.MaxAmmo		= 36
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "357"

SWEP.Secondary.Delay		= .5
SWEP.Secondary.Automatic	= true

SWEP.MuzzleScale			= 3.5
SWEP.MuzzleSmoke			= false

function SWEP:SpecialDeploy()
	local owner = self:GetOwner()
	if IsValid(owner) and owner:IsPlayer() then
		local vm = owner:GetViewModel()
		if owner:Alive() and IsValid(vm) and self:IsMultiplayerRules() then
			local bodygr = vm:FindBodygroupByName("scope")
			vm:SetBodygroup(bodygr, 1)
		end
	end
end

function SWEP:SpecialHolster()	
	if self:GetInZoom() then
		self:SecondaryAttack()
	end
end

function SWEP:OnRemove()
	local owner = self:GetOwner()
	if IsValid(owner) and owner:IsPlayer() then
		local vm = owner:GetViewModel()
		if IsValid(vm) then
			local bodygr = vm:FindBodygroupByName("scope")
			if vm:GetBodygroup(bodygr) != 0 then
				vm:SetBodygroup(bodygr, 0)
			end
		end
	end
end

function SWEP:SecondaryAttack()
	if self:GetInZoom() then
		self:SetInZoom(false)
		self.Owner:SetCanZoom(true)
		self.Owner:SetFOV(0, 0)
	elseif self:IsMultiplayerRules() then
		self:SetInZoom(true)
		self.Owner:SetCanZoom(false)
		self.Owner:SetFOV(40, 0)		
	end		
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
end

function SWEP:Reload()
	if self:Clip1() >= self.Primary.ClipSize or self:rgAmmo() <= 0 then --compare to HL1
		return
	end

	if self:GetInZoom() then
		self:SetInZoom(false)
		self.Owner:SetCanZoom(true)
		self.Owner:SetFOV(0, 0)
	end

	self:DefReload()
end

function SWEP:WeaponIdle()
	local iAnim
	local flRand = util.SharedRandom("flRand", 0, 1)
	if flRand <= 0.5 then		
		iAnim = self:LookupSequence("idle1")
		self:SetWeaponIdleTime(CurTime() + 70.0/30.0)
	elseif flRand <= 0.7 then		
		iAnim = self:LookupSequence("idle2")
		self:SetWeaponIdleTime(CurTime() + 60.0/30.0)
	elseif flRand <= 0.9 then
		iAnim = self:LookupSequence("idle3")
		self:SetWeaponIdleTime(CurTime() + 88.0/30.0)
	else		
		iAnim = self:LookupSequence("fidget1")
		self:SetWeaponIdleTime(CurTime() + 170.0/30.0)
	end
	self.Owner:GetViewModel():SendViewModelMatchingSequence(iAnim)
end

if SERVER then
	
	function SWEP:GetNPCBulletSpread()
		return 2
	end
	
end