AddCSLuaFile()

SWEP.Category			="Counter-Strike"
SWEP.PrintName			="Nighthawk .50 C"
SWEP.Slot				=1

SWEP.Hold				="revolver"
SWEP.Base				="base_lidi_css"

SWEP.ViewModel			= "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_deagle.mdl"

SWEP.ClipSize			=7
SWEP.MaxAmmo			=35

SWEP.Sound			= Sound( "Weapon_Deagle.Single" )
SWEP.Recoil				=1.5
SWEP.Damage				=50
SWEP.Rate				=0.2
SWEP.Automatic			=false

-- Accuracy
SWEP.ConeCrouch				= 0.01 -- Accuracy when we're crouching
SWEP.ConeCrouchWalk			= 0.02 -- Accuracy when we're crouching and walking
SWEP.ConeWalk				= 0.025 -- Accuracy when we're walking
SWEP.ConeAir				= 0.1 -- Accuracy when we're in air
SWEP.ConeStand			= 0.015 -- Accuracy when we're standing still
SWEP.ConeIronsights			= 0.015

