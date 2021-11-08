AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.PickupSound = "items/9mmclip1.wav"

function ENT:Pickup(ent)
	local cvar = cvars.Bool("hl1_sv_clampammo")
	local ammoCount = ent:GetAmmoCount(self.AmmoType)
	local ammoMax = self.MaxAmmo
	local ammoMaxMul = ent.HL1MaxAmmoMultiplier
	if ammoMaxMul then
		ammoMax = math.Round(ammoMax * ammoMaxMul)
	end
	if cvar and ammoCount >= ammoMax then return end
	if self:ItemShouldRespawn() then
		self:RespawnItem()
	else
		self:Remove()
	end
	if cvar then
		ent:GiveAmmo(math.min(ammoMax - ammoCount, self.AmmoAmount), self.AmmoType)
	else
		ent:GiveAmmo(self.AmmoAmount, self.AmmoType)
	end
	ent:EmitSound(self.PickupSound, 85, 100, 1, CHAN_ITEM)
	self.Pickable = false
end