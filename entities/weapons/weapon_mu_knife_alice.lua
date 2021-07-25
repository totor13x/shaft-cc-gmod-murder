SWEP.Base = "weapon_mu_knife_def"

SWEP.ViewModel 			= "models/weapons/v_csgo_vorpalblade.mdl"
SWEP.WorldModel 		= "models/weapons/w_csgo_vorpalblade.mdl"
SWEP.ENT 				= "mu_knife_alice"
SWEP.iSCustom = true
function SWEP:Reload()
	local getseq = self:GetSequence()
	local act = self:GetSequenceActivity(getseq) --GetActivity() method doesn't work :\
	if (act == ACT_VM_IDLE_LOWERED and CurTime() < self:GetInspectTime()) then
        self:SetInspectTime( CurTime() + 0.1 ) -- We should press R repeately instead of holding it to loop
        return end

	self.Weapon:SendWeaponAnim(ACT_VM_IDLE_LOWERED)
	self:SetIdleTime( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
    self:SetInspectTime( CurTime() + 0.1 )
	return true
end