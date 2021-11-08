
if CLIENT then

	SWEP.PrintName			= "Snarks"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 4
	SWEP.SlotPos			= 3
	SWEP.HideWhenEmpty		= true
	SWEP.WepSelectIcon		= surface.GetTextureID("hl1/icons/snark")
	SWEP.WorldModelSequence = 1

end

SWEP.Base 				= "weapon_hl1_base"
SWEP.Weight				= 5
SWEP.HoldType			= "slam"

SWEP.Category			= "Half-Life"
SWEP.Spawnable			= true

SWEP.PlayerModel		= Model("models/hl1/p_squeak.mdl")
SWEP.EntModel			= Model("models/w_sqknest.mdl")

SWEP.CModel				= Model("models/weapons/c_hl_squeak.mdl")
SWEP.VModel				= Model("models/v_squeak.mdl")

SWEP.ViewModel			= SWEP.CModel
SWEP.WorldModel			= SWEP.PlayerModel

SWEP.IsThrowable		= true
SWEP.ThrowEntity		= "monster_snark"

SWEP.HuntSounds = {
	Sound("squeek/sqk_hunt2.wav"),
	Sound("squeek/sqk_hunt3.wav")
}

SWEP.Primary.Delay			= 0.3
SWEP.Primary.ClipSize 		= -1
SWEP.Primary.DefaultClip	= 5
SWEP.Primary.MaxAmmo		= 15
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "Snark"

function SWEP:SpecialDeploy()
	self:EmitSound(self.HuntSounds[math.random(1,2)])
end

function SWEP:SpecialHolster()
	if SERVER and self:rgAmmo() <= 0 then
		self.Owner:StripWeapon(self:GetClass())
		return
	end
end

function SWEP:PrimaryAttack()
	if self:rgAmmo() > 0 then
		local trace_origin = self.Owner:WorldSpaceCenter()
		local ang = self.Owner:GetAimVector():Angle()
		if self.Owner:Crouching() then
			trace_origin = trace_origin - ( Vector(-16, -16, -24) - Vector(-16, -16, -18 ) )
		end
		local entFilter = self:TraceFilter()
		local tr = util.TraceHull({
			start = trace_origin + ang:Forward() * 20,
			endpos = trace_origin + ang:Forward() * 64,
			filter = entFilter,
			mins = Vector(-4, -4, 0),
			maxs = Vector(4, 4, 8)
		})
		
		if !tr.AllSolid && !tr.StartSolid && tr.Fraction > 0.25 then
			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
			self.Owner:SetAnimation(PLAYER_ATTACK1)			

			if SERVER then
				local pSqueak = ents.Create(self.ThrowEntity)
				if IsValid(pSqueak) then
					pSqueak:SetPos(tr.HitPos)
					pSqueak:SetAngles(ang)
					pSqueak:SetOwner(self.Owner)
					pSqueak:SetVelocity(ang:Forward() * 200 + self.Owner:GetVelocity())
					pSqueak:Spawn()
				end
			end
			
			self:EmitSound(self.HuntSounds[math.random(1,2)], 105) -- not sure about 105
			self:TakeClipPrimary()
			self.m_fJustThrown = true
			self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
			self:SetWeaponIdleTime(CurTime() + 1)
		end
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:WeaponIdle()
	if self.m_fJustThrown then
		self.m_fJustThrown = false
		
		if self:rgAmmo() <= 0 then
			self:RetireWeapon()
			return
		end
		self:SendWeaponAnim(ACT_VM_DRAW)
		self:SetWeaponIdleTime(CurTime() + math.Rand(10, 15))
		return
	end

	local iAnim
	local flRand = util.SharedRandom("flRand", 0, 1)
	if flRand <= 0.75 then		
		iAnim = self:LookupSequence("idle1")
		self:SetWeaponIdleTime(CurTime() + 30.0 / 16 * (2))
	elseif flRand <= 0.875 then		
		iAnim = self:LookupSequence("fidgetfit")
		self:SetWeaponIdleTime(CurTime() + 70.0 / 16.0)
	else		
		iAnim = self:LookupSequence("fidgetnip")
		self:SetWeaponIdleTime(CurTime() + 80.0 / 16.0)
	end
	self.Owner:GetViewModel():SendViewModelMatchingSequence(iAnim)
end