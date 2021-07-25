SWEP.PrintName 		= "M4A1"

SWEP.Base				= "base_lidi_csgo"
SWEP.isCSGO = true
SWEP.ViewModel				= "models/weapons/tfa_csgo/c_m4a1.mdl"	-- Weapon view model
SWEP.WorldModel				= "models/weapons/tfa_csgo/w_m4a1.mdl"	-- Weapon world model
SWEP.WorldModelSilencer		= "models/weapons/tfa_csgo/w_m4a1.mdl"	-- Weapon world model

SWEP.Sound 			= Sound("TFA_CSGO_M4A1.2")				-- This is the sound of the weapon, when you shoot.
SWEP.SSound 			= Sound("TFA_CSGO_M4A1.1")				-- This is the sound of the weapon, when you shoot.

SWEP.HoldType			= "ar2"

SWEP.Recoil				=1
SWEP.Damage				=50
SWEP.Rate				=.1
SWEP.ClipSize			=30
SWEP.MaxAmmo			=120
SWEP.Primary.Automatic	=true
SWEP.SetSilenced = true


-- Accuracy
SWEP.ConeCrouch			=.01
SWEP.ConeCrouchWalk		=.02
SWEP.ConeWalk			=.025
SWEP.ConeAir			=.1
SWEP.ConeStand			=.015
SWEP.ConeIronsights		=.015


SWEP.Offset = { --Procedural world model animation, defaulted for CS:S purposes.
        Pos = {
        Up = -1.5,
        Right = 0.8,
        Forward = 6,
        },
        Ang = {
        Up = 0,
        Right = 81,
        Forward = 180
        },
		Scale = 1
}


function SWEP:SetSilenced()
	self.Weapon.Silenced = true
end


function SWEP:GetSilenced()
	return true
end