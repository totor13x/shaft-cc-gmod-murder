
if SERVER then
	AddCSLuaFile()
else
	//function SWEP:DrawWeaponSelection( x, y, w, h, alpha )
	//end
end

//SWEP.Author					=""

SWEP.Base = "weapon_mu_base"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
 SWEP.UseHands = true

SWEP.ViewModel = "models/weapons/tfa_csgo/c_revolver.mdl"
SWEP.WorldModel = "models/weapons/tfa_csgo/w_revolver.mdl"
SWEP.ViewModelFlip = false

SWEP.HoldType = "revolver"
SWEP.SequenceDraw = "draw"
SWEP.SequenceIdle = "idle01"
SWEP.SequenceHolster = "holster"

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Sound = "TFA_CSGO_REVOLVER.1"
SWEP.Primary.Sequence = "fire"
-- SWEP.Primary.Delay = 0.
SWEP.Primary.Damage = 200
SWEP.Primary.Cone = 0
SWEP.Primary.DryFireSequence = "fireempty"
SWEP.Primary.DryFireSound = Sound("Weapon_Pistol.Empty")
SWEP.Primary.Recoil = 9
SWEP.Primary.InfiniteAmmo = true
SWEP.Primary.AutoReload = true


SWEP.ReloadSequence = "reload"
SWEP.ReloadSound = Sound("")

function SWEP:Initialize()
	weapons.Get("weapon_mu_base").Initialize(self)
	if ( CLIENT ) then surface.SetMaterial(Material( self.Skin or "models/csgo_knife/cssource" )) end --Ugly hack. Used to "precache" skin's material
	self.PrintName = translate and translate.magnum or "Magnum"
	self:SetClip1(self:GetMaxClip1())
end


function SWEP:Holster()
    self:ClearMaterial()
	return weapons.Get("weapon_mu_base").Holster(self)
end

function SWEP:OwnerChanged()
    self:ClearMaterial()
	weapons.Get("weapon_mu_base").OwnerChanged(self)
	return true
end

function SWEP:OnRemove()
    self:ClearMaterial()
	weapons.Get("weapon_mu_base").OnRemove(self)
	return true
end

function SWEP:SetupDataTables()
	weapons.Get("weapon_mu_base").SetupDataTables(self)
	self:NetworkVar("Float", 3, "FistHit")
	self:NetworkVar( "Float", 0, "InspectTime" )
    self:NetworkVar( "Float", 1, "IdleTime" )
    self:NetworkVar( "Float", 1, "Trigger" )
    self:NetworkVar( "String", 0, "Classname" ) --Do we need this?
    self:NetworkVar( "Bool", 0, "Thrown" )
    -- self:NetworkVar( "Entity", 0, "Attacker" ) --Do we need this?
    -- self:NetworkVar( "Entity", 1, "Victim" ) --Do we need this?
    self:NetworkVar( "Entity", 2, "ViewModel" )
end

SWEP.PrintName = translate and translate.magnum or "Magnum"

function SWEP:Think()
	weapons.Get("weapon_mu_base").Think(self)
	
	if CurTime()>=self:GetIdleTime() then
    	self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
    	self:SetIdleTime( CurTime() + self.Owner:GetViewModel():SequenceDuration() +0.2)
	end
	
end


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

		if (act == ACT_VM_FIDGET and CurTime() < self:GetInspectTime()) then
			return 
		end

		self.Weapon:SendWeaponAnim(ACT_VM_FIDGET)
		self:SetInspectTime( CurTime() + self.Owner:GetViewModel():SequenceDuration() +0.2)
	else
		if (act == ACT_VM_FIDGET and CurTime() < self:GetInspectTime()) and self:Clip1() == 0 and self:GetTrigger() < CurTime() then
			local vm = self.Owner:GetViewModel()
				vm:SendViewModelMatchingSequence(vm:LookupSequence(self.ReloadSequence))
				if self.ReloadSound then
					self:EmitSound(self.ReloadSound)
				end
				self.Owner:SetAnimation(PLAYER_RELOAD)
				self:SetTrigger(CurTime() + vm:SequenceDuration()+0.2)
				self:SetReloadEnd(CurTime() + vm:SequenceDuration()+0.2)
				self:SetNextIdle(CurTime() + vm:SequenceDuration()+0.2)
		end
	end
end



function SWEP:ClearMaterial()
    if IsValid(self.Owner) then
		local Viewmodel = self.Owner:GetViewModel()
		if IsValid(Viewmodel) then Viewmodel:SetMaterial("") end
	end
end


function SWEP:PreDrawViewModel(vm, ply, weapon)
    self:SetViewModel(vm) -- Stores viewmodel's entity into NetworkVar, NOT actually changes viewmodel. Do we need this?
    
    vm:SetMaterial( "" )
    vm:SetSubMaterial()

    self:PaintMaterial(vm)
	-- PrintTable(vm:GetMaterials())
	-- vm:SetSubMaterial(1,'models/wireframe')
end
function SWEP:DrawWorldModel()
	self:SetMaterial(self.Skin or "")
	self:DrawModel()
end

function SWEP:PaintMaterial(vm)
    if ( CLIENT ) and IsValid(vm) then
            local Mat = self:GetThrown() and "" or ( self.Skin or "" )
			if IsValid(vm) and vm:GetModel() == self.ViewModel then vm:SetMaterial(Mat) end 
			if LocalPlayer():GetRole(VOR) and self:GetClass() == 'weapon_mu_magnum_fake' then vm:SetMaterial( "models/props_lab/Tank_Glass001" ) end
	end
end


SWEP.Offset = { --Procedural world model animation, defaulted for CS:S purposes.
        Pos = {
        Up = -3,
        Right = 1.4,
        Forward = 7.3,
        },
        Ang = {
        Up = 3,
        Right = 0,
        Forward = 178
        },
		Scale = 0.9
}

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
		
	
	self:SetMaterial(self.Skin or "")
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
					
	
					self:SetMaterial(self.Skin or "")
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

