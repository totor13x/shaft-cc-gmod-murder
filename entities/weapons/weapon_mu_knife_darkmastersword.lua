SWEP.Base = "weapon_mu_knife_base_for_custom_props"

SWEP.ViewModel 				= "models/weapons/c_ebonyblade.mdl"
SWEP.WorldModel 			= "models/weapons/w_ebonyblade.mdl"
SWEP.ENT 					= "mu_knife_darkmastersword"
SWEP.ViewModelFOV =75
SWEP.UseHands = true
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false

SWEP.VElements = {
	["_FFFF3"] = { type = "Model", model = "models/darkmastersword/darkmastersword3.mdl", bone = "EbonyBlade", rel = "", pos = Vector(24,0.5,0), angle = Angle(0,180,0), size = Vector(1.5,1.5,1.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = nil }
}
SWEP.WElements = {
	["_FFFF2"] = { type = "Model", model = "models/darkmastersword/darkmastersword3.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.5,1.5,-20), angle = Angle(90, 90, 0), size = Vector(1.5, 1.5, 1.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = nil }
}

function SWEP:Initialize()
	weapons.Get("weapon_mu_knife_base_for_custom_props").Initialize(self)
	self.HitBack = ACT_VM_PRIMARYATTACK
	self.HitCenter = ACT_VM_PRIMARYATTACK
	self.Miss = ACT_VM_PRIMARYATTACK
	self.Miss2 = ACT_VM_PRIMARYATTACK

	self.HitPlySound = {
		"weapons/skyrimswords/wpn_impact_blade_flesh_01.wav",
		"weapons/skyrimswords/wpn_impact_blade_flesh_02.wav",
		"weapons/skyrimswords/wpn_impact_blade_flesh_03.wav",
	}
	self.HitWallSound = {
		"weapons/skyrimswords/fx_melee_sword_other_01.wav",
		"weapons/skyrimswords/fx_melee_sword_other_02.wav",
		"weapons/skyrimswords/fx_melee_sword_other_03.wav",
	}
	self.MissSound = {
		"weapons/skyrimswords/fx_swing_blade_medium_01.wav",
		"weapons/skyrimswords/fx_swing_blade_medium_02.wav",
		"weapons/skyrimswords/fx_swing_blade_medium_03.wav",
		"weapons/skyrimswords/fx_swing_blade_medium_04.wav",
	}
end
	