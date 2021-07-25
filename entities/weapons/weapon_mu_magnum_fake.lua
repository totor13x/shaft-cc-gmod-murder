SWEP.Base = "weapon_mu_magnum_def"

function SWEP:Initialize()
	if self.Owner:GetNWString("ps_weapon_rev") == '' then
		self.Owner:SetNWString("ps_weapon_rev",'weapon_mu_magnum_def')
	end
	weapons.Get(self.Base).Initialize(self)
	if CLIENT then
		local no = self.Owner:GetNWString("ps_weapon_rev")
		self.Skin = weapons.Get(no).Skin
		self.ViewModel = weapons.Get(no).ViewModel
		self.WorldModel = weapons.Get(no).WorldModel
	end
end

function SWEP:PrimaryAttack()
	if SERVER then   

	local bone = self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand")

	//if (!bone) then return end
	
	pos, ang = self:GetOwner():GetPos(), Angle(0,0,0)
	if (bone) then
		local m = self:GetOwner():GetBoneMatrix(bone)
		if (m) then
			pos, ang = m:GetTranslation(), m:GetAngles()
		end
	end
	local ent = ents.Create( "env_explosion" )
	ent:SetPos( pos )

	//ent:SetOwner( self.Owner )
	ent:SetKeyValue( "iMagnitude", "120" )
	ent:Spawn()
	ent:Fire( "Explode", 0, 0 )
	self:Remove()
	end
end