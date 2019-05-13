function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local norm = data:GetNormal()
	local emitter = ParticleEmitter(pos)
	local amount = math.random(1, 7)
	for i = 0, amount do
		local size = math.Rand(6, 12)
		local sparks = emitter:Add("hl1/sprites/hotglow", pos)
		sparks:SetCollide(true)
		sparks:SetBounce(.6)
		sparks:SetVelocity(norm * math.random(100, 260) + VectorRand() * math.random(30, 60))
		sparks:SetAirResistance(0)
		sparks:SetGravity(Vector(0, 0, -400))
		sparks:SetDieTime(math.Rand(2, 8))
		sparks:SetStartAlpha(255)
		sparks:SetEndAlpha(0)
		sparks:SetStartSize(size)
		sparks:SetEndSize(size)
		sparks:SetRoll(math.Rand(-90, 90))
		sparks:SetRollDelta(math.Rand(-.4, .4))
		sparks:SetColor(170, 255, 255)
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end