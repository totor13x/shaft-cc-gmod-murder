-----------------------------------------------------

if( SERVER ) then
	AddCSLuaFile( "shared.lua" );
end

 SWEP.Base = "weapon_base"
SWEP.PrintName		= "Шокер"
SWEP.ViewModelFOV       = 62
SWEP.ViewModelFlip      = false
SWEP.Spawnable      = false
SWEP.AdminSpawnable          = true
SWEP.NextStrike = 0;
SWEP.FakeAttack = 0;
SWEP.ViewModel 		= "models/weapons/v_stunbaton.mdl"
SWEP.WorldModel 	= "models/weapons/w_stunbaton.mdl"
SWEP.UseHands = true
SWEP.Primary.ClipSize      = -1    
SWEP.Primary.DefaultClip        = 0  
SWEP.Primary.Automatic    = false  
SWEP.Primary.Ammo                     = ""
SWEP.Secondary.ClipSize  = -1    
SWEP.Secondary.DefaultClip      = 0   
SWEP.Secondary.Automatic        = false  
SWEP.Secondary.Ammo               = ""

SWEP.Primary.Sound = "weapons/stunstick/stunstick_fleshhit" .. math.random(1,2) .. ".wav" 
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""
SWEP.DrawWeaponInfoBox = false
SWEP.Slot				= 2
SWEP.SlotPos			= 1

function SWEP:SetupDataTables()
	self:NetworkVar( "Int", 0, "Charge" )
	self:NetworkVar( "Int", 1, "MaxCharge" )
end

function SWEP:Initialize()
	self:SetHoldType( "melee" );
end

function SWEP:tasePlayer( ply )
	if !IsValid(ply) then return end
	local defaultTime = 0.2
	if ply:GetRole(MURDER) then
		defaultTime = 0.6
	end
	timer.Simple(defaultTime, function()
		if IsValid(ply) then
			ply:SetMoveType(MOVETYPE_WALK)
			ply:SetDSP(0)
			ply:SetMaterial( "" )
		end
	end)
	ply:SetMoveType(MOVETYPE_FLYGRAVITY)
	ply:SetDSP(8)
	ply:SetMaterial( "models/alyx/emptool_glow" )
	umsg.Start( "ulx_blind", ply )
	umsg.Bool( true )
	umsg.Short( 255 )
	umsg.End()
	timer.Simple( defaultTime, function()
		for i = -255, 0 do
			umsg.Start( "ulx_blind", ply )
				umsg.Bool( true )
				umsg.Short( math.abs( i ) )
			umsg.End()
			if i == 0 then
				umsg.Start( "ulx_blind", ply )
					umsg.Bool( false )
					umsg.Short( 0 )
				umsg.End()
			end
		end
	end )
	umsg.Start( "StartBlurShock", ply )
	umsg.End()
	if (ply:GetRole(HEADCRAB) or ply:GetRole(HEADCRAB_BLACK)) and ply:Alive() then
		
		ply:SetNWInt("CountHited", ply:GetNWInt("CountHited")+1)
		if ply:GetNWBool("hooked") then
			ply:SetNWBool("hooked", false)
			local h = ply:GetNWEntity("hooked_ply")

			if IsValid(h) then
				h.ModelOld = h:GetModel()
				h:Spawn()
				h:SetHealth(10)
				h:SetPos(ply:GetPos())
				h:SetAngles(ply:GetAngles())
				h:SetNWBool("h_hooked",false)
				h:SetModel(h.ModelOld)
			end
			
			ply:SetPos(ply:GetPos()+Vector(0,0,90))
			ply:SetNWEntity("hooked_ply",nil)
			ply:SetNWEntity("hooked_dbl", nil)
			local id = 'headcrab_poison'
			if ply:GetRole(HEADCRAB) then
				id = 'headcrab_fast'
			end
			pk_pills.apply(ply,id)
		end
		
		if ply:GetNWInt("CountHited") == 1 then
			ply:SetHealth(1)
		end
		if ply:GetNWInt("CountHited") == 2 then
			ply:SetNWBool("cant", true)
		end
		if ply:GetNWInt("CountHited") >= 3 then
			ply:Kill()
		end
	end
	/*
	if ply:GetRole(HEADCRAB) then
		if ply:GetNWBool("hooked") then
			if ply.Bited == 1 then
				local ent = ply:GetNWEntity("hooked_dbl")
				ply:SetNWBool("hooked", false)
				local h = ply:GetNWEntity("hooked_ply")
				if IsValid(h) then
				h.ModelOld = h:GetModel()
				h:Spawn()
				h:SetPos(ply:GetPos())
				h:SetAngles(ply:GetAngles())
				h:SetNWBool("h_hooked",false)
				h:SetModel(h.ModelOld)
				h:Kill()
				h.Bited = 0
				end
				ply:SetNWEntity("hooked_ply",nil)
				ply:SetNWEntity("hooked_dbl", nil)
				
				pk_pills.apply(ply,'headcrab_fast')

				ply.Hited = 0
				
				ply:SetPos(ply:GetPos()+Vector(0,0,90))
				ply:SetWalkSpeed(40)
				ply:SetRunSpeed(55)
				ply:SetNWBool("cant", true)
				return 
			end
			if ply.Hited == 2 then
			
				local ent = ply:GetNWEntity("hooked_dbl")
				ply:SetNWBool("hooked", false)
				local h = ply:GetNWEntity("hooked_ply")
				if IsValid(h) then
				h.ModelOld = h:GetModel()
				h:Spawn()
				h:SetPos(ply:GetPos())
				h:SetAngles(ply:GetAngles())
				h:SetNWBool("h_hooked",false)
				h:SetModel(h.ModelOld)
				h.Bited = 1
				end
				ply:SetNWEntity("hooked_ply",nil)
				ply:SetNWEntity("hooked_dbl", nil)
				
				pk_pills.apply(ply,'headcrab_fast')

				ply.Hited = 0
				
				ply:SetPos(ply:GetPos()+Vector(0,0,90))
			end
			if ply.Hited == nil then
			ply.Hited = 0
			end
			ply.Hited = ply.Hited + 1
		end	 
	end
	*/
end
 
if ( CLIENT ) then

	usermessage.Hook( "StartBlurShock", function()
		
		hook.Add( "RenderScreenspaceEffects", "DrawMotionBlur", function()
			DrawMotionBlur( 0.1, 1, 0.05)
		end )
		timer.Simple( 0.2, function()
			hook.Add( "RenderScreenspaceEffects", "DrawMotionBlur", function()
				DrawMotionBlur( 0.1, 0.9, 0.05)
			end )	
		end )
		timer.Simple( 0.3, function()
			hook.Add( "RenderScreenspaceEffects", "DrawMotionBlur", function()
				DrawMotionBlur( 0.1, 0.8, 0.05)
			end )	
		end )
		timer.Simple( 0.4, function()
			hook.Add( "RenderScreenspaceEffects", "DrawMotionBlur", function()
				DrawMotionBlur( 0.1, 0.7, 0.05)
			end )	
		end )
		timer.Simple( 0.5, function()
			hook.Add( "RenderScreenspaceEffects", "DrawMotionBlur", function()
				DrawMotionBlur( 0.1, 0.6, 0.05)
			end )
		end )
		timer.Simple( 0.6, function()
			hook.Add( "RenderScreenspaceEffects", "DrawMotionBlur", function()
				DrawMotionBlur( 0.1, 0.5, 0.05)
			end )	
		end )
		timer.Simple( 0.7, function()
			hook.Add( "RenderScreenspaceEffects", "DrawMotionBlur", function()
				DrawMotionBlur( 0.1, 0.4, 0.05)
			end )	
		end )
		timer.Simple( 0.8, function()
			hook.Add( "RenderScreenspaceEffects", "DrawMotionBlur", function()
				DrawMotionBlur( 0.1, 0.3, 0.05)
			end )	
		end )
		timer.Simple( 0.9, function()
			hook.Add( "RenderScreenspaceEffects", "DrawMotionBlur", function()
				DrawMotionBlur( 0.1, 0.2, 0.05)
			end )	
		end )
		timer.Simple( 1, function()
			hook.Add( "RenderScreenspaceEffects", "DrawMotionBlur", function()
				DrawMotionBlur( 0.1, 0.1, 0.05)
			end )		
		end )
		timer.Simple( 1.1, function()
			hook.Remove( "RenderScreenspaceEffects", "DrawMotionBlur" )
		end )
		
	end )
	
end

function SWEP:Deploy()
	if IsValid(self.Owner) then
		//self:PreModel()
	end
end

function SWEP:DrawHUD()
	
	local charge = (self:GetCharge() - CurTime())/self:GetMaxCharge()*100
	if charge > 0 then
		local aa = math.EaseInOut( charge, 0.1, 0.1 ) 
			surface.SetDrawColor( Color(255,255,255,150)  )
			surface.DrawRect( (ScrW()/2)-100, (ScrH()/2)+150, 200, 16 )
			local tcol = self.Owner:GetPlayerColor()
			local scc = string.Explode(".",charge)
			//draw.SimpleText('Cooldown: '..scc[1]..'%', "Default", (ScrW()/2)-100+5,  (ScrH()/2)+150-8, tcol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			surface.SetDrawColor( Color(tcol.x*255,tcol.y*255,tcol.z*255,255)  )
			surface.DrawRect( (ScrW()/2)-(charge), (ScrH()/2)+150, charge*2, 16 )
			draw.SimpleTextOutlined( 'Cooldown: '..scc[1]..'%', Default, (ScrW()/2)-100+5, (ScrH()/2)+150+8, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, tcol )
			
	end
end  



function SWEP:PrimaryAttack()
	if !IsFirstTimePredicted()  then return end
	
	if( CurTime() <= self:GetCharge() ) then 		
		return; 
	end	 

	self.Owner:LagCompensation(true)
	
	local aim=self.Owner:GetAimVector() 
	aim.z=0
	aim:Normalize()

	local tracedata = {}
	tracedata.start = self.Owner:EyePos()
	tracedata.endpos = self.Owner:EyePos()+aim*90+Vector(0,0,-5)
	tracedata.filter = self.Owner
	tracedata.mins = Vector(-8,-8,-8)
	tracedata.maxs = Vector(8,8,8)

	local tr1 = util.TraceLine( tracedata )
	local tr2 = util.TraceHull( tracedata )
	local tr = IsValid(tr2.Entity) and tr2 or tr1
	
	self.Owner:LagCompensation(false) -- Don't forget to disable it!

	local DidHit            = tr.Hit and not tr.HitSky
	local HitEntity         = tr.Entity
	
	//if DidHit then
	//if HitEntity and IsValid( HitEntity ) then
	 
	local ent = HitEntity	
	if DidHit and ent and IsValid(ent) and ent:IsPlayer() and ent:Alive() and tr2.HitPos:Distance(tr2.StartPos) < 255  then
		self.Owner:EmitSound("weapons/stunstick/stunstick_fleshhit" .. math.random(1,2) .. ".wav" );
		self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)	
		self.Owner:SetAnimation( PLAYER_ATTACK1 )

		if( SERVER ) then self:SetMaxCharge(4) self:SetCharge( CurTime() + self:GetMaxCharge());	self:tasePlayer( ent )	end
	else
		if SERVER then self:SetMaxCharge(1) self:SetCharge( CurTime() + self:GetMaxCharge()) end
		self.Owner:EmitSound("weapons/stunstick/stunstick_swing" .. math.random(1,2) .. ".wav" )
		self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER)
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
	end
	
end

function SWEP:SecondaryAttack()
end