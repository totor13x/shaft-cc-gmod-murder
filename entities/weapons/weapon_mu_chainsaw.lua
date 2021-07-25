SWEP.ViewModelFOV = 53
SWEP.ViewModel = "models/weapons/v_chainsaw.mdl"
SWEP.WorldModel = "models/weapons/w_chainsaw.mdl"
SWEP.Slot = 0
SWEP.HoldType = "physgun" 
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = false
SWEP.PrintName = "Бензопила"
SWEP.base = "weapon_base"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic = true

SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	self:SetDeploySpeed(0.5)
	self.RSaw_Idle = CreateSound(self,"weapons/melee/chainsaw_idle.wav")
	self.RSaw_Attack = CreateSound(self,"weapons/melee/chainsaw_attack.wav")
	if CLIENT then
		emitter = ParticleEmitter(self:GetPos())
	end
	self.Rivok = CurTime()
	self.Owner:SetNWBool('slowmouse', false)
end

function SWEP:Deploy()
	self:EmitSound("weapons/melee/chainsaw_start_01.wav",42.5, 100, 0.5)
	self.Owner:SetAnimation(PLAYER_RELOAD)
	timer.Create("rsaw_idlesound_start"..self:EntIndex(),3,1,function()
		if not IsValid(self) then return end
		self.RSaw_Idle:Play()
		self.RSaw_Idle:ChangeVolume(0.5,0.01)
	end)
end

function SWEP:Think()
if CLIENT then
	emitter:SetPos(self:GetPos()) --Still here, yup
	local BoneIndx = self.Owner:LookupBone("ValveBiped.Bip01_R_Hand")
	local particle = emitter:Add( table.Random({"particle/smokesprites_0001","particle/smokesprites_0002","particle/smokesprites_0003","particle/smokesprites_0004","particle/smokesprites_0005","particle/smokesprites_0006","particle/smokesprites_0007","particle/smokesprites_0008","particle/smokesprites_0009","particle/smokesprites_0010","particle/smokesprites_0012","particle/smokesprites_0013","particle/smokesprites_0014","particle/smokesprites_0015","particle/smokesprites_0016"}),self.Owner:GetBonePosition(BoneIndx))
	particle:SetDieTime( 1 )
	particle:SetStartAlpha( 10 )
	particle:SetEndAlpha( 0 )
	particle:SetStartSize( 0 )
	particle:SetEndSize( math.Rand( 20, 30 ) )
	particle:SetRoll( math.Rand( 360, 480 ) )
	particle:SetRollDelta( math.Rand( -1, 1 ) )
	particle:SetColor( 180, 180, 180 )
	particle:SetVelocity(VectorRand()*10+vector_up*40)
	particle:SetGravity(Vector(math.Rand(-100,100),math.Rand(-100,100),math.Rand(150,200)))
	particle:SetAirResistance(100)
	particle:SetCollide(true)
end

	if self.Owner and IsValid(self.Owner) then
		if self.Owner:KeyPressed(IN_ATTACK) then
			self.RSaw_Idle:Stop()
			self.RSaw_Attack:Play()
			self.RSaw_Attack:ChangeVolume(0.5,0.01)
		elseif self.Owner:KeyReleased(IN_ATTACK) then
			self.RSaw_Idle:Play()
			self.RSaw_Idle:ChangeVolume(0.5,0.01)
			self.RSaw_Attack:Stop()
		end
	end
	
		local trace = {}

	local world = Entity( 0 )

	local ply = self.Owner
	

end

function SWEP:AdjustMouseSensitivity()
	if self.Owner:GetNWBool('slowmouse') then
		return 0.5
	else
		return 1
	end
end

function SWEP:PrimaryAttack()
--Trace shit from weapon_fists.lua packed with Gmod
local trace = util.TraceLine( {
	start = self.Owner:GetShootPos(),
	endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 100,
	filter = self.Owner
} )

local trace2 = util.TraceLine( {
	start = self.Owner:GetShootPos(),
	endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 100,
	filter = self.Owner
} )

if ( !IsValid( trace.Entity ) ) then 
	trace = util.TraceHull( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 100,
		filter = self.Owner,
		mins = Vector( -10, -10, -8 ),
		maxs = Vector( 10, 10, 8 )
	} )
end
	self:SendWeaponAnim(ACT_VM_HITCENTER)
	
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	if trace.Entity:IsValid() then
		if SERVER then
			if trace.Entity:GetClass() == "func_breakable" or trace.Entity:GetClass() == "func_breakable_surf" then
				local bullet = {}
				bullet.Num = self.GunShots
				bullet.Src = self.Owner:GetShootPos()
				bullet.Dir = self.Owner:GetAimVector()
				bullet.Spread = Vector(0,0,0)
				bullet.Tracer = 0
				bullet.Force = 1
				bullet.Damage = 25
				self.Owner:FireBullets( bullet )
			else
				trace.Entity:TakeDamage(45,self.Owner)
			end
		end
		if trace2.Entity:IsPlayer() or trace2.Entity:IsNPC() then
			self.RSaw_Attack:ChangePitch(50,0.75)
			local BLOOOD = EffectData()
			BLOOOD:SetOrigin(trace2.HitPos)
			BLOOOD:SetMagnitude(math.random(1,3))
			BLOOOD:SetEntity(trace2.Entity)
			util.Effect("bloodstream",BLOOOD)
		end
	else
		self.RSaw_Attack:ChangePitch(100,0.75)
	end
	
	if trace.HitWorld then
		self:SendWeaponAnim(ACT_VM_MISSCENTER)
		local effectdata = EffectData()
		effectdata:SetOrigin(trace.HitPos)
		effectdata:SetNormal(trace.HitNormal)
		effectdata:SetMagnitude(1)
		effectdata:SetScale(2)
		effectdata:SetRadius(1)
		util.Effect("Sparks",effectdata)
		sound.Play("npc/manhack/grind"..math.random(1,5)..".wav",trace.HitPos,75,150,0.2)
	end
	
	self.Weapon:SetNextPrimaryFire( CurTime() + 0.01)
	self.Weapon:SetNextSecondaryFire( CurTime() + 0.25 )
end

function SWEP:SecondaryAttack()
if self.Rivok > CurTime() then return end
local o = self.Owner
self.Rivok = CurTime() + 25
self.Owner:SetNWBool('slowmouse', true)
		o:SetRunSpeed(650)
		o:SetWalkSpeed(650)
timer.Simple(3, function()
	if not self:IsValid() then return end
	if not self.Owner:IsValid() then return end

	o:SetRunSpeed(200)
	o:SetWalkSpeed(200)
	self.Owner:SetNWBool('slowmouse', false)
end)
//self.Owner:SetLocalVelocity( Vector(self.Owner:GetForward().x, self.Owner:GetForward().y, 0)*1300 )
end

function SWEP:Holster()
	self:OnRemove()
	if IsValid(self.Owner) then
		self:EmitSound("weapons/melee/chainsaw_die_01.wav",42.5, 100, 0.5)
	end
	return true
end

function SWEP:OnRemove()
	timer.Destroy("rsaw_idlesound_start"..self:EntIndex())
	if not self.RSaw_Idle then return end
	self.RSaw_Idle:Stop()
	self.RSaw_Attack:Stop()
end


function SWEP:PreDrawViewModel( vm, ply, weapon ) 

end

function SWEP:PostDrawViewModel(vm, ply, weapon)
	vm:SetMaterial( "" )
	vm:SetSubMaterial()
end
