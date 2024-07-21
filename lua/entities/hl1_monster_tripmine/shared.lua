ENT.Type			= "anim"
ENT.Base			= "ent_hl1_base"
ENT.PrintName		= "HL1 Tripmine"
ENT.Author			= "Upset"
ENT.MaxDistance		= 2048

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "DrawLaser")
end

function ENT:BeamTrace(startPos, endPos, filterAdd)
	local trFilter = self
	if filterAdd then
		trFilter = {self}
		table.insert(trFilter, filterAdd)
	end
	local tr = util.TraceHull({
		start = startPos + self:GetForward() * 9, -- extra space to prevent exploding on stack
		endpos = endPos,
		filter = trFilter
	})
	return tr
end