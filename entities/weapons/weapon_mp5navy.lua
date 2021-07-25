AddCSLuaFile()

	SWEP.PrintName			= "KM Sub-Machine Gun"
	SWEP.Author				= "Counter-Strike"
	SWEP.Slot				= 0


SWEP.Hold			= "smg"
SWEP.Base				= "base_lidi_css"


SWEP.ViewModel			= "models/weapons/cstrike/c_smg_mp5.mdl"
SWEP.WorldModel			= "models/weapons/w_smg_mp5.mdl"

SWEP.Sound			= Sound( "Weapon_MP5Navy.Single" )
SWEP.Recoil			= 0.8
SWEP.Damage			= 24
SWEP.NumShots		= 1
SWEP.Cone			= 0.025
SWEP.ClipSize		= 30
SWEP.Rate			= 0.08
SWEP.MaxAmmo		= 120
SWEP.Primary.Automatic		= true

-- Accuracy
SWEP.CrouchCone				= 0.02 -- Accuracy when we're crouching
SWEP.CrouchWalkCone			= 0.03 -- Accuracy when we're crouching and walking
SWEP.WalkCone				= 0.03 -- Accuracy when we're walking
SWEP.AirCone				= 0.1 -- Accuracy when we're in air
SWEP.StandCone				= 0.03 -- Accuracy when we're standing still
SWEP.IronsightsCone			= 0.015

