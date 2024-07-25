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
	if IsValid(owner) and owner:IsPlayer() and owner:GetGravity() > 0 then
		return owner:GetGravity()
	end
	return 1
end

function ENT:SetCorrectGravity()
	local svgravity = cvars.Number("sv_gravity", 800)
	if svgravity != 0 then
		local gravityMul = 400 / svgravity * self:GetOwnerGravity()
		self:SetGravity(gravityMul)
	end
end