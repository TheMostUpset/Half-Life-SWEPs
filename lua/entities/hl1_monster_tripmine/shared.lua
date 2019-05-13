ENT.Type			= "anim"
ENT.Base			= "ent_hl1_base"
ENT.PrintName		= "HL1 Tripmine"
ENT.Author			= "Upset"
ENT.MaxDistance		= 2048

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "DrawLaser")
end