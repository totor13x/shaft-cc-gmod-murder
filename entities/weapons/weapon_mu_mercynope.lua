SWEP.Base = "weapon_base"

SWEP.ViewModel = "models/weapons/mercy/c_mercy_nope.mdl" --Viewmodel path
SWEP.WorldModel = "models/weapons/mercy/w_mercy_blaster.mdl" -- Worldmodel path
SWEP.ViewModelFOV = 65
SWEP.DrawCrosshair  = true
SWEP.PrintName = "Mercy Gun"
SWEP.DrawAmmo			= false
SWEP.DrawWeaponInfoBox = false
SWEP.HoldType = "pistol"
SWEP.Primary.Damage = 15
SWEP.Primary.Delay = 0.3
SWEP.Primary.ClipSize		=12
SWEP.Primary.DefaultClip	=12000
SWEP.Slot				=4
SWEP.UseHands = true
SWEP.Primary.Automatic = true
SWEP.Primary.InfiniteAmmo = true
SWEP.Primary.Sound = Sound("NOPE_MERCY.1") -- This is the sound of the weapon, when you shoot.
SWEP.Primary.Damage = 16 -- Damage, in standard damage points.
SWEP.MuzzleFlashEffect = 'nope_mercy_particles' -- Damage, in standard damage points.

local oiv = nil

function SWEP:OwnerIsValid()
	if oiv == nil then oiv = IsValid(self:GetOwner()) end
	return oiv
end

function SWEP:SetupDataTables()
end

function SWEP:Initialize()
	self.NextTick = CurTime()
end

function SWEP:Think()
	if self.NextTick >  CurTime() then return end
		
		if self.Owner:Health() < 100 then
			self.Owner:SetHealth(self.Owner:Health()+1)
		end
		
		self.NextTick = CurTime() + 1
end

function SWEP:SecondaryAttack()
end

function SWEP:IsFirstPerson()
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

function SWEP:PrimaryAttack()

	if ( !self:CanPrimaryAttack() ) then return end

	if ( IsFirstTimePredicted() ) then
		
		local ply = self.Owner
		
		
		
	end
	
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
			//ent:SetAngles( angle.HitPos:Angle())
			ent:SetAngles( (angle.HitPos-posn):Angle() +self.Owner:GetViewPunchAngles() )
			ent:SetOwner( self.Owner )
			ent:Spawn()
			ent:Activate()
			
			local phys = ent:GetPhysicsObject()
			if ( IsValid( phys ) ) then phys:Wake() phys:AddVelocity( ent:GetForward() * 2000 ) end
			
		end

		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		self.Owner:EmitSound(self.Primary.Sound)
		self.Owner:ViewPunch(Angle(math.Rand(-0.2,-0.1)*1,math.Rand(-0.1,0.1)*1,0)*2)
		self:TakePrimaryAmmo( 1 )
	end
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

end


function SWEP:DoImpactEffect( trace, damageType )
	local effectdata = EffectData()
	effectdata:SetStart( trace.HitPos )
	effectdata:SetOrigin( trace.HitNormal + Vector( math.Rand( -0.5, 0.5 ), math.Rand( -0.5, 0.5 ), math.Rand( -0.5, 0.5 ) ) )
	util.Effect( "impact_mercy", effectdata )

	return true
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
