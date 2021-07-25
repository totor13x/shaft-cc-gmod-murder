if SERVER then
	AddCSLuaFile()
else
	function SWEP:DrawWeaponSelection( x, y, w, h, alpha )
	end
end

SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.UseHands = false
SWEP.ViewModel	= "models/weapons/c_arms.mdl"
SWEP.WorldModel	= ""
SWEP.ViewModelFlip = false

SWEP.HoldType = "normal"

SWEP.PrintName = "Руки"

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	self:SetHoldType(self.HoldType)
	if SERVER then
	timer.Simple(0, function()
		if IsValid(self) and IsValid(self.Owner) then
			self.Owner:DrawViewModel(true)
			self.Owner:SetupHands()
			self:SetHoldType(self.HoldType)
			
		end
	end)
	end
end

function SWEP:DoPrimaryAttackEffect()
end

function SWEP:PreDrawPlayerHands( vm, Player, Weapon )
	return
end

function SWEP:PostDrawPlayerHands( hands, vm, pl )
	return
end

function SWEP:PreDrawViewModel( vm, Player, Weapon )
	return
end

function SWEP:PostDrawViewModel( vm, Player, Weapon )
	return
end

function SWEP:SecondaryAttack()
end

function SWEP:Think()
end

function SWEP:Reload()
end

function SWEP:PrimaryAttack()
end
