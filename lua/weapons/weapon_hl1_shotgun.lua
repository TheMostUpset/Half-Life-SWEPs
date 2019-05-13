
if CLIENT then

	SWEP.PrintName			= "Shotgun"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 2
	SWEP.SlotPos			= 1
	SWEP.CrosshairXY		= {48, 24}
	SWEP.WepSelectIcon		= surface.GetTextureID("hl1/icons/shotgun")
	
	SWEP.ViewModelOffset = {
		PosForward = -.5,
		PosRight = .6,
		PosUp = 1,
		
		AngForward = 0,
		AngRight = 0,
		AngUp = 3
	}

end

SWEP.Base 				= "weapon_hl1_base"
SWEP.Weight				= 15
SWEP.HoldType			= "shotgun"

SWEP.Category			= "Half-Life"
SWEP.Spawnable			= true

SWEP.PlayerModel		= Model("models/hl1/p_shotgun.mdl")
SWEP.EntModel			= Model("models/w_shotgun.mdl")

SWEP.CModel				= Model("models/hl1/c_shotgun.mdl")
SWEP.VModel				= Model("models/v_shotgun.mdl")

SWEP.ViewModel			= SWEP.CModel
SWEP.WorldModel			= SWEP.PlayerModel

SWEP.ReloadTime = .5
SWEP.ReloadSnds = {Sound("weapons/reload1.wav"), Sound("weapons/reload3.wav")}
SWEP.AutoReload = false

SWEP.Primary.Sound			= Sound("weapons/sbarrel1.wav")
SWEP.Primary.Damage			= 5
SWEP.Primary.DamageCVar		= "hl1_sk_plr_dmg_buckshot"
SWEP.Primary.Recoil			= -5
SWEP.Primary.Cone			= 0.08716
SWEP.Primary.NumShots		= 6
SWEP.Primary.Delay			= 0.75
SWEP.Primary.ClipSize 		= 8
SWEP.Primary.DefaultClip	= 8
SWEP.Primary.MaxAmmo		= 125
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "buckshot"

SWEP.Secondary.Sound		= Sound("weapons/dbarrel1.wav")
SWEP.Secondary.Recoil		= -10
SWEP.Secondary.NumShots		= 12
SWEP.Secondary.Delay		= 1.5
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.MuzzleScale			= 2.5
SWEP.MuzzleSmoke			= true
SWEP.MuzzlePos				= Vector(24, 1, 8)

function SWEP:SpecialDT()
	self:NetworkVar("Int", 1, "fInSpecialReload")
	self:NetworkVar("Float", 2, "flPumpTime")
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end

	if self.Owner:WaterLevel() == 3 then
		self:PlayEmptySound()
		self:SetNextPrimaryFire(CurTime() + 0.15)
		return
	end
	if self:Clip1() <= 0 then
		self:Reload()
		if self:Clip1() == 0 then
			self:PlayEmptySound()
		end
		return
	end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	if self:IsMultiplayerRules() then
		self:ShootBullet(cvars.Number(self.Primary.DamageCVar, self.Primary.Damage), 4, Vector(0.08716, 0.04362, 0))
	else
		// regular old, untouched spread.
		self:ShootBullet(cvars.Number(self.Primary.DamageCVar, self.Primary.Damage), self.Primary.NumShots, self.Primary.Cone)
	end
	self:WeaponSound(self.Primary.Sound)
	self:TakeClipPrimary()
	self:HL1MuzzleFlash()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:EjectShell(self.Owner, 1)
	self:SendRecoil()
	
	if self:Clip1() != 0 then
		self:SetflPumpTime(CurTime() + 0.5)
	end
	
	if self:Clip1() != 0 then
		self:SetWeaponIdleTime(CurTime() + 5)
	else
		self:SetWeaponIdleTime(CurTime() + .75)
	end
	self:SetfInSpecialReload(0)
end

function SWEP:SecondaryAttack()
	if !self:CanPrimaryAttack() then return end

	if self.Owner:WaterLevel() == 3 then
		self:PlayEmptySound()
		self:SetNextPrimaryFire(CurTime() + 0.15)
		return
	end
	if self:Clip1() <= 1 then
		self:Reload()
		self:PlayEmptySound()
		return
	end
	self:SetNextPrimaryFire(CurTime() + self.Secondary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
	if self:IsMultiplayerRules() then
		// tuned for deathmatch
		self:ShootBullet(cvars.Number(self.Primary.DamageCVar, self.Primary.Damage), 8, Vector(0.17365, 0.04362, 0))
	else
		// untouched default single player
		self:ShootBullet(cvars.Number(self.Primary.DamageCVar, self.Primary.Damage), self.Secondary.NumShots, self.Primary.Cone)
	end
	self:WeaponSound(self.Secondary.Sound)
	self:TakeClipPrimary(2)
	self:HL1MuzzleFlash()
	self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:EjectShell(self.Owner, 1)
	self:EjectShell(self.Owner, 1)
	self:SendRecoil(1)
	
	if self:Clip1() != 0 then
		self:SetflPumpTime(CurTime() + 0.95)
	end
	
	if self:Clip1() != 0 then
		self:SetWeaponIdleTime(CurTime() + 6)
	else
		self:SetWeaponIdleTime(CurTime() + 1.5)
	end
	self:SetfInSpecialReload(0)
end

function SWEP:Reload()
	if self:rgAmmo() <= 0 || self:Clip1() >= self.Primary.ClipSize then
		return
	end
	
	// don't reload until recoil is done
	if self:GetNextPrimaryFire() > CurTime() then
		return
	end

	// check to see if we're ready to reload
	if self:GetfInSpecialReload() == 0 then
		self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
		self.Owner:SetAnimation(PLAYER_RELOAD)
		self:SetfInSpecialReload(1)
		self:SetWeaponIdleTime(CurTime() + .6)
		self:SetNextPrimaryFire(CurTime() + 1)
		self:SetNextSecondaryFire(CurTime() + 1)
		return
	elseif self:GetfInSpecialReload() == 1 then
		if self:GetWeaponIdleTime() > CurTime() then
			return
		end
		// was waiting for gun to move to side
		self:SetfInSpecialReload(2)
		self:EmitSound(self.ReloadSnds[math.random(1, 2)], 80, 85 + math.random(0, 31), 1, CHAN_ITEM)
		self:SendWeaponAnim(ACT_VM_RELOAD)
		self:SetWeaponIdleTime(CurTime() + self.ReloadTime)
	else
		// Add them to the clip
		self:SetClip1(self:Clip1() + 1)
		if !cvars.Bool("hl1_sv_unlimitedammo") then
			self.Owner:RemoveAmmo(1, self.Primary.Ammo)
		end
		self:SetfInSpecialReload(1)
	end
end

function SWEP:SpecialThink()
	self:ResetEmptySound()

	local flPumpTime = self:GetflPumpTime()
	if flPumpTime > 0 && flPumpTime < CurTime() then
		// play pumping sound
		self:EmitSound("weapons/scock1.wav", 85, 95 + math.random(0, 31), 1, CHAN_ITEM)
		self:SetflPumpTime(0)
	end
	
	if self:GetWeaponIdleTime() < CurTime() then	
		if (self:Clip1() == 0 && self:GetfInSpecialReload() == 0 && self:rgAmmo() > 0) then
			self:Reload()
		elseif self:GetfInSpecialReload() != 0 then
			if (self:Clip1() != self.Primary.ClipSize && self:rgAmmo() > 0) then
				self:Reload()
			else
				// reload debounce has timed out
				self:SendWeaponAnim(ACT_SHOTGUN_PUMP)
				
				// play cocking sound
				self:EmitSound("weapons/scock1.wav", 85, 95 + math.random(0, 31), 1, CHAN_ITEM)
				self:SetfInSpecialReload(0)
				self:SetWeaponIdleTime(CurTime() + 1.5)
			end
		else
			local iAnim
			local flRand = util.SharedRandom("flRand", 0, 1)
			if flRand <= .8 then
				iAnim = ACT_SHOTGUN_IDLE_DEEP
				self:SetWeaponIdleTime(CurTime() + 60.0/12.0)
			elseif flRand <= .95 then
				iAnim = ACT_VM_IDLE
				self:SetWeaponIdleTime(CurTime() + 20.0/9.0)
			else
				iAnim = ACT_SHOTGUN_IDLE4
				self:SetWeaponIdleTime(CurTime() + 20.0/9.0)
			end
			self:SendWeaponAnim(iAnim)
		end
	end
end