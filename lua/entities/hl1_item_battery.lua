AddCSLuaFile()

ENT.Base = "hl1_item_pickup_base"
ENT.Type = "anim"
ENT.PrintName = "Suit Battery"
ENT.Category = "Half-Life"
ENT.Author = "Upset"
ENT.Spawnable = true

ENT.Model = "models/w_battery.mdl"

function ENT:HEV_ArmorPickup(ply, maxarmor)
end

function ENT:Pickup(ply)
	if !ply:IsSuitEquipped() then return end
	local armor = ply:Armor()
	local maxarmor = 100
	if armor >= maxarmor then return end
	ply:SetArmor(math.min(armor + GetConVarNumber("sk_battery"), maxarmor))
	ply:EmitSound("items/gunpickup2.wav", 85)
	if self:ItemShouldRespawn() then
		self:RespawnItem()
	else
		self:Remove()
	end
	self.Pickable = false
	self:PickupMessage(ply)
	self:HEV_ArmorPickup(ply, maxarmor)
end