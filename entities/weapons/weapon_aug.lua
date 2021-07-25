AddCSLuaFile()
SWEP.PrintName			= "Bullpup"
SWEP.Slot				= 0
SWEP.ViewModelFOV		= 58

SWEP.Hold			= "ar2"
SWEP.Base				="base_lidi_css"
SWEP.Category			= "Counter-Strike"


SWEP.ViewModel			= "models/weapons/cstrike/c_rif_aug.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_aug.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Sound			= Sound( "Weapon_aug.Single" )
SWEP.Recoil			= 0.6
SWEP.Damage			= 36
SWEP.Rate				=.1
SWEP.ClipSize			=30
SWEP.MaxAmmo			=120
SWEP.Primary.Automatic	=true

-- Weapon Variations
SWEP.CrouchCone				= 0.01 -- Accuracy when we're crouching
SWEP.CrouchWalkCone			= 0.02 -- Accuracy when we're crouching and walking
SWEP.WalkCone				= 0.025 -- Accuracy when we're walking
SWEP.AirCone				= 0.1 -- Accuracy when we're in air
SWEP.StandCone				= 0.015 -- Accuracy when we're standing still
SWEP.IronsightsCone			= 0.015
SWEP.Recoil				= 1.1	-- Recoil For not Aimed
SWEP.RecoilZoom				= 0.8	-- Recoil For Zoom
SWEP.Delay				= 0.1	-- Delay For Not Zoom
SWEP.DelayZoom				= 0.15	-- Delay For Zoom

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
			self.Owner:SetFOV( 40, 0.3 )
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