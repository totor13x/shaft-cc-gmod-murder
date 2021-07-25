SWEP.Base = "weapon_mu_knife_base_for_custom_props"

SWEP.ViewModel 				= "models/weapons/c_ebonyblade.mdl"
SWEP.WorldModel 			= "models/weapons/w_knife_t.mdl"
SWEP.ViewModelFOV 			=  77 
SWEP.ENT 					= "mu_knife_alicehorseb"

SWEP.UseHands				= true	//Use C Models, basically hands that look like your model's hands. Custom models require custom hands.
SWEP.ShowViewModel = false	//Show the view model? KEEP THIS TRUE AT ALL TIMES, IF DISABLED, ON WEAPON SWITCH ALL VIEWMODELS, INCLUDING EVERY GUN, WILL BE INVISIBLE!!
SWEP.ShowWorldModel = false	//Show the world model?

--HobbyHorseB
SWEP.VElements = {
	["_FFFF3"] = { type = "Model", model = "models/hobbyhorseb.mdl", bone = "EbonyBlade", rel = "", pos = Vector(0, 0, 0), angle = Angle(0, 90, 90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
	["_FFFF2"] = { type = "Model", model = "models/hobbyhorseb.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3,1,-10), angle = Angle(180,180,0), size = Vector(1,1,1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

function SWEP:Initialize()
	weapons.Get("weapon_mu_knife_base_for_custom_props").Initialize(self)
	self.HitBack = ACT_VM_PRIMARYATTACK
	self.HitCenter = ACT_VM_PRIMARYATTACK
	self.Miss = ACT_VM_PRIMARYATTACK
	self.Miss2 = ACT_VM_PRIMARYATTACK
end