AddCSLuaFile()

SWEP.Category			="Counter-Strike"
SWEP.PrintName			="Nighthawk .50 C"
SWEP.Slot				=1

SWEP.Hold				="revolver"
SWEP.Base				="base_lidi_csgo"

SWEP.isCSGO = true
SWEP.ViewModel				= "models/weapons/tfa_csgo/c_pist_deagle.mdl"	-- Weapon view model
SWEP.WorldModel				= "models/weapons/tfa_csgo/w_deagle.mdl"	-- Weapon world model

SWEP.ClipSize			=7
SWEP.MaxAmmo			=35

SWEP.Sound			= Sound( "TFA_CSGO_DEAGLE.1" )
SWEP.Recoil				=1.5
SWEP.Damage				=50
SWEP.Rate				=0.2
SWEP.Automatic			=false

-- Accuracy
SWEP.ConeCrouch				= 0.01 -- Accuracy when we're crouching
SWEP.ConeCrouchWalk			= 0.02 -- Accuracy when we're crouching and walking
SWEP.ConeWalk				= 0.025 -- Accuracy when we're walking
SWEP.ConeAir				= 0.1 -- Accuracy when we're in air
SWEP.ConeStand				= 0.015 -- Accuracy when we're standing still
SWEP.ConeIronsights			= 0.015

SWEP.v_skin 					= nil
SWEP.w_skin 					= SWEP.v_skin

SWEP.Offset = { --Procedural world model animation, defaulted for CS:S purposes.
        Pos = {
        Up = -3.5,
        Right = 0.8,
        Forward = 6,
        },
        Ang = {
        Up = 3,
        Right = 90,
        Forward = 178
        },
		Scale = 1
}
