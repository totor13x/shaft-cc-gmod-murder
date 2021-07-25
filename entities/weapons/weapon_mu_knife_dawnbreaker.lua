SWEP.Base = "weapon_mu_knife_alicedlc"

SWEP.ViewModel 			= "models/weapons/tfa_csgo/c_knife_survival_bowie_anim.mdl"
SWEP.WorldModel 		= "models/weapons/tfa_csgo/w_knife_bowie.mdl" 
SWEP.iSCustom = false
SWEP.ENT 					= "mu_knife_dawnbreaker"

SWEP.VElements = {
	["DLC"] = { type = "Model", model = "models/weapons/sirris_sword.mdl", bone = "v_weapon.knife", rel = "", pos = Vector(-2.2,-8.5,0.5), angle = Angle(0, -90, 90), size = Vector(0.75,1,1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = nil }
}
SWEP.WElements = {
	["DLC"] = { type = "Model", model = "models/weapons/sirris_sword.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2,3,-12), angle = Angle(90, 90, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = nil }
}

function SWEP:Reload()
	local getseq = self:GetSequence()
	local act = self:GetSequenceActivity(getseq) --GetActivity() method doesn't work :\
	if (act == ACT_VM_FIDGET and CurTime() < self:GetInspectTime()) then
        self:SetInspectTime( CurTime() + 0.1 ) -- We should press R repeately instead of holding it to loop
        return end

	self.Weapon:SendWeaponAnim(ACT_VM_FIDGET)
	self:SetIdleTime( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
    self:SetInspectTime( CurTime() + 0.1 )
	return true
end