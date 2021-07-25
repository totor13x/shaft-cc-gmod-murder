AddCSLuaFile()

SWEP.PrintName			= "KM UMP45"
SWEP.Author				= "Counter-Strike"
SWEP.Slot				= 0

SWEP.Hold				= "ar2"
SWEP.Base				= "base_lidi_css"

SWEP.ViewModel			= "models/weapons/cstrike/c_smg_ump45.mdl"
SWEP.WorldModel			= "models/weapons/w_smg_ump45.mdl"

SWEP.Sound			= Sound( "Weapon_ump45.Single" )
SWEP.Recoil			= 0.6
SWEP.Damage			= 25
SWEP.NumShots		= 1
SWEP.Cone			= 0.025
SWEP.ClipSize		= 32
SWEP.Rate			= 0.1
SWEP.MaxAmmo	= 128
SWEP.Primary.Automatic		= true

-- Accuracy
SWEP.CrouchCone				= 0.02 -- Accuracy when we're crouching
SWEP.CrouchWalkCone			= 0.022 -- Accuracy when we're crouching and walking
SWEP.WalkCone				= 0.025 -- Accuracy when we're walking
SWEP.AirCone				= 0.1 -- Accuracy when we're in air
SWEP.StandCone				= 0.025 -- Accuracy when we're standing still
SWEP.IronsightsCone			= 0.015

