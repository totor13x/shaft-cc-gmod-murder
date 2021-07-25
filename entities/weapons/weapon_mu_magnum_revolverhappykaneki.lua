SWEP.Base = "weapon_mu_magnum_def"
SWEP.Primary.Sound 			= Sound("N_Reaper.fire")

SWEP.ViewModel = "models/weapons/c_reaper_nope.mdl"
SWEP.WorldModel = "models/weapons/w_reaper_nope.mdl"
SWEP.Primary.Delay = 1.1

function SWEP:Reload()
	local getseq = self:GetSequence()
	local act = self:GetSequenceActivity(getseq) --GetActivity() method doesn't work :\
	//if act == ACT_VM_DRAW then return end
	if self:IsIdle() then
		if self:GetWeaponState() == "normal" && self:GetMaxClip1() > 0 && self:Clip1() < self:GetMaxClip1() then
			local spare = self.Owner:GetAmmoCount(self:GetPrimaryAmmoType())
			if spare > 0 || self.Primary.InfiniteAmmo then
				local vm = self.Owner:GetViewModel()
				vm:SendViewModelMatchingSequence(vm:LookupSequence(self.ReloadSequence))
				if self.ReloadSound then
					self:EmitSound(self.ReloadSound)
				end
				self.Owner:SetAnimation(PLAYER_RELOAD)
				self:SetReloadEnd(CurTime() + vm:SequenceDuration())
				self:SetNextIdle(CurTime() + vm:SequenceDuration())
				return
			end
		end
	end
end

function SWEP:IsIdle()
	if not self:IsValid() then return false end
	if self:GetReloadEnd() ~= nil and self:GetReloadEnd() > 0 && self:GetReloadEnd() >= CurTime() then return false end
	if self:GetNextPrimaryFire() > 0 && self:GetNextPrimaryFire() >= CurTime() then return false end
	if self:GetDrawEnd() > 0 && self:GetDrawEnd() >= CurTime() then return false end
	return true
end