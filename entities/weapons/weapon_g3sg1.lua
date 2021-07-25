AddCSLuaFile()

if (CLIENT) then
	SWEP.PrintName 		= "D3/AU-1"
	SWEP.ViewModelFOV		= 68
	SWEP.Slot 			= 0
	SWEP.SlotPos 		= 1
end

SWEP.Base 				= "base_lidi_css"
SWEP.Hold 		= "ar2"

SWEP.ViewModel 			= "models/weapons/cstrike/c_snip_g3sg1.mdl"
SWEP.WorldModel 			= "models/weapons/w_snip_g3sg1.mdl"

SWEP.Sound 		= Sound("Weapon_G3SG1.Single")
SWEP.Damage 		= 45
SWEP.Recoil 		= 0.75
SWEP.NumShots 		= 1
SWEP.Cone 		= 0.001
SWEP.ClipSize 		= 20
SWEP.Rate	 		= 0.2
SWEP.MaxAmmo 	= 90
SWEP.Primary.Automatic 		= true


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

-- Weapon Variations
SWEP.ScopeScale 			= 0.55 -- The scale of the scope's reticle in relation to the player's screen size.
SWEP.ScopeZoom				= 4
-- Accuracy
SWEP.CrouchCone				= 0.001 -- Accuracy when we're crouching
SWEP.CrouchWalkCone			= 0.005 -- Accuracy when we're crouching and walking
SWEP.WalkCone				= 0.025 -- Accuracy when we're walking
SWEP.AirCone				= 0.1 -- Accuracy when we're in air
SWEP.StandCone				= 0.001 -- Accuracy when we're standing still
