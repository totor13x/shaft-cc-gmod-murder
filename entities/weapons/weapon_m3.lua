AddCSLuaFile()

SWEP.Category			= "Counter-Strike"
SWEP.PrintName			= "Leone 12 Gauge Super"
SWEP.Slot				= 0
SWEP.Hold				= "shotgun"
SWEP.HoldType				= "shotgun"
SWEP.Base				="base_lidi_css"

SWEP.ViewModelFOV		=55

SWEP.ViewModel			= "models/weapons/cstrike/c_shot_m3super90.mdl"
SWEP.WorldModel			= "models/weapons/w_shot_m3super90.mdl"
SWEP.Weight				= 10
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Sound				= Sound("Weapon_m3.Single")
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


/*---------------------------------------------------------
	Reload does nothing
---------------------------------------------------------
function SWEP:Reload()
if self.Weapon.Delay < CurTime() then
	// Already reloading

	if ( self.Weapon:GetNetworkedBool( "reloadingend" ) and self.Clip >= self.ClipSize) then return false end

	// Start reloading if we can
	if ( self.Clip >= self.ClipSize ) then
		self.Weapon:SetNetworkedBool( "reloadingend", true )
		self.Weapon:SendWeaponAnim( ACT_SHOTGUN_RELOAD_FINISH )
	end
	
		if ( self.Clip < self.ClipSize and self.Ammo > 0 ) then

			self.Weapon.Delay = CurTime()+0.62222224200213
			self.Weapon:SetNetworkedBool( "reloadingend", false )
			
			timer.Simple(0.63,function()
				self.Clip=self.Clip+1
				self.Ammo=self.Ammo-1
				//self.Owner:DoReloadEvent()
				self:Reload()
			end)
			
			self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )
			self.Owner:DoReloadEvent()
			
		end
	end
	
end
*/
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