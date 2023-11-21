AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.ExplosionSounds = {
	Sound("hl1/weapons/explode3.wav"),
	Sound("hl1/weapons/explode4.wav"),
	Sound("hl1/weapons/explode5.wav")
}
ENT.DebrisSounds = {
	Sound("weapons/debris1.wav"),
	Sound("weapons/debris2.wav"),
	Sound("weapons/debris3.wav")
}

function ENT:ExplosionEffects(pos, norm, scale)
	pos = pos or self:GetPos()
	norm = norm or Vector()
	scale = scale or 33

	local effPos = pos + norm * (scale / 2 + 28)
	local tr = util.QuickTrace(effPos, Vector(0,0,10), self)
	effPos = tr.HitPos
	tr = util.QuickTrace(effPos, Vector(0,0,5), self)
	if norm[3] > 0 and !tr.Hit then
		effPos = tr.HitPos
	end

	local explosion = EffectData()
	explosion:SetOrigin(effPos)
	explosion:SetNormal(norm)
	explosion:SetScale(scale)
	explosion:SetFlags(1)
	util.Effect("hl1_explosion", explosion)
	util.Effect("hl1_explosionsmoke", explosion)
	
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

function ENT:InsertSound(sndtype, pos, volume, duration, parent)
	parent = parent or self
	
	local ent = ents.Create("ai_sound")
	ent:SetPos(pos)
	ent:Spawn()
	if IsValid(parent) then ent:SetParent(parent) end
	ent:SetKeyValue("soundtype", sndtype)
	ent:SetKeyValue("volume", volume)
	ent:SetKeyValue("duration", duration)
	ent:Activate()
	ent:Fire("EmitAISound")
	
	if !IsValid(parent) then
		timer.Simple(duration, function()
			if IsValid(ent) then
				ent:Remove()
			end
		end)
	end

	return ent
end

function ENT:UpdateOnRemove()
	if self:IsFlagSet(FL_GRAPHED) then
	// this entity was a LinkEnt in the world node graph, so we must remove it from
	// the graph since we are removing it from the world.
		/*for ( i = 0 ; i < WorldGraph.m_cLinks ) do
			if ( WorldGraph.m_pLinkPool [ i ].m_pLinkEnt == pev ) then
				// if this link has a link ent which is the same ent that is removing itself, remove it!
				WorldGraph.m_pLinkPool [ i ].m_pLinkEnt = NULL;
			end
		end*/
	end
	/*if pev->globalname then
		gGlobalState.EntitySetState( pev->globalname, GLOBAL_DEAD );
	end*/
end

function ENT:SUB_Remove()
	--self:UpdateOnRemove()
	if self:Health() > 0 then
		// this situation can screw up monsters who can't tell their entity pointers are invalid.
		self:SetHealth(0)
		print("SUB_Remove called on entity with health > 0\n")
	end

	self:Remove()
end

function ENT:GetOwnerGravity()
	local owner = self:GetOwner()
	local ownerGravity = 1
	if IsValid(owner) then
		ownerGravity = owner:GetGravity()
	end
	return ownerGravity
end

function ENT:SetCorrectGravity()
	local svgravity = cvars.Number("sv_gravity", 800)
	if svgravity != 0 then
		local gravityMul = 400 / svgravity * self:GetOwnerGravity()
		self:SetGravity(gravityMul)
	end
end