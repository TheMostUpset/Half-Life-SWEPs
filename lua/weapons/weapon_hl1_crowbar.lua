
if CLIENT then

	SWEP.PrintName			= "Crowbar"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 0
	SWEP.SlotPos			= 0
	SWEP.WepSelectIcon		= surface.GetTextureID("hl1/icons/crowbar")
	SWEP.AutoIconAngle		= Angle(-20, 0, 90)

end

SWEP.Base 				= "weapon_hl1_base"
SWEP.Weight				= 0
SWEP.HoldType			= "melee"

SWEP.Category			= "Half-Life"
SWEP.Spawnable			= true

SWEP.PlayerModel		= Model("models/hl1/p_crowbar.mdl")
SWEP.EntModel			= Model("models/w_crowbar.mdl")

SWEP.CModel				= Model("models/hl1/c_crowbar.mdl")
SWEP.VModel				= Model("models/v_crowbar.mdl")

SWEP.ViewModel			= SWEP.CModel
SWEP.WorldModel			= SWEP.PlayerModel

SWEP.PrimaryHitSounds = {
	Sound("hl1/weapons/cbar_hit1.wav"),
	Sound("hl1/weapons/cbar_hit2.wav")	
}
SWEP.PrimaryHitBodSounds = {
	Sound("hl1/weapons/cbar_hitbod1.wav"),
	Sound("hl1/weapons/cbar_hitbod2.wav"),
	Sound("hl1/weapons/cbar_hitbod3.wav")	
}

SWEP.MissSound				= Sound("hl1/weapons/cbar_miss1.wav")

SWEP.Primary.Damage			= 10
SWEP.Primary.DamageCVar		= "hl1_sk_plr_dmg_crowbar"
SWEP.Primary.Delay			= 0.5
SWEP.Primary.DelayHit		= 0.25
SWEP.Primary.ClipSize 		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

local textureVol = {
	[MAT_CONCRETE] = 0.6,
	[MAT_METAL] = 0.3,
	[MAT_DIRT] = 0.1,
	[MAT_VENT] = 0.3,
	[MAT_GRATE] = 0.5,
	[MAT_TILE] = 0.2,
	[MAT_SLOSH] = 0,
	[MAT_WOOD] = 0.2,
	[MAT_GLASS] = 0.2,
	[MAT_COMPUTER] = 0.2,
	[MAT_PLASTIC] = 0.4
}

local noFleshSound = {
	["monster_miniturret"] = true,
	["monster_turret"] = true,
	["monster_sentry"] = true,
	["monster_gargantua"] = true,
	["class C_BaseHelicopter_HL1"] = true,
	["monster_osprey"] = true,
	["monster_apache"] = true,
	["npc_turret_floor"] = true,
	["npc_strider"] = true,
	["npc_combine_camera"] = true,
	["npc_turret_ceiling"] = true,
	["npc_cscanner"] = true,
	["npc_combinedropship"] = true,
	["npc_combinegunship"] = true,
	["npc_helicopter"] = true,
	["npc_manhack"] = true,
	["npc_rollermine"] = true,
	["npc_clawscanner"] = true,
	["npc_dog"] = true,
}

function SWEP:FindHullIntersection(vecSrc, tr, mins, maxs, pEntity)
	local minmaxs = {mins, maxs}
	local vecHullEnd = tr.HitPos
	local vecEnd = Vector()
	local distance = 7791
	vecHullEnd = vecSrc + ((vecHullEnd - vecSrc)*2)
	if SERVER then self.Owner:LagCompensation(true) end
	local tmpTrace = util.TraceLine({
		start = vecSrc,
		endpos = vecHullEnd,
		filter = pEntity,
		mask = MASK_SHOT_HULL
	})
	if SERVER then self.Owner:LagCompensation(false) end
	if tmpTrace.Fraction < 1 then
		tr = tmpTrace
		return tr
	end
	for i = 1, 2 do
		for j = 1, 2 do
			for k = 1, 2 do
				vecEnd.x = vecHullEnd.x + minmaxs[i][1]
				vecEnd.y = vecHullEnd.y + minmaxs[j][2]
				vecEnd.z = vecHullEnd.z + minmaxs[k][3]
				
				if SERVER then self.Owner:LagCompensation(true) end
				local tmpTrace = util.TraceLine({
					start = vecSrc,
					endpos = vecEnd,
					filter = pEntity,
					mask = MASK_SHOT_HULL
				})
				if SERVER then self.Owner:LagCompensation(false) end
				if tmpTrace.Fraction < 1 then
					local thisDistance = (tmpTrace.HitPos - vecSrc):Length()
					if thisDistance < distance then
						tr = tmpTrace
						distance = thisDistance
					end
				end
			end
		end
	end
	return tr
end

function SWEP:SpecialHolster()
	self.nextSwing = nil
end

function SWEP:PrimaryAttack()
	if !self:Swing(true) then
		self.nextSwing = CurTime() + .1
	end
end

function SWEP:SpecialThink()
	if self.nextSwing and self.nextSwing <= CurTime() then
		self.nextSwing = nil
		self:SwingAgain()
	end
end

function SWEP:SwingAgain()
	self:Swing(false)
end

function SWEP:Swing(fFirst)
	local fDidHit = false
	
	local vecSrc = self.Owner:GetShootPos()
	local vecEnd = vecSrc + self.Owner:GetAimVector() * 32
	local entFilter = self:TraceFilter()

	if SERVER then self.Owner:LagCompensation(true) end
	self.tr = util.TraceLine({
		start = vecSrc,
		endpos = vecEnd,
		filter = entFilter,
		mask = MASK_SHOT_HULL
	})
	if SERVER then self.Owner:LagCompensation(false) end
	local tr = self.tr
	
	if tr.Fraction >= 1 then
		local duckMins, duckMaxs = Vector(-16, -16, -18), Vector(16, 16, 18)
		if SERVER then self.Owner:LagCompensation(true) end
		self.tr = util.TraceHull({
			start = vecSrc,
			endpos = vecEnd,
			filter = self.Owner,
			mins = duckMins,
			maxs = duckMaxs,
			mask = MASK_SHOT_HULL
		})
		if SERVER then self.Owner:LagCompensation(false) end
		local tr = self.tr
		if tr.Fraction < 1 then
			// Calculate the point of intersection of the line (or hull) and the object we hit
			// This is and approximation of the "best" intersection
			local pHit = tr.Entity
			if !IsValid(phit) || !pHit || self:IsBSPModel(phit) then				
				self.tr = self:FindHullIntersection(vecSrc, tr, duckMins, duckMaxs, self.Owner)
			end
			vecEnd = tr.HitPos
		end
	end
	if fFirst then self:EmitSound(self.MissSound) end
	if self.tr.Fraction >= 1 then	
		if fFirst then
			// miss
			self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
			self:SendWeaponAnim(ACT_VM_MISSCENTER)
			self.Owner:SetAnimation(PLAYER_ATTACK1)
		end
	else
		local tr = self.tr
		self:SendWeaponAnim(ACT_VM_HITCENTER)
		self.Owner:SetAnimation(PLAYER_ATTACK1)
		// hit
		fDidHit = true
		local pEntity = tr.Entity
		
		if pEntity then
			if (pEntity:IsPlayer() or pEntity:IsNPC() or pEntity:IsNextBot()) and !noFleshSound[pEntity:GetClass()] then				
				self:EmitSound(self.PrimaryHitBodSounds[math.random(1,3)], 85, 100, 1, CHAN_ITEM)
			else
				local fvolbar = textureVol[tr.MatType] or 0
				if pEntity:Health() > 0 then
					fvolbar = fvolbar / 2
				end
				self:EmitSound(self.PrimaryHitSounds[math.random(1,2)], 95, 98 + math.random(0,3), fvolbar, CHAN_ITEM)
				self:ImpactEffect(tr)
				local phys = pEntity:GetPhysicsObject()
				if IsValid(phys) then
					phys:ApplyForceOffset(tr.Normal * 800, tr.HitPos)
				end
			end
		
			if IsValid(pEntity) then
				local hitDmg = cvars.Number(self.Primary.DamageCVar, self.Primary.Damage)
				local dmginfo = DamageInfo()
				dmginfo:SetAttacker(self.Owner)
				dmginfo:SetInflictor(self)
				dmginfo:SetDamageType(DMG_CLUB)
				if !self:IsMultiplayerRules() and self:GetNextPrimaryFire() + 1 >= CurTime() then
					// first swing does full damage
					// subsequent swings do half
					hitDmg = hitDmg / 2
				end
				dmginfo:SetDamage(hitDmg)
				dmginfo:SetDamagePosition(tr.HitPos)
				dmginfo:SetDamageForce(tr.Normal * hitDmg * 900)
				pEntity:DispatchTraceAttack(dmginfo, tr)
			end
		end

		self:SetNextPrimaryFire(CurTime() + self.Primary.DelayHit)
		
	end
	return fDidHit
end

function SWEP:ImpactEffect(tr)
	if !IsFirstTimePredicted() then return end
	local e = EffectData()
	e:SetOrigin(tr.HitPos)
	e:SetStart(tr.StartPos)
	e:SetSurfaceProp(tr.SurfaceProps)
	e:SetDamageType(DMG_BULLET)
	e:SetHitBox(tr.HitBox)
	if CLIENT then
		e:SetEntity(tr.Entity)
	else
		e:SetEntIndex(tr.Entity:EntIndex())
	end
	util.Effect("Impact", e)
end