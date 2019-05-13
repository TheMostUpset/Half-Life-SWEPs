include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

local laser = Material("hl1/sprites/laserbeam")

function ENT:Think()
	local tr = util.TraceHull({
		start = self:GetPos(),
		endpos = self:GetPos() + self:GetForward() * self.MaxDistance,
		filter = self
	})
	
	self:SetRenderBoundsWS(tr.StartPos, tr.HitPos, Vector(8,8,8))
end

function ENT:DrawTranslucent()
	if !self:GetDrawLaser() then return end
	
	local tr = util.TraceHull({
		start = self:GetPos(),
		endpos = self:GetPos() + self:GetForward() * self.MaxDistance,
		filter = self
	})
	
	local texScroll = CurTime() * 10
	render.SetMaterial(laser)
	render.DrawBeam(tr.StartPos, tr.HitPos, 2, texScroll, texScroll, Color(0, 214, 198, 64))
end