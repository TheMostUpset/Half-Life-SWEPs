AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Model = Model("models/w_satchel.mdl")
ENT.ModelHD = Model("models/hl1/hd/w_satchel.mdl")

function ENT:Initialize()
	self:SetMoveType(MOVETYPE_FLYGRAVITY)
	self:SetMoveCollide(MOVECOLLIDE_FLY_SLIDE)
	self:SetSolid(SOLID_BBOX)
	if self:IsHDEnabled() and self.Model == "models/w_satchel.mdl" then
		self:SetModel(self.ModelHD)
	else
		self:SetModel(self.Model)
	end
	self:SetCollisionBounds(Vector(-4, -4, 0), Vector(4, 4, 8))	
	
	self:NextThink(CurTime() + .1)
	
	self:SetCorrectGravity()
	self:SetFriction(0.8)
	self.dmg = cvars.Number("hl1_sk_plr_dmg_satchel", 150)
	self.m_flNextBounceSoundTime = 0
	
	self:SetSequence(1)
end

function ENT:Deactivate()
	self:SetSolid(SOLID_NONE)
	self:Remove()
end

function ENT:Touch(pOther)
	// don't hit the guy that launched this grenade
	if pOther == self:GetOwner() or !pOther:IsSolid() then
		return
	end
	
	self:SetGravity(1)
	
	local tr = util.TraceLine({
		start = self:GetPos(),
		endpos = self:GetPos() - Vector(0,0,10),
		filter = self
	})

	if tr.Fraction < 1 then
		// add a bit of static friction
		self:SetLocalVelocity(self:GetVelocity() * 0.95)
		self:SetLocalAngularVelocity(self:GetLocalAngularVelocity() * 0.9)
		// play sliding sound, volume based on velocity
	end

	if !self:IsFlagSet(FL_ONGROUND) && self:GetVelocity():Length2D() > 10 then
		self:BounceSound()
	end
end

function ENT:Think()
	self:NextThink(CurTime() + .1)
	
	if !self:IsInWorld() then
		self:Remove()
		return
	end

	if self:WaterLevel() == 3 then
		self:SetMoveType(MOVETYPE_FLY)
		self:SetLocalVelocity(self:GetVelocity() * 0.8)
		self:SetLocalAngularVelocity(self:GetLocalAngularVelocity() * 0.9)
		local vel = self:GetVelocity()
		vel[3] = vel[3] + 8
		self:SetLocalVelocity(vel)
	elseif self:WaterLevel() == 0 then
		self:SetMoveType(MOVETYPE_FLYGRAVITY)
	else
		local vel = self:GetVelocity()
		vel[3] = vel[3] - 8
		self:SetLocalVelocity(vel)
	end
	return true
end

function ENT:BounceSound()
	if CurTime() > self.m_flNextBounceSoundTime then
		self:EmitSound("SatchelCharge.Bounce")
		self.m_flNextBounceSoundTime = CurTime() + 0.1
	end
end

function ENT:Detonate()
	local tr = util.QuickTrace(self:GetPos(), -self:GetUp(), self)
	local pos, norm = tr.HitPos, tr.HitNormal
	local efpos = pos

	if norm:Length() == 0 then
		efpos = pos + Vector(0,0,40)
	end
	self:ExplosionEffects(efpos, norm, 63)
	util.Decal("Scorch", pos - norm, pos + norm)

	self:InsertSound(1, self:GetPos(), 1024, 3, NULL)

	local radius = self.dmg * 2.5
	if IsValid(self.Owner) then
		util.BlastDamage(self, self.Owner, pos, radius, self.dmg)
	end
	
	self:Remove()
	
	gamemode.Call("OnEntityExplosion", self, pos, radius, self.dmg)
end