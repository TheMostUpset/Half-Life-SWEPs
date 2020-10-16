AddCSLuaFile("shared.lua")
include("shared.lua")

local iHornetTrail = "sprites/laserbeam.vmt"
ENT.TrailLifeTime = 1

local HORNET_TYPE_RED = 0
local HORNET_TYPE_ORANGE = 1
local HORNET_RED_SPEED = 600
local HORNET_ORANGE_SPEED = 800

function ENT:Initialize()
	self:SetMoveType(MOVETYPE_FLY)
	self:SetSolid(SOLID_BBOX)
	self:SetHealth(1)
	--[[if !game.SinglePlayer() then
		self.m_flStopAttack = CurTime() + 3.5
	else
		self.m_flStopAttack = CurTime() + 5
	end]]
	if math.random(1,5) <= 2 then
		self.m_iHornetType = HORNET_TYPE_RED
		self.m_flFlySpeed = HORNET_RED_SPEED
	else
		self.m_iHornetType = HORNET_TYPE_ORANGE
		self.m_flFlySpeed = HORNET_ORANGE_SPEED
	end
	self:SetModel("models/hornet.mdl")
	local size = 4
	local mins, maxs = Vector(-size, -size, -size), Vector(size, size, size)
	self:SetCollisionBounds(mins, maxs)

	self.m_flDamage = cvars.Number("hl1_sk_plr_dmg_hornet", 7)
	//self:NextThink(CurTime() + .1)
	self:ResetSequenceInfo()
	
	self:IgniteTrail()
end

function ENT:Touch(ent)
	if !ent or !ent:IsSolid() or ent:GetSolidFlags() == FSOLID_VOLUME_CONTENTS or self.noDamage then
		return
	end

	if IsValid(self.Owner) and ent:Health() > 0 and ent:GetClass() != "nihilanth_energy_ball" then
		self:EmitSound("Hornet.Die")
		local dmginfo = DamageInfo()
		dmginfo:SetAttacker(self.Owner)
		dmginfo:SetInflictor(self)
		dmginfo:SetDamage(self.m_flDamage)
		dmginfo:SetDamageType(DMG_NEVERGIB)
		dmginfo:SetDamageForce(self:GetForward() * 2000)
		dmginfo:SetDamagePosition(self:GetPos())
		ent:TakeDamageInfo(dmginfo)
	end

	self.noDamage = true
	self:SetLocalVelocity(Vector())
	self:SetMoveType(MOVETYPE_NONE)
	self:AddEffects(EF_NODRAW)
	self:AddSolidFlags(FSOLID_NOT_SOLID)// intangible
	SafeRemoveEntityDelayed(self, self.TrailLifeTime)
end

function ENT:IgniteTrail()
	local vColor
	if self.m_iHornetType == HORNET_TYPE_RED then
		vColor = Color(179, 39, 14, 128)
	else
		vColor = Color(255, 128, 0, 128)
	end

	util.SpriteTrail(self, 0, vColor, true, 4, 2, self.TrailLifeTime, .05, iHornetTrail)
end