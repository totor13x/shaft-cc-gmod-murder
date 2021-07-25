AddCSLuaFile()
SWEP.PrintName			= "Glock"
SWEP.Slot				= 1

SWEP.Hold				="revolver"
SWEP.Base				= "base_lidi_css"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/cstrike/c_pist_glock18.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_glock18.mdl"

SWEP.Sound			= Sound( "Weapon_Glock.Single" )
SWEP.Recoil			= 0.3
SWEP.Damage			= 24
SWEP.NumShots		= 1
SWEP.ClipSize		= 18
SWEP.MaxAmmo		= 120
SWEP.Rate			= 0.1
SWEP.Primary.Automatic		= false


-- Accuracy
SWEP.CrouchCone				= 0.02 -- Accuracy when we're crouching
SWEP.CrouchWalkCone			= 0.025 -- Accuracy when we're crouching and walking
SWEP.WalkCone				= 0.03 -- Accuracy when we're walking
SWEP.AirCone				= 0.1 -- Accuracy when we're in air
SWEP.StandCone				= 0.02 -- Accuracy when we're standing still
SWEP.IronsightsCone			= 0.015
