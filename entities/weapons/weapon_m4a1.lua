AddCSLuaFile()

SWEP.Category			="Counter-Strike"
SWEP.PrintName			="M4A1"
SWEP.Slot				=0

SWEP.Hold				="ar2"
SWEP.Base				="base_lidi_css"
SWEP.id 				='weapon_m4a1'

SWEP.ViewModelFOV		=60

SWEP.ViewModel			= "models/weapons/cstrike/c_rif_m4a1.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_m4a1.mdl"
SWEP.WorldModelSilencer	= "models/weapons/w_rif_m4a1_silencer.mdl"


SWEP.Sound				= Sound("Weapon_M4a1.single")
SWEP.SSound      		= Sound( "Weapon_M4a1.Silenced" )
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


function SWEP:SetSilenced()
	if  self.Weapon.Silenced == false then
		self.Weapon.Silenced = true
	else
		self.Weapon.Silenced = false
	end
end


function SWEP:GetSilenced()
	return self.Weapon.Silenced
end
