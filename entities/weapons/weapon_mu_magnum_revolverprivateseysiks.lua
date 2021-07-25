SWEP.Base = "weapon_mu_magnum_def"

SWEP.ViewModel = "models/weapons/v_catgun.mdl"
SWEP.WorldModel = "models/weapons/w_catgun.mdl"
SWEP.ReloadSequence = "reload1"
SWEP.UseHands = true
SWEP.HoldType = "smg"
SWEP.Primary = SWEP.Primary or {}
//SWEP.Primary.Delay = 2.5
SWEP.Primary.Sound = "catgun.catgun_fire"

function SWEP:Reload()
	local getseq = self:GetSequence()
	local act = self:GetSequenceActivity(getseq) --GetActivity() method doesn't work :\
	if act == ACT_VM_DRAW then return end
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
				self:SetReloadEnd(CurTime() + vm:SequenceDuration()+0.2)
				self:SetNextIdle(CurTime() + vm:SequenceDuration()+0.2)
				return
			end
		end
	end
end


sound.Add( { 
  name = "catgun.catgun_fire",
  channel = CHAN_WEAPON,
  volume = 0.90,
  level = SNDLVL_GUNFIRE,
  sound = { 
    "weapons/catgun_fire01.wav",
    "weapons/catgun_fire02.wav",
    "weapons/catgun_fire03.wav",
    "weapons/catgun_fire04.wav",
    "weapons/catgun_fire05.wav",
    "weapons/catgun_fire06.wav",
    "weapons/catgun_fire07.wav",
    "weapons/catgun_fire08.wav"
  }
} )
sound.Add( { name = "catgun.catgun_reload", channel = CHAN_ITEM, volume = 0.70, level = SNDLVL_NORM, sound = "weapons/catgun_reload.wav" } )
sound.Add( { name = "catgun.catgun_reload00", channel = CHAN_ITEM, volume = 0.70, level = SNDLVL_NORM, sound = "weapons/catgun_reload00.wav" } )
--sound.Add( { name = "catgun.catgun_reload_shorter", channel = CHAN_ITEM, volume = 0.70, level = SNDLVL_NORM, sound = "weapons/catgun_reload_shorter.wav" } )
--sound.Add( { name = "catgun.catgun_reload00_shorter", channel = CHAN_ITEM, volume = 0.70, level = SNDLVL_NORM, sound = "weapons/catgun_reload00_shorter.wav" } )
sound.Add( { name = "catgun.catgun_deploy", channel = CHAN_STATIC, volume = 0.70, level = SNDLVL_NORM, sound = "weapons/catgun_deploy.wav" } )