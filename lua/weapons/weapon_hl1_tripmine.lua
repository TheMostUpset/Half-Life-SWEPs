
if CLIENT then

	SWEP.PrintName			= "Tripmine"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 4
	SWEP.SlotPos			= 2
	SWEP.WepSelectIcon		= surface.GetTextureID("hl1/icons/tripmine")

end

SWEP.Base 				= "weapon_hl1_base"
SWEP.Weight				= -10
SWEP.HoldType			= "slam"

SWEP.Category			= "Half-Life"
SWEP.Spawnable			= true

SWEP.PlayerModel		= Model("models/hl1/p_tripmine.mdl")
SWEP.EntModel			= Model("models/w_tripmine.mdl")

SWEP.CModel				= Model("models/hl1/c_tripmine.mdl")
SWEP.VModel				= Model("models/v_tripmine.mdl")

SWEP.ViewModel			= SWEP.CModel
SWEP.WorldModel			= SWEP.PlayerModel

SWEP.ThrowEntity		= "hl1_monster_tripmine"

SWEP.Primary.Delay			= 0.3
SWEP.Primary.ClipSize 		= -1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.MaxAmmo		= 5
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "TripMine"

function SWEP:SpecialHolster()
	if SERVER and self:rgAmmo() <= 0 then
		// out of mines
		self.Owner:StripWeapon(self:GetClass())
		return
	end
end

function SWEP:PrimaryAttack()
	if self:rgAmmo() <= 0 then
		return
	end
	
	local vecSrc = self.Owner:GetShootPos()
	local vecAiming = self.Owner:GetAimVector():Angle():Forward()

	local tr = util.TraceLine({
		start = vecSrc,
		endpos = vecSrc + vecAiming * 128,
		filter = self.Owner
	})
	
	if tr.Fraction < 1 then
		local pEntity = tr.Entity
		if pEntity && !pEntity:IsFlagSet(FL_CONVEYOR) then
			local angles = tr.HitNormal:Angle()			
			if SERVER then
				local pEnt = ents.Create(self.ThrowEntity)
				if IsValid(pEnt) then
					pEnt:SetPos(tr.HitPos + tr.HitNormal * 8)
					pEnt:SetAngles(angles)
					pEnt:SetOwner(self.Owner)
					pEnt.WeaponClass = self:GetClass()
					pEnt:Spawn()
				end
			end			
			self:TakeClipPrimary()
			if self:rgAmmo() > 0 then
				self:SendWeaponAnim(ACT_VM_DRAW)
			else
				self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
			end
			self.Owner:SetAnimation(PLAYER_ATTACK1)			
			if self:rgAmmo() <= 0 then
				// no more mines! 
				self:RetireWeapon()
				return
			end
		end
	end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetWeaponIdleTime(CurTime() + math.Rand(10, 15))
end

function SWEP:SecondaryAttack()
end

function SWEP:WeaponIdle()
	if self:rgAmmo() > 0 then
		self:SendWeaponAnim(ACT_VM_DRAW)
	else
		self:RetireWeapon()
		return
	end

	local iAnim
	local flRand = util.SharedRandom("flRand", 0, 1)
	if flRand <= 0.25 then		
		iAnim = self:LookupSequence("idle1")
		self:SetWeaponIdleTime(CurTime() + 90.0 / 30.0)
	elseif flRand <= 0.75 then		
		iAnim = self:LookupSequence("idle2")
		self:SetWeaponIdleTime(CurTime() + 60.0 / 30.0)
	else		
		iAnim = self:LookupSequence("fidget")
		self:SetWeaponIdleTime(CurTime() + 100.0 / 30.0)
	end
	self.Owner:GetViewModel():SendViewModelMatchingSequence(iAnim)
end