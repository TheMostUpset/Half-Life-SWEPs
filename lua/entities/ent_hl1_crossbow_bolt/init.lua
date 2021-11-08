AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Model		= Model("models/hl1/crossbow_bolt.mdl")
ENT.SndHit		= Sound("weapons/xbow_hit1.wav")
ENT.SndHitBody	= {Sound("weapons/xbow_hitbod1.wav"), Sound("weapons/xbow_hitbod2.wav")}

function ENT:Initialize()
	self:SetMoveType(MOVETYPE_FLY)
	self:SetMoveCollide(MOVECOLLIDE_COUNT)
	self:SetSolid(SOLID_NONE)
	self:SetModel(self.Model)
	self:SetCollisionBounds(Vector(), Vector())
	if IsValid(self.Owner) and !self.Owner:IsPlayer() then
		self:SetSolid(SOLID_BBOX)
		self:SetMoveCollide(MOVECOLLIDE_FLY_BOUNCE)
		return
	end
	self:NextThink(CurTime())
	
	if !game.SinglePlayer() then
		local entFilter = self:TraceFilter()
		local tr = util.TraceLine({
			start = self:GetPos() - self:GetForward() * 12,
			endpos = self:GetPos() + self:GetForward() * 64,
			filter = entFilter
		})
		if !self.didHit and tr.Hit and IsValid(tr.Entity) then
			self:BoltTouch(tr)
		end
	end
	
	self.HitCheckDist = math.Clamp(2000 * FrameTime() - 18, 12, 96)
	self.HitCheckDist = math.ceil(self.HitCheckDist)
end

function ENT:StartTouch(ent)
	if self.Owner:IsPlayer() then return end
	self:BoltTouch(self:GetTouchTrace())
end

function ENT:BoltTouch(tr)
	local pOther = tr.Entity
	if !pOther:IsSolid() then return end
	self.didHit = true
	if pOther:Health() > 0 then
		local pevOwner = self:GetOwner()
		if IsValid(pevOwner) then
			local dmg = cvars.Number("hl1_sk_plr_dmg_xbow_bolt_npc", 50)
			if pOther:IsPlayer() then
				dmg = cvars.Number("hl1_sk_plr_dmg_xbow_bolt_plr", 10)
			end
			local dmginfo = DamageInfo()
			dmginfo:SetAttacker(pevOwner)
			dmginfo:SetInflictor(self)
			dmginfo:SetDamage(dmg)
			dmginfo:SetDamageType(bit.bor(DMG_BULLET, DMG_NEVERGIB))
			dmginfo:SetDamageForce(self:GetForward() * 8000)
			dmginfo:SetDamagePosition(tr.HitPos)
			pOther:DispatchTraceAttack(dmginfo, tr)
		end
		self:SetLocalVelocity(Vector(0, 0, 0))
	
		// play body "thwack" sound
		self:EmitSound(self.SndHitBody[math.random(1, 2)], 80, 100, 1, CHAN_BODY)
		if !self:IsMultiplayerRules() then
			self:Remove()
		end
	else
		sound.Play(self.SndHit, tr.HitPos, 80, 98 + math.random(0,7), math.Rand(0.95, 1.0))

		// if what we hit is static architecture, can stay around for a while.
		local vecDir = self:GetForward()
		self:SetPos(tr.HitPos - vecDir * 12)
		local angles = vecDir:Angle()
		angles.z = math.random(0, 360)
		self:SetAngles(angles)
		self:SetSolid(SOLID_NONE)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetLocalVelocity(Vector(0, 0, 0))
		self:SetLocalAngularVelocity(Angle(0,0,0))
		
		SafeRemoveEntityDelayed(self, 10)
		self:NextThink(CurTime() + 10)
		if !pOther:IsWorld() then
			timer.Simple(0, function()
				if IsValid(self) and IsValid(pOther) then
					self:SetParent(pOther)
				end
			end)
			local phys = pOther:GetPhysicsObject()
			if IsValid(phys) then
				phys:ApplyForceOffset(vecDir * 4000, tr.HitPos)
			end
		end
		if bit.band(util.PointContents(tr.HitPos), CONTENTS_WATER) != CONTENTS_WATER then
			local effectdata = EffectData()
			effectdata:SetOrigin(tr.HitPos)
			effectdata:SetNormal(tr.HitNormal)
			effectdata:SetMagnitude(2)
			effectdata:SetScale(1)
			util.Effect("ElectricSpark", effectdata, true, true)
		end
		if !self:IsMultiplayerRules() then
			self:ImpactEffect(tr)
		end
	end
	if self:IsMultiplayerRules() then
		self:Explode(tr)
	end
end

function ENT:Think()
	if !self.HitCheckDist or self.didHit then return end
	local entFilter = self:TraceFilter()
	local tr = util.TraceLine({
		start = self:GetPos() - self:GetForward() * 12,
		endpos = self:GetPos() + self:GetForward() * self.HitCheckDist,
		filter = entFilter
	})
	if !self.didHit and tr.Hit then
		self:BoltTouch(tr)
	end

	self:NextThink(CurTime())
	return true
end

function ENT:Explode(tr)
	local iContents = util.PointContents(self:GetPos())
	self.dmg = 40
	
	local vecDir = self:GetVelocity():GetNormalized()
	
	local eftr = util.QuickTrace(self:GetPos(), Vector(0,0,8), self)
	
	local explosion = EffectData()
	explosion:SetOrigin(eftr.HitPos)
	explosion:SetNormal(vecDir)
	explosion:SetScale(10)
	explosion:SetFlags(0)
	util.Effect("hl1_explosion", explosion, true, true)
	self:EmitSound("hl1/weapons/explode"..math.random(3,5)..".wav", 400, 100, 1, CHAN_ITEM)

	if IsValid(self.Owner) then
		util.BlastDamage(self, self.Owner, tr.HitPos, 128, self.dmg)
	end
	
	self:Remove()
end