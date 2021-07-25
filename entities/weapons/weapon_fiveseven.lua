AddCSLuaFile()

SWEP.PrintName			="ES Five-Seven"
SWEP.Slot				=1

SWEP.Hold				="revolver"
SWEP.Base				="base_lidi_css"

SWEP.ViewModel			= "models/weapons/cstrike/c_pist_fiveseven.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_fiveseven.mdl"

SWEP.ClipSize			=21
SWEP.MaxAmmo			=84

SWEP.Sound			= Sound( "Weapon_FiveSeven.Single" )
SWEP.Damage				=35
SWEP.Rate				=0.08
SWEP.Recoil			= 0.5
SWEP.Automatic			=false


-- Accuracy
SWEP.CrouchCone				= 0.02 -- Accuracy when we're crouching
SWEP.CrouchWalkCone			= 0.025 -- Accuracy when we're crouching and walking
SWEP.WalkCone				= 0.03 -- Accuracy when we're walking
SWEP.AirCone				= 0.1 -- Accuracy when we're in air
SWEP.StandCone				= 0.02 -- Accuracy when we're standing still
SWEP.IronsightsCone			= 0.015
