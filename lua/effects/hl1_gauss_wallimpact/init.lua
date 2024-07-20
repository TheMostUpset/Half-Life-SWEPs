function EFFECT:Init(data)
	self:SetRenderMode(RENDERMODE_GLOW)
	self:SetRenderFX(kRenderFxNoDissipation)
	local vecStart = data:GetOrigin()
	local vecDir = data:GetNormal()
	local flMagnitude = data:GetMagnitude()
	
	local alpha = math.Clamp(flMagnitude - 100, 0, 255)
	local size = flMagnitude / 25 + 25

	local emitter = ParticleEmitter(vecStart, true)

	local glow = emitter:Add("hl1/sprites/hotglow", vecStart + vecDir)
	glow:SetAngles(vecDir:Angle() - Angle(0,0,90))
	glow:SetVelocity(Vector(0,0,0))
	glow:SetAirResistance(0)
	glow:SetGravity(Vector(0, 0, 0))
	glow:SetDieTime(6)
	glow:SetStartAlpha(alpha)
	glow:SetEndAlpha(0)
	glow:SetStartSize(size)
	glow:SetEndSize(size)
	glow:SetColor(120, 150, 80)

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end