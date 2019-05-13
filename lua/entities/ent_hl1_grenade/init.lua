AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Model = Model("models/w_grenade.mdl")
ENT.BounceSounds = {
	Sound("hl1/weapons/grenade_hit1.wav"),
	Sound("hl1/weapons/grenade_hit2.wav"),
	Sound("hl1/weapons/grenade_hit3.wav")
}

function ENT:Initialize()
	self:SetMoveType(MOVETYPE_FLYGRAVITY)
	self:SetMoveCollide(MOVECOLLIDE_FLY_BOUNCE)
	self:SetSolid(SOLID_BBOX)
	self:AddSolidFlags(FSOLID_NOT_STANDABLE)
	self:SetModel(self.Model)
	self:SetCollisionBounds(Vector(), Vector())
	
	self.m_bHasWarnedAI = false
end

function ENT:ShootTimed(pOwner, vecVelocity, flTime)
	self:SetVelocity(vecVelocity)
	self:SetOwner(pOwner)
	
	self.dmgtime = CurTime() + flTime
	self:NextThink(CurTime() + .1)
	if flTime < .1 then
		--self:NextThink(CurTime())
		self:SetVelocity(Vector())
	end

	self:SetSequence(0)
	self:SetPlaybackRate(1)
	
	self:SetAngles(Angle(0,0,60)) 

	self:SetLocalAngularVelocity(Angle(math.random( -200, 200 ), math.random( 400, 500 ), math.random( -100, 100 )))
	
	local svgravity = cvars.Number("sv_gravity", 800)
	if svgravity != 0 then
		local gravityMul = 400 / svgravity
		self:SetGravity(gravityMul)
	end
	self:SetFriction(0.8)
	
	self.dmg = cvars.Number("hl1_sk_plr_dmg_grenade", 100)
	self.m_flNextAttack = CurTime()
end

function ENT:Deactivate()
	self:SetSolid(SOLID_NONE)
	self:Remove()
end

function ENT:Touch(pOther)
	if !pOther:IsSolid() or pOther:GetSolidFlags() == FSOLID_VOLUME_CONTENTS then
		return
	end

	// don't hit the guy that launched this grenade
	if pOther == self:GetOwner() then
		return
	end
	
	// Do a special test for players
	if pOther:IsPlayer() then
		// Never hit a player again (we'll explode and fixup anyway)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	end
	
	// only do damage if we're moving fairly fast
	if self.m_flNextAttack < CurTime() && self:GetVelocity():Length() > 100 then
		local pevOwner = self:GetOwner()
		if IsValid(pevOwner) then
			local tr = util.QuickTrace(self:GetPos(), self:GetForward(), self)
			local dmginfo = DamageInfo()
			dmginfo:SetAttacker(pevOwner)
			dmginfo:SetInflictor(self)
			dmginfo:SetDamage(1)
			dmginfo:SetDamageType(DMG_CLUB)
			pOther:DispatchTraceAttack(dmginfo, tr, self:GetForward())
		end
		self.m_flNextAttack = CurTime() + 1
	end
	
	local vecTestVelocity = self:GetAbsVelocity()
	vecTestVelocity.z = vecTestVelocity.z * -0.45

	if !self.m_bHasWarnedAI && vecTestVelocity:Length() <= 60 then
		// grenade is moving really slow. It's probably very close to where it will ultimately stop moving. 
		// emit the danger sound.
		
		// register a radius louder than the explosion, so we make sure everyone gets out of the way
		self:InsertSound(8, self:GetPos(), self.dmg / 0.4, 0.3)
		self.m_bHasWarnedAI = true
	end

	local tr = util.TraceLine({
		start = self:GetPos(),
		endpos = self:GetPos() - Vector(0,0,10),
		mask = MASK_SOLID_BRUSHONLY,
		filter = self
	})

	if tr.Fraction < 1.0 then
		self:SetSequence(self:SelectWeightedSequence(ACT_IDLE))
		self:SetAngles(Angle())
	end

	if !pOther:IsWorld() then
		local phys = pOther:GetPhysicsObject()
		if IsValid(phys) then
			phys:ApplyForceOffset(self:GetVelocity() * 8, self:GetPos())
		end
	end
	
	self:BounceSound()

	self:SetPlaybackRate(self:GetVelocity():Length() / 200)
	if self:GetPlaybackRate() > 1.0 then
		self:SetPlaybackRate(1)
	elseif self:GetPlaybackRate() < 0.5 then
		self:SetPlaybackRate(0)
	end
end

function ENT:Think()	
	if !self:IsInWorld() then
		self:Remove()
		return
	end
	
	self:NextThink(CurTime() + .1)
	
	if self.dmgtime - 1 < CurTime() then
		self:InsertSound(8, self:GetPos() + self:GetVelocity() * (self.dmgtime - CurTime()), 400, 0.1)
	end
	
	if self.dmgtime <= CurTime() then
		local vecSpot = self:GetPos() + Vector ( 0 , 0 , 8 )
		local tr = util.TraceLine({
			start = vecSpot,
			endpos = vecSpot + Vector ( 0, 0, -40 ),
			filter = self
		})
		self:Explode(tr)
	end
	if self:WaterLevel() != 0 then
		self:SetLocalVelocity(self:GetVelocity() * 0.5)
		self:SetPlaybackRate(0.2)
	end
	return true
end

function ENT:BounceSound()
	self:EmitSound(self.BounceSounds[math.random(1,3)], 90, 100, 0.25, CHAN_VOICE)
end

function ENT:Explode(pTrace)
	local hitpos, hitnorm = pTrace.HitPos, pTrace.HitNormal

	// Pull out of the wall a bit
	if pTrace.Fraction != 1 then
		local tr = util.TraceLine({
			start = self:GetPos(),
			endpos = hitpos + (hitnorm * (self.dmg - 24) * 0.6),
			filter = self
		})
		self:SetPos(tr.HitPos)
	end

	if hitnorm:Length() == 0 then
		hitpos = hitpos + Vector(0,0,60)
	end
	self:ExplosionEffects(hitpos, hitnorm, (self.dmg - 50) *.6)
	self:InsertSound(1, self:GetPos(), 1024, 3, NULL)
	
	local pevOwner = self:GetOwner()
	--[[if IsValid(self:GetOwner()) then
		pevOwner = self:GetOwner()
	else
		pevOwner = NULL
	end
	self:SetOwner(NULL)]]--

	local radius = self.dmg * 2.5
	if IsValid(pevOwner) then
		util.BlastDamage(self, pevOwner, self:GetPos(), radius, self.dmg)
	end

	util.Decal("Scorch", hitpos + hitnorm, hitpos - hitnorm)

	self:Remove()
	
	gamemode.Call("OnEntityExplosion", self, self:GetPos(), radius, self.dmg)
end