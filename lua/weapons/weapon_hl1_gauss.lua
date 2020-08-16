
if CLIENT then

	SWEP.PrintName			= "Tau Cannon"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 1
	SWEP.CrosshairXY		= {48, 48}
	SWEP.WepSelectIcon		= surface.GetTextureID("hl1/icons/gauss")

end

SWEP.Base 				= "weapon_hl1_base"
SWEP.Weight				= 20
SWEP.HoldType			= "slam" -- need for correctly working reflect trace
SWEP.HoldTypeDucked		= "shotgun"

SWEP.Category			= "Half-Life"
SWEP.Spawnable			= true

SWEP.PlayerModel		= Model("models/hl1/p_gauss.mdl")
SWEP.EntModel			= Model("models/w_gauss.mdl")

SWEP.CModel				= Model("models/hl1/c_gauss.mdl")
SWEP.VModel				= Model("models/v_gauss.mdl")

SWEP.ViewModel			= SWEP.CModel
SWEP.WorldModel			= SWEP.PlayerModel

SWEP.Primary.Sound			= Sound("Weapon_Gauss.Fire")
SWEP.Primary.Special		= Sound("Weapon_Gauss.Spin")
SWEP.Primary.Damage			= 20
SWEP.Primary.DamageCVar		= "hl1_sk_plr_dmg_gauss"
SWEP.Primary.Recoil			= -2
SWEP.Primary.Delay			= 0.2
SWEP.Primary.ClipSize 		= -1
SWEP.Primary.DefaultClip	= 20
SWEP.Primary.MaxAmmo		= 100
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "Uranium"

SWEP.Secondary.Damage		= 200
SWEP.Secondary.Delay		= .5
SWEP.Secondary.Automatic	= true

SWEP.MaxDistance			= 8192

function SWEP:SpecialDT()
	self:NetworkVar("Bool", 2, "PrimaryFire")
	self:NetworkVar("Float", 2, "NextAmmoBurn")
	self:NetworkVar("Float", 3, "StartCharge")
	self:NetworkVar("Float", 4, "PlayAftershock")
end

function SWEP:GetFullChargeTime()
	if self:IsMultiplayerRules() then
		return 1.5
	end
	return 4
end

function SWEP:ReflectGauss(ent)
	return self:IsBSPModel(ent) && ent:Health() <= 0
end

function SWEP:GlowSprite(tr, m)
	if IsFirstTimePredicted() then
		local gloweffect = EffectData()
		gloweffect:SetOrigin(tr.HitPos)
		gloweffect:SetNormal(tr.HitNormal)
		gloweffect:SetMagnitude(m)
		util.Effect("hl1_gauss_glow", gloweffect)
	end
end

function SWEP:ImpactBalls(tr, m)
	if IsFirstTimePredicted() and !tr.Entity:IsPlayer() and !tr.Entity:IsNPC() then
		local impactfx = EffectData()
		impactfx:SetOrigin(tr.HitPos)
		impactfx:SetNormal(tr.HitNormal)
		//impactfx:SetMagnitude(m)
		util.Effect("hl1_gauss_impact", impactfx)
	end
end

function SWEP:SpecialDeploy()
	self:SetPlayAftershock(0)
end

function SWEP:OnDrop()
	self:OnRemove()
end

function SWEP:OnRemove()
	self:SetInAttack(0)
	if self.ChargeSound then self.ChargeSound:Stop() end
end

function SWEP:PrimaryAttack()
	if self.Owner:IsNPC() then
		if self:GetNextPrimaryFire() <= CurTime() then
			self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)			
			self:WeaponSound()
	
			local tr = util.TraceLine({
				start = self.Owner:GetShootPos(),
				endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.MaxDistance,
				filter = self.Owner
			})
		
			if IsFirstTimePredicted() then
				local beameffect = EffectData()
				beameffect:SetEntity(self)
				beameffect:SetFlags(1)
				beameffect:SetStart(tr.StartPos)
				beameffect:SetOrigin(tr.HitPos)
				beameffect:SetNormal(tr.HitNormal)
				beameffect:SetAttachment(1)
				beameffect:SetScale(4)
				beameffect:SetColor(1)
				util.Effect("hl1_gauss_beam", beameffect)
			end
	
			self:DoRicochetSound(tr.HitPos)		
			self:ImpactBalls(tr)
			util.Decal("FadingScorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
				
			if IsValid(tr.Entity) then
				if tr.Entity:Health() > 0 then
					local dmginfo = DamageInfo()
					dmginfo:SetAttacker(self.Owner)
					dmginfo:SetInflictor(self)
					dmginfo:SetDamage(self.Primary.Damage)
					dmginfo:SetDamageType(DMG_ENERGYBEAM)
					dmginfo:SetDamageForce(self.Owner:GetForward() * 16000)
					tr.Entity:DispatchTraceAttack(dmginfo, tr)
				end
				
				if !tr.Entity:IsPlayer() then
					local phys = tr.Entity:GetPhysicsObject()
					if IsValid(phys) then
						phys:ApplyForceOffset(self.Owner:GetForward() * 4000, tr.HitPos)
					end
				end
			end
		end
		return
	end

	if self:GetInAttack() > 0 then return end
	if self.Owner:WaterLevel() == 3 then
		self:PlayEmptySound()
		self:SetNextPrimaryFire(CurTime() + .15)
		self:SetNextSecondaryFire(CurTime() + .15)
		return
	end
	if self:rgAmmo() < 2 then
		self:PlayEmptySound()
		self:SetNextAttack(CurTime() + 0.5)
		return
	end
	
	self:SetPrimaryFire(true)
	self:TakeClipPrimary(2)
	self:StartFire()
	self:SetInAttack(0)
	self:SetWeaponIdleTime(CurTime() + 1)
	self:SetNextAttack(CurTime() + self.Primary.Delay)
end

function SWEP:SecondaryAttack()
	local fInAttack = self:GetInAttack()
	if self.Owner:WaterLevel() == 3 then
		if fInAttack != 0 then
			self:EmitSound("Weapon_Gauss.Zap1")
			self.Owner:GetViewModel():SendViewModelMatchingSequence(self:LookupSequence("idle"))
			self:OnRemove()
		else
			self:PlayEmptySound()
		end
		self:SetNextPrimaryFire(CurTime() + .5)
		self:SetNextSecondaryFire(CurTime() + .5)
		return
	end
	
	if fInAttack == 0 then
		if self:rgAmmo() <= 0 then
			self:EmitSound(self.DrySound)
			self:SetNextAttack(CurTime() + .5)
			return
		end
		self:SetPrimaryFire(false)
		self:TakeClipPrimary()
		self:SetNextAmmoBurn(CurTime())
		self:SendWeaponAnim(ACT_GAUSS_SPINUP)
		self:SetInAttack(1)
		self:SetWeaponIdleTime(CurTime() + .5)
		self:SetStartCharge(CurTime())
		self.flAmmoStartCharge = CurTime() + self:GetFullChargeTime()
		if !self.ChargeSound then
			self.ChargeSound = CreateSound(self.Owner, self.Primary.Special)
		end
		if IsFirstTimePredicted() then
			self.ChargeSound:PlayEx(.7, 110)
		end
	end
end

function SWEP:SpecialThink()
	self:ResetEmptySound()
	
	if self.Owner:Crouching() or !self.Owner:IsOnGround() then
		if self:GetHoldType() != self.HoldTypeDucked then
			self:SetHoldType(self.HoldTypeDucked)
		end
	elseif self:GetHoldType() != self.HoldType then
		self:SetHoldType(self.HoldType)
	end
	
	local flPlayAftershock = self:GetPlayAftershock()
	if flPlayAftershock > 0 && flPlayAftershock < CurTime() then
		local rand = math.random(3, 6)
		if rand > 3 then
			self:EmitSound("weapons/electro"..rand..".wav", 100, 100, math.Rand(.7, .8), CHAN_AUTO)
		end
		self:SetPlayAftershock(0)
	end

	local fInAttack = self:GetInAttack()
	if fInAttack == 1 then		
		if self:GetWeaponIdleTime() < CurTime() then
			self:SendWeaponAnim(ACT_GAUSS_SPINCYCLE)
			self:SetInAttack(2)
		end
	elseif fInAttack == 2 then
		if !self.Owner:KeyDown(IN_ATTACK2) or self:rgAmmo() <= 0 then
			self.ChargeSound:Stop()
			self:StartFire()
			self:SetInAttack(0)
			self:SetWeaponIdleTime(CurTime() + 2.0)
			if self:rgAmmo() <= 0 then
				self:SetWeaponIdleTime(CurTime() + 1.0)
				self:SetNextAttack(CurTime() + 1)
			end
			return
		end
		local flNextAmmoBurn = self:GetNextAmmoBurn()
		if CurTime() >= flNextAmmoBurn && flNextAmmoBurn != 1000 then
			if self:IsMultiplayerRules() then
				self:TakeClipPrimary()
				self:SetNextAmmoBurn(CurTime() + .1)
			else
				self:TakeClipPrimary()
				self:SetNextAmmoBurn(CurTime() + .3)
			end
		end
		if CurTime() >= self.flAmmoStartCharge then
			// don't eat any more ammo after gun is fully charged.
			self:SetNextAmmoBurn(1000)
		end
		local pitch = (CurTime() - self:GetStartCharge()) * ( 150 / self:GetFullChargeTime() ) + 100
		if pitch > 250 then
			pitch = 250
		end
		self.ChargeSound:ChangePitch(pitch)
		
		if self:GetStartCharge() < CurTime() - 10 then
			// Player charged up too long. Zap him.
			self.ChargeSound:Stop()
			self:EmitSound("weapons/electro4.wav")
			self:EmitSound("weapons/electro6.wav", 100, 100, 1, CHAN_ITEM)
			self:SetInAttack(0)
			self:SetWeaponIdleTime(CurTime() + 1)
			self:SetNextAttack(CurTime() + 1)
			self.Owner:ScreenFade(SCREENFADE.IN, Color(255,128,0,128), 2, 0.5)
			self.Owner:GetViewModel():SendViewModelMatchingSequence(self:LookupSequence("idle"))
			if SERVER then
				local dmginfo = DamageInfo()
				dmginfo:SetDamage(50)
				dmginfo:SetAttacker(self.Owner)
				dmginfo:SetDamageType(DMG_SHOCK)
				self.Owner:TakeDamageInfo(dmginfo)
			end
			// Player may have been killed and this weapon dropped, don't execute any more code after this!
			return
		end
	end
end

function SWEP:StartFire()
	local flDamage
	local fPrimaryFire = self:GetPrimaryFire()
	local flStartCharge = self:GetStartCharge()
	
	local punchangle = self.Owner.punchangle and Angle(self.Owner.punchangle[1], 0, 0) or Angle()
	local ang = self.Owner:EyeAngles() + punchangle
	
	local vecAiming = ang:Forward()
	local vecSrc = self.Owner:GetShootPos()
	if CurTime() - flStartCharge > self:GetFullChargeTime() then
		flDamage = self.Secondary.Damage
	else
		flDamage = self.Secondary.Damage * (CurTime() - flStartCharge) / self:GetFullChargeTime()
	end
	if fPrimaryFire then
		flDamage = cvars.Number(self.Primary.DamageCVar, self.Primary.Damage)
	end
	if self:GetInAttack() != 3 then
		if !fPrimaryFire then
			local gravityMul = 800 - GetConVarNumber("sv_gravity")
			if IsFirstTimePredicted() then
				self.forwardDir = self.Owner:GetForward()
			end
			local vel = self.forwardDir * (flDamage * 5)
			if !self:IsMultiplayerRules() then
				// in deathmatch, gauss can pop you up into the air. Not in single play.
				vel[3] = 0
			else
				vel[3] = vel[3] - gravityMul / 4
			end
			if CLIENT then
				self.Owner:SetAbsVelocity(self.Owner:GetVelocity() - vel)
			else
				self.Owner:SetVelocity(-vel)
			end
		end
		self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
		self:SetPlayerAnimation(ACT_HL2MP_GESTURE_RANGE_ATTACK_PHYSGUN)
	end
	// time until aftershock 'static discharge' sound
	self:SetPlayAftershock(CurTime() + util.SharedRandom("flPlayAftershock", 0.3, 0.8 ))

	self:GaussFire(vecSrc, vecAiming, flDamage)
	self:WeaponSound()
end

function SWEP:GaussFire(vecOrigSrc, vecDir, flDamage)
	local vecSrc = vecOrigSrc
	local vecDest = vecSrc + vecDir * self.MaxDistance
	local flMaxFrac = 1.0
	local fHasPunched = false
	local fFirstBeam = true
	local nMaxHits = 10
	
	local pentIgnore = GAMEMODE.Cooperative and player.GetAll() or self.Owner

	self:SendRecoil()	
	
	while flDamage > 10 && nMaxHits > 0 && IsValid(self:GetOwner()) do
		nMaxHits = nMaxHits - 1
		
		if SERVER then self.Owner:LagCompensation(true) end
		local tr = util.TraceLine({
			start = vecSrc,
			endpos = vecDest,
			//mask = MASK_SHOT,
			filter = pentIgnore
		})
		if SERVER then self.Owner:LagCompensation(false) end

		if tr.AllSolid then
			break
		end
		
		local pEntity = tr.Entity

		if pEntity == NULL then
			break
		end
			
		if IsFirstTimePredicted() then
			local beameffect = EffectData()
			beameffect:SetEntity(self)
			if fFirstBeam then
				beameffect:SetFlags(1) --from viewmodel
				fFirstBeam = false
			else
				beameffect:SetFlags(0) --in world
			end
			beameffect:SetStart(tr.StartPos)
			beameffect:SetOrigin(tr.HitPos)
			beameffect:SetNormal(tr.HitNormal)
			beameffect:SetAttachment(1)
			if self:GetPrimaryFire() then
				beameffect:SetScale(4)
				beameffect:SetColor(1)
			else
				beameffect:SetScale(8)
				beameffect:SetColor(0)
			end
			util.Effect("hl1_gauss_beam", beameffect)
		end

		if pEntity:Health() > 0 then
			local dmginfo = DamageInfo()
			dmginfo:SetAttacker(self.Owner)
			dmginfo:SetInflictor(self)
			dmginfo:SetDamage(flDamage)
			dmginfo:SetDamageType(DMG_ENERGYBEAM)
			dmginfo:SetDamagePosition(tr.HitPos)
			local forceDir = vecDir
			if pEntity == self.Owner then
				forceDir = -forceDir
			end
			dmginfo:SetDamageForce(forceDir * flDamage * 600)
			pEntity:DispatchTraceAttack(dmginfo, tr, vecDir)
		end
		
		if IsValid(pEntity) and !pEntity:IsPlayer() then
			local phys = pEntity:GetPhysicsObject()
			if IsValid(phys) then
				phys:ApplyForceOffset(vecDir * flDamage * 200, tr.HitPos)
			end
		end
		
		if self:ReflectGauss(pEntity) then
			pentIgnore = NULL
			
			local n = -tr.HitNormal:Dot(vecDir)
			
			if (n < 0.5) then // 60 degrees
				local r = 2.0 * tr.HitNormal * n + vecDir
				flMaxFrac = flMaxFrac - tr.Fraction
				vecDir = r
				vecSrc = tr.HitPos + vecDir * 8
				vecDest = vecSrc + vecDir * self.MaxDistance
				
				// explode a bit
				local dmginfo = DamageInfo()
				dmginfo:SetInflictor(self)
				dmginfo:SetAttacker(self.Owner)
				dmginfo:SetDamage(flDamage * n)
				dmginfo:SetDamageType(DMG_GENERIC) --DMG_BLAST in original, but we dont want ear ringing
				util.BlastDamageInfo(dmginfo, tr.HitPos, flDamage * n * 2.5)

				/*local data1 = EffectData()
				data1:SetOrigin(tr.HitPos)
				data1:SetNormal(tr.HitNormal)
				data1:SetMagnitude(flDamage * n)
				util.Effect("hl1_gauss_glow", data1)*/
				//HL1GaussReflect
				
				//gEngfuncs.pEfxAPI->R_TempSprite( tr.endpos, vec3_origin, 0.2, m_iGlow, kRenderGlow, kRenderFxNoDissipation, flDamage * n / 255.0, flDamage * n * 0.5 * 0.1, FTENT_FADEOUT );
				//self:GlowSprite(tr, flDamage / 255.0)
				self:ImpactBalls(tr, flDamage * n)
				
				// lose energy
				if (n == 0) then
					n = 0.1
				end
				flDamage = flDamage * (1 - n)
				
			else

				// tunnel
				self:DoRicochetSound(tr.HitPos)
				util.Decal("FadingScorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
				//self:GlowSprite(tr, flDamage)
				// R_TempSprite( tr.endpos, vec3_origin, 1.0, m_iGlow, kRenderGlow, kRenderFxNoDissipation, flDamage / 255.0, 6.0, FTENT_FADEOUT );
			
				// limit it to one hole punch
				if fHasPunched then
					break
				end
				fHasPunched = true
			
				// try punching through wall if secondary attack (primary is incapable of breaking through)
				if !self:GetPrimaryFire() then
					if SERVER then self.Owner:LagCompensation(true) end
					local punch_tr = util.TraceLine({
						start = tr.HitPos + vecDir * 8,
						endpos = vecDest,
						//mask = MASK_SHOT,
						filter = pentIgnore
					})
					if SERVER then self.Owner:LagCompensation(false) end
					if !punch_tr.AllSolid and cvars.Bool("hl1_sv_gauss_tracebackwards") then
						// trace backwards to find exit point
						if SERVER then self.Owner:LagCompensation(true) end
						local exit_tr = util.TraceLine({
							start = punch_tr.HitPos,
							endpos = tr.HitPos,
							//mask = MASK_SHOT,
							filter = pentIgnore
						})
						if SERVER then self.Owner:LagCompensation(false) end

						local n = (exit_tr.HitPos - tr.HitPos):Length()
					
						if n < flDamage then
							if n == 0 then n = 1 end
							flDamage = flDamage - n
							
							/*local data2 = EffectData()
							data2:SetOrigin(tr.HitPos)
							data2:SetNormal(vecDir)
							util.Effect( "HL1GaussWallPunchEnter", data2)*/
							
							self:ImpactBalls(tr)
							if !pEntity:IsPlayer() and !pEntity:IsNPC() then
								self:DoRicochetSound(tr.HitPos)
								util.Decal("FadingScorch", tr.HitPos - tr.HitNormal, tr.HitPos + tr.HitNormal)
							end
							
							/*local data3 = EffectData()
							data3:SetOrigin(exit_tr.HitPos)
							data3:SetNormal(vecDir)
							data3:SetMagnitude(flDamage)
							util.Effect( "HL1GaussWallPunchExit", data3)*/
							
							// exit blast damage
							local damage_radius
							if self:IsMultiplayerRules() then
								damage_radius = flDamage * 1.75
							else
								damage_radius = flDamage * 2.5
							end
							
							local dmginfo = DamageInfo()
							dmginfo:SetInflictor(self)
							dmginfo:SetAttacker(self.Owner)
							dmginfo:SetDamage(flDamage)
							dmginfo:SetDamageType(DMG_GENERIC)
							util.BlastDamageInfo(dmginfo, exit_tr.HitPos + vecDir * 8, damage_radius)
							
							--self:InsertSound(1, self:GetPos(), 1024, 3)
							
							vecSrc = exit_tr.HitPos + vecDir
						else
							break
						end
					else
						flDamage = 0
					end
				else
					if self:GetPrimaryFire() then
						// slug doesn't punch through ever with primary 
						// fire, so leave a little glowy bit and make some balls
						//gEngfuncs.pEfxAPI->R_TempSprite( tr.endpos, vec3_origin, 0.2, m_iGlow, kRenderGlow, kRenderFxNoDissipation, 200.0 / 255.0, 0.3, FTENT_FADEOUT );
						self:GlowSprite(tr, 200 / 255)
						self:ImpactBalls(tr)
					end
					flDamage = 0
				end
			end
		else
			vecSrc = tr.HitPos + vecDir;
			pentIgnore = pEntity
		end
	end
end

function SWEP:WeaponIdle()
	if self:GetInAttack() > 0 then return end
	local iAnim
	local flRand = util.SharedRandom("flRand", 0, 1)
	if flRand <= 0.5 then		
		iAnim = self:LookupSequence("idle")
		self:SetWeaponIdleTime(CurTime() + math.Rand(10, 15))
	elseif flRand <= 0.75 then		
		iAnim = self:LookupSequence("idle2")
		self:SetWeaponIdleTime(CurTime() + math.Rand(10, 15))
	else		
		iAnim = self:LookupSequence("fidget")
		self:SetWeaponIdleTime(CurTime() + 3)
	end
	self.Owner:GetViewModel():SendViewModelMatchingSequence(iAnim)
end
