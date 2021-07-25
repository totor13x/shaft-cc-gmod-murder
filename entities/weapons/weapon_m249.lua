AddCSLuaFile()

SWEP.PrintName			= "M249"
SWEP.Author				= "Counter-Strike"
SWEP.Slot				= 0

SWEP.Hold				= "ar2"
SWEP.Base				= "base_lidi_css"

SWEP.ViewModel			= "models/weapons/cstrike/c_mach_m249para.mdl"
SWEP.WorldModel			= "models/weapons/w_mach_m249para.mdl"

SWEP.Sound			= Sound( "Weapon_m249.Single" )
SWEP.Recoil			= 1
SWEP.Damage			= 60
SWEP.NumShots		= 1
SWEP.Cone			= 0.05
SWEP.ClipSize		= 100
SWEP.Rate			= 0.09
SWEP.MaxAmmo	= 300
SWEP.Primary.Automatic	= true

-- Accuracy
SWEP.CrouchCone				= 0.02 -- Accuracy when we're crouching
SWEP.CrouchWalkCone			= 0.05 -- Accuracy when we're crouching and walking
SWEP.WalkCone				= 0.09 -- Accuracy when we're walking
SWEP.AirCone				= 0.1 -- Accuracy when we're in air
SWEP.StandCone				= 0.07 -- Accuracy when we're standing still
SWEP.IronsightsCone			= 0.015
