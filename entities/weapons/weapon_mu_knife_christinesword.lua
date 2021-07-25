SWEP.Base = "weapon_mu_knife_base_for_custom_props"

SWEP.ViewModel 				= "models/weapons/c_ebonyblade.mdl"
SWEP.WorldModel 			= "models/weapons/w_ebonyblade.mdl"
SWEP.ENT 					= "mu_knife_cristinesword"
SWEP.ViewModelFOV =75
SWEP.UseHands				= true	//Use C Models, basically hands that look like your model's hands. Custom models require custom hands.
SWEP.ShowViewModel = true	//Show the view model? KEEP THIS TRUE AT ALL TIMES, IF DISABLED, ON WEAPON SWITCH ALL VIEWMODELS, INCLUDING EVERY GUN, WILL BE INVISIBLE!!
SWEP.ShowWorldModel = false	//Show the world model?


SWEP.VElements = {
	-- ["2b_virtuos"] = { type = "Model", model = "models/kuma96/2b/virtuouscontract/virtuouscontract.mdl", bone = "EbonyBlade", rel = "", pos = Vector(8, 0, -6), angle = Angle(0, 0, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0 }
	["2b_virtuos"] = { type = "Model", model = "models/player/dewobedil/christine/props/sword.mdl", bone = "EbonyBlade", rel = "", pos = Vector(35, 0, 0), angle = Angle(90, 0, 0), size = Vector(1, 1, 1.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0,  bodygroup = {[1] = 1} }
}
SWEP.WElements = {
	-- ["2b_virtuos"] = { type = "Model", model = "models/kuma96/2b/virtuouscontract/virtuouscontract.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.596, 6.5, -4), angle = Angle(-90, 180, 90), size = Vector(0.9, 0.9, 0.9), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0 }
	["2b_virtuos"] = { type = "Model", model = "models/player/dewobedil/christine/props/sword.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.76, 1.1, -32), angle = Angle(0, -90, 0), size = Vector(1, 1, 1.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0,  bodygroup = {[1] = 1}  }
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
	