AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Model		= Model("models/rpgrocket.mdl")
ENT.Trail		= "hl1/sprites/smoke.vmt"
ENT.Sprite		= "sprites/animglow01.vmt"
ENT.FlySound	= "Missile.Ignite"

function ENT:Initialize()
	self:SetMoveType(MOVETYPE_FLYGRAVITY)
	self:SetMoveCollide(MOVECOLLIDE_FLY_BOUNCE)
	self:SetSolid(SOLID_BBOX)
	self:SetModel(self.Model)
	self:SetCollisionBounds(Vector(), Vector())
	
	local angAngs = self:GetAngles()
	angAngs.x = angAngs.x - 30
	local vecFwd = angAngs:Forward()
	
	self:SetLocalVelocity(vecFwd * 250)
	local svgravity = cvars.Number("sv_gravity", 800)
	if svgravity != 0 then
		local gravityMul = 400 / svgravity
		self:SetGravity(gravityMul)
	end

	self:NextThink(CurTime() + .4)
	
	self.dmg = cvars.Number("hl1_sk_plr_dmg_rpg", 100)
	self.radius = self.dmg * 2.5
end

function ENT:Touch(pOther)
	if !pOther:IsSolid() or pOther:GetClass() == "hornet" then
		return
	end
	--[[if self.pLauncher then
		// my launcher is still around, tell it I'm dead.
		self.pLauncher.cActiveRockets = cActiveRockets - 1
	end]]--
	self:StopSound(self.FlySound)
	self:Explode(pOther)
end

function ENT:Explode(ent)
	if self.didHit then return end
	local vecDir = self:GetForward()
	local tr = util.QuickTrace(self:GetPos(), vecDir, self)
	local pos, norm = tr.HitPos, tr.HitNormal

	if norm:Length() == 0 then
		pos = pos + Vector(0,0,40)
	end
	self:ExplosionEffects(pos, norm)
	util.Decal("Scorch", pos - vecDir + norm, pos + vecDir)

	self:InsertSound(1, self:GetPos(), 1024, 3, NULL)

	local owner = IsValid(self.Owner) and self.Owner or self
	local dmg = DamageInfo()
	dmg:SetInflictor(self)
	dmg:SetAttacker(owner)
	dmg:SetDamage(self.dmg)
	dmg:SetDamageType(bit.bor(DMG_BLAST, DMG_AIRBOAT))
	util.BlastDamageInfo(dmg, tr.HitPos, self.radius)
	
	self.didHit = true
	self:RemoveEffects(EF_BRIGHTLIGHT)
	self:StopSound(self.FlySound)
	self:SetLocalVelocity(Vector())
	self:SetMoveType(MOVETYPE_NONE)
	self:AddEffects(EF_NODRAW)
	self:AddSolidFlags(FSOLID_NOT_SOLID)
	if self.glow and IsValid(self.glow) then self.glow:Remove() end
	SafeRemoveEntityDelayed(self, 4)
	
	gamemode.Call("OnEntityExplosion", self, tr.HitPos, self.radius, self.dmg)
end

function ENT:Think()
	if self.didHit then return end
	if !self.m_flIgniteTime then
		self:SetMoveType(MOVETYPE_FLY)
		self:AddEffects(EF_BRIGHTLIGHT)
		self:EmitSound(self.FlySound)
		
		self.glow = ents.Create("env_sprite")
		local glow = self.glow
		glow:SetKeyValue("rendercolor", "224 224 255")
		glow:SetKeyValue("GlowProxySize", "2")
		glow:SetKeyValue("HDRColorScale", "1")
		glow:SetKeyValue("renderfx", "15")
		glow:SetKeyValue("rendermode", "3")
		glow:SetKeyValue("renderamt", "255")
		glow:SetKeyValue("model", self.Sprite)
		glow:SetKeyValue("scale", ".4")
		glow:Spawn()
		glow:SetParent(self)
		glow:SetPos(self:GetPos())
		util.SpriteTrail(self, 0, Color(224,224,255,255), true, 10, 15, 4, .03, self.Trail)
		
		self.m_flIgniteTime = CurTime()

		self.vecTarget = self:GetForward()
		self:NextThink(CurTime() + 0.1)
	end
	local spot = IsValid(self.pLauncher) and self.pLauncher:GetSpotEntity() or NULL
	local vecDir = Vector()
	local flDist, flMax, flDot
	flMax = 4096
	
	if IsValid(spot) and spot:GetOwner() == self:GetOwner() and spot:GetDrawLaser() then
		local tr = util.TraceLine({
			start = self:GetPos(),
			endpos = spot:GetPos(),
			filter = {self, self.Owner, spot}
		})
		if tr.Fraction >= 0.90 then
			vecDir = spot:GetPos() - self:GetPos()
			flDist = vecDir:Length()
			vecDir = vecDir:GetNormalized()
			flDot = self:GetForward():Dot(vecDir)
			if (flDot > 0) and (flDist * (1 - flDot) < flMax) then
				flMax = flDist * (1 - flDot)
				self.vecTarget = vecDir
			end
		end
	end
	
	self:SetAngles(self.vecTarget:Angle())
	
	local flSpeed = self:GetVelocity():Length()
	if CurTime() - self.m_flIgniteTime < 1 then
		self:SetLocalVelocity(self:GetVelocity() * 0.2 + self.vecTarget * (flSpeed * 0.8 + 400))
		if self:WaterLevel() == 3 then
			if self:GetVelocity():Length() > 300 then
				self:SetLocalVelocity(self:GetVelocity():GetNormalized() * 300)
			end
		else
			if self:GetVelocity():Length() > 2000 then
				self:SetLocalVelocity(self:GetVelocity():GetNormalized() * 2000)
			end
		end
	else
		--[[if self:IsEffectActive(EF_BRIGHTLIGHT) then
			self:RemoveEffects(EF_BRIGHTLIGHT)
			self:StopSound(self.FlySound)
		end]]--
		self:SetLocalVelocity(self:GetVelocity() * 0.2 + self.vecTarget * flSpeed * 0.798)
		if self:WaterLevel() == 0 && self:GetVelocity():Length() < 1500 then
			self:Explode()
		end
	end
	
	self:NextThink(CurTime() + .1)
	return true
end

function ENT:OnRemove()
	self:StopSound(self.FlySound)
end