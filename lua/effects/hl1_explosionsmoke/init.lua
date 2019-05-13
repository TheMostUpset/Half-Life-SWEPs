function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local norm = data:GetNormal()
	local emitter = ParticleEmitter(pos)
	local col = math.random(0, 30)

	if emitter:IsValid() then
		for i = 0,30 do
			local vel = Vector(0,0,250) + norm * 50 + VectorRand() * 60
			if norm[3] < -.5 then
				vel = VectorRand() * 150
				vel[3] = norm[3] * 10
			end
			
			local particle = emitter:Add("particle/particle_smokegrenade", pos)
			particle:SetCollide(true)
			particle:SetVelocity(vel)
			particle:SetAirResistance(100)
			particle:SetGravity(Vector(0, 0, 60) + VectorRand() * 150)
			particle:SetDieTime(math.Rand(1.5, 3))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(0)
			particle:SetEndSize(math.Rand(60, 120))
			particle:SetRoll(math.Rand(-90, 90))
			particle:SetRollDelta(math.Rand(-1, 1))
			particle:SetColor(col, col, col)
		end

		emitter:Finish()
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end