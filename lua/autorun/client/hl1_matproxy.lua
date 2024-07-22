local function ChromeFixProxy(ent)
	if !IsValid(ent) then return end

	local lightCol = render.GetLightColor(ent:GetPos() + Vector(0,0,2))
	local hdrScale = render.GetToneMappingScaleLinear()
	if hdrScale[1] != 1 then -- checking for HDR
		lightCol = lightCol * 1.75 + hdrScale / 28
	else
		lightCol = lightCol * 2
	end
	
	return lightCol
end
matproxy.Add(
{
	name = "HL1Chrome",
	init = function(self, mat, values)
		self.ResultTo = values.resultvar
	end,		
	bind = function(self, mat, ent)
		local col = ChromeFixProxy(ent)
		if !col then return end
		mat:SetVector(self.ResultTo, col)
	end
})

local fTime = 0
local blinkSpeed = 24
local blinkDelay = 60
local function SnarkEyeProxy(ent)
	if !IsValid(ent) then return end
	local owner = ent:GetOwner()
	if !IsValid(owner) or !owner:IsPlayer() then return end
	
	local weapon = owner:GetActiveWeapon()
	if !weapon or !IsValid(weapon) then return end

	fTime = (fTime + FrameTime() * blinkSpeed) % blinkDelay
	local frame = math.floor(fTime)
	if frame == 3 then
		frame = 1
		blinkDelay = math.random(30, 200)
	elseif frame > 3 then
		frame = 0
	end
	
	return frame
end
matproxy.Add(
{
	name = "HL1SnarkEyeBlink",
	init = function(self, mat, values)
		self.ResultTo = values.resultvar
	end,		
	bind = function(self, mat, ent)
		local frame = SnarkEyeProxy(ent)
		if !frame then return end
		mat:SetInt(self.ResultTo, frame)
	end
})

local function GaussGlowProxy(ent)
	if !IsValid(ent) then return end
	local owner = ent:GetOwner()
	if !IsValid(owner) or !owner:IsPlayer() then return end
	local wep = ent
	if !wep:IsWeapon() then
		wep = owner:GetActiveWeapon()
	end
	if !IsValid(wep) or !wep.GetInAttack then return end
	
	local idleCol = render.GetLightColor(ent:GetPos()) * 1.5
	for i = 1, 3 do
		idleCol[i] = math.max(idleCol[i], .4)
	end

	local col = idleCol * (math.sin(CurTime() * 5) * .1 + 1)
	if wep:GetInAttack() > 0 then
		local charge = math.abs(wep:GetStartCharge() - CurTime()) / wep:GetFullChargeTime()
		col = idleCol + Vector(1,1,1) * charge
	end

	return col
end
matproxy.Add(
{
	name = "HL1GaussGlow",
	init = function(self, mat, values)
		self.ResultTo = values.resultvar
	end,		
	bind = function(self, mat, ent)
		local col = GaussGlowProxy(ent)
		if !col then return end
		mat:SetVector(self.ResultTo, col)
	end
})