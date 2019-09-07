AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Pickup(ent)
	if hook.Run("PlayerCanPickupItem", ent, self) == false then return end
	local cvar = cvars.Bool("hl1_sv_clampammo")
	local ammoCount = ent:GetAmmoCount(self.AmmoType)
	if cvar and ammoCount >= self.MaxAmmo then return end
	local ammoGiven = 0
	if cvar then
		ammoGiven = ent:GiveAmmo(math.min(self.MaxAmmo - ammoCount, self.AmmoAmount), self.AmmoType)
	else
		ammoGiven = ent:GiveAmmo(self.AmmoAmount, self.AmmoType)
	end
	if ammoGiven == 0 then return end
	if self:ItemShouldRespawn() then
		self:RespawnItem()
	else
		self:Remove()
	end
	ent:EmitSound("items/9mmclip1.wav", 85)
	self.Pickable = false
end