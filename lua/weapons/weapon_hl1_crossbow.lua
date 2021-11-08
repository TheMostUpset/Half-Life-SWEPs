
if CLIENT then

	SWEP.PrintName			= "Crossbow"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 2
	SWEP.SlotPos			= 2
	SWEP.CrosshairXY		= {72, 0}
	SWEP.WepSelectIcon		= surface.GetTextureID("hl1/icons/crossbow")
	SWEP.AutoIconAngle		= Angle(0, 180, 0)
	
	net.Receive("HL1CrossbowSniperBolt", function()
		local pos = net.ReadVector()
		local ang = net.ReadAngle()
		local ent = net.ReadEntity()
		sound.Play("weapons/xbow_hit1.wav", pos, 80)
		local boltMdl = ClientsideModel("models/hl1/crossbow_bolt.mdl")
		boltMdl:SetPos(pos)
		boltMdl:SetAngles(ang)
		if IsValid(ent) and !ent:IsWorld() then
			boltMdl:SetParent(ent)
		end
		timer.Simple(10, function()
			boltMdl:Remove()
		end)
	end)
	
	if game.SinglePlayer() then
		net.Receive("HL1CrossbowCrosshair", function()
			local xy, wh, ent = net.ReadTable(), net.ReadTable(), net.ReadEntity()
			ent.CrosshairXY = xy
			ent.CrosshairWH = wh
		end)
	end
	
else

	util.AddNetworkString("HL1CrossbowSniperBolt")
	if game.SinglePlayer() then
		util.AddNetworkString("HL1CrossbowCrosshair")
	end

end

SWEP.Base 				= "weapon_hl1_base"
SWEP.Weight				= 10
SWEP.HoldType			= "crossbow"
SWEP.TPReloadAnim		= ACT_HL2MP_GESTURE_RELOAD_AR2

SWEP.Category			= "Half-Life"
SWEP.Spawnable			= true

SWEP.PlayerModel		= Model("models/hl1/p_crossbow.mdl")
SWEP.EntModel			= Model("models/w_crossbow.mdl")

SWEP.CModel				= Model("models/hl1/c_crossbow.mdl")
SWEP.VModel				= Model("models/v_crossbow.mdl")

SWEP.ViewModel			= SWEP.CModel
SWEP.WorldModel			= SWEP.PlayerModel

SWEP.ReloadTime			= 4.5
SWEP.UnloadTime			= 1.1
SWEP.MagBone			= "Bone20"
SWEP.MagTime			= 3.5
SWEP.ReloadSound		= Sound("weapons/xbow_reload1.wav")

SWEP.Primary.Sound			= Sound("weapons/xbow_fire1.wav")
SWEP.Primary.Damage			= 120 -- damage for SniperBolt (mp rules)
SWEP.Primary.Recoil			= -2
SWEP.Primary.Cone			= .01
SWEP.Primary.Delay			= 0.75
SWEP.Primary.ClipSize 		= 5
SWEP.Primary.DefaultClip	= 5
SWEP.Primary.MaxAmmo		= 50
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "XBowBolt"

SWEP.Secondary.Delay		= 1
SWEP.Secondary.Automatic	= true

SWEP.SndHit		= Sound("weapons/xbow_hit1.wav")
SWEP.SndHitBody	= {Sound("weapons/xbow_hitbod1.wav"), Sound("weapons/xbow_hitbod2.wav")}

SWEP.BOLT_AIR_VELOCITY = 2000
SWEP.BOLT_WATER_VELOCITY = 1000

function SWEP:SpecialDeploy()
	if self:Clip1() <= 0 then
		self:SendWeaponAnim(ACT_CROSSBOW_DRAW_UNLOADED)
	end
end

function SWEP:SpecialHolster()
	if self:GetInZoom() then
		self:SecondaryAttack()
	end
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end

	if self:GetInZoom() && self:IsMultiplayerRules() then
		self:FireSniperBolt()
		return
	end
	self:FireBolt()
end

function SWEP:FireSniperBolt()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	
	if self:Clip1() <= 0 then
		self:PlayEmptySound()
		return
	end
	
	self:WeaponSound(nil, 80)
	self:EmitSound(self.ReloadSound, 70, 100, 0.5, CHAN_ITEM)
	self:TakeClipPrimary()
	if self:Clip1() > 0 then
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	else
		self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	end
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	
	local anglesAim = self.Owner:EyeAngles() + self.Owner:GetViewPunchAngles()
	local vecSrc = self.Owner:GetShootPos() - anglesAim:Up() * 2
	local vecDir = anglesAim:Forward()
	
	if SERVER then self.Owner:LagCompensation(true) end
	local tr = util.TraceLine({
		start = vecSrc,
		endpos = vecSrc + vecDir * 8192,
		mask = MASK_SHOT,
		filter = self.Owner
	})
	if SERVER then self.Owner:LagCompensation(false) end
	
	if !tr.Entity or tr.Entity == NULL then return end
	if tr.Entity:Health() > 0 then
		if SERVER then
			sound.Play(self.SndHitBody[math.random(1, 2)], tr.HitPos, 80)
		end
	else
		local pos = tr.HitPos - vecDir * 12
		local ang = vecDir:Angle()
		ang.z = math.random(0, 360)
		local ent = tr.Entity
		if SERVER then
			local filter = RecipientFilter()
			filter:AddAllPlayers()
			if !game.SinglePlayer() and self.Owner:IsListenServerHost() then
				filter:RemovePlayer(self.Owner)
			end
			net.Start("HL1CrossbowSniperBolt")
			net.WriteVector(pos)			
			net.WriteAngle(ang)
			net.WriteEntity(ent)
			net.Send(filter)
		elseif IsFirstTimePredicted() then	
			sound.Play("weapons/xbow_hit1.wav", pos, 80)
			local boltMdl = ClientsideModel("models/hl1/crossbow_bolt.mdl")
			boltMdl:SetPos(pos)
			boltMdl:SetAngles(ang)
			if IsValid(ent) and !ent:IsWorld() then
				boltMdl:SetParent(ent)
			end
			timer.Simple(10, function()
				if IsValid(boltMdl) then
					boltMdl:Remove()
				end
			end)
		end
		if IsFirstTimePredicted() then
			local effectdata = EffectData()
			effectdata:SetOrigin(tr.HitPos)
			util.Effect("cball_bounce", effectdata)
		end
	end
	
	local dmginfo = DamageInfo()
	dmginfo:SetAttacker(self.Owner)
	dmginfo:SetInflictor(self)
	dmginfo:SetDamage(self.Primary.Damage)
	dmginfo:SetDamageType(bit.bor(DMG_BULLET, DMG_NEVERGIB))
	dmginfo:SetDamageForce(vecDir * 6000)
	dmginfo:SetDamagePosition(tr.HitPos)
	tr.Entity:DispatchTraceAttack(dmginfo, tr, vecDir)
	
	local phys = tr.Entity:GetPhysicsObject()
	if IsValid(phys) then
		phys:ApplyForceOffset(vecDir * 4000, tr.HitPos)
	end
end

function SWEP:FireBolt()
	if self:Clip1() <= 0 then
		self:PlayEmptySound()
		return
	end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self:WeaponSound(nil, 80)
	self:EmitSound(self.ReloadSound, 70, 100, 0.5, CHAN_ITEM)
	self:TakeClipPrimary()
	if self:Clip1() > 0 then
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	else
		self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	end
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	
	if SERVER then
		local anglesAim, vecSrc, vecDir
		if self.Owner:IsPlayer() then
			anglesAim = self.Owner:EyeAngles() + self.Owner:GetViewPunchAngles()
			vecSrc = self.Owner:GetShootPos() - anglesAim:Up() * 2
			vecDir = anglesAim:Forward()
		else
			vecDir = self.Owner:GetAimVector()
			anglesAim = vecDir:Angle()
			vecSrc = self.Owner:GetShootPos() - anglesAim:Up() * 2
		end
	
		local pBolt = ents.Create("ent_hl1_crossbow_bolt")
		if IsValid(pBolt) then
			pBolt:SetPos(vecSrc)
			pBolt:SetAngles(anglesAim)
			pBolt:SetOwner(self.Owner)
			if self.Owner:WaterLevel() == 3 then				
				pBolt:SetVelocity(vecDir * self.BOLT_WATER_VELOCITY)
			else
				pBolt:SetVelocity(vecDir * self.BOLT_AIR_VELOCITY)
			end
			pBolt:SetLocalAngularVelocity(Angle(0,0,10))
			pBolt:Spawn()
		end
	end
	
	self:SendRecoil()
	if self:Clip1() <= 0 and self:rgAmmo() <= 0 then
		self:HEV_NoAmmo()
	end
	if self:Clip1() != 0 then
		self:SetWeaponIdleTime(CurTime() + 5)
	else
		self:SetWeaponIdleTime(CurTime() + self.Primary.Delay)
	end	
end

function SWEP:SecondaryAttack()
	if self:GetReloadTime() > 0 then return end
	if self:GetInZoom() then
		self:SetInZoom(false)
		self.Owner:SetCanZoom(true)
		self.Owner:SetFOV(0, 0)
		if CLIENT then
			self.CrosshairXY = {72, 0}
			self.CrosshairWH = {24, 24}
		elseif game.SinglePlayer() then
			net.Start("HL1CrossbowCrosshair")
			net.WriteTable({72, 0})
			net.WriteTable({24, 24})
			net.WriteEntity(self)
			net.Send(self.Owner)
		end		
	else
		self:SetInZoom(true)
		self.Owner:SetCanZoom(false)
		self.Owner:SetFOV(20, 0)
		if CLIENT then
			self.CrosshairXY = {25, 98}
			self.CrosshairWH = {104, 16}
		elseif game.SinglePlayer() then
			net.Start("HL1CrossbowCrosshair")
			net.WriteTable({25, 98})
			net.WriteTable({104, 16})
			net.WriteEntity(self)
			net.Send(self.Owner)
		end
	end		
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
end

function SWEP:Reload()
	if self:rgAmmo() <= 0 then
		return
	end	

	if self:GetInZoom() then
		self:SecondaryAttack()
	end

	self:DefReload()
end

function SWEP:SpecialThink()
	self:ResetEmptySound()
end

function SWEP:WeaponIdle(b)
	local iAnim
	local flRand = util.SharedRandom("flRand", 0, 1)
	if flRand <= 0.75 or b then		
		if self:Clip1() > 0 then
			iAnim = self:LookupSequence("idle1")
		else
			iAnim = self:LookupSequence("idle2")
		end
		self:SetWeaponIdleTime(CurTime() + math.Rand(10, 15))
	else
		if self:Clip1() > 0 then
			iAnim = self:LookupSequence("fidget1")
			self:SetWeaponIdleTime(CurTime() + 90.0 / 30.0)
		else
			iAnim = self:LookupSequence("fidget2")
			self:SetWeaponIdleTime(CurTime() + 80.0 / 30.0)
		end
	end
	self.Owner:GetViewModel():SendViewModelMatchingSequence(iAnim)
end

if SERVER then
	
	function SWEP:GetNPCBulletSpread()
		return 1
	end
	
end