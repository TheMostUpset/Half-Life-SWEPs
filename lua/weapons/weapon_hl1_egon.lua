
if CLIENT then

	SWEP.PrintName			= "Gluon Gun"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 2
	SWEP.CrosshairXY		= {72, 48}
	SWEP.WepSelectIcon		= surface.GetTextureID("hl1/icons/egon")
	SWEP.AutoIconAngle		= Angle(0, 90, 0)

end

SWEP.Base 				= "weapon_hl1_base"
SWEP.Weight				= 20
SWEP.HoldType			= "physgun"

SWEP.Category			= "Half-Life"
SWEP.Spawnable			= true

SWEP.PlayerModel		= Model("models/hl1/p_egon.mdl")
SWEP.EntModel			= Model("models/w_egon.mdl")

SWEP.CModel				= Model("models/hl1/c_egon.mdl")
SWEP.VModel				= Model("models/v_egon.mdl")

SWEP.ViewModel			= SWEP.CModel
SWEP.WorldModel			= SWEP.PlayerModel

SWEP.Primary.Sound			= Sound("Weapon_Gluon.Start")
SWEP.Primary.SoundRun		= Sound("Weapon_Gluon.Run")
SWEP.Primary.SoundOff		= Sound("Weapon_Gluon.Off")
SWEP.Primary.Damage			= 14
SWEP.Primary.DamageCVar		= "hl1_sk_plr_dmg_egon_wide"
SWEP.Primary.Delay			= 0.75
SWEP.Primary.ClipSize 		= -1
SWEP.Primary.DefaultClip	= 20
SWEP.Primary.MaxAmmo		= 100
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "Uranium"

local FIRE_OFF = 0
local FIRE_CHARGE = 1

local FIRE_WIDE = 1

function SWEP:SpecialDT()
	self:NetworkVar("Bool", 2, "DrawBeam")
	self:NetworkVar("Int", 1, "FireState")
	self:NetworkVar("Float", 2, "DmgTime")
	self:NetworkVar("Float", 3, "AmmoUseTime")
	self:NetworkVar("Float", 4, "ShakeTime")
end

function SWEP:SpecialDeploy()
	self:SetFireState(FIRE_OFF)
end

function SWEP:SpecialHolster()
	self:SetNextAttack(CurTime() + 0.5)
end

function SWEP:OnRemove()
	if IsValid(self:GetOwner()) then
		self:EndAttack()
	end
end

function SWEP:GetPulseInterval()
	return .1
end

function SWEP:GetDischargeInterval()
	return .1
end

function SWEP:EgonHasAmmo()
	return self:rgAmmo() > 0
end

function SWEP:UseAmmo(count)
	if cvars.Bool("hl1_sv_unlimitedammo") then return end
	if self:Ammo1() >= count then
		self.Owner:SetAmmo(self:Ammo1() - count, self.Primary.Ammo)
	else
		self.Owner:SetAmmo(0, self.Primary.Ammo)
	end
end

function SWEP:Attack()
	// don't fire underwater
	if self.Owner:WaterLevel() == 3 then
		if self:GetFireState() != FIRE_OFF || self.m_pBeam then
			self:EndAttack()
		else
			self:PlayEmptySound()
		end
		return
	end
	
	local vecAiming = self.Owner:GetAimVector()
	local vecSrc = self.Owner:GetShootPos()
	
	if self:GetFireState() == FIRE_OFF then
		if !self:EgonHasAmmo() then
			self:SetNextPrimaryFire(CurTime() + 0.25)
			self:SetNextSecondaryFire(CurTime() + 0.25)
			self:PlayEmptySound()
			return
		end
		self:SetAmmoUseTime(CurTime()) // start using ammo ASAP.
		
		self:EmitSound(self.Primary.Sound)
		
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		
		self:SetShakeTime(0)
		self:SetDrawBeam(true)
		self:CreateEffect()
		
		self.m_flStartFireTime = CurTime() + 4
		
		self:SetDmgTime(CurTime() + self:GetPulseInterval())
		self:SetFireState(FIRE_CHARGE)
	elseif self:GetFireState() == FIRE_CHARGE then
		self:EgonFire(vecSrc, vecAiming)
		
		if self.m_flStartFireTime and self.m_flStartFireTime <= CurTime() then
			self:StopSound(self.Primary.Sound)
			self:EmitSound(self.Primary.SoundRun)
			self.m_flStartFireTime = nil
		end
		
		if !self:EgonHasAmmo() then
			self:EndAttack()
			self:SetNextPrimaryFire(CurTime() + 1)
			self:SetNextSecondaryFire(CurTime() + 1)
		end
	end
end

function SWEP:PrimaryAttack()
	self.m_fireMode = FIRE_WIDE
	self:Attack()
end

function SWEP:EgonFire(vecOrigSrc, vecDir)
	local vecDest = vecOrigSrc + vecDir * 2048
	--local tmpSrc = vecOrigSrc + self:GetUp() * -8 + self:GetRight() * 3
	local entFilter = self:TraceFilter()
	
	if SERVER then self.Owner:LagCompensation(true) end
	local tr = util.TraceLine({
		start = vecOrigSrc,
		endpos = vecDest,
		filter = entFilter
	})
	if SERVER then self.Owner:LagCompensation(false) end
	
	if tr.AllSolid then return end
	
	local pEntity = tr.Entity
	
	if self.m_fireMode == FIRE_NARROW then
		if self:GetDmgTime() < CurTime() then
			// Narrow mode only does damage to the entity it hits
			if IsValid(pEntity) and pEntity:Health() > 0 then
				local dmginfo = DamageInfo()
				dmginfo:SetAttacker(self.Owner)
				dmginfo:SetDamage(6)--gSkillData.plrDmgEgonNarrow
				dmginfo:SetDamageType(DMG_ENERGYBEAM)
				pEntity:DispatchTraceAttack(dmginfo, tr, vecDir)
			end
			
			if self:IsMultiplayerRules() then
				// multiplayer uses 1 ammo every 1/10th second
				if CurTime() >= self:GetAmmoUseTime() then
					self:UseAmmo(1)
					self:SetAmmoUseTime(CurTime() + .1)
				end
			else
				// single player, use 3 ammo/second
				if CurTime() >= self:GetAmmoUseTime() then
					self:UseAmmo(1)
					self:SetAmmoUseTime(CurTime() + 0.166)
				end
			end
			self:SetDmgTime(CurTime() + self:GetPulseInterval())
		end
	elseif self.m_fireMode == FIRE_WIDE then
		if self:GetDmgTime() < CurTime() then
			// wide mode does damage to the ent, and radius damage
			local dmg = cvars.Number(self.Primary.DamageCVar, self.Primary.Damage)
			if IsValid(pEntity) then
				local dmginfo = DamageInfo()
				dmginfo:SetAttacker(self.Owner)
				dmginfo:SetInflictor(self)
				dmginfo:SetDamage(dmg)
				dmginfo:SetDamageType(bit.bor(DMG_ENERGYBEAM, DMG_ALWAYSGIB))
				dmginfo:SetDamagePosition(tr.HitPos)
				dmginfo:SetDamageForce(vecDir * 8000)
				pEntity:DispatchTraceAttack(dmginfo, tr, vecDir)
				
				local phys = pEntity:GetPhysicsObject()
				if !pEntity:IsNPC() and !pEntity:IsNextBot() and !pEntity:IsPlayer() and IsValid(phys) then
					phys:ApplyForceOffset(vecDir * 10000, tr.HitPos)
					if game.SinglePlayer() and phys:GetMass() <= 100 then
						if !self.Dissolver or !IsValid(self.Dissolver) then
							self.Dissolver = ents.Create("env_entity_dissolver")
							self.Dissolver:Spawn()
						end
						if self.Dissolver and IsValid(self.Dissolver) then
							local name = "Dissolving_"..math.random()
							pEntity:SetName(name)
							self.Dissolver:SetKeyValue("dissolvetype", math.random(0, 2))
							self.Dissolver:SetKeyValue("magnitude", math.random(-200, 200))
							self.Dissolver:Fire("Dissolve", name, 0)
						end
					end
				end
			end
			
			if self:IsMultiplayerRules() then
				// radius damage a little more potent in multiplayer.		
				local dmginfo = DamageInfo()
				dmginfo:SetInflictor(self)
				dmginfo:SetAttacker(self.Owner)
				dmginfo:SetDamage(dmg / 4)
				dmginfo:SetDamageType(bit.bor(DMG_ENERGYBEAM, DMG_ALWAYSGIB))
				util.BlastDamageInfo(dmginfo, tr.HitPos, 128)
			end
			
			if !self.Owner:Alive() then return end
			
			if self:IsMultiplayerRules() then
				//multiplayer uses 5 ammo/second
				if CurTime() >= self:GetAmmoUseTime() then
					self:UseAmmo(1)
					self:SetAmmoUseTime(CurTime() + .2)
				end
			else
				// Wide mode uses 10 charges per second in single player
				if CurTime() >= self:GetAmmoUseTime() then
					self:UseAmmo(1)
					self:SetAmmoUseTime(CurTime() + .1)
				end
			end
			
			self:SetDmgTime(CurTime() + self:GetDischargeInterval())
			if self:GetShakeTime() < CurTime() then
				if IsFirstTimePredicted() then
					util.ScreenShake(tr.HitPos, 5, 150, .75, 250) -- weird in MP with high ping
				end
				self:SetShakeTime(CurTime() + 1.5)
			end
		end
	end
	
	self:UpdateEffect(tr.HitPos, tr.Entity)
end

function SWEP:UpdateEffect(endPoint, hitent)
	if !self.entBeam then
		self:CreateEffect()
	end
	
	if self.entBeam and IsValid(self.entBeam) then		
		self.entBeam:SetEndPos(endPoint)
		self.entBeam:SetHitEntity(hitent)
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:CreateEffect()
	if CLIENT then return end
	
	if self.entBeam and IsValid(self.entBeam) then return end
	
	local tr = util.TraceLine({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 2048,
		filter = self.Owner
	})
	
	self.entBeam = ents.Create("ent_hl1_egon_beam")
	local entBeam = self.entBeam
	if IsValid(entBeam) then
		entBeam:SetPos(tr.StartPos)
		entBeam:SetEndPos(tr.HitPos)
		entBeam:SetAngles(self:GetAngles())
		entBeam:SetOwner(self.Owner)
		entBeam:SetParent(self)
		entBeam:SetWepEntity(self)
		entBeam:SetHitEntity(tr.Entity)
		entBeam:Spawn()
	end
end

function SWEP:DestroyEffect()
	self:SetDrawBeam(false)
	if self.entBeam and IsValid(self.entBeam) then
		self.entBeam:Remove()
	end
end

function SWEP:SpecialThink()
	self:ResetEmptySound()
	if !self.Owner:KeyDown(IN_ATTACK) and self:GetFireState() != FIRE_OFF then
		self:EndAttack()
	end
end

function SWEP:WeaponIdle()
	if self:GetFireState() == FIRE_CHARGE then return end
	local iAnim
	local flRand = util.SharedRandom("flRand", 0, 1)
	if flRand <= 0.5 then		
		iAnim = ACT_VM_IDLE
		self:SetWeaponIdleTime(CurTime() + math.Rand(10, 15))
	else		
		iAnim = ACT_VM_FIDGET
		self:SetWeaponIdleTime(CurTime() + 3)
	end
	self:SendWeaponAnim(iAnim)
end

function SWEP:EndAttack()
	self:StopSound(self.Primary.SoundRun)

	if self:GetFireState() != FIRE_OFF then
		self:EmitSound(self.Primary.SoundOff)
	end
	
	self:SetWeaponIdleTime(CurTime() + .1)
	self:SetNextPrimaryFire(CurTime() + .5)
	self:SetNextSecondaryFire(CurTime() + .5)
	
	self:SetFireState(FIRE_OFF)
	
	self:DestroyEffect()
end

if CLIENT then

function SWEP:ViewModelDrawn(vm)
	local att = vm:GetAttachment(1)
	if att then
		self:RenderBeam(att)
	end
end

local matBeam = Material("hl1/sprites/xbeam1")
local matFlare = Material("hl1/sprites/xspark1")

function SWEP:RenderBeam(att)
	if self:GetDrawBeam() then
		local entFilter = self:TraceFilter()
		local tr = util.TraceLine({
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 2048,
			filter = entFilter
		})
		
		local Angle = self.Owner:GetAimVector():Angle()
		local Forward	= Angle:Forward()
		local Right 	= Angle:Right()
		local Up 		= Angle:Up()

		local texWidth = 10
		local texScroll = CurTime() * 10
		local color = Color(50, 50, 255, 255)

		local startPos = att.Pos
		local endPos = tr.HitPos
		local dist = startPos:Distance(endPos)
		dist = math.min(dist, 2048)
		local stepSize = 16

		local RingTightness = 0.025

		render.SetMaterial(matBeam)
		render.StartBeam(128)
		render.AddBeam(startPos, texWidth, texScroll, color)
		for i = 0, dist, stepSize do
			local sin = math.sin( CurTime() + i * RingTightness )
			local cos = math.cos( CurTime() + i * RingTightness )
			
			local prog = i * i * .2 / dist
			prog = math.min(prog, 16)
			
			local Pos = startPos + (Forward * i) + (Up * sin * prog) + (Right * cos * prog)
			
			render.AddBeam(Pos, texWidth, texScroll + i / 64, color)
		end
		render.AddBeam(endPos, texWidth, texScroll, color)
		render.AddBeam(endPos, texWidth, texScroll, color)		
		render.EndBeam()
		
		render.StartBeam(10)
		render.AddBeam(startPos, texWidth, texScroll, color)
		for i = 0, dist / 32, stepSize do		
			local Pos = startPos + (Forward * i * 16) + VectorRand() * i / 2
			
			render.AddBeam(Pos, texWidth, texScroll + i / 32, color)	
		end
		render.AddBeam(endPos, texWidth, texScroll, color)
		render.AddBeam(endPos, texWidth, texScroll, color)
		render.EndBeam()

		if tr.Entity != NULL and tr.Entity:Health() <= 0 then
			render.SetMaterial(matFlare)
			render.DrawSprite(endPos, 32, 32, Color(255,255,255,255))
		end
		self:SetRenderBoundsWS(startPos, endPos)
	end
end

end