local cvar_light = GetConVar("hl1_cl_firelight")
local cvar_muzzle = GetConVar("hl1_cl_muzzleflash")
local cvar_smoke = GetConVar("hl1_cl_muzzlesmoke")

function EFFECT:GetMuzzleFlashPos(Position, Ent, Attachment)

	if !IsValid(Ent) then return Position end
	if !Ent:IsWeapon() then return Position end
	
	local ply = LocalPlayer()
	local specply = ply:GetObserverTarget()
	local owner = Ent:GetOwner()

	-- Shoot from the viewmodel
	if Ent:IsCarriedByLocalPlayer() and !ply:ShouldDrawLocalPlayer() or ply:GetObserverMode() == OBS_MODE_IN_EYE and IsValid(specply) and owner == specply then
	
		local ViewModel = ply:GetViewModel()
		
		if ViewModel:IsValid() then
			
			local att = ViewModel:GetAttachment(Attachment)
			if att then
				Position = att.Pos
			end
			
		end
	
	-- Shoot from the world model
	else
	
		if IsValid(owner) and (ply:IsLineOfSightClear(owner) or owner == ply) then
			local att = Ent:GetAttachment(Attachment)
			if att then
				Position = att.Pos
			else
				local hand = owner:GetAttachment(owner:LookupAttachment("anim_attachment_rh"))
				if hand then
					Position = hand.Pos + hand.Ang:Forward() * self.WPos[1] + hand.Ang:Right() * self.WPos[2] + hand.Ang:Up() * self.WPos[3]
				end
			end
		end
	
	end

	return Position

end

function EFFECT:Init(data)
	self.Position = data:GetOrigin()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	self.WPos = data:GetStart()
	self.Normal = data:GetNormal()
	self.Size = data:GetScale()
	if IsValid(self.WeaponEnt) and self.WeaponEnt:IsWeapon() and self.WeaponEnt:IsCarriedByLocalPlayer() and !LocalPlayer():ShouldDrawLocalPlayer() then
		self.Size = self.Size * 90 / self.WeaponEnt.ViewModelFOV
	end
	self.DieTime = math.Rand(.04, .07)

	local pos = self:GetMuzzleFlashPos(self.Position, self.WeaponEnt, self.Attachment)
	local emitter = ParticleEmitter(pos)
	
	if !cvar_muzzle or cvar_muzzle:GetBool() then
		self.particle = emitter:Add( "hl1/sprites/muzzleflash1_hd", pos )
		self.particle:SetVelocity( 60 * self.Normal )
		self.particle:SetGravity( Vector(0,0,0) )
		self.particle:SetDieTime( self.DieTime )
		self.particle:SetStartAlpha( 255 )
		self.particle:SetStartSize( math.Rand(8, 10) * self.Size )
		self.particle:SetEndSize( math.Rand(12, 14) * self.Size )
		self.particle:SetRoll( math.Rand( -180, 180 ) )
		self.particle:SetRollDelta( math.Rand( -1, 1 ) )
		self.particle:SetColor( 255, 255, 255 )	
	end
		
	if !cvar_smoke or cvar_smoke:GetBool() then
		for i = 1, 4 do
			local smokecol = math.random(40, 170)
			local smoke = emitter:Add("particle/particle_smokegrenade", pos)
			smoke:SetVelocity(40 * self.Normal * i)
			smoke:SetAirResistance(128)
			smoke:SetGravity(Vector(0, 0, math.Rand(50, 140)))
			smoke:SetDieTime(math.Rand(.1, .5))
			smoke:SetStartAlpha(math.Rand(160, 255))
			smoke:SetEndAlpha(0)
			smoke:SetStartSize(math.Rand(0, 1) * self.Size)
			smoke:SetEndSize(math.Rand(5, 15) * self.Size)
			smoke:SetRoll(math.Rand(-180, 180))
			smoke:SetRollDelta(math.Rand(-3, 3))
			smoke:SetColor(smokecol, smokecol, smokecol)
		end
	end

	emitter:Finish()
	
	if !cvar_light or cvar_light:GetBool() then
		local dynlight = DynamicLight(self:EntIndex())
		dynlight.Pos = pos
		dynlight.Size = 75
		dynlight.Decay = 900
		dynlight.R = 255
		dynlight.G = 140
		dynlight.B = 30
		dynlight.Brightness = 4
		dynlight.DieTime = CurTime()+.07
	end
	
	self:SetRenderBoundsWS(pos, self.Position)
end

function EFFECT:Think()
	if !self.particle then return false end
	local pos = self:GetMuzzleFlashPos(self.Position, self.WeaponEnt, self.Attachment, self.ModelIndex)
	self.particle:SetPos(pos)
	self.DieTime = self.DieTime - FrameTime()
	return self.DieTime > 0
end

function EFFECT:Render()
end