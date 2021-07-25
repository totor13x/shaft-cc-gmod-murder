AddCSLuaFile()

SWEP.Category			="Counter-Strike"
SWEP.PrintName			="USP"
SWEP.Slot				=1

SWEP.Hold				="revolver"
SWEP.Base				="base_lidi_css"

SWEP.ViewModel			="models/weapons/cstrike/c_pist_usp.mdl"
SWEP.WorldModel			="models/weapons/w_pist_usp.mdl"
SWEP.WorldModelSilencer	="models/weapons/w_pist_usp_silencer.mdl"

SWEP.ClipSize			=18
SWEP.MaxAmmo			=100

SWEP.Sound				=Sound("Weapon_usp.Single")
SWEP.SSound				=Sound("Weapon_usp.SilencedShot")
SWEP.Recoil				=0.3
SWEP.Damage				=24
SWEP.Rate				=0.08
SWEP.Automatic			=false

SWEP.SetSilenced			=true

-- Accuracy
SWEP.ConeCrouch			=.02 -- Accuracy when we're crouching
SWEP.ConeCrouchWalk		=.025 -- Accuracy when we're crouching and walking
SWEP.ConeWalk			=.03 -- Accuracy when we're walking
SWEP.ConeAir			=.1 -- Accuracy when we're in air
SWEP.ConeStand			=.02 -- Accuracy when we're standing still
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
