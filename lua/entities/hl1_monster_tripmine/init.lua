AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Model			= Model("models/w_tripmine.mdl")
ENT.SoundDeploy		= "TripmineGrenade.Deploy"
ENT.SoundCharge		= "TripmineGrenade.Charge"
ENT.SoundActivate	= Sound("weapons/mine_activate.wav")

function ENT:Initialize()
	self:SetMoveType(MOVETYPE_FLY)
	self:SetSolid(SOLID_NONE)
	self:SetModel(self.Model)
	self:SetCollisionBounds(Vector(-8, -8, -8), Vector(8, 8, 8))
	
	if self:CreatedByMap() then
		// power up quickly
		self.m_flPowerUp = CurTime() + 1.0
	else
		// power up in 2.5 seconds
		self.m_flPowerUp = CurTime() + 2.5
	end
	
	--SetThink( &CTripmineGrenade::PowerupThink )
	self.PowerUpDelay = true
	self:NextThink(CurTime() + .2)
	
	self.dmg = cvars.Number("hl1_sk_plr_dmg_tripmine", 150)
	self:SetHealth(1)
	
	if self:GetOwner() != NULL then
		self:EmitSound(self.SoundDeploy, 80, 100, 1, CHAN_VOICE)
		self:EmitSound(self.SoundCharge, 100, 100, 1, CHAN_BODY)
		
		self.m_pRealOwner = self:GetOwner() // see CTripmineGrenade for why.
	end
	
	//UTIL_MakeAimVectors( pev->angles )
	
	self.m_vecDir = self:GetForward()
	self.m_vecEnd = self:GetPos() + self.m_vecDir * self.MaxDistance
end

function ENT:PowerupThink()
	if !self.m_hOwner or self.m_hOwner == NULL then
		// find an owner
		local oldowner = self:GetOwner()
		self:SetOwner(NULL)
		local tr = util.TraceLine({
			start = self:GetPos() + self.m_vecDir * 8,
			endpos = self:GetPos() - self.m_vecDir * 32,
			filter = self
		})
		if tr.StartSolid || (oldowner && tr.Entity == oldowner) then
			self:SetOwner(oldowner)
			self.m_flPowerUp = self.m_flPowerUp + 0.1
			self:NextThink(CurTime() + .1)
			return
		end
		if tr.Fraction < 1 then
			self:SetOwner(tr.Entity)
			self.m_hOwner = self:GetOwner()
			self.m_posOwner = self.m_hOwner:GetPos()
			self.m_angleOwner = self.m_hOwner:GetAngles()
		else
			self:StopSound(self.SoundDeploy)
			self:StopSound(self.SoundCharge)
			--SetThink(&CTripmineGrenade::SUB_Remove )
			self:Remove()
			self.PowerUpDelay = nil
			self:NextThink(CurTime() + .1)
			print("WARNING:Tripmine at "..self:GetPos()[1], self:GetPos()[2], self:GetPos()[3].." removed")
			self:KillBeam()
			return
		end
	elseif IsValid(self.m_hOwner) and (self.m_posOwner != self.m_hOwner:GetPos() || self.m_angleOwner != self.m_hOwner:GetAngles()) then
		// disable
		self:StopSound(self.SoundDeploy)
		self:StopSound(self.SoundCharge)
		local weaponEnt = self.WeaponClass or "weapon_hl1_tripmine"
		local pMine = ents.Create(weaponEnt)
		if IsValid(pMine) then
			pMine:SetPos(self:GetPos() + self.m_vecDir * 24)
			pMine:SetAngles(self:GetAngles())
			pMine:Spawn()
			--spawnflags |= SF_NORESPAWN
		end
		--SetThink( &CTripmineGrenade::SUB_Remove );
		self:Remove()
		self.PowerUpDelay = nil
		self:KillBeam()
		self:NextThink(CurTime() + 0.1)
		return
	end
	
	if CurTime() > self.m_flPowerUp then
		// make solid
		self:SetSolid(SOLID_BBOX)
		
		self:MakeBeam()
		
		// play enabled sound
		self:EmitSound(self.SoundActivate, 85, 75, 1, CHAN_VOICE)
		self.PowerUpDelay = nil
	end
	self:NextThink(CurTime() + .1)
end

function ENT:Think()
	if self.PowerUpDelay then
		self:PowerupThink()
	end
	if self.DelayDeath then
		self:DelayDeathThink()
	end
	if self.BeamThink then
		self:BeamBreakThink()
	end
	return true
end

function ENT:KillBeam()
	self:SetDrawLaser(false)
end

function ENT:MakeBeam()
	local tr = self:BeamTrace(self:GetPos(), self.m_vecEnd)
	
	self.m_flBeamLength = tr.Fraction
	
	// set to follow laser spot
	self.BeamThink = true
	self:NextThink(CurTime() + 0.1)
	
	//local vecTmpEnd = self:GetPos() + self.m_vecDir * self.MaxDistance * self.m_flBeamLength
	
	self:SetDrawLaser(true)
end

function ENT:BeamBreakThink()
	local bBlowup = false
	
	local tr = self:BeamTrace(self:GetPos(), self.m_vecEnd, self.m_hOwner)

	// respawn detect. 
	if !self:GetDrawLaser() then
		self:MakeBeam()
		if tr.Entity then
			self.m_hOwner = tr.Entity // reset owner too
		end
	end

	if math.abs(self.m_flBeamLength - tr.Fraction) > 0.001 then
		bBlowup = true
	else
		if self.m_hOwner == NULL then
			bBlowup = true
		elseif self.m_posOwner != self.m_hOwner:GetPos() then
			bBlowup = true
		elseif self.m_angleOwner != self.m_hOwner:GetAngles() then
			bBlowup = true
		end
	end

	if bBlowup then
		if !self.m_pRealOwner then self.m_pRealOwner = tr.Entity end
		self:SetOwner(self.m_pRealOwner)
		self:SetHealth(0)
		self:Killed(self:GetOwner())
		return
	end
	
	self:NextThink(CurTime() + .05)
end

function ENT:OnTakeDamage(dmginfo)
	if self.NoDamage then return end
	local pevInflictor = dmginfo:GetInflictor()
	local pevAttacker = dmginfo:GetAttacker()
	local flDamage = dmginfo:GetDamage()

	if CurTime() < self.m_flPowerUp && flDamage < self:Health() then
		// disable
		--SetThink( &CTripmineGrenade::SUB_Remove )
		self:NextThink(CurTime() + .1)
		self:KillBeam()
		return
	end
	self:SetHealth(self:Health() - flDamage)
	if self:Health() <= 0 then
		self:Killed(pevAttacker)
	end
end

function ENT:Killed(pevAttacker, iGib)
	self.NoDamage = true
	
	if pevAttacker && pevAttacker:IsPlayer() then
		// some client has destroyed this mine, he'll get credit for any kills
		self:SetOwner(pevAttacker)
	end
	
	--SetThink( &CTripmineGrenade::DelayDeathThink )
	self.DelayDeath = true
	self:NextThink(CurTime() + math.Rand(.1, .3))
end

function ENT:DelayDeathThink()
	self.DelayDeath = nil
	self:KillBeam()
	local tr = util.TraceLine({
		start = self:GetPos() + self.m_vecDir * 8,
		endpos = self:GetPos() - self.m_vecDir * 64,
		filter = self
	})
	self:StopSound(self.SoundCharge)
	self:Explode(tr)
end

function ENT:Explode(tr)
	local pos, norm = tr.HitPos, tr.HitNormal
	local efpos = pos

	if norm:Length() == 0 then
		efpos = pos + Vector(0,0,40)
	end
	self:ExplosionEffects(efpos, norm, 63)
	util.Decal("Scorch", pos - norm, pos + norm)

	self:InsertSound(1, self:GetPos(), 1024, 3, NULL)

	local radius = self.dmg * 2.5
	if self:GetOwner() != NULL then
		util.BlastDamage(self, self:GetOwner(), tr.HitPos, radius, self.dmg)
	end
	
	self:Remove()
	
	gamemode.Call("OnEntityExplosion", self, tr.HitPos, radius, self.dmg)
end