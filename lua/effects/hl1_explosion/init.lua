EFFECT.mat = Material("hl1/sprites/zerogxplode")
local exists = file.Exists("materials/sprites/zerogxplode.vtf", "GAME")
local cvar_light = GetConVar("hl1_cl_firelight")

function EFFECT:Init(data)
	self.Pos = data:GetOrigin()
	self.Norm = data:GetNormal()
	self.Scale = data:GetScale()
	
	if cvar_light:GetBool() then
		local dynlight = DynamicLight(self:EntIndex())
		dynlight.Pos = data:GetOrigin()
		dynlight.Size = 6 * self.Scale
		dynlight.Decay = 10 * self.Scale
		dynlight.R = 255
		dynlight.G = 150
		dynlight.B = 50
		dynlight.Brightness = 4
		dynlight.DieTime = CurTime()+.4
	end
	
	self.Time = 0
	self.Size = 6 * self.Scale
	
	self:SetRenderBoundsWS(data:GetOrigin(), self.Pos, Vector(self.Scale/2, self.Scale/2, self.Scale/2))

	if !self.mat:IsError() and exists then
		self.Animated = true
	end
end

function EFFECT:Think()
	self.Time = self.Time + FrameTime()
	//self.Size = 256 * self.Time

	return self.Time < 1
end

function EFFECT:Render()
	render.SetMaterial(self.mat)
	if self.Animated then
		self.mat:SetInt("$frame", math.Clamp(math.floor(self.Time*15), 0, 14))
	end
	render.DrawSprite(self.Pos, self.Size, self.Size, Color(255, 255, 255, 255))
end