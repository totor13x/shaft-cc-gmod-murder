if ( CLIENT ) then

	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= false
	
	SWEP.ViewModelFOV		=55
	SWEP.ViewModelFlip = false
	SWEP.CSMuzzleFlashes	= true
	SWEP.UseHands = true

end

SWEP.Author					="Marquis"

SWEP.UseHands				=true

SWEP.HoldType			= "ar2"
SWEP.Primary.ClipSize		=-1
SWEP.Primary.DefaultClip	=-1
SWEP.Primary.Ammo			="none"

SWEP.Secondary.ClipSize		=-1
SWEP.Secondary.DefaultClip	=-1
SWEP.Secondary.Ammo			="none"

SWEP.Zooming = false
SWEP.NextFire=0
SWEP.LastFire=0
SWEP.Cone=0
SWEP.ScopedFOV = 25
SWEP.Shotgun = false
SWEP.v_skin = "none"
SWEP.w_skin = "none"
SWEP.SwayScale 	= 1.0
SWEP.BobScale 	= 1.0

SWEP.weps = {
	['weapon_ak47'] 	= 1,
	['weapon_aug'] 		= 2,
	['weapon_awp'] 		= 2,
	['weapon_deagle'] 	= 1,
	['weapon_elite'] 	= 2,
	['weapon_famas'] 	= 1,
	['weapon_fiveseven']= 1,
	['weapon_g3sg1'] 	= 2,
	['weapon_galil'] 	= 2,
	['weapon_glock'] 	= 1,
	['weapon_m3'] 		= 1,
	['weapon_m4a1'] 	= 1,
	['weapon_m249'] 	= 2,
	['weapon_mac10'] 	= 1,
	['weapon_mp5'] 		= 1,
	['weapon_p90'] 		= 1,
	['weapon_p228'] 	= 1,
	['weapon_scout'] 	= 2,
	['weapon_sg550'] 	= 2,
	['weapon_sg552'] 	= 2,
	['weapon_tmp'] 		= 1,
	['weapon_ump45']	= 1,
	['weapon_usp'] 		= 1,
	['weapon_xm1014'] 	= 1,
}

function SWEP:Initialize()
	self.Clip=self.ClipSize
	self.Ammo=self.MaxAmmo
    self.Owner:SetNWBool('Zoom', false)
	if self.Shotgun then
		self.Weapon.Delay = CurTime()
	end
	self:SetHoldType(self.Hold)	
	self:SkinsInit()
end

function SWEP:OnRemove() 		
	if self.Owner:GetNWBool('Zoom') then
		if(SERVER) then
			self.Owner:SetFOV( 90, 0.2 )
			self.Weapon:EmitSound( Sound( "Default.Zoom" ) )
		end
	        self.Weapon:SetNextSecondaryFire( CurTime() + 0.2 );
            self.Owner:SetNWBool('Zoom',false)
	end
return true 
end
function SWEP:OnDrop() 			
	if self.Owner:GetNWBool('Zoom') then
		if(SERVER) then
			self.Owner:SetFOV( 90, 0.2 )
			self.Weapon:EmitSound( Sound( "Default.Zoom" ) )
		end
	        self.Weapon:SetNextSecondaryFire( CurTime() + 0.2 );
            self.Owner:SetNWBool('Zoom',false)
	end 
return true 
end

function SWEP:SecondaryAttack()
	if(self.NextFire>CurTime())then return end
	if(self.SetSilenced)then
		local b=not self:GetSilenced()
		self:SendWeaponAnim(b and ACT_VM_ATTACH_SILENCER or ACT_VM_DETACH_SILENCER)
		local s=self.WorldModel
		self.WorldModel=self.WorldModelSilencer
		self.WorldModelSilencer=s

		self.NextFire=CurTime()+self.Owner:GetViewModel():SequenceDuration()

		self:SetSilenced(b)
		self.Silenced=b
	end
end


function SWEP:Think()
/*
local btrigger = self.Weapon:GetNetworkedBool( "btrigger" )
if not btrigger then 
self.Weapon:SetNetworkedBool( "btrigger", true )
end

	if self.Owner:KeyDown(IN_SPEED) then 
		self.Weapon:SetNetworkedBool("Ironsights", true)
	end
		
	if self.Owner:KeyReleased(IN_SPEED) then
		self.Weapon:SetNetworkedBool("Ironsights", false)
	end
	if ontr then
		if (fIronTime > CurTime() - IRONSIGHT_TIME) then
			Mul = math.Clamp((CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1)

			if (!bIron) then Mul = 1 - Mul end
		end	
	end
*/
	local Owner=self.Owner
	if Owner:OnGround() and (Owner:KeyDown(IN_FORWARD) or Owner:KeyDown(IN_BACK) or Owner:KeyDown(IN_MOVERIGHT) or Owner:KeyDown(IN_MOVELEFT)) then
		if Owner:KeyDown(IN_DUCK) then
			self.Cone=self.ConeCrouchWalk
		else
			self.Cone=self.ConeWalk
		end
	elseif Owner:OnGround() and Owner:KeyDown(IN_DUCK)then
		self.Cone=self.ConeCrouch
	elseif not Owner:OnGround() then
		self.Cone=self.ConeAir
	else
		self.Cone=self.ConeStand
	end
	if self.Shotgun then
	if ( self.Weapon:GetNetworkedBool( "reloading", false ) ) then
	
		if ( self.Weapon:GetVar( "reloadtimer", 0 ) < CurTime() ) then
			//self.Clip < self.ClipSize && self.Ammo > 0
			// Finsished reload -
			if ( self.Clip  >= self.ClipSize || self.Ammo <= 0 ) then
				self.Weapon:SetNetworkedBool( "reloading", false )
				return
			end
			
			// Next cycle
			self.Weapon:SetVar( "reloadtimer", CurTime() + 0.5 )
			self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )
			self.Owner:DoReloadEvent()
			
			
			self.Clip = self.Clip + 1
			self.Ammo = self.Ammo - 1
			// Add ammo
			//self.Owner:RemoveAmmo( 1, self.Primary.Ammo, false )
			//self.Weapon:SetClip1(  self.Weapon:Clip1() + 1 )
			
			// Finish filling, final pump
			if ( self.Clip  >= self.ClipSize||  self.Ammo <= 0 ) then
				self.Weapon:SendWeaponAnim( ACT_SHOTGUN_RELOAD_FINISH )
				self.Owner:DoReloadEvent()
			else
			
			end
			
		end
	
	end
	end
end


function SWEP:Deploy()
	if(self.GetSilenced)then
		self.Silenced=self:GetSilenced()
	end
	self:SendWeaponAnim(self.Silenced and ACT_VM_DRAW_SILENCED or ACT_VM_DRAW)

	self.NextFire=CurTime()+self.Owner:GetViewModel():SequenceDuration()

	return true
end

function SWEP:Reload()
	if(self.NextFire>CurTime())then return end
	if(self.Ammo<=0)then return end
	if(self.Clip>=self.ClipSize)then return end
	if self.ClipSize == nil then return end

	
	self:SendWeaponAnim(self.Silenced and ACT_VM_RELOAD_SILENCED or ACT_VM_RELOAD)
	self.Owner:DoReloadEvent()
	if self.Owner:GetNWBool('Zoom') then
		if(SERVER) then
			self.Owner:SetFOV( 90, 0.2 )
			self.Weapon:EmitSound( Sound( "Default.Zoom" ) )
		end
	        self.Weapon:SetNextSecondaryFire( CurTime() + 0.2 );
            self.Owner:SetNWBool('Zoom',false)
	end

	self.NextFire=CurTime()+self.Owner:GetViewModel():SequenceDuration()
	
	timer.Simple(self.Owner:GetViewModel():SequenceDuration(),function()
		if self.ClipSize == nil then return end
		local ca=math.min(self.ClipSize-self.Clip,self.Ammo)
		self.Clip=self.Clip+ca
		self.Ammo=self.Ammo-ca
	end)
end

function PenetrateCallback(n,att,tr,dmg)
	if CLIENT then return end
	if not tr.HitSky and n<5 and att.lbd>0 and tr.Fraction<0.01 then

		
		local dst=tr.StartPos:Distance(tr.HitPos)
		local aim=(att:EyeAngles()+att:GetViewPunchAngles()):Forward()
		local bullet=
		{
			Num 		=1;
			Src 		=tr.HitPos+aim;
			Dir 		=aim/6;
			Spread	 	=Vector(0,0,0);
			Tracer		=2;
			Force		=5;
			Damage		=math.floor(math.max(att.lbd*(1-tr.Fraction),0)/n);
		}
			
		if tr.Entity:IsPlayer() then
			if tr.HitGroup == HITGROUP_HEAD then
				tr.Entity:EmitSound("player/bhit_helmet-1.wav", 400, 100, 1 )
				local ed = EffectData()
				ed:SetOrigin( tr.HitPos )
				ed:SetMagnitude( 0.5 )
				timer.Simple(0,function() util.Effect("StunstickImpact", ed) end)
				
			end
			return
		end
		
		att.lbd=bullet.Damage
		bullet.Callback=function(a,b,c) PenetrateCallback(n+1,a,b,c) end
		timer.Simple(0,function() att.FireBullets(att,bullet) end)
	end
end

function SWEP:PrimaryAttack()

	if(self.NextFire>CurTime())then return end
	//print("Attack!")

	if(self.Clip<=0)then
		if(self.Ammo>0)then
			self:Reload()
			return
		end
		--self:SendWeaponAnim(ACT_VM_DRYFIRE)
		--self:EmitSound(self.SEmpty)
		self.NextFire=CurTime()+self.Rate
		return
	end
	if self.Shotgun then
	self.Weapon:SetNetworkedBool( "reloading", false )
	end
	self.NextFire=CurTime()+self.Rate
	self.LastFire=CurTime()
	//if SERVER then
	//	self.Clip=self.Clip-1;
	//	net.Start("base_gf_css")
	//		net.WriteEntity(self)
	//		net.WriteUInt(self.Clip,8)
	//	net.Send(self.Owner)
	//end

	self.Clip=self.Clip-1
	self:EmitSound(self.Silenced and self.SSound or self.Sound)

	local bullet=
	{
		Num 		=self.NumShots;
		Src 		=self.Owner:GetShootPos();
		Dir 		=(self.Owner:EyeAngles()+self.Owner:GetViewPunchAngles()):Forward();
		Spread		=Vector(self.Cone,self.Cone,0);
		Tracer		=2;
		Force		=10;
		Damage		=self.Damage;
	}
	self.Owner.lbd=bullet.Damage

	bullet.Callback=function(a,b,c) PenetrateCallback(1,a,b,c) end

	self.Owner:FireBullets(bullet)
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	self:SendWeaponAnim(self.Silenced and ACT_VM_PRIMARYATTACK_SILENCED or ACT_VM_PRIMARYATTACK)

	self.Owner:ViewPunch(Angle(math.Rand(-0.2,-0.1)*self.Recoil,math.Rand(-0.1,0.1)*self.Recoil,0)*10)
end

function SWEP:KickBack()

end

function SWEP:AcceptInput( name, activator, caller, data )
	if ( name == "ConstraintBroken" && self:HasSpawnFlags( 1 ) ) then
		local phys = self:GetPhysicsObject()
		if ( IsValid( phys ) ) then phys:EnableMotion( false ) end
	
		local newflags = bit.band( self:GetSpawnFlags(), bit.bnot( 1 ) )
		self:SetKeyValue( "spawnflags", newflags )
	end
end

function SWEP:SkinsInit()
	tbl = string.Explode("_",self:GetClass(),false)
	local class = tbl[1].."_"..tbl[2]
	
	if self.w_skin ~= "none" then 
		self:SetMaterial( self.w_skin )
	end 
	if !IsValid(self.Owner) then return end
	local tbl = util.JSONToTable(self.Owner:GetNWString("wep_skins",util.TableToJSON({})))
	if SERVER and tbl[self:GetClass()] ~= nil then 
		self.Owner:Give(self:GetClass().."_"..tbl[self:GetClass()])
		self.Owner:SelectWeapon(self:GetClass().."_"..tbl[self:GetClass()])
		self.Owner:StripWeapon(self:GetClass())
	end
	
	if self:GetClass() == 'weapon_m4a1_rl' and self.Owner:GetNWBool("m4a1rl") then
		self.Owner:SetWeaponColor(Vector(self.Owner:GetNWInt("m4a1rlR")/255,self.Owner:GetNWInt("m4a1rlG")/255,self.Owner:GetNWInt("m4a1rlB")/255 ))
	end	
	if self:GetClass() == 'weapon_deagle_rl' and self.Owner:GetNWBool("deaglerl") then
		self.Owner:SetWeaponColor(Vector(self.Owner:GetNWInt("deaglerlR")/255,self.Owner:GetNWInt("deaglerlG")/255,self.Owner:GetNWInt("deaglerlB")/255 ))
	end	
	if self:GetClass() == 'weapon_awp_rl' and self.Owner:GetNWBool("awprl") then
		self.Owner:SetWeaponColor(Vector(self.Owner:GetNWInt("awprlR")/255,self.Owner:GetNWInt("awprlG")/255,self.Owner:GetNWInt("awprlB")/255 ))
	end	
	if self:GetClass() == 'weapon_ak47_rl' and self.Owner:GetNWBool("ak47rl") then
		self.Owner:SetWeaponColor(Vector(self.Owner:GetNWInt("ak47rlR")/255,self.Owner:GetNWInt("ak47rlG")/255,self.Owner:GetNWInt("ak47rlB")/255 ))
	end

end

function SWEP:PreDrawViewModel( vm, ply, weapon ) 
	local tbl = string.Explode("_",self:GetClass(),false)
	local class = tbl[1].."_"..tbl[2]
	
	if self.weps[class] ~= nil then
		if self.v_skin ~= "none" then 
			vm:SetSubMaterial(self.weps[class]-1, self.v_skin )
		end 
		if self.skin_scope ~= "none" then
			vm:SetSubMaterial(self.weps[class]-2,self.skin_scope)
		end
		if self.skin_sight ~= "none" then
			vm:SetSubMaterial(self.weps[class]+1,self.skin_sight)
		end
	end
end

function SWEP:PostDrawViewModel(vm, ply, weapon)
	vm:SetMaterial( "" )
	vm:SetSubMaterial()
end

function SWEP:Holster( )

	
    	if self.Owner:GetNWBool('Zoom') then
		if(SERVER) then
			self.Owner:SetFOV( 90, 0.2 )
			self.Weapon:EmitSound( Sound( "Default.Zoom" ) )
		end
	        self.Weapon:SetNextSecondaryFire( CurTime() + 0.2 );
            self.Owner:SetNWBool('Zoom',false)
	end

	return true

end
if CLIENT then
	local scopedirt = surface.GetTextureID( "sprites/scope_arc.vtf" )
	local scoperadius = ScrH()/2 - 50

	SWEP.LastCalcView = RealTime()

	function SWEP:DrawHUD()
	if not self.Owner:GetNWBool('Zoom') then return end
	if GetConVarNumber("deathrun_thirdperson_enabled") == 1 then return end
	
		local dt = RealTime() - self.LastCalcView

			local x,y = 0,0
			if GetConVar("deathrun_thirdperson_enabled"):GetBool() == true then
				local tr = LocalPlayer():GetEyeTrace()
				x = tr.HitPos:ToScreen().x - ScrW()/2
				y = tr.HitPos:ToScreen().y - ScrH()/2
			end

			surface.SetDrawColor(0,0,0)
			surface.DrawRect(0+x-200,y+0-800,ScrW()+200, ScrH()/2-scoperadius + 5 +800)
			surface.DrawRect(0+x-500,y+0-700,500+ScrW()/2-scoperadius + 5, ScrH()+1200)
			surface.DrawRect(x+ScrW()/2 + scoperadius - 5,y+0-750,ScrW()/2-scoperadius + 5+500, ScrH()+1200)
			surface.DrawRect(x+0-100,y+ScrH()/2 + scoperadius - 5, ScrW()+200, ScrH()/2 - scoperadius+700)

			surface.SetTexture( scopedirt )
			surface.DrawTexturedRectUV(x+(ScrW()/2) - scoperadius, y+(ScrH()/2) - scoperadius, scoperadius, scoperadius, 1,1,0,0)
			surface.DrawTexturedRectUV(x+(ScrW()/2), y+(ScrH()/2) - scoperadius, scoperadius, scoperadius, 0,1,1,0)
			surface.DrawTexturedRectUV(x+(ScrW()/2) - scoperadius, y+(ScrH()/2) , scoperadius, scoperadius, 1,0,0,1)
			surface.DrawTexturedRectUV(x+(ScrW()/2) , y+(ScrH()/2) , scoperadius, scoperadius, 0,0,1,1)

	end
	end
	/*---------------------------------------------------------
   Name: GetViewModelPosition
   Desc: Allows you to re-position the view model
---------------------------------------------------------

SWEP.IronSightsPos = Vector(2.155, -4.353, 1.271)
SWEP.IronSightsAng = Vector(0.144, -0.029, 0)
SWEP.AimSightsPos 		= Vector(2.155, -4.353, 1.271)
SWEP.AimSightsAng 		= Vector(0.144, -0.029, 0)
SWEP.DashArmPos = Vector(-5.595, -3.536, 0.842)
SWEP.DashArmAng = Vector(-9.87, -55.738, -1.231)

function SWEP:GetViewModelPosition( pos, ang )

local btrigger = self.Weapon:GetNetworkedBool( "btrigger" )

if not ontr then
self.posof = pos
self.angof = ang
end
	if ontr then 
	
	local bIron = self.Weapon:GetNetworkedBool( "Ironsights" )
	
	if (bIron != self.bLastIron) then
		self.bLastIron = bIron 
		self.fIronTime = CurTime()
		
		if (bIron) then 
			self.SwayScale 	= 0.3
			self.BobScale 	= 0.1
		else 
			self.SwayScale 	= 1.0
			self.BobScale 	= 1.0
		end
	
	end
	
	local fIronTime = self.fIronTime or 0
	
	if (!bIron && fIronTime < CurTime() - IRONSIGHT_TIME) then 
		return pos, ang
	end
	
	local Mul = 1.0
	
	if (fIronTime > CurTime() - IRONSIGHT_TIME) then
		Mul = math.Clamp((CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1)

		if (!bIron) then Mul = 1 - Mul end
	end

	ang:RotateAroundAxis(ang:Right(), 	30 * Mul)
	ang:RotateAroundAxis(ang:Up(), 60 * Mul)
	ang:RotateAroundAxis(ang:Forward(), 20 * Mul)

	
	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()
	
	pos = pos + 9 * Right * Mul
	pos = pos + -20 * Forward * Mul
	pos = pos + 0 * Up * Mul
	self.posof = pos
	self.angof = ang
	self.btrigger = btrigger
	end
		
	if self.Owner:KeyReleased(IN_SPEED) then
	
		self.Weapon:SetNetworkedBool("Ironsights", false)
		self.bLastIron = nil
		self.SwayScale 	= 1.0
		self.BobScale 	= 1.0
		
		
	end
	if (btrigger == self.btrigger) && self.bLastIron == nil then
	ang:RotateAroundAxis(ang:Right(), 	30)
	ang:RotateAroundAxis(ang:Up(), 60)
	ang:RotateAroundAxis(ang:Forward(), 20)	
		
	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()
	pos = pos + 9 * Right
	pos = pos + -20 * Forward
	pos = pos + 0 * Up
	self.posof = pos
	self.angof = ang
	end

	
	return self.posof, self.angof
end
*/