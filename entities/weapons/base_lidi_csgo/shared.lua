if ( CLIENT ) then

	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= false
	
	SWEP.ViewModelFOV		=70
	SWEP.ViewModelFlip = false
	SWEP.CSMuzzleFlashes	= true
	SWEP.UseHands = true

end

SWEP.Author					="Marquis"

SWEP.UseHands				=true

SWEP.Slot				=1
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
	['weapon_awpcsgo'] 	= 2,
	['weapon_m4a1csgo'] 	= 2,
	['weapon_ak47csgo'] 	= 2,
	['weapon_deaglecsgo'] 	= 2,
}

function SWEP:SetupDataTables() --This also used for variable declaration and SetVar/GetVar getting work
    self:NetworkVar( "Float", 0, "InspectTime" )
    self:NetworkVar( "Float", 1, "IdleTime" )
    self:NetworkVar( "Bool", 0, "Thrown" )
    self:NetworkVar( "Entity", 2, "ViewModel" )
end


function SWEP:Initialize()
	self.Clip=self.ClipSize
	self.Ammo=self.MaxAmmo
    self.Owner:SetNWBool('Zoom', false)
	if self.Shotgun then
		self.Weapon.Delay = CurTime()
	end
	self:SetHoldType(self.HoldType)	
	self:SkinsInit()
	if self.SetSilenced then
		self.Weapon.Silenced = true
	end
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
end


function SWEP:Think()

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
	self.Owner:SetNWInt('clip1wea', self.Clip)
	self.Owner:SetNWInt('ammo1wea', self.Ammo)
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
    self:SetInspectTime( 0 )
	
	if(self.GetSilenced)then
		self.Silenced=self:GetSilenced()
	end
	self:SendWeaponAnim(self.Silenced and ACT_VM_DRAW_SILENCED or ACT_VM_DRAW)

	self.NextFire=CurTime()+self.Owner:GetViewModel():SequenceDuration()

	return true
end

function SWEP:Reload()	

	if(self.NextFire>CurTime())then return false end
	if(self.Ammo<=0)then return false end
	if(CurTime() < self:GetInspectTime()) then  return false end 
	if(self.Clip>=self.ClipSize) then 
		
	local getseq = self:GetSequence()
	local act = self:GetSequenceActivity(getseq) --GetActivity() method doesn't work :\
	if (act == ACT_VM_FIDGET and CurTime() < self:GetInspectTime()) then
        return 
	end

	self.Weapon:SendWeaponAnim(ACT_VM_FIDGET)
    self:SetInspectTime( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
	return end
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

    self:SetInspectTime( CurTime() + self.Owner:GetViewModel():SequenceDuration() +0.3)
	self.NextFire=CurTime()+self.Owner:GetViewModel():SequenceDuration()
	
	timer.Simple(self.Owner:GetViewModel():SequenceDuration(),function()
		if self.ClipSize == nil then return end
		local ca=math.min(self.ClipSize-self.Clip,self.Ammo)
		self.Clip=self.Clip+ca
		self.Ammo=self.Ammo-ca
	end)
	
end


function SWEP:PenetrateCallback(n,att,tr,dmg)
	if CLIENT then return end
	//	print('asd')
	//local tr = ply:GetEyeTraceNoCursor()
	//if IsValid(tr.Entity) && (tr.Entity:IsPlayer() || tr.Entity:GetClass() == "prop_ragdoll") && tr.HitPos:Distance(tr.StartPos) < 500
	local aim=(self.Owner:EyeAngles()+self.Owner:GetViewPunchAngles()):Forward()
	local eye = self.Owner:EyePos()
	local tr = self.Owner:GetEyeTraceNoCursor()
	//PrintTable(tr)
	local frac = tr.Fraction
	if not tr.HitSky then
		local damage = self.Damage
		if tr.Entity:IsPlayer() then
			if tr.HitGroup == HITGROUP_HEAD then
				tr.Entity:EmitSound("player/bhit_helmet-1.wav", 400, 100, 1 )
				local ed = EffectData()
				ed:SetOrigin( tr.HitPos )
				ed:SetMagnitude( 0.5 )
				timer.Simple(0,function() util.Effect("StunstickImpact", ed) end)
				damage = damage * 2 
				frac = 0
			elseif tr.HitGroup == HITGROUP_LEFTARM or tr.HitGroup == HITGROUP_RIGHTARM or tr.HitGroup == HITGROUP_LEFTLEG or tr.HitGroup == HITGROUP_RIGHTLEG then
				damage = damage * 0.4 
			end
		end
		
		local dst=tr.StartPos:Distance(tr.HitPos)
		//print(frac)
		local bullet=
		{
			Num 		=1;
			Src 		=self.Owner:GetShootPos();
			Dir 		=aim;
			Spread	 	=Vector(0,0,0);
			Tracer		=1;
			Force		=5;
			Damage		=damage* (1-frac);
		}
		
		//att.lbd=bullet.Damage
		//att.aim=bullet.Dir
		//bullet.Callback=function(a,b,c) PenetrateCallback(n+1,a,b,c) end
		//print(tr)
		timer.Simple(0,function() 
			if IsValid(self) then
			self.Owner:FireBullets(bullet) 
		
			//att.FireBullets(att,bullet) 
			end
		end)
	end
end

function SWEP:PrimaryAttack()
	if CLIENT then return end
	if self:IsValid() then 
	if(self.NextFire>CurTime())then return end
	if(self.Clip<=0)then
		if(self.Ammo>0)then
			self:Reload()
			return
		end

		self.NextFire=CurTime()+self.Rate
		return
	end
	if self.Shotgun then
	self.Weapon:SetNetworkedBool( "reloading", false )
	end
	self.NextFire=CurTime()+self.Rate
	self.LastFire=CurTime()

	self.Clip=self.Clip-1
	self.Owner:EmitSound(self.Sound)
	
	self:PenetrateCallback(1,a,b,c) 

	//self.Owner:FireBullets(bullet)
	self.Owner:MuzzleFlash()
	
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	self.Weapon:SendWeaponAnim(self.Silenced and ACT_VM_PRIMARYATTACK_SILENCED or ACT_VM_PRIMARYATTACK)

	self.Owner:ViewPunch(Angle(math.Rand(-0.2,-0.1)*self.Recoil,math.Rand(-0.1,0.1)*self.Recoil,0)*10)
end
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
	
	if tbl[3] == 'csgo' then
		class = tbl[1].."_"..tbl[2]..tbl[3]
	end
	
	if self.w_skin ~= "none" and tbl[3] ~= 'csgo'  then 
		self:SetMaterial( self.w_skin )
	end 
	
	if self.weps[class] ~= nil and tbl[3] == 'csgo' then
		if self.w_skin ~= "none" then 
			self:SetSubMaterial(self.weps[class]-2, self.w_skin )
		end 
		if self.skin_scope ~= "none" then
			self:SetSubMaterial(self.weps[class]-1, self.skin_scope)
		end
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
	
	if tbl[3] == 'csgo' then
		class = tbl[1].."_"..tbl[2]..tbl[3]
	end
	//1	=	marquis/awp/awp
//2	=	marquis/awp/scope_awp

	
	//PrintTable(vm:GetMaterials())
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
	if self.weps[class] ~= nil and tbl[3] == 'csgo' then
		if self.v_skin ~= "none" then 
			vm:SetSubMaterial(self.weps[class]-2, self.v_skin )
		end 
		if self.skin_scope ~= "none" then
			vm:SetSubMaterial(self.weps[class]-1, self.skin_scope)
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
	
	
function SWEP:GetViewModelPosition( pos, ang )

	ang:RotateAroundAxis(ang:Up(),  -90)
	
	
	return pos, ang
end

function SWEP:DrawWorldModel()

	local ply = self:GetOwner()	
	if IsValid(ply) and ply.SetupBones then ply:SetupBones() end
	
	if (self.ShowWorldModel == nil or self.ShowWorldModel) then
	
		if game.SinglePlayer() or CLIENT then
			local hand, offset, rotate

			if IsValid( ply ) and self.Offset and self.Offset.Pos and self.Offset.Ang then
				local handBone = ply:LookupBone( "ValveBiped.Bip01_R_Hand" )
				if handBone then
					local pos, ang = ply:GetBonePosition( handBone )
					pos = pos + ang:Forward() * self.Offset.Pos.Forward + ang:Right() * self.Offset.Pos.Right + ang:Up() * self.Offset.Pos.Up
					ang:RotateAroundAxis( ang:Up(), self.Offset.Ang.Up)
					ang:RotateAroundAxis( ang:Right(), self.Offset.Ang.Right )
					ang:RotateAroundAxis( ang:Forward(),  self.Offset.Ang.Forward )
					self:SetRenderOrigin( pos )
					self:SetRenderAngles( ang )
					--if self.Offset.Scale and ( !self.MyModelScale or ( self.Offset and self.MyModelScale!=self.Offset.Scale ) ) then
						self:SetModelScale( self.Offset.Scale or 1, 0 )
						self.MyModelScale = self.Offset.Scale
					--end
				end
			else
				self:SetRenderOrigin( nil )
				self:SetRenderAngles( nil )
				if !self.MyModelScale or self.MyModelScale!=1 then
					self:SetModelScale( 1, 0 )
					self.MyModelScale = 1
				end
			end
		end
		
		self:DrawModel()
		elseif !IsValid( ply ) or !ply:IsPlayer() then
		if self.WElements then
			local keys = table.GetKeys( self.WElements )
			if #keys>=1 then
				local tbl = self.WElements[ keys[1] ]
				if tbl then
					local mdl = tbl.model
					if self:GetModel()!=mdl then
						self:SetModel( mdl )
					end
					self:DrawModel()
					self.WorldModelOG = self.WorldModel
					self.WorldModel = mdl
				end
			end
		end
	else
		self.WorldModel = self.WorldModelOG or self.WorldModel
	end
	
	if (!self.WElements) then return end
	
	self:CreateModels(self.WElements)
	
	if (!self.wRenderOrder) then
		self.wRenderOrder = {}
		for k, v in pairs( self.WElements ) do
			if (v.type == "Model") then
				table.insert(self.wRenderOrder, 1, k)
			elseif (v.type == "Sprite" or v.type == "Quad") then
				table.insert(self.wRenderOrder, k)
			end
		end
	end
	
end

--[[ 
Function Name:  GetBoneOrientation
Syntax: self:GetBoneOrientation( base bone mod table, bone mod table, entity, bone override ). 
Returns:  Position, Angle.
Notes:  This is a very specific function for a specific purpose, and shouldn't be used generally to get a bone's orientation.
Purpose:  SWEP Construction Kit Compatibility / Basic Attachments.
]]--

function SWEP:GetBoneOrientation( basetabl, tabl, ent, bone_override )
	
	local bone, pos, ang
	
	if !IsValid(ent) then
		return Vector(0,0,0), Angle(0,0,0)
	end
	
	if (tabl.rel and tabl.rel != "") then
		
		local v = basetabl[tabl.rel]
		
		if (!v) then return end
		
		--As clavus states in his original code, don't make your elements named the same as a bone, because recursion.
		pos, ang = self:GetBoneOrientation( basetabl, v, ent )
		
		if (!pos) then return end
		
		pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
		ang:RotateAroundAxis(ang:Up(), v.angle.y)
		ang:RotateAroundAxis(ang:Right(), v.angle.p)
		ang:RotateAroundAxis(ang:Forward(), v.angle.r)
			
	else
		bone = ent:LookupBone(bone_override or tabl.bone)
		if (!bone) or (bone==-1) then return end
		
		pos, ang = Vector(0,0,0), Angle(0,0,0)
		local m = ent:GetBoneMatrix(bone)
		if (m) then
			pos, ang = m:GetTranslation(), m:GetAngles()
		end
		
		if (IsValid(self.Owner) and self.Owner:IsPlayer() and ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
			ang.r = -ang.r -- For mirrored viewmodels.  You might think to scale negatively on X, but this isn't the case.
		end
	
	end
	
	return pos, ang
end

--[[ 
Function Name:  CleanModels
Syntax: self:CleanModels( elements table ). 
Returns:   Nothing.
Notes:  Removes all existing models.
Purpose:  SWEP Construction Kit Compatibility / Basic Attachments.
]]--

function SWEP:CleanModels( tabl )
	if (!tabl) then return end
	
	for k, v in pairs( tabl ) do
		if (v.type == "Model" and v.curmodel) then
			
			if v.curmodel and v.curmodel.Remove then
				
				timer.Simple(0,function()
					if v.curmodel and v.curmodel.Remove then v.curmodel:Remove() end
					v.curmodel = nil
				end)
				
			else
				v.curmodel = nil
			end
			
		elseif ( v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spritemat or v.cursprite != v.sprite) ) then
			
			v.cursprite = nil
			v.spritemat = nil
			
		end
	end
	
end

--[[ 
Function Name:  CreateModels
Syntax: self:CreateModels( elements table ). 
Returns:   Nothing.
Notes:  Creates the elements for whatever you give it.
Purpose:  SWEP Construction Kit Compatibility / Basic Attachments.
]]--

function SWEP:CreateModels( tabl )
	if (!tabl) then return end
	
	for k, v in pairs( tabl ) do
		if (v.type == "Model" and v.model and (!IsValid(v.curmodel) or v.curmodelname != v.model) and v.model != "" and 
				string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
			
			v.curmodel = ClientsideModel(v.model, RENDERGROUP_VIEWMODEL)
			if (IsValid(v.curmodel)) then
				v.curmodel:SetPos(self:GetPos())
				v.curmodel:SetAngles(self:GetAngles())
				v.curmodel:SetParent(self)
				v.curmodel:SetNoDraw(true)
				local matrix = Matrix()
				matrix:Scale(v.size)
				v.curmodel:EnableMatrix( "RenderMultiply", matrix )
				v.curmodelname = v.model
			else
				v.curmodel = nil
			end
			
		elseif ( v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spritemat or v.cursprite != v.sprite) ) then
			
			local name = v.sprite.."-"
			local params = { ["$basetexture"] = v.sprite }
			-- // make sure we create a unique name based on the selected options
			local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
			for i, j in pairs( tocheck ) do
				if (v[j]) then
					params["$"..j] = 1
					name = name.."1"
				else
					name = name.."0"
				end
			end
			v.cursprite = v.sprite
			v.spritemat = CreateMaterial(name,"UnlitGeneric",params)
			
		end
	end
	
end
	
--[[ 
Function Name:  UpdateBonePositions
Syntax: self:UpdateBonePositions( viewmodel ). 
Returns:   Nothing.
Notes:   Updates the bones for a viewmodel.
Purpose:  SWEP Construction Kit Compatibility / Basic Attachments.
]]--

local bpos, bang
local onevec = Vector(1,1,1)

function SWEP:UpdateBonePositions(vm)
	
	if self.ViewModelBoneMods then
		
		if !self.ViewModelBoneMods then
			self.ViewModelBoneMods = {}
		end
		
		if !self.BlowbackBoneMods then
			self.BlowbackBoneMods = {}
		end
		
		if (!vm:GetBoneCount()) then return end
		
		local loopthrough = {}
		
		local vbones = {}
		for i=0, vm:GetBoneCount() do
			local bonename = vm:GetBoneName(i)
			if (self.ViewModelBoneMods[bonename]) then 
				vbones[bonename] = self.ViewModelBoneMods[bonename]
			else
				vbones[bonename] = { 
					scale = onevec,
					pos = vector_origin,
					angle = angle_zero
				}
			end
			if self.BlowbackBoneMods[bonename] then
				if !( self.SequenceEnabled[ACT_VM_RELOAD_EMPTY] and self:GetReloading() ) or !( self.Blowback_PistolMode and self:GetReloading() ) then
					vbones[bonename].pos = vbones[bonename].pos + self.BlowbackBoneMods[bonename].pos * self.BlowbackCurrent
					vbones[bonename].angle = vbones[bonename].angle + self.BlowbackBoneMods[bonename].angle * self.BlowbackCurrent
					vbones[bonename].scale = Lerp(self.BlowbackCurrent, vbones[bonename].scale,vbones[bonename].scale  *  self.BlowbackBoneMods[bonename].scale )
				else
					self.BlowbackCurrent = math.Approach(self.BlowbackCurrent,0,self.BlowbackCurrent*FrameTime()*30)
				end
			end
		end
		
		loopthrough = vbones
		
		for k, v in pairs( loopthrough ) do
			--print(v)
			local bone = vm:LookupBone(k)
			if (!bone) or (bone==-1) then continue end
			
			local s = Vector(v.scale.x,v.scale.y,v.scale.z)
			local p = Vector(v.pos.x,v.pos.y,v.pos.z)
			local childscale = Vector(1,1,1)
			local cur = vm:GetBoneParent(bone)
			while( cur != -1) do
				local pscale = loopthrough[vm:GetBoneName(cur)].scale
				childscale = childscale * pscale
				cur = vm:GetBoneParent(cur)
			end
			
			s = s * childscale
			
			if vm:GetManipulateBoneScale(bone) != s then
				vm:ManipulateBoneScale( bone, s )
			end
			
			if vm:GetManipulateBoneAngles(bone) != v.angle then
				vm:ManipulateBoneAngles( bone, v.angle )
			end
			
			if vm:GetManipulateBonePosition(bone) != p then
				vm:ManipulateBonePosition( bone, p )
			end
			
		end
	elseif self.BlowbackBoneMods then
		for bonename, tbl in pairs(self.BlowbackBoneMods) do
			local bone = vm:LookupBone( bonename )
			if bone and bone>=0 then
				bpos = tbl.pos * self.BlowbackCurrent
				bang = tbl.angle * self.BlowbackCurrent
				vm:ManipulateBonePosition( bone, bpos )
				vm:ManipulateBoneAngles( bone, bang )
			end
		end
	end
end
	
--[[ 
Function Name:  ResetBonePositions
Syntax: self:ResetBonePositions( viewmodel ). 
Returns:   Nothing.
Notes:   Resets the bones for a viewmodel.
Purpose:  SWEP Construction Kit Compatibility / Basic Attachments.
]]--
 
function SWEP:ResetBonePositions(val)
	
	if SERVER then
		self:CallOnClient("ResetBonePositions","")
		return
	end
	
	vm = self.Owner:GetViewModel()
	
	if !IsValid(vm) then return end
	if (!vm:GetBoneCount()) then return end
	for i=0, vm:GetBoneCount() do
		vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
		vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
		vm:ManipulateBonePosition( i, vector_origin )
	end
end


