include('shared.lua')

function ENT:Detonate()
	local tr = util.QuickTrace(self:GetPos(), -self:GetUp(), self)
	local pos, norm = tr.HitPos, tr.HitNormal

	if norm:Length() == 0 then
		pos = pos + Vector(0,0,40)
	end
	self:ExplosionEffects(pos, norm, 63)
end