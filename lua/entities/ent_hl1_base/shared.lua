ENT.Type			= "anim"
ENT.PrintName		= "HL1 Ent Base"
ENT.Author			= "Upset"

function ENT:IsMultiplayerRules()
	return (!game.SinglePlayer() or cvars.Bool("hl1_sv_mprules")) and !(GAMEMODE.Cooperative and !cvars.Bool("hl1_sv_mprules"))
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