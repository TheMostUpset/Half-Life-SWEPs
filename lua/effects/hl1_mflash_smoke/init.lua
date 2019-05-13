function EFFECT:GetMuzzleFlashPos( Position, Ent, Attachment )
	
	if !IsValid(Ent) or !Ent:IsWeapon() then return Position end
	
	local ply = LocalPlayer()
	local specply = ply:GetObserverTarget()

	-- Shoot from the viewmodel
	if Ent:IsCarriedByLocalPlayer() and !ply:ShouldDrawLocalPlayer() or ply:GetObserverMode() == OBS_MODE_IN_EYE and IsValid(specply) and Ent:GetOwner() == specply then
	
		local ViewModel = ply:GetViewModel(0)
		
		if ( ViewModel:IsValid() ) then
			
			local att = ViewModel:GetAttachment( Attachment )
			if ( att ) then
				return att.Pos
			end
			
		end
	
	end

end

function EFFECT:Init(data)
	self.Position = data:GetOrigin()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	self.Normal = data:GetNormal()
	self.Size = data:GetScale()

	local pos = self:GetMuzzleFlashPos(self.Position, self.WeaponEnt, self.Attachment)
	if !pos then return end
	local emitter = ParticleEmitter(pos)
	
	for i = 0, 10 do
		local smokecol = math.random(10, 60)
		local smoke = emitter:Add("particle/particle_smokegrenade", pos)
		smoke:SetVelocity(70 * self.Normal + VectorRand()*20*self.Size)
		smoke:SetAirResistance(0)
		smoke:SetGravity(Vector(0, 0, math.Rand(80, 100)))
		smoke:SetDieTime(math.Rand(.4, 1))
		smoke:SetStartAlpha(math.Rand(140, 250))
		smoke:SetEndAlpha(0)
		smoke:SetStartSize(math.Rand(1, 2) * self.Size)
		smoke:SetEndSize(math.Rand(10, 16) * self.Size)
		smoke:SetRoll(math.Rand(-90, 90))
		smoke:SetRollDelta(math.Rand(-4, 4))
		smoke:SetColor(smokecol, smokecol, smokecol)
	end

	emitter:Finish()
	
	self:SetRenderBoundsWS(pos, self.Position)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end