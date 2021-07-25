AddCSLuaFile()

SWEP.PrintName 		= "Magnum Sniper Rifle"
SWEP.ViewModelFOV		= 68
SWEP.Slot 			= 0


SWEP.Category			= "Counter-Strike"		-- Swep Categorie (You can type what your want)

SWEP.Base				= "base_lidi_css"

SWEP.Hold 		= "ar2"
SWEP.ViewModel 			= "models/weapons/cstrike/c_snip_awp.mdl"
SWEP.WorldModel 			= "models/weapons/w_snip_awp.mdl"

SWEP.Sound 		= Sound("Weapon_awp.Single")
SWEP.Damage 		= 100
SWEP.Recoil 		= 2
SWEP.NumShots 		= 1
SWEP.Cone 		= 0.0001
SWEP.ClipSize 		= 10
SWEP.Rate 		= 1.2
SWEP.MaxAmmo		= 30
SWEP.Primary.Automatic 		= false
SWEP.Ammo 		= "smg1"

-- Accuracy
SWEP.CrouchCone				= 0.0001 -- Accuracy when we're crouching
SWEP.CrouchWalkCone			= 0.005 -- Accuracy when we're crouching and walking
SWEP.WalkCone				= 0.025 -- Accuracy when we're walking
SWEP.AirCone				= 0.1 -- Accuracy when we're in air
SWEP.StandCone				= 0.0001 -- Accuracy when we're standing still


SWEP.Zooming = true

function SWEP:SecondaryAttack()
	if self.Owner:GetNWBool('Zoom') then
		if(SERVER) then
			self.Owner:SetFOV( 90, 0.2 )
			self.Weapon:EmitSound( Sound( "Default.Zoom" ) )
		end
	        self.Weapon:SetNextSecondaryFire( CurTime() + 0.2 );
            self.Owner:SetNWBool('Zoom',false)
	else
		if(SERVER) then
			self.Owner:SetFOV( 20, 0.3 )
			self.Weapon:EmitSound( Sound( "Default.Zoom" ) )
		end
	        self.Weapon:SetNextSecondaryFire( CurTime() + 0.2 );
            self.Owner:SetNWBool('Zoom',true)
	end
end
function SWEP:AdjustMouseSensitivity()
	if self.Zooming then
		if self.Owner:GetNWBool('Zoom') then
			return 0.5
		else
			return 1
		end
	end
end
