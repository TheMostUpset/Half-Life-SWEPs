ENT.Type			= "anim"
ENT.PrintName		= "HL1 Ent Base"
ENT.Author			= "Upset"

function ENT:IsMultiplayerRules()
	return cvars.Bool("hl1_sv_mprules")
end

function ENT:IsScreenShakeEnabled()
	return cvars.Bool("hl1_sv_explosionshake")
end

function ENT:IsCreature(ent)
	return ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()
end

function ENT:TraceFilter()
	local t = {self, self.Owner}
	if hl1_coop_sv_friendlyfire and !hl1_coop_sv_friendlyfire:GetBool() then
		t = player.GetAll()
		table.insert(t, self)
	end
	return t
end

function ENT:ExplosionEffects(pos, norm, scale)
	if CLIENT and !IsFirstTimePredicted() then return end
	pos = pos or self:GetPos()
	norm = norm or Vector()
	scale = scale or 33

	local effPos = pos + norm * (scale / 2 + 28)
	if SERVER and !util.IsInWorld(effPos) then
		effPos = pos
	end
	local tr = util.QuickTrace(effPos, Vector(0,0,10), self)
	effPos = tr.HitPos
	tr = util.QuickTrace(effPos, Vector(0,0,5), self)
	if norm[3] > 0 and !tr.Hit then -- if hits floor
		effPos = tr.HitPos
	end

	local explosion = EffectData()
	explosion:SetOrigin(effPos)
	explosion:SetNormal(norm)
	explosion:SetScale(scale)
	explosion:SetFlags(1)
	util.Effect("hl1_explosion", explosion)
	util.Effect("hl1_explosionsmoke", explosion)
	
	if CLIENT then return end
	
	if self:WaterLevel() == 0 then
		for i = 0, math.random(0,3) do
			local sparks = ents.Create("spark_shower")
			if IsValid(sparks) then
				sparks:SetPos(pos + Vector(0,0,40))
				sparks:SetAngles(AngleRand())
				sparks:Spawn()
			end
		end
		self:EmitSound(self.DebrisSounds[math.random(1,3)], 80, 100, 1, CHAN_VOICE)
	end
	
	self:EmitSound(self.ExplosionSounds[math.random(1,3)], 400, 100, 1, CHAN_ITEM)

	if self:IsScreenShakeEnabled() then
		util.ScreenShake(pos, scale*.2, scale, 1, scale*50)
	end
end

function ENT:ImpactEffect(tr)
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
	
	local effect = "Impact"
	if self:IsCreature(tr.Entity) then
		effect = "BloodImpact"
	end

	util.Effect(effect, e, true, true)
end

function ENT:IsHDEnabled()
	return GetConVar("hl1_sv_hdmodels"):GetBool()
end