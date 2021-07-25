if SERVER then
	game.AddParticles("particles/nope_mercy_particles.pcf")
	PrecacheParticleSystem("nope_muzzle_mercy")
	PrecacheParticleSystem("nope_muzzle_flash_mercy")
	PrecacheParticleSystem("nope_muzzle_flash_mercy2")
	PrecacheParticleSystem("nope_muzzle_flash_energy_nospiral_mercy")
	PrecacheParticleSystem("nope_muzzle_brake_mercy")
end

SWEP.Base = "weapon_mu_magnum_def"

SWEP.ViewModel = "models/weapons/mercy/c_mercy_nope.mdl" --Viewmodel path
SWEP.WorldModel = "models/weapons/mercy/w_mercy_blaster.mdl" -- Worldmodel path
SWEP.Primary.Sound = Sound("NOPE_MERCY.1") -- This is the sound of the weapon, when you shoot.
//~giveweapon Toto weapon_mu_magnum_revolverprivatesey2
SWEP.Offset = { --Procedural world model animation, defaulted for CS:S purposes.
        Pos = {
        Up = -0,
        Right = 1.4,
        Forward = 5.3,
        },
        Ang = {
        Up = 3,
        Right = 0,
        Forward = 178
        },
		Scale = 0.9
}
//print(file.Exists( 'particles/nope_mercy_particles.pcf', 'GAME' ))

local oiv = nil

function SWEP:OwnerIsValid()
	if oiv == nil then oiv = IsValid(self:GetOwner()) end
	return oiv
end

function SWEP:IsFirstPerson()//~giveweapon Toto weapon_mu_magnum_revolverprivatesey2
	if not IsValid(self) or not self:OwnerIsValid() then return false end
	if sp and SERVER then return not self:GetOwner().TFASDLP end
	if self:GetOwner().ShouldDrawLocalPlayer and self:GetOwner():ShouldDrawLocalPlayer() then return false end
	local gmsdlp

	if LocalPlayer then
		gmsldp = hook.Call("ShouldDrawLocalPlayer", GAMEMODE, self:GetOwner())
	else
		gmsldp = false
	end

	if gmsdlp then return false end
	return true
end

function SWEP:DoPrimaryAttackEffect(stats)
	weapons.Get("weapon_mu_magnum_def").DoPrimaryAttackEffect(self, stats)
	
	local vm = self:GetOwner():GetViewModel()
	
	local att = math.max(1, self:LookupAttachment(1))
	fx = EffectData()
	fx:SetOrigin(self:GetOwner():GetShootPos())
	fx:SetNormal(self:GetOwner():EyeAngles():Forward())
	fx:SetEntity(self)
	fx:SetAttachment(att)
	
	util.Effect( "nope_mercy_particles" , fx)
	if  SERVER then
		local ent = ents.Create( "bullet_mercy" )
		if ( IsValid( ent )  ) then
		local ang = self.Owner:EyeAngles()
			local vmpos, vmang = self:GetOwner():GetBonePosition( self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand") )
			local posn = (vmpos+vmang:Forward()*-10+vmang:Up()*-5+vmang:Right()*2)
			local angle = self.Owner:GetEyeTraceNoCursor()
			ent:SetPos( posn )
			ent:SetAngles( (angle.HitPos-posn):Angle() +self.Owner:GetViewPunchAngles() )
			ent:SetOwner( self.Owner )
			ent:Spawn()
			ent:Activate()
			
			local phys = ent:GetPhysicsObject()
			if ( IsValid( phys ) ) then phys:Wake() phys:AddVelocity( ent:GetForward() * 2000 ) end
		end
	end

end


function SWEP:DoImpactEffect( trace, damageType )
	local effectdata = EffectData()
	effectdata:SetStart( trace.HitPos )
	effectdata:SetOrigin( trace.HitNormal + Vector( math.Rand( -0.5, 0.5 ), math.Rand( -0.5, 0.5 ), math.Rand( -0.5, 0.5 ) ) )
	util.Effect( "impact_mercy", effectdata )

	return true
end

