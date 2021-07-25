SWEP.Category				= "Counter-Strike"
SWEP.PrintName				= "C4"
SWEP.WeaponType				= "Free"

SWEP.Cost					= 0
SWEP.CSSMoveSpeed				= 250

SWEP.Spawnable				= true
SWEP.AdminOnly				= true

SWEP.Slot					= 4
SWEP.UseHands					= true
SWEP.SlotPos				= 1

SWEP.ViewModel 				= "models/weapons/cstrike/c_c4.mdl"
SWEP.WorldModel				= "models/weapons/w_c4.mdl"
SWEP.VModelFlip 			= false
SWEP.HoldType				= "slam"

SWEP.Primary.Damage			= 0
SWEP.Primary.NumShots		= 0
SWEP.Primary.Sound			= Sound("weapons/ak47/ak47-1.wav")
SWEP.Primary.Cone			= 0
SWEP.Primary.ClipSize		= -1
SWEP.Primary.SpareClip		= -1
SWEP.Primary.Delay			= 1
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Automatic 		= false

SWEP.RecoilMul				= 1
SWEP.HasScope 				= false
SWEP.ZoomAmount 			= 1
SWEP.HasCrosshair 			= false
SWEP.HasCSSZoom 			= false

SWEP.HasPumpAction 			= false
SWEP.HasBoltAction 			= true
SWEP.HasBurstFire 			= false
SWEP.HasSilencer 			= false
SWEP.HasDoubleZoom			= true
SWEP.HasSideRecoil			= false

SWEP.IsThrowing 			= false
SWEP.HasAnimated			= false
SWEP.HasThrown				= false
SWEP.CanHolster				= true

function SWEP:Deploy()

end

function SWEP:Holster()
	return self.CanHolster
end

function SWEP:Initialize()
	self:SetWeaponHoldType("slam")	
end

function SWEP:PrimaryAttack()
	if self.IsThrowing then return end
	
	self:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration()+0.5)

	self.HasThrown = false
	self.HasAnimated = false
	
	self.CanHolster = false
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	
	self.DefaultWalkSpeed = self.Owner:GetWalkSpeed()
	self.DefaultRunSpeed = self.Owner:GetRunSpeed()
	
	self.Owner:SetRunSpeed(0.01)
	self.Owner:SetWalkSpeed(0.01)
	
	self.IsThrowing = true
	
	self.ThrowAnimation = CurTime() + 3
	self.Throw = CurTime() + 3.1
	--self.ThrowRemove = CurTime() + 3.5
	//print(self.Owner:GetViewModel():SequenceDuration())
	timer.Simple(self.Owner:GetViewModel():SequenceDuration()+0.2, function()
		if self:IsValid() then
			self:PlantC4()
		end
	end)
	
end

function SWEP:Reload()
	--PrintTable(GetActivities(self))
end

function SWEP:SecondaryAttack()

end

function SWEP:PlantC4()
	if CLIENT then return end
	local EA =  Angle(0,self.Owner:GetAngles().y,0)
	local pos = self.Owner:GetPos()

	self.Owner:SetRunSpeed(self.DefaultRunSpeed)
	self.Owner:SetWalkSpeed(self.DefaultWalkSpeed)
	
	
	
	local ent = ents.Create("ent_cs_c4")		
		ent:SetPos(pos)
		ent:SetAngles(EA)
		ent:Spawn()
		ent:Activate()
		ent:SetNWEntity("owner",self.Owner)
		--ent:SetOwner(self.Owner)
		
	ent:EmitSound("weapons/c4/c4_plant.wav")
	self:Remove()
	--self.Owner:Freeze(false)
	

	
end
