
if CLIENT then

	SWEP.PrintName			= "Hand Grenade"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 4
	SWEP.SlotPos			= 0
	SWEP.WepSelectIcon		= surface.GetTextureID("hl1/icons/grenade")

end

SWEP.Base 				= "weapon_hl1_base"
SWEP.Weight				= 5
SWEP.HoldType			= "grenade"

SWEP.Category			= "Half-Life"
SWEP.Spawnable			= true

SWEP.PlayerModel		= Model("models/hl1/p_grenade.mdl")
SWEP.EntModel			= Model("models/w_grenade.mdl")

SWEP.CModel				= Model("models/hl1/c_grenade.mdl")
SWEP.VModel				= Model("models/v_grenade.mdl")

SWEP.ViewModel			= SWEP.CModel
SWEP.WorldModel			= SWEP.PlayerModel

SWEP.IsThrowable		= true -- used for hl coop
SWEP.ThrowEntity		= "ent_hl1_grenade"

SWEP.Primary.Damage			= 40
SWEP.Primary.Delay			= 0.5
SWEP.Primary.ClipSize 		= -1
SWEP.Primary.DefaultClip	= 5
SWEP.Primary.MaxAmmo		= 10
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "Grenade"

SWEP.Secondary.Delay		= .1
SWEP.Secondary.Automatic	= true

function SWEP:SpecialDT()
	self:NetworkVar("Float", 2, "StartThrow")
	-- self:NetworkVar("Float", 3, "ReleaseThrow")
end

--[[function SWEP:SpecialDeploy()
	self:SetReleaseThrow(-1)
end]]

--[[function SWEP:CanHolster()
	return self:GetStartThrow() == 0
end]]

function SWEP:SpecialHolster()
	if SERVER and self:rgAmmo() <= 0 then
		// no more grenades!
		self.Owner:StripWeapon(self:GetClass())
	end
end

function SWEP:PrimaryAttack()
	if self:GetStartThrow() <= 0 && self:rgAmmo() > 0 then
		self:SetStartThrow(CurTime())
		-- self:SetReleaseThrow(0)

		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		self:SetWeaponIdleTime(CurTime() + 0.5)
	end
end

--[[function SWEP:SpecialThink()
	if self:GetReleaseThrow() == 0 && self:GetStartThrow() > 0 then
		self:SetReleaseThrow(CurTime())
	end
end]]--

function SWEP:WeaponIdle()
	if self.Owner:KeyDown(IN_ATTACK) then return end
	if self:GetStartThrow() > 0 then
		local angThrow = self.Owner:EyeAngles() + self.Owner:GetViewPunchAngles()
		
		if angThrow.x < 0 then
			angThrow.x = -10 + angThrow.x * ( ( 90 - 10 ) / 90.0 )
		else
			angThrow.x = -10 + angThrow.x * ( ( 90 + 10 ) / 90.0 )
		end
		
		local flVel = ( 90 - angThrow.x ) * 4
		if flVel > 500 then
			flVel = 500
		end
		
		local vecSrc = self.Owner:GetShootPos() + angThrow:Forward() * 16
	
		local vecThrow = angThrow:Forward() * flVel + self.Owner:GetVelocity()
		
		// alway explode 3 seconds after the pin was pulled
		local flTime = self:GetStartThrow() - CurTime() + 3.0
		if flTime < 0 then
			flTime = 0
		end

		if SERVER then
			local pGrenade = ents.Create(self.ThrowEntity)
			if IsValid(pGrenade) then
				pGrenade:SetPos(vecSrc)
				pGrenade:SetAngles(vecThrow:Angle())// - Angle(90,0,0))
				pGrenade:Spawn()
				pGrenade:ShootTimed(self.Owner, vecThrow, flTime)
			end
		end
		
		if flVel < 500 then		
			self:SendWeaponAnim(ACT_HANDGRENADE_THROW1)	
		elseif flVel < 1000 then		
			self:SendWeaponAnim(ACT_HANDGRENADE_THROW2)		
		else		
			self:SendWeaponAnim(ACT_HANDGRENADE_THROW3)
		end

		// player "shoot" animation
		self.Owner:SetAnimation(PLAYER_ATTACK1)

		-- self:SetReleaseThrow(0)
		self:SetStartThrow(0)
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		self:SetWeaponIdleTime(CurTime() + self.Primary.Delay)

		self:TakeClipPrimary()
		return
	--[[elseif self:GetReleaseThrow() > 0 then
		// we've finished the throw, restart.
		self:SetStartThrow(0)
		
		if self:rgAmmo() > 0 then
			self:SendWeaponAnim(ACT_VM_DRAW)
		else
			self:RetireWeapon()
			return
		end
		
		self:SetWeaponIdleTime(CurTime() + math.Rand(10, 15))
		self:SetReleaseThrow(-1)
		return]]
	end
	
	if self:rgAmmo() > 0 then
		local iAnim
		local flRand = util.SharedRandom("flRand", 0, 1)
		if flRand <= 0.75 then		
			iAnim = ACT_VM_IDLE
			self:SetWeaponIdleTime(CurTime() + math.Rand(10, 15))
		else		
			iAnim = ACT_VM_FIDGET
			self:SetWeaponIdleTime(CurTime() + 75.0 / 30.0)
		end
		self:SendWeaponAnim(iAnim)
	else
		self:RetireWeapon()
	end
end