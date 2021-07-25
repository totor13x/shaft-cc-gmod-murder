AddCSLuaFile()

SWEP.PrintName			= "Schmidt Machine Pistol"
SWEP.Author				= "Counter-Strike"
SWEP.Slot				= 0

SWEP.Hold				= "ar2"
SWEP.Base				= "base_lidi_css"

SWEP.ViewModel			= "models/weapons/cstrike/c_smg_tmp.mdl"
SWEP.WorldModel			= "models/weapons/w_smg_tmp.mdl"

SWEP.Sound			= Sound( "Weapon_tmp.Single" )
SWEP.Recoil			= 0.4
SWEP.Damage			= 25
SWEP.NumShots		= 1
SWEP.Cone			= 0.04
SWEP.ClipSize		= 25
SWEP.Rate			= 0.075
SWEP.MaxAmmo	= 100
SWEP.Primary.Automatic		= true

-- Accuracy
SWEP.CrouchCone				= 0.025 -- Accuracy when we're crouching
SWEP.CrouchWalkCone			= 0.03 -- Accuracy when we're crouching and walking
SWEP.WalkCone				= 0.04 -- Accuracy when we're walking
SWEP.AirCone				= 0.1 -- Accuracy when we're in air
SWEP.StandCone				= 0.04 -- Accuracy when we're standing still
SWEP.IronsightsCone			= 0.015

