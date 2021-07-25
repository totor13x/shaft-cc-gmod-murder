SWEP.PrintName 		= "Nova"

SWEP.Base				= "base_lidi_csgo"
SWEP.isCSGO = true
SWEP.ViewModel				= "models/weapons/tfa_csgo/c_nova.mdl"	-- Weapon view model
SWEP.WorldModel				= "models/weapons/tfa_csgo/w_nova.mdl"	-- Weapon world model

SWEP.Sound 			= Sound("TFA_CSGO_NOVA.1")				-- This is the sound of the weapon, when you shoot.

SWEP.Hold				= "shotgun"
SWEP.HoldType				= "shotgun"

SWEP.ViewModelFOV		=70

SWEP.Recoil				=1.5
SWEP.Damage				=23
SWEP.Rate				=1
SWEP.ClipSize			=8
SWEP.MaxAmmo			=32
SWEP.NumShots			=16
SWEP.Primary.Automatic	=false
SWEP.Shotgun = true

-- Accuracy
SWEP.ConeCrouch			=.2
SWEP.ConeCrouchWalk		=.5
SWEP.ConeWalk			=.125
SWEP.ConeAir			=.2
SWEP.ConeStand			=.15
SWEP.ConeIronsights		=.15

SWEP.Offset = { --Procedural world model animation, defaulted for CS:S purposes.
        Pos = {
        Up = -2,
        Right = 1.3,
        Forward = 5.8,
        },
        Ang = {
        Up = 180,
        Right = 100,
        Forward = 0
        },
		Scale = 1
}
