function EFFECT:GetBeamPos(Position, Ent, Attachment)
	
	if !IsValid(Ent) then return Position end
	if !Ent:IsWeapon() then return Position end
	
	local ply = LocalPlayer()
	local specply = ply:GetObserverTarget()

	-- Shoot from the viewmodel
	if Ent:IsCarriedByLocalPlayer() and !ply:ShouldDrawLocalPlayer() or ply:GetObserverMode() == OBS_MODE_IN_EYE and IsValid(specply) and Ent:GetOwner() == specply then
	
		local ViewModel = ply:GetViewModel(modelindex)
		
		if ( ViewModel:IsValid() ) then
			
			local att = ViewModel:GetAttachment( Attachment )
			if ( att ) then
				Position = att.Pos
			end
			
		end
	
	-- Shoot from the world model
	else

		local att = Ent:GetAttachment( Attachment )
		if ( att ) then
			Position = att.Pos
		else
			local owner = Ent:GetOwner()
			if IsValid(owner) then
				local hand = owner:GetAttachment(owner:LookupAttachment("anim_attachment_rh"))
				if hand then
					Position = hand.Pos + hand.Ang:Forward() * 28 + hand.Ang:Right() * -1 + hand.Ang:Up() * 4
				end
			end
		end
	
	end

	return Position

end

EFFECT.Mat = Material("hl1/sprites/smoke")

function EFFECT:Init(data)
	self.Position = data:GetOrigin()
	self.StartPos = data:GetStart()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	//self.Normal = data:GetNormal()
	self.Flags = data:GetFlags()
	self.Size = data:GetScale()
	self.DieTime = .1
	if data:GetColor() == 1 then
		self.Color = Color(255, 255, 0, 255)
	else
		self.Color = Color(255, 255, 255, 255)
	end
	local pos = self:GetBeamPos(self.Position, self.WeaponEnt, self.Attachment)
	self:SetRenderBoundsWS(pos, self.Position)
end

function EFFECT:Think()
	self.DieTime = self.DieTime - FrameTime()
	return self.DieTime > 0
end

function EFFECT:Render()
	local pos = self.Flags == 1 and self:GetBeamPos(self.Position, self.WeaponEnt, self.Attachment) or self.StartPos
	render.SetMaterial(self.Mat)
	render.DrawBeam(pos, self.Position, self.Size, 0, 1, self.Color)
end