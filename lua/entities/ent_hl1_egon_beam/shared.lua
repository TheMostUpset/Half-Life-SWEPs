if SERVER then AddCSLuaFile("shared.lua") end

ENT.Type			= "anim"
ENT.PrintName		= "HL1 Gluon Beam"
ENT.Author			= "Upset"

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "WepEntity")
	self:NetworkVar("Entity", 1, "HitEntity")
	self:NetworkVar("Vector", 0, "EndPos")
end

if SERVER then

	function ENT:Initialize()
		self:DrawShadow(false)
	end

end

if SERVER then return end

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:GetBeamPos(Position, Ent, Attachment)
	if !IsValid(Ent) then return Position end
	if !Ent:IsWeapon() then return Position end
	
	local ply = LocalPlayer()
	local specply = ply:GetObserverTarget()

	if (!Ent:IsCarriedByLocalPlayer() or ply:ShouldDrawLocalPlayer()) and !(ply:GetObserverMode() == OBS_MODE_IN_EYE and IsValid(specply) and Ent:GetOwner() == specply) then

		local att = Ent:GetAttachment(Attachment)
		if att then
			return att.Pos
		end
	
	end
end

function ENT:Initialize()
	self:SetRenderBoundsWS(self:GetPos(), self:GetEndPos())
end

local matBeam = Material("hl1/sprites/xbeam1")
local matFlare = Material("hl1/sprites/xspark1")

function ENT:Draw()
end

function ENT:DrawTranslucent()
	local startPos = self:GetBeamPos(self:GetPos(), self:GetWepEntity(), 1)
	if !startPos then return end
	local endPos = self:GetEndPos()
	local dist = startPos:Distance(endPos)
	dist = math.min(dist, 2048)
	local stepSize = 16
	
	local texWidth = 10
	local texScroll = CurTime() * 10
	local color = Color( 50, 50, 255, 255 )
	local RingTightness = 0.025
	
	local Angle = self:GetOwner():GetAimVector():Angle()
	local Forward	= Angle:Forward()
	local Right 	= Angle:Right()
	local Up 		= Angle:Up()
		
	render.SetMaterial(matBeam)
	render.StartBeam(128)
	render.AddBeam(startPos, texWidth, texScroll, color)
	for i = 0, dist, stepSize do
		local sin = math.sin( CurTime() + i * RingTightness )
		local cos = math.cos( CurTime() + i * RingTightness )
		
		local prog = i * i * .2 / dist
		prog = math.min(prog, 16)
		
		local Pos = startPos + (Forward * i) + (Up * sin * prog) + (Right * cos * prog)
		
		render.AddBeam(Pos, texWidth, texScroll + i / 64, color)
	end
	render.AddBeam(endPos, texWidth, texScroll, color)
	render.AddBeam(endPos, texWidth, texScroll, color)		
	render.EndBeam()
	
	render.StartBeam(10)
	render.AddBeam(startPos, texWidth, texScroll, color)
	for i = 0, dist / 32, stepSize do		
		local Pos = startPos + (Forward * i * 16) + VectorRand() * i / 2
		
		render.AddBeam(Pos, texWidth, texScroll + i / 32, color)	
	end
	render.AddBeam(endPos, texWidth, texScroll, color)
	render.AddBeam(endPos, texWidth, texScroll, color)
	render.EndBeam()

	local hitEnt = self:GetHitEntity()
	if hitEnt != NULL and hitEnt:Health() <= 0 then
		render.SetMaterial(matFlare)
		render.DrawSprite(endPos, 32, 32, Color(255,255,255,255))
	end
end

function ENT:Think()
	self:SetRenderBoundsWS(self:GetPos(), self:GetEndPos())
end