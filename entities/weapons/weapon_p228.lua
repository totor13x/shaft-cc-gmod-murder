AddCSLuaFile()
	SWEP.PrintName			= "228 Compact"
	SWEP.Author				= "Counter-Strike"
	SWEP.Slot				= 1


SWEP.Hold			= "revolver"
SWEP.Base				= "base_lidi_css"

SWEP.ViewModel			= "models/weapons/cstrike/c_pist_p228.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_p228.mdl"

SWEP.Sound			= Sound( "Weapon_p228.Single" )
SWEP.Recoil			= 0.5
SWEP.Damage			= 24
SWEP.NumShots		= 1
SWEP.Cone			= 0.02
SWEP.ClipSize		= 12
SWEP.Rate			= 0.08
SWEP.MaxAmmo	= 48
SWEP.Primary.Automatic		= false


-- Accuracy
SWEP.CrouchCone				= 0.02 -- Accuracy when we're crouching
SWEP.CrouchWalkCone			= 0.025 -- Accuracy when we're crouching and walking
SWEP.WalkCone				= 0.03 -- Accuracy when we're walking
SWEP.AirCone				= 0.1 -- Accuracy when we're in air
SWEP.StandCone				= 0.02 -- Accuracy when we're standing still
SWEP.IronsightsCone			= 0.015
