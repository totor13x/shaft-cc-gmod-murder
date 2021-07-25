SWEP.PrintName 		= "AK-47"

SWEP.Base				= "base_lidi_csgo"
SWEP.isCSGO = true
SWEP.ViewModel				= "models/marquis/wep/c_ak47.mdl"	-- Weapon view model
SWEP.WorldModel				= "models/marquis/wep/w_ak47.mdl"	-- Weapon world model

SWEP.Sound 			= Sound("TFA_CSGO_AK47.1")				-- This is the sound of the weapon, when you shoot.

SWEP.HoldType			= "ar2"

SWEP.Recoil				=0.5
SWEP.Damage				=50
SWEP.Rate				=.1
SWEP.ClipSize			=30
SWEP.MaxAmmo			=120
SWEP.Primary.Automatic	=true

-- Accuracy
SWEP.ConeCrouch			=.01
SWEP.ConeCrouchWalk		=.02
SWEP.ConeWalk			=.025
SWEP.ConeAir			=.1
SWEP.ConeStand			=.015
SWEP.ConeIronsights		=.015

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
