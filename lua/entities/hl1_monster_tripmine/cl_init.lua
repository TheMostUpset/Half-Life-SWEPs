include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.LaserMaterial = Material("hl1/sprites/laserbeam")
ENT.LaserColor = Color(0, 214, 198, 64)

function ENT:Think()
	self.tr = util.TraceHull({
		start = self:GetPos(),
		endpos = self:GetPos() + self:GetForward() * self.MaxDistance,
		filter = self
	})
	
	local tr = self.tr
	
	self:SetRenderBoundsWS(tr.StartPos, tr.HitPos, Vector(8,8,8))
end

function ENT:DrawTranslucent()
	if !self:GetDrawLaser() then return end
	
	local tr = self.tr

	if tr then
		local texScroll = CurTime() * 10
		render.SetMaterial(self.LaserMaterial)
		render.DrawBeam(tr.StartPos, tr.HitPos, 2, texScroll, texScroll, self.LaserColor)
	end
end