function EFFECT:Init(data)
	self:SetRenderMode(RENDERMODE_GLOW)
	self:SetRenderFX(kRenderFxNoDissipation)
	local vecStart = data:GetOrigin()
	local vecNormal = data:GetNormal()
	local flMagnitude = data:GetMagnitude()
	
	local alpha = flMagnitude * 255
	//alpha = math.Clamp(alpha*255, 0, 255)
	local dieTime = flMagnitude / 25 + 1.225

	local emitter = ParticleEmitter(vecStart)

	local glow = emitter:Add("hl1/sprites/hotglow", vecStart)
	glow:SetVelocity(Vector(0,0,0))
	glow:SetAirResistance(0)
	glow:SetGravity(Vector(0, 0, 0))
	glow:SetDieTime(dieTime)
	glow:SetStartAlpha(alpha)
	glow:SetEndAlpha(0)
	glow:SetStartSize(8)
	glow:SetEndSize(8)
	glow:SetRoll(math.Rand(-90, 90))
	glow:SetRollDelta(0)
	glow:SetColor(170, 255, 255)

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end