AddCSLuaFile()

ENT.Base = "hl1_item_pickup_base"
ENT.Type = "anim"
ENT.PrintName = "Medkit"
ENT.Category = "Half-Life"
ENT.Author = "Upset"
ENT.Spawnable = true

ENT.Model = "models/w_medkit.mdl"

function ENT:Pickup(ply)
	if hook.Run("PlayerCanPickupItem", ply, self) == false then return end
	local hp = ply:Health()
	local maxhp = ply:GetMaxHealth()
	if hp >= maxhp then return end
	ply:SetHealth(math.min(hp + GetConVarNumber("sk_healthkit"), maxhp))
	ply:EmitSound("items/smallmedkit1.wav", 85)
	if self:ItemShouldRespawn() then
		self:RespawnItem()
	else
		self:Remove()
	end
	self.Pickable = false
	self:PickupMessage(ply)
end