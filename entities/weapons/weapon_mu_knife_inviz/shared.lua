SWEP.Base = "weapon_mu_knife_def"

SWEP.ViewModel 			= "models/weapons/v_csgo_default_t.mdl"
SWEP.WorldModel 		= "models/weapons/w_csgo_default_t.mdl" 
SWEP.ENT 				= "mu_knife_sickle" 
SWEP.ViewModelFOV = 65
SWEP.DrawCrosshair  = true
SWEP.Primary.Damage = 120
SWEP.Primary.Delay = 0.5
SWEP.RenderGroup = RENDERGROUP_BOTH
SWEP.GetMaxClip = 20
SWEP.IronsightsPercent = 0

function SWEP:SetupDataTables()
	weapons.Get("weapon_mu_knife_def").SetupDataTables(self)
	self:NetworkVar( "Int", 0, "Charge" )
	self:NetworkVar( "Int", 1, "Clip" )
end

function SWEP:Think()
	//weapons.Get("weapon_mu_knife_def").Think(self)
	
	if self.NextTick and self.NextTick > CurTime() then return end

	if SERVER then
		if self:IsCloaked() then
			self:SetClip( math.Clamp( self:GetClip() - 1, 0, self.GetMaxClip ) )
		else
			self:SetClip( math.Clamp( self:GetClip() + 1, 0, self.GetMaxClip ) )
		end
	end
	
	if self:IsCloaked() and self:GetClip() <= 0 then
		self:Uncloak()
	end

	self.NextTick = CurTime() + 1
end

function SWEP:SecondaryAttack()
	if self:IsCloaked() and self:GetClip() > 0 then self:Uncloak() else self:Cloak() end
	self:SetNextSecondaryFire( CurTime() + 1 )
	
end

function SWEP:IsCloaked()
	return self.Owner:GetNWBool( "StealthCamo", false )
end

function SWEP:Cloak( pl )
	if SERVER then self.Owner:PS_PlayerDeath() end
	self.Primary.Damage = 40
	self.Owner:SetNWBool( "StealthCamo", true )
	self.Owner:DrawShadow( false )
end

function SWEP:Holster()
	self:Uncloak( self.Owner )
	return not self:IsCloaked()
end

function SWEP:OnRemove()
	self:Uncloak( self.Owner )
end

function SWEP:Uncloak( pl )
	if SERVER then self.Owner:PS_PlayerSpawn() end
	self.Primary.Damage = 120
	self.Owner:SetNWBool( "StealthCamo", false )
	self.Owner:DrawShadow( true )
end


function SWEP:DrawHUD()
	
	local charge = (self:GetClip())/self.GetMaxClip*100
	//if charge > 0 then
	local aa = math.EaseInOut( charge, 0.1, 0.1 ) 
	surface.SetDrawColor( Color(255,255,255,150)  )
	surface.DrawRect( (ScrW()/2)-100, (ScrH()/2)+230, 200, 16 )
	local tcol = self.Owner:GetPlayerColor()
	local scc = string.Explode(".",charge)
	//draw.SimpleText('Cooldown: '..scc[1]..'%', "Default", (ScrW()/2)-100+5,  (ScrH()/2)+150-8, tcol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	surface.SetDrawColor( Color(tcol.x*255,tcol.y*255,tcol.z*255,255)  )
	surface.DrawRect( (ScrW()/2)-(charge), (ScrH()/2)+230, charge*2, 16 )
	draw.SimpleTextOutlined( 'Заряд: '..scc[1]/10 ..'', Default, (ScrW()/2)-100+5, (ScrH()/2)+230+8, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, tcol )
	
	//end
end  

if CLIENT then
	function SWEP:Initialize()
		hook.Add( "PrePlayerDraw", self, self.PrePlayerDraw )
		hook.Add( "PostPlayerDraw", self, self.PostPlayerDraw )
		hook.Add( "PreDrawPlayerHands", self, self.PreDrawPlayerHands )
		hook.Add( "PostDrawPlayerHands", self, self.PostDrawPlayerHands )
	end

	local Materials = {}

	function SWEP:PrepareMaterial( mat )
		--~local shader = Material( mat ):GetShader()
		local shader = "VertexLitGeneric"
		local params = util.KeyValuesToTable( file.Read( "materials/" .. mat .. ".vmt", "GAME" ) or "") or {}
		params.Proxies = params.proxies or {}

		params[ "$cloakpassenabled" ] = 1
		params[ "$cloakfactor" ] = 0

		params.Proxies[ "PlayerCloak" ] = {}

		Materials[ mat ] = CreateMaterial( mat .. "_c", shader, params )
	end

	function SWEP:CloakThink()
		if not self.Owner.CloakFactor then self.Owner.CloakFactor = 0 end
		
		self.Owner.CloakFactor = math.Approach(	self.Owner.CloakFactor, self:IsCloaked( self.Owner ) and 1 or 0, FrameTime() )
			
	end

	function SWEP:PrePlayerDraw( pl )
		if pl ~= self.Owner then return end
		
		self:CloakThink()

		if self.Owner.CloakFactor <= 0 then return end

		render.UpdateRefractTexture() 

		for k, v in ipairs( self.Owner:GetMaterials() ) do
			if not Materials[ v ] then self:PrepareMaterial( v ) end
			render.MaterialOverrideByIndex( k - 1, Materials[ v ] )
		end
	end

	function SWEP:PostPlayerDraw( pl )
		if pl ~= self.Owner or self.Owner.CloakFactor <= 0 then return end

		render.MaterialOverrideByIndex()
	end

	function SWEP:PreDrawPlayerHands( hands, vm, pl )
	
		if pl ~= self.Owner then return end

		self:CloakThink()

		if self.Owner.CloakFactor <= 0 then return end
		
		render.SetBlend( 1 - self.Owner.CloakFactor )
	end

	function SWEP:PostDrawPlayerHands( hands, vm, pl )
		if pl ~= self.Owner or self.Owner.CloakFactor <= 0 then return end

		render.SetBlend( 1 )
	end

	function SWEP:CustomAmmoDisplay()
		self.AmmoDisplay = self.AmmoDisplay or {} 
		self.AmmoDisplay.Draw = true
		self.AmmoDisplay.PrimaryClip = self:Clip1()

		return self.AmmoDisplay
	end

	matproxy.Add{
		name = "PlayerCloak",
		init = function() end,
		bind = function( self, mat, ent )
			if not IsValid( ent ) or not ent.CloakFactor then return end
			mat:SetFloat( "$cloakfactor", ent.CloakFactor )
		end
	}
end
