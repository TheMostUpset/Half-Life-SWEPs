include('shared.lua')

function ENT:ExplosionEffects(pos, norm, scale)
	if !IsFirstTimePredicted() then return end
	pos = pos or self:GetPos()
	norm = norm or Vector()
	scale = scale or 33
	
	pos = pos + norm * (scale / 2 + 28)
	local tr = util.QuickTrace(pos, Vector(0,0,10), self)
	pos = tr.HitPos
	tr = util.QuickTrace(pos, Vector(0,0,5), self)
	if norm[3] > 0 and !tr.Hit then
		pos = tr.HitPos
	end

	local explosion = EffectData()
	explosion:SetOrigin(pos)
	explosion:SetNormal(norm)
	explosion:SetScale(scale)
	explosion:SetFlags(1)
	util.Effect("hl1_explosion", explosion)
	util.Effect("hl1_explosionsmoke", explosion)
	
	if self:WaterLevel() == 0 then
		--self:EmitSound("weapons/debris"..math.random(1,3)..".wav", 80, 100, 1, CHAN_VOICE)
	end
	
	--self:EmitSound("hl1/weapons/explode"..math.random(3,5)..".wav", 400, 100, 1, CHAN_ITEM)
end