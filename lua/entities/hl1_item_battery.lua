AddCSLuaFile()

ENT.Base = "hl1_item_pickup_base"
ENT.Type = "anim"
ENT.PrintName = "Suit Battery"
ENT.Category = "Half-Life"
ENT.Author = "Upset"
ENT.Spawnable = true

ENT.Model = "models/w_battery.mdl"

function ENT:Pickup(ply)
	if hook.Run("PlayerCanPickupItem", ply, self) == false then return end
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
	
	--[[local pct = math.Round((ply:Armor() * 100) * (1.0/maxarmor) + 0.5)
	pct = (pct / 5)
	if pct > 0 then
		pct = pct - 1
	end
	pct = math.floor(pct)
	EmitSentence("HEV_"..pct.."P", ply:GetPos(), ply:EntIndex(), CHAN_VOICE, 0.5)]]
end