SWEP.PrintName 		= "M1897"

SWEP.Base				= "base_lidi_csgo"
SWEP.ViewModelFlip				= true
SWEP.isCSGO = true
SWEP.ViewModel				= "models/marquis/wep/v_m1897.mdl"	-- Weapon view model
SWEP.WorldModel				= "models/marquis/wep/w_m1897.mdl"	-- Weapon world model

SWEP.Sound 			= Sound("Trench_97.Single")				-- This is the sound of the weapon, when you shoot.

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

function SWEP:Reload()
	
	//if ( CLIENT ) then return end
	// Already reloading
	if ( self.Weapon:GetNetworkedBool( "reloading", false ) ) then return end
	
	// Start reloading if we can
	if ( self.Clip < self.ClipSize && self.Ammo > 0 ) then
		
		self.Weapon:SetNetworkedBool( "reloading", true )
		self.Weapon:SetVar( "reloadtimer", CurTime() + 0.7 )
		self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )
		self.Owner:DoReloadEvent()
	end
	
end
function SWEP:GetViewModelPosition( pos, ang )

	//ang:RotateAroundAxis(ang:Up(),  -90)
	pos = pos  + (ang:Up() * 0)
	
	return pos, ang
end