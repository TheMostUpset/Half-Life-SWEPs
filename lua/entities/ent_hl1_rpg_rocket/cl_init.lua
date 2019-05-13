include('shared.lua')

function ENT:Draw()
	self:DrawModel()

	local pos = self:GetPos() - self:GetForward()*32
	local vel = self:GetVelocity()

	if self:WaterLevel() >= 3 and vel:Length() > 100 then
		if !self.emitter then self.emitter = ParticleEmitter(self:GetPos()) end	

		local particle = self.emitter:Add("hl1/sprites/bubble", pos)
		if particle then
			particle:SetVelocity(VectorRand() * 10)
			particle:SetAirResistance(0)
			particle:SetGravity(Vector(0, 0, 100))
			particle:SetDieTime(math.Rand(.2, 2))
			particle:SetStartAlpha(math.Rand(150,255))
			particle:SetEndAlpha(0)
			particle:SetStartSize(0)
			particle:SetEndSize(math.Rand(5, 10))
			particle:SetRoll(math.Rand(-90, 90))
			particle:SetRollDelta(math.Rand(-.25, .25))
			particle:SetColor(255, 255, 255)
		end
	
	end
end

function ENT:OnRemove()
	if self.emitter and self.emitter:IsValid() then
		self.emitter:Finish()
	end
end