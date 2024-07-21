AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("HL1_HUDPickupMessage")

function ENT:KeyValue(k, v)
	if k == "respawnable" then
		self.Respawnable = tobool(v)
	elseif k == "OnPlayerTouch" then
		self:StoreOutput(k, v)
	end
end

function ENT:Initialize()
	if !self:IsInWorld() then
		print(self:GetClass().." is not in world, removing!", self:GetPos())
		self:Remove()
	end
	self:SetModel(self.Model)
	self:SetMoveType(MOVETYPE_FLYGRAVITY)
	self:SetMoveCollide(MOVECOLLIDE_FLY_BOUNCE)
	-- self:SetSolid(SOLID_BSP)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetCollisionBounds(Vector(-8, -8, 0), Vector(8, 8, 8))
	self:SetTrigger(true)
	self:UseTriggerBounds(true, 16)
	//local tr = util.QuickTrace(self:GetPos() + Vector(0,0,1), self:GetUp() * -64, self)
	//self:SetPos(tr.HitPos)
	self:DrawShadow(true)
	self.Pickable = true
	self:SpecialInit()
end

function ENT:SpecialInit()
end

function ENT:ItemShouldRespawn()
	return (self:IsMultiplayerRules() or (!game.SinglePlayer() and GAMEMODE.Cooperative)) and self:CreatedByMap() or self.Respawnable
end

function ENT:RespawnItem(delay)
	delay = delay or self.RespawnTime or cvars.Number("hl1_sv_itemrespawntime", 23)
	self:SetNoDraw(true)
	self.nextSpawnTime = CurTime() + delay
end

function ENT:RespawnThink()
	if self.nextSpawnTime and CurTime() >= self.nextSpawnTime then
		self.nextSpawnTime = nil
		self.Pickable = true
		self:SetNoDraw(false)
		self:EmitSound("items/suitchargeok1.wav", 80, 150)
	end
end

function ENT:Think()
	self:RespawnThink()
	
	local tr = util.TraceEntity({
		start = self:GetPos(),
		endpos = self:GetPos() - Vector(0,0,10),
		filter = self
	}, self)

	if self:OnGround() and tr.Fraction >= 1 then
		self:SetLocalVelocity(Vector(0,0,1))
	end
end

local movingEntityTable = {
	["func_door"] = true,
	["func_platrot"] = true,
	["func_train"] = true,
	["func_tracktrain"] = true,
	["func_trackchange"] = true,
	["func_rotating"] = true,
}

function ENT:Touch(ent)
	if IsValid(ent) then
		if ent:IsPlayer() and ent:Alive() and self.Pickable and hook.Run("PlayerCanPickupItem", ent, self) then
			self:Pickup(ent)
		end
		if movingEntityTable[ent:GetClass()] then
			if !self:IsOnGround() then
				local tr = util.TraceEntity({
					start = self:GetPos(),
					endpos = self:GetPos() - Vector(0,0,1),
					filter = self
				}, self)
				if IsValid(tr.Entity) then
					self:SetGroundEntity(tr.Entity)
				end
			end
			local groundent = self:GetGroundEntity()
			if IsValid(groundent) and groundent == ent then
				self:SetMoveType(MOVETYPE_NONE)
				self:SetMoveCollide(MOVECOLLIDE_FLY_CUSTOM)
				self:SetParent(ent)
			end
		end
	end
end

function ENT:PickupMessage(ent, class)
	class = class or self:GetClass()
	net.Start("HL1_HUDPickupMessage")
	net.WriteString(class)
	net.Send(ent)
end