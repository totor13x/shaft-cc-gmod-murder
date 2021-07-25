
SWEP.Base = "weapon_lightsaber"
SWEP.Slot = 1
SWEP.SlotPos = 4

SWEP.Spawnable = true
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.DrawWeaponInfoBox = false

SWEP.ViewModel = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel = "models/sgg/starwars/weapons/w_anakin_ep2_saber_hilt.mdl"
SWEP.ViewModelFOV = 55

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"


function SWEP:SetupDataTables()
	self:NetworkVar( "Float", 0, "LengthAnimation" )
	self:NetworkVar( "Float", 1, "MaxLength" )
	self:NetworkVar( "Float", 2, "BladeWidth" )
	self:NetworkVar( "Float", 3, "Force" )

	self:NetworkVar( "Bool", 0, "DarkInner" )
	self:NetworkVar( "Bool", 1, "Enabled" )
	self:NetworkVar( "Bool", 2, "WorksUnderwater" )
	self:NetworkVar( "Int", 0, "ForceType" )
	self:NetworkVar( "Int", 1, "IncorrectPlayerModel" )
	self:NetworkVar( "Int", 2, "MaxForce" )

	self:NetworkVar( "Vector", 0, "CrystalColor" )
	self:NetworkVar( "String", 0, "WorldModel" )
	self:NetworkVar( "String", 1, "OnSound" )
	self:NetworkVar( "String", 2, "OffSound" )

	if ( SERVER ) then
		self:SetLengthAnimation( 0 )
		self:SetBladeWidth( 2 )
		self:SetMaxLength( 42 )
		self:SetDarkInner( false )
		self:SetWorksUnderwater( true )
		self:SetEnabled( false )

		self:SetForceType( 1 )
		self:SetMaxForce( 100 )
		self:SetForce( self:GetMaxForce() )
		self:SetOnSound( "lightsaber/saber_on" .. math.random( 1, 4 ) .. ".wav" )
		self:SetOffSound( "lightsaber/saber_off" .. math.random( 1, 4 ) .. ".wav" )
		self:SetCrystalColor( Vector( 255, 10, 10 ) )
		//local v, k = table.Random( list.Get( "LightsaberModels" ) )
		//self:SetWorldModel( k )
		self:SetWorldModel( "models/sgg/starwars/weapons/w_anakin_ep2_saber_hilt.mdl" )

		self:NetworkVarNotify( "Force", self.OnForceChanged )
		self:NetworkVarNotify( "Enabled", self.OnEnabledOrDisabled )
	end
end


local isCalcViewFuckedUp2 = true
hook.Add( "CalcView", "!!!111_rb655_lightsaber_3rdperson", function( ply, pos, ang )
	if ( !IsValid( ply ) or !ply:Alive() or ply:InVehicle() or ply:GetViewEntity() != ply ) then return end
	if ( !LocalPlayer().GetActiveWeapon or !IsValid( LocalPlayer():GetActiveWeapon() ) or LocalPlayer():GetActiveWeapon():GetClass() != "weapon_mu_knife_lightsaber" ) then return end

	isCalcViewFuckedUp2 = false

	local trace = util.TraceHull( {
		start = pos,
		endpos = pos - ang:Forward() * 100,
		filter = { ply:GetActiveWeapon(), ply },
		mins = Vector( -4, -4, -4 ),
		maxs = Vector( 4, 4, 4 ),
	} )

	if ( trace.Hit ) then pos = trace.HitPos else pos = pos - ang:Forward() * 100 end

	return {
		origin = pos,
		angles = ang,
		drawviewer = true
	}
end )

function SWEP:DrawHUD()
	local charge = (self:GetForce())
	//if charge > 0 then
		local aa = math.EaseInOut( charge, 0.1, 0.1 ) 
			surface.SetDrawColor( Color(255,255,255,150)  )
			surface.DrawRect( (ScrW()/2)-100, (ScrH()/2)+230, 200, 16 )
			local tcol = self.Owner:GetPlayerColor()
			local scc = string.Explode(".",charge)
			//draw.SimpleText('Cooldown: '..scc[1]..'%', "Default", (ScrW()/2)-100+5,  (ScrH()/2)+150-8, tcol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			surface.SetDrawColor( Color(tcol.x*255,tcol.y*255,tcol.z*255,255)  )
			surface.DrawRect( (ScrW()/2)-(charge), (ScrH()/2)+230, charge*2, 16 )
			draw.SimpleTextOutlined( 'Заряд: '..scc[1]..'%', Default, (ScrW()/2)-100+5, (ScrH()/2)+230+8, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, tcol )
			
	//end
end

function SWEP:PrimaryAttack()
	weapons.Get("weapon_lightsaber").PrimaryAttack(self)
	
    local Weapon    = self.Weapon
    local Attacker  = self:GetOwner()
    local Forward 	= Attacker:GetAimVector()
	local AttackSrc = Attacker:EyePos()
	local AttackEnd = AttackSrc + Forward * self:GetBladeLength()
    local Act
    local Snd
    local Backstab
    local Damage
    
    Attacker:LagCompensation(true)
    
    local tracedata = {}

	tracedata.start     = AttackSrc
	tracedata.endpos    = AttackEnd
	tracedata.filter    = Attacker
    tracedata.mask      = MASK_SOLID
    tracedata.mins      = Vector( -16 , -16 , -18 )
    tracedata.maxs      = Vector( 16, 16 , 18 )
	
    -- We should calculate trajectory twice. If TraceHull hits entity, then we use second trace, otherwise - first.
    -- It's needed to prevent head-shooting since in CS:GO you cannot headshot with knife
    local tr1 = util.TraceLine( tracedata )
    local tr2 = util.TraceHull( tracedata )
    local tr = IsValid(tr2.Entity) and tr2 or tr1
    
    Attacker:LagCompensation(false) -- Don't forget to disable it!
    
    local DidHit            = tr.Hit and not tr.HitSky
    -- local trHitPos          = tr.HitPos -- Unused
    local HitEntity         = tr.Entity
    local DidHitPlrOrNPC    = HitEntity and ( HitEntity:IsPlayer() or HitEntity:IsNPC() ) and IsValid( HitEntity )
    
    -- Calculate damage and deal hurt if we can
    if DidHit then
        if HitEntity and IsValid( HitEntity ) then
		
            //Backstab = DidHitPlrOrNPC and self:EntityFaceBack( HitEntity ) -- Because we can only backstab creatures
			
            Damage = 2000
          	
            local damageinfo = DamageInfo()
            damageinfo:SetAttacker( Attacker )
            damageinfo:SetInflictor( self )

            damageinfo:SetDamage( Damage )
            damageinfo:SetDamageType( bit.bor( DMG_BULLET , DMG_NEVERGIB ) )
            damageinfo:SetDamageForce( Forward * 1000 )
            damageinfo:SetDamagePosition( AttackEnd )
            HitEntity:DispatchTraceAttack( damageinfo, tr, Forward )
            
        end
    end
end

function SWEP:Think()
	weapons.Get("weapon_lightsaber").Think(self)
	
	//self:GetBladeLength()
	
	if !self.ThinkingTime then self.ThinkingTime = CurTime() end
	if self.ThinkingTime > CurTime() then return end
	if self:GetForce() > 100 then return end
	
	self.ThinkingTime = CurTime()+1.5
	self:SetForce( self:GetForce() + 1 )
end


function SWEP:GetActiveForcePowers()
	local Force = {}
	
	for id, t in pairs( rb655_GetForcePowers() ) do
		//PrintTable(t)
		if t and t.name and t.name == "Force Lightning" then
		//local ret = hook.Run( "CanUseLightsaberForcePower", self:GetOwner(), t.name )
		//if ( ret == false ) then continue end
		//print(ret)
		table.insert( Force, t )
		end
	end
	//PrintTable(Force)
	return Force
end

hook.Add( "CanLightsaberDamageEntity", "my_unqiue_hook_name_here", function( victim, lightsaber, trace )
	return 200 -- Makes the damage twice as high for the weapon
end )


function SWEP:SecondaryAttack()
	if self:GetForce() <= 0 then return end
	if ( !IsValid( self.Owner ) or !self:GetActiveForcePowerType( self:GetForceType() ) ) then return end
	if ( game.SinglePlayer() && SERVER ) then self:CallOnClient( "SecondaryAttack", "" ) end

	local selectedForcePower = self:GetActiveForcePowerType( self:GetForceType() )
	if ( !selectedForcePower ) then return end
	local ret = hook.Run( "CanUseLightsaberForcePower", self.Owner, selectedForcePower.name )
	if ( ret == false ) then return end

		//print(self:GetForce())
	if ( CLIENT ) then return end
		local foundents = 0
		for id, ent in pairs( self:SelectTargets( 2 ) ) do
			if ( !IsValid( ent ) ) then continue end
			if (ent:IsPlayer() and ent:GetRole(MURDER)) then continue end
			if (ent:IsPlayer() and ent:GetRole(MURDER_HELPER)) then continue end
			foundents = foundents + 1
			local ed = EffectData()
			ed:SetOrigin( self:GetSaberPosAng() )
			ed:SetEntity( ent )
			util.Effect( "rb655_force_lighting", ed, true, true )

			local dmg = DamageInfo()
			dmg:SetAttacker( self.Owner or self )
			dmg:SetInflictor( self.Owner or self )

			dmg:SetDamage( math.Clamp( 512 / self.Owner:GetPos():Distance( ent:GetPos() ), 1, 25 ) )
			if ( ent:IsNPC() ) then dmg:SetDamage( 4 ) end
			ent:TakeDamageInfo( dmg )

		end

		if ( foundents > 0 ) then
			self:SetForce( self:GetForce() - foundents )
			if ( !self.SoundLightning ) then
				self.SoundLightning = CreateSound( self.Owner, "lightsaber/force_lightning" .. math.random( 1, 2 ) .. ".wav" )
				self.SoundLightning:Play()
			else
				self.SoundLightning:Play()
			end

			timer.Create( "rb655_force_lighting_soundkill", 0.2, 1, function() if ( self.SoundLightning ) then self.SoundLightning:Stop() self.SoundLightning = nil end end )
		end
		self:SetNextAttack( 0.3 )
		self:SetForce( self:GetForce() - 1 )
end
