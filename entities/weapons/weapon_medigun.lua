// Show debug info?
//local debug = true
 
//----------------------------------------------
//Author Info
//----------------------------------------------
SWEP.Author             = "ReverseVelocity"
SWEP.Contact            = "Nope"
SWEP.Purpose            = "Healing People"
SWEP.Instructions       = "Right click to fire a healing station, which sticks to a surface and heals people around it."
//----------------------------------------------
 
SWEP.PrintName = "Medical Station Propulsion Device"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.UseHands = true
// First person Model
SWEP.ViewModel = "models/weapons/c_shotgun.mdl"
// Third Person Model
SWEP.WorldModel = "models/weapons/w_shotgun.mdl"
// Weapon Details
SWEP.Primary.Clipsize = 6
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Automatic = false
SWEP.Secondary.Clipsize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Slot				= 4
// Sound

reloadbuffer = 0
 
//--------------------------------------------
// Called when it reloads 
//--------------------------------------------

function SWEP:Reload()

end	 

	 
 
//--------------------------------------------
// Called when the player Shoots
//--------------------------------------------
function SWEP:PrimaryAttack()
	if self:Clip1() > 0 then
	 	//self:GetOwner():EmitSound("launch.wav",70,90)
		if SERVER then
			local medi = ents.Create( "medi_station" )
			if ( !IsValid( medi ) ) then return end
			medi:SetPos(self:GetOwner():GetPos() + Vector(0,0,50))
			medi:SetOwner(self:GetOwner())
			medi:SetModel("models/healthvial.mdl")
			medi:Spawn()
			self:SetClip1(self:Clip1() - 1)
			self:GetOwner():ViewPunch( Angle( -20, 0, 0 ) )
			self:SetNextPrimaryFire(CurTime()+20)
		end
	end
end
 
 

