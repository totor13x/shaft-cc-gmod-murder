
-----------------------------------------------------

if( SERVER ) then
	AddCSLuaFile( "shared.lua" );
end

 SWEP.Base = "weapon_base"
SWEP.PrintName		= "Шокер"
SWEP.ViewModelFOV       = 62
SWEP.ViewModelFlip      = false
SWEP.AnimPrefix  = "stunstick"
SWEP.Spawnable      = false
SWEP.AdminSpawnable          = true
SWEP.NextStrike = 0;
SWEP.FakeAttack = 0;
SWEP.ViewModel = Model( "models/weapons/c_pistol.mdl" );
SWEP.WorldModel = Model( "models/weapons/w_pistol.mdl" );
SWEP.UseHands = true
SWEP.Primary.ClipSize      = -1    
SWEP.Primary.DefaultClip        = 0  
SWEP.Primary.Automatic    = false  
SWEP.Primary.Ammo                     = ""
SWEP.Secondary.ClipSize  = -1    
SWEP.Secondary.DefaultClip      = 0   
SWEP.Secondary.Automatic        = false  
SWEP.Secondary.Ammo               = ""

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
	self:SetHoldType( "pistol" );
end

function SWEP:tasePlayer( ply, delay )
	if !IsValid(ply) then return end
	timer.Simple(delay, function()
		if IsValid(ply) then
			ply:SetMoveType(MOVETYPE_WALK)
			ply:SetNWBool("DisabledWASD", false)
			ply:SetDSP(0)
			ply:SetMaterial( "" )
			if ply.OriginalColor then
				ply:SetColor(ply.OriginalColor)
				ply.OriginalColor = nil
			end
		end
	end)
	ply:SetMoveType(MOVETYPE_WALK)
	ply:SetNWBool("DisabledWASD", true)
	ply:SetDSP(8)
	if !self.Owner:GetRole(MURDER_HELPER) and !self.Owner:GetRole(MURDER) then
		ply.OriginalColor = ply:GetColor()
		ply:SetColor(0,0,255)
	end
	ply:SetMaterial( "models/alyx/emptool_glow" )
	netstream.Start(ply, "MU.Blind", delay)
end
 
if ( CLIENT ) then
	// and (!ent:GetRole(MURDER) and !ent:GetRole(MURDER_HELPER) and !ent:GetRole(CHICKEN)) 

	netstream.Hook("MU.Blind", function(delay)
		hook.Add( "RenderScreenspaceEffects", "MU.Blind.Render", function()
			DrawMotionBlur( 0.1, 1, 0.05)
		end )
		timer.Simple( delay/3, function()
			hook.Add( "RenderScreenspaceEffects", "MU.Blind.Render", function()
				DrawMotionBlur( 0.1, 0.9, 0.05)
			end )	
		end )
		timer.Simple( delay/1.2, function()
			hook.Add( "RenderScreenspaceEffects", "MU.Blind.Render", function()
				DrawMotionBlur( 0.1, 0.8, 0.05)
			end )	
		end )
		timer.Simple( delay/1.1, function()
			hook.Add( "RenderScreenspaceEffects", "MU.Blind.Render", function()
				DrawMotionBlur( 0.1, 0.6, 0.05)
			end )	
		end )
		timer.Simple( delay/1.05, function()
			hook.Add( "RenderScreenspaceEffects", "MU.Blind.Render", function()
				DrawMotionBlur( 0.1, 0.3, 0.05)
			end )		
		end )
		timer.Simple( delay, function()
			hook.Remove( "RenderScreenspaceEffects", "MU.Blind.Render" )
		end )
	end)
end
function SWEP:SecondaryAttack()
	if CLIENT then return end
	if( CurTime() < self:GetCharge() ) then 		
		//self:FakeAttackF()
		return; 
	end
	if !self.Owner:GetRole(MURDER_HELPER) and !self.Owner:GetRole(MURDER) then
		self:PrimaryAttack()
		return
	end
	self.Owner:LagCompensation(true)
	

	local tracedata = {}
	tracedata.start = self.Owner:EyePos()
	tracedata.endpos = self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * 70
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
		 
	local ent = tr.Entity	
	if DidHit and IsValid(ent) and ent:IsPlayer() then	
		if( SERVER ) and (!ent:GetRole(MURDER) and !ent:GetRole(MURDER_HELPER) and !ent:GetRole(CHICKEN)) then 
			ent:SetNWBool("Marked_ply", true)
			self:SetCharge( CurTime() + 10);
			self.Owner:SetAnimation( PLAYER_ATTACK1 );
			self:SendWeaponAnim( ACT_VM_PRIMARYATTACK );
			
			timer.Simple(45, function()
				if ent:IsValid() then
					ent:SetNWBool("Marked_ply", false)
				end
			end)
		end
	else
		//self:FakeAttackF()
	end
end

function SWEP:Deploy()
	if IsValid(self.Owner) then
		//self:PreModel()
	end
end

function SWEP:Reload()
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


function SWEP:FakeAttackF()
	if CurTime() >= self.FakeAttack then
		self.Owner:EmitSound(self.FakeSnd or "Weapon_StunStick.Activate");
		if SERVER then
		self.Owner:SetAnimation( PLAYER_ATTACK1 );
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK );
		end
		self.FakeAttack = CurTime() + 0.5
	end
end

function SWEP:PrimaryAttack()
	if CLIENT then return end
	if( CurTime() < self:GetCharge() ) then 		
		return; 
	end
	
	self.Owner:LagCompensation(true)
	
	local tracedata = {}
	tracedata.start = self.Owner:EyePos()
	tracedata.endpos = self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * 500
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
	 
	self.Owner:ViewPunch(Angle(-1, 0, 0))
	local ent = HitEntity	
		 
	local ent = tr.Entity	
	if DidHit and IsValid(ent) and ent:IsPlayer()  then
		if ( SERVER ) then 
			local delay_or_can = 4
			local charges_time = 10
			if self.Owner:GetRole(MURDER_HELPER) or self.Owner:GetRole(MURDER) then
				if (ent:GetRole(MURDER) or ent:GetRole(MURDER_HELPER)) then
					delay_or_can = false
				else
					delay_or_can = 4
				end
			else
				delay_or_can = 1
				charges_time = 17
			end
			
			if ent:GetRole(CHICKEN) then
				delay_or_can = false
			end
			
			if delay_or_can then
				self:tasePlayer(ent, delay_or_can)
				self:SetCharge( CurTime() + charges_time);
				self:SetMaxCharge(charges_time);
				self.Owner:SetAnimation( PLAYER_ATTACK1 );
				self.Owner:EmitSound("Weapon_StunStick.Activate");
				self:SendWeaponAnim( ACT_VM_PRIMARYATTACK );
			end
		end
	else
		self:SetCharge( CurTime() + 0.5);
		self:SetMaxCharge(0.5);
		self:FakeAttackF()
	end
end
