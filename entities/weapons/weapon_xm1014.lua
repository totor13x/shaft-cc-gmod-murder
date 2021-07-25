AddCSLuaFile()

SWEP.PrintName			= "Leone YG1265 Auto Shotgun"
SWEP.Author				= "Counter-Strike"
SWEP.Slot				= 0

SWEP.Hold				= "shotgun"
SWEP.Base				= "base_lidi_css"

SWEP.ViewModel			= "models/weapons/cstrike/c_shot_xm1014.mdl"
SWEP.WorldModel			= "models/weapons/w_shot_xm1014.mdl"

SWEP.Weight				= 10

SWEP.Sound			= Sound( "Weapon_xm1014.Single" )
SWEP.Recoil			= 1.5
SWEP.Damage			= 20
SWEP.NumShots		= 16
SWEP.Cone			= 0.05
SWEP.ClipSize		= 8
SWEP.Rate			= 0.2
SWEP.MaxAmmo		= 32
SWEP.Primary.Automatic		= true
SWEP.Shotgun = true

-- Accuracy
SWEP.ConeCrouch			=.2
SWEP.ConeCrouchWalk		=.5
SWEP.ConeWalk			=.125
SWEP.ConeAir			=.2
SWEP.ConeStand			=.15
SWEP.ConeIronsights		=.15

function SWEP:Reload()
if self.Weapon.Delay < CurTime() then
	// Already reloading
	if ( self.Weapon:GetNetworkedBool( "reloadingend" ) and self.Clip >= self.ClipSize) then return false end

	// Start reloading if we can
	if ( self.Clip >= self.ClipSize ) then
	
		self.Weapon:SetNetworkedBool( "reloadingend", true )
		
		self.Weapon:SendWeaponAnim( ACT_SHOTGUN_RELOAD_FINISH )
		self.Owner:DoReloadEvent()
	end
	
		if ( self.Clip < self.ClipSize and self.Ammo  > 0 ) then

			self.Weapon.Delay = CurTime()+self:SequenceDuration()
			self.Weapon:SetNetworkedBool( "reloadingend", false )
			self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )
			
			timer.Simple(self:SequenceDuration(),function()
				self.Clip=self.Clip+1
				self.Ammo=self.Ammo-1
				self:Reload()
			end)
			
			self.Owner:DoReloadEvent()
		end
	end
end
