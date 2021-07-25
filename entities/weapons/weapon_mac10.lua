AddCSLuaFile()

	SWEP.PrintName			= "Ingram Mac-10"
	SWEP.Author				= "Counter-Strike"
	SWEP.Slot				= 0
	SWEP.SlotPos			= 4

SWEP.Hold				= "pistol"
SWEP.Base				= "base_lidi_css"

SWEP.ViewModel			= "models/weapons/cstrike/c_smg_mac10.mdl"
SWEP.WorldModel			= "models/weapons/w_smg_mac10.mdl"

SWEP.Sound			= Sound( "Weapon_mac10.Single" )
SWEP.Recoil			= 0.7
SWEP.Damage			= 24
SWEP.NumShots		= 1
SWEP.Cone			= 0.03
SWEP.ClipSize		= 25
SWEP.Rate			= 0.07
SWEP.MaxAmmo	= 100
SWEP.Primary.Automatic		= true

-- Accuracy
SWEP.CrouchCone				= 0.025 -- Accuracy when we're crouching
SWEP.CrouchWalkCone			= 0.03 -- Accuracy when we're crouching and walking
SWEP.WalkCone				= 0.04 -- Accuracy when we're walking
SWEP.AirCone				= 0.1 -- Accuracy when we're in air
SWEP.StandCone				= 0.04 -- Accuracy when we're standing still
SWEP.IronsightsCone			= 0.015


