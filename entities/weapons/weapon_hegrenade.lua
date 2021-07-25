if (CLIENT) then

	SWEP.PrintName 			= "Осколочная граната"
	SWEP.Slot 				= 3
	SWEP.SlotPos 			= 1
	SWEP.DrawAmmo 			= false
	SWEP.DrawCrosshair 		= false
	SWEP.ViewModelFOV			= 65
	-- SWEP.ViewModelFlip		= true
	SWEP.CSMuzzleFlashes		= false
	SWEP.Category			= "CS:S Realistic Weapons"

	SWEP.IconLetter 			= "O"
	killicon.AddFont("weapon_real_cs_grenade", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ))
end
SWEP.HoldType				= "grenade"

SWEP.UseHands = true

SWEP.Spawnable 				= true
SWEP.AdminSpawnable 			= true

SWEP.ViewModel 				= "models/weapons/cstrike/c_eq_fraggrenade.mdl"
SWEP.WorldModel 				= "models/weapons/w_eq_fraggrenade.mdl"

SWEP.Primary.ClipSize 			= 1
SWEP.Primary.DefaultClip 		= 1
SWEP.Primary.Automatic 			= false
SWEP.Primary.Ammo 			= "grenade"

SWEP.Secondary.ClipSize 		= -1
SWEP.Secondary.DefaultClip 		= -1
SWEP.Secondary.Automatic 		= false
SWEP.Secondary.Ammo 			= "none"

SWEP.Primed 				= 0
SWEP.Throw 					= CurTime()
SWEP.PrimaryThrow				= true

/*---------------------------------------------------------
Initialize
---------------------------------------------------------*/
function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
end

/*---------------------------------------------------------
Holster
---------------------------------------------------------*/
function SWEP:Holster()
	self.Primed = 0
	self.Throw = CurTime()
	if self.Owner:IsValid() then
	self.Owner:DrawViewModel(true)
	end
	return true
end

/*---------------------------------------------------------
Holster
---------------------------------------------------------*/
function SWEP:Reload()
	self.Owner:DrawViewModel(true)
	self.Weapon:DefaultReload(ACT_VM_DRAW)
end

/*---------------------------------------------------------
Think
---------------------------------------------------------*/
function SWEP:Think()
	if ((self:Clip1() > 0)) then
		self.Owner:DrawViewModel(true)
	else
		if self ~= nil and self.Owner ~= nil and self.Owner:IsValid()and self:IsValid()  then
			//self.Owner:StripWeapon(self:GetClass())
			//print(self:GetClass())
			if SERVER then
			self:Remove()
			local owner = self.Owner 
			for k, wep in pairs(owner:GetWeapons()) do
				if string.find( wep:GetClass(), "csgo_" )  then
					owner:SelectWeapon(wep:GetClass())
					break
				end
				end
			end
		end
	end

	if self.Primed == 1 and not self.Owner:KeyDown(IN_ATTACK) and self.PrimaryThrow then
		if self.Throw < CurTime() then
			self.Primed = 2
			self.Throw = CurTime() + 1.5

			self.Weapon:SendWeaponAnim(ACT_VM_THROW)
			self.Owner:SetAnimation(PLAYER_ATTACK1)

			timer.Simple( 0.35, function()
				if (!self or !IsValid(self)) then return end
				self:ThrowFar()
			end)

		end

	elseif self.Primed == 1 and not self.Owner:KeyDown(IN_ATTACK2) and not self.PrimaryThrow then
		if self.Throw < CurTime() then
			self.Primed = 2
			self.Throw = CurTime() + 1.5

			self.Weapon:SendWeaponAnim(ACT_VM_THROW)
			self.Owner:SetAnimation(PLAYER_ATTACK1)

			timer.Simple( 0.35, function()
				if (!self or !IsValid(self)) then return end
				self:ThrowShort()
			end)
		end
	end
end

/*---------------------------------------------------------
ThrowFar
---------------------------------------------------------*/
function SWEP:ThrowFar()

	if self.Primed != 2 then return end
	if not self.Owner:IsValid() then return end
	local tr = self.Owner:GetEyeTrace()

	if (!SERVER) then return end

	local ent = ents.Create ("ent_explosivegrenade")

			local v = self.Owner:GetShootPos()
				v = v + self.Owner:GetForward() * 1
				v = v + self.Owner:GetRight() * 3
				v = v + self.Owner:GetUp() * 1
			ent:SetPos( v )
	
	if self.Owner:GetNWBool("GrenadeTrail") then
		util.SpriteTrail(ent, 6, Color(self.Owner:GetNWInt("GrenadeTrailR",0),self.Owner:GetNWInt("GrenadeTrailG",0),self.Owner:GetNWInt("GrenadeTrailB",0)), false, 15, 1, 10, 0.125, 'trails/laser.vmt')
	end
	
	ent:SetAngles(Angle(math.random(1,100),math.random(1,100),math.random(1,100)))
	ent.GrenadeOwner = self.Owner
	ent:Spawn()

	local phys = ent:GetPhysicsObject()
	if !IsValid(phys) then self.Primed = 0 self.Weapon:SendWeaponAnim(ACT_VM_DRAW) return end

	if self.Owner:KeyDown( IN_FORWARD ) then
		self.Force = 1500
	elseif self.Owner:KeyDown( IN_BACK ) then
		self.Force = 500
	elseif self.Owner:KeyDown( IN_MOVELEFT ) then
		self.Force = 900
	elseif self.Owner:KeyDown( IN_MOVERIGHT ) then
		self.Force = 900
	else
		self.Force = 900
	end

	phys:ApplyForceCenter(self.Owner:GetAimVector() *self.Force *1.2 + Vector(0,0,200) )
	phys:AddAngleVelocity(Vector(math.random(-500,500),math.random(-500,500),math.random(-500,500)))

	self:TakePrimaryAmmo(1)
	-- self:Reload()
	if not self:IsValid() then return end
	timer.Simple(0.6,
	function()

		if not self:IsValid() then return end
		if not self.Owner:IsValid() then return end

		if self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
			--self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
			self.Primed = 0
		else
			self.Primed = 0
		--	self.Weapon:Remove()
		--	self.Owner:ConCommand("lastinv")
		end

	end)
end

/*---------------------------------------------------------
ThrowShort
---------------------------------------------------------*/
function SWEP:ThrowShort()

	if self.Primed != 2 then return end

	local tr = self.Owner:GetEyeTrace()

	if (!SERVER) then return end

	local ent = ents.Create ("ent_explosivegrenade")

			local v = self.Owner:GetShootPos()
				v = v + self.Owner:GetForward() * 2
				v = v + self.Owner:GetRight() * 3
				v = v + self.Owner:GetUp() * -3
			ent:SetPos( v )

	ent:SetAngles(Angle(math.random(1,100),math.random(1,100),math.random(1,100)))
	ent.GrenadeOwner = self.Owner
	ent:Spawn()

	local phys = ent:GetPhysicsObject()
	if !IsValid(phys) then self.Weapon:SendWeaponAnim(ACT_VM_DRAW) self.Primed = 0 return end

	if self.Owner:KeyDown( IN_FORWARD ) then
		self.Force = 1100
	elseif self.Owner:KeyDown( IN_BACK ) then
		self.Force = 300
	elseif self.Owner:KeyDown( IN_MOVELEFT ) then
		self.Force = 700
	elseif self.Owner:KeyDown( IN_MOVERIGHT ) then
		self.Force = 700
	else
		self.Force = 700
	end

	phys:ApplyForceCenter(self.Owner:GetAimVector() * self.Force * 2 + Vector(0, 0, 0))
	phys:AddAngleVelocity(Vector(math.random(-500,500),math.random(-500,500),math.random(-500,500)))

	self:TakePrimaryAmmo(1)
	if not self:IsValid() then return end
	-- self:Reload()
	timer.Simple(0.6,
	function()

		if self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
			--self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
			self.Primed = 0
		else
			self.Primed = 0
		--	self.Weapon:Remove()
		--	self.Owner:ConCommand("lastinv")
		end
	end)
end

/*---------------------------------------------------------
PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()

	if self.Throw < CurTime() and self.Primed == 0 and self:CanPrimaryAttack() then
		self.Weapon:SendWeaponAnim(ACT_VM_PULLPIN)
		self.Primed = 1
		self.Throw = CurTime() + 1
		self.PrimaryThrow = true
	end
end

/*---------------------------------------------------------
SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()

end

/*---------------------------------------------------------
Deploy
---------------------------------------------------------*/
function SWEP:Deploy()

	if (self:Clip1() > 0) then
		self.Throw = CurTime() + 0.75
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
		self.Owner:DrawViewModel(true)
	else
		self.Throw = CurTime() + 0.75
		self.Owner:DrawViewModel(false)
	end
	-- return true
end

/*---------------------------------------------------------
DrawWeaponSelection
---------------------------------------------------------*/
function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)

	//draw.SimpleText(self.IconLetter, "CSSelectIcons", x + wide / 2, y + tall * 0.2, Color(255, 210, 0, 255), TEXT_ALIGN_CENTER)
	-- Draw a CS:S select icon

	self:PrintWeaponInfo(x + wide + 20, y + tall * 0.95, alpha)
	-- Print weapon information
end

function SWEP:AcceptInput( name, activator, caller, data )
	if ( name == "ConstraintBroken" && self:HasSpawnFlags( 1 ) ) then
		local phys = self:GetPhysicsObject()
		if ( IsValid( phys ) ) then phys:EnableMotion( false ) end
	
		local newflags = bit.band( self:GetSpawnFlags(), bit.bnot( 1 ) )
		self:SetKeyValue( "spawnflags", newflags )
	end
end

function SWEP:AcceptInput( name, activator, caller, data )
	if ( name == "ConstraintBroken" && self:HasSpawnFlags( 1 ) ) then
		local phys = self:GetPhysicsObject()
		if ( IsValid( phys ) ) then phys:EnableMotion( false ) end
	
		local newflags = bit.band( self:GetSpawnFlags(), bit.bnot( 1 ) )
		self:SetKeyValue( "spawnflags", newflags )
	end
end