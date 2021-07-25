SWEP.Base = "weapon_mu_knife_def"
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
 
SWEP.PrintName = "Wristblade"
 
SWEP.Slot = 1
SWEP.SlotPos = 1
 
SWEP.Spawnable = true 
SWEP.AdminSpawnable = true 

SWEP.ViewModelFOV = 70
SWEP.ViewModel = "models/viewmodels/c_pred_wristblade.mdl" 
SWEP.WorldModel = "" 
SWEP.UseHands			= true	
SWEP.HoldType = "fist"	
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false 

SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Damage = 70
SWEP.Primary.Cone = 10
 
SWEP.Primary.Automatic = false

SWEP.Secondary.Ammo = "none" 
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Damage = 50
SWEP.guardbroken = false
SWEP.Noanim = false
SWEP.guard = false
SWEP.OnLeap = false
SWEP.Cloak = false
SWEP.CloakToggle = false


function SWEP:Initialize()
	weapons.Get(self.Base).Initialize(self)
	if CLIENT then
		hook.Add( "PreDrawPlayerHands", self, self.PreDrawPlayerHands )
		hook.Add( "PostDrawPlayerHands", self, self.PostDrawPlayerHands )
	end
	self:SetWeaponHoldType( self.HoldType )
	if SERVER then
	self.Owner.OnLeap = false
	end
	// other initialize code goes here
	if CLIENT then
	
		// Create a new table for every weapon instance
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )

		self:CreateModels(self.VElements) // create viewmodels
		self:CreateModels(self.WElements) // create worldmodels
		
		// init view model bone build function
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
				
				// Init viewmodel visibility
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					// we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
					vm:SetColor(Color(255,255,255,1))
					// ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
					// however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
					vm:SetMaterial("Debug/hsv")			
				end
			end
		end
		
	end

end

function SWEP:PrimaryAttack()
    local Weapon    = self.Weapon
    local Attacker  = self:GetOwner()
    local Forward 	= Attacker:GetAimVector()
	local AttackSrc = Attacker:EyePos()
	local AttackEnd = AttackSrc + Forward * 45
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
		
            Backstab = DidHitPlrOrNPC and self:EntityFaceBack( HitEntity ) -- Because we can only backstab creatures
			
            Damage = self.Primary.Damage
            if self.virus then Damage = self.Primary.Damage/2 end
			if self.virus and Backstab then 
				Damage = Damage*2
			end
			
            local damageinfo = DamageInfo()
            damageinfo:SetAttacker( Attacker )
            damageinfo:SetInflictor( self )

            damageinfo:SetDamage( Damage )
            damageinfo:SetDamageType( bit.bor( DMG_BULLET , DMG_NEVERGIB ) )
            damageinfo:SetDamageForce( Forward * 1000 )
            damageinfo:SetDamagePosition( AttackEnd )
            HitEntity:DispatchTraceAttack( damageinfo, tr, Forward )
            
        else
            util.Decal("ManhackCut", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
        end
    end
    
    --Change next attack time
    local NextAttack = 0.5
    Weapon:SetNextPrimaryFire( CurTime() + NextAttack )
	Weapon:SetNextSecondaryFire( CurTime() + NextAttack )
    
    --Send animation to attacker
    Attacker:SetAnimation( PLAYER_ATTACK1 )
    
    --Send animation to viewmodel
	Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:SetIdleTime( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
    
	local StabSnd    = "csgo_knife.Stab"
	local HitSnd     = "csgo_knife.Hit"
	local HitwallSnd = Oldsounds and "csgo_knife.HitWall_old" or "csgo_knife.HitWall"
    local SlashSnd   = Oldsounds and "csgo_knife.Slash_old" or "csgo_knife.Slash"
    Snd = DidHitPlrOrNPC and ( StabSnd or HitSnd) or DidHit and HitwallSnd or SlashSnd
    if Snd then Weapon:EmitSound( Snd ) end
    
end

function SWEP:OnRemove()
	self:Holster()
end

if CLIENT then

	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()
		
		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end
		
		if (!self.VElements) then return end
		
		self:UpdateBonePositions(vm)

		if (!self.vRenderOrder) then
			
			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
			
		end

		for k, name in ipairs( self.vRenderOrder ) do
		
			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (!v.bone) then continue end
			
			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )
			
			if (!pos) then continue end
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()
		
		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end
		
		if (!self.WElements) then return end
		
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
		
		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end
		
		for k, name in pairs( self.wRenderOrder ) do
		
			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end
			
			if (!pos) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
		
		local bone, pos, ang
		if (tab.rel and tab.rel != "") then
			
			local v = basetab[tab.rel]
			
			if (!v) then return end
			
			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )
			
			if (!pos) then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
		else
		
			bone = ent:LookupBone(bone_override or tab.bone)

			if (!bone) then return end
			
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
			
			if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end
		
		end
		
		return pos, ang
	end

	function SWEP:CreateModels( tab )

		if (!tab) then return end

		// Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
				
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
				
			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
				
				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
				
			end
		end
		
	end
	
	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)
		
		if self.ViewModelBoneMods then
			
			if (!vm:GetBoneCount()) then return end
			
			// !! WORKAROUND !! //
			// We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then 
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = { 
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end
				
				loopthrough = allbones
			end
			// !! ----------- !! //
			
			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end
				
				// !! WORKAROUND !! //
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end
				
				s = s * ms
				// !! ----------- !! //
				
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
		else
			self:ResetBonePositions(vm)
		end
		   
	end
	 
	function SWEP:ResetBonePositions(vm)
		
		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end
		
	end

	/**************************
		Global utility code
	**************************/

	// Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
	// Does not copy entities of course, only copies their reference.
	// WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
	function table.FullCopy( tab )

		if (!tab) then return nil end
		
		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) // recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end
		
		return res
		
	end
	
end

function SWEP:Think()
	if 	self.Owner:OnGround()  then
		--timer.Stop( "LeapAttack" )
		if 	self.Owner.OnLeap == true then
			self.Weapon:SendWeaponAnim( ACT_VM_DRYFIRE )
			self:SetWeaponHoldType( "fist"	)
			self.Owner.OnLeap = false
		end
	end
	
	if self.Owner.OnLeap == true then
	
		local Weapon    = self.Weapon
		local Attacker  = self:GetOwner()
		local Forward 	= Attacker:GetAimVector()
		local AttackSrc = Attacker:EyePos()
		local AttackEnd = AttackSrc + Forward * 45
		
		self.Owner:LagCompensation(true)
		
		local aim=self.Owner:GetAimVector()
		aim.z=0
		aim:Normalize()
		local tabl = {}
	
		for i,v in pairs(team.GetPlayers(2)) do
			if v:GetRole(MURDER) then
				tabl[#tabl+1] = v
			end
		end
		tabl[#tabl+1] = self:GetOwner()
		local tracedata = {}
		tracedata.start = self.Owner:EyePos()
		tracedata.endpos = self.Owner:EyePos()+aim*70+Vector(0,0,-5)
		tracedata.filter = tabl
		tracedata.mins = Vector(-8,-8,-8)
		tracedata.maxs = Vector(8,8,8)

		local tr1 = util.TraceLine( tracedata )
		local tr2 = util.TraceHull( tracedata )
		local tr = IsValid(tr2.Entity) and tr2 or tr1
		
		self.Owner:LagCompensation(false) -- Don't forget to disable it!

		local DidHit            = tr.Hit and not tr.HitSky
		local HitEntity         = tr.Entity
		
		if DidHit then
			if HitEntity and IsValid( HitEntity ) then
				 local damageinfo = DamageInfo()
				damageinfo:SetAttacker( self.Owner )
				damageinfo:SetInflictor( self )

				damageinfo:SetDamage( 120 )
				damageinfo:SetDamageType( bit.bor( DMG_BULLET , DMG_NEVERGIB ) )
				damageinfo:SetDamageForce( Forward * 1000 )
				damageinfo:SetDamagePosition( AttackEnd )
				HitEntity:DispatchTraceAttack( damageinfo, tr, Forward )
			end
		end
	end
	print(self.Owner:Health() > 180 and 255 or self.Owner:Health())
	self.Owner:SetColor(Color(255,255,255, self.Owner:GetMaxHealth()+5 - (self.Owner:Health() > 180 and 255 or self.Owner:Health())))
	//self.Owner:SetColor(Color(255,255,255,(self.Owner:GetMaxHealth()+5)-self.Owner:Health()))
	
	if self.Owner:WaterLevel() ~= 0 then
		
		if 	self.Owner.OnLeap == true then
			self.Weapon:SendWeaponAnim( ACT_VM_DRYFIRE )
			self:SetWeaponHoldType( "fist"	)
		
			self.Owner.OnLeap = false
		end
		
	end

	
end


hook.Add( "OnPlayerHitGround", "StopLeapAnim", function(ply)
	if 	ply.OnLeap == true then
	local weapon = ply:GetActiveWeapon()
	if IsValid(weapon) then
		weapon:SendWeaponAnim( ACT_VM_DRYFIRE )
		ply:ViewPunch( Angle( -5, 0, 0 ) )	
		weapon:SetWeaponHoldType( "fist"	)
		
		ply.OnLeap = false
	end
	end

end )

function SWEP:DrawHUD()
	local chargeLeap = math.Clamp(5-(self:GetIdleTime()-CurTime()),0,5)/5*100
	local chargePlazma = math.Clamp(15-(self:GetInspectTime()-CurTime()),0,15)/15*100
	
	local aa = math.EaseInOut( chargeLeap, 0.1, 0.1 ) 
	surface.SetDrawColor( Color(255,255,255,150)  )
	surface.DrawRect( (ScrW()/2)-100, (ScrH()/2)+230, 200, 16 )
	local tcol = self.Owner:GetPlayerColor()
	local scc = string.Explode(".",chargeLeap)
	//draw.SimpleText('Cooldown: '..scc[1]..'%', "Default", (ScrW()/2)-100+5,  (ScrH()/2)+150-8, tcol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	surface.SetDrawColor( Color(tcol.x*255,tcol.y*255,tcol.z*255,255)  )
	surface.DrawRect( (ScrW()/2)-(chargeLeap), (ScrH()/2)+230, chargeLeap*2, 16 )
	draw.SimpleTextOutlined( '[ПКМ] Заряд прыжка: '..scc[1] ..'%', Default, (ScrW()/2)-100+5, (ScrH()/2)+230+8, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, tcol )
	
	local aa = math.EaseInOut( chargePlazma, 0.1, 0.1 ) 
	surface.SetDrawColor( Color(255,255,255,150)  )
	surface.DrawRect( (ScrW()/2)-100, (ScrH()/2)+230+18, 200, 16 )
	local tcol = self.Owner:GetPlayerColor()
	local scc = string.Explode(".",chargePlazma)
	//draw.SimpleText('Cooldown: '..scc[1]..'%', "Default", (ScrW()/2)-100+5,  (ScrH()/2)+150-8, tcol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	surface.SetDrawColor( Color(tcol.x*255,tcol.y*255,tcol.z*255,255)  )
	surface.DrawRect( (ScrW()/2)-(chargePlazma), (ScrH()/2)+230+18, chargePlazma*2, 16 )
	draw.SimpleTextOutlined( '[R] Заряд плазмы: '..scc[1] ..'%', Default, (ScrW()/2)-100+5, (ScrH()/2)+230+8+18, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, tcol )
end

function SWEP:SecondaryAttack()
	if SERVER then
		if ( IsFirstTimePredicted() ) then
			if !self.Owner.OnLeap then
			self.Weapon:SendWeaponAnim( ACT_VM_THROW )
			
			local Playeraim = self.Owner:GetAimVector()
			--Msg( tostring( Playeraim.x ) .. "\n" )
			--Msg( tostring( Playeraim.y ) .. "\n" )
			--Msg( tostring( Playeraim.z ) .. "\n" )
				

				PlayeraimX = (Playeraim.x * 1000 )
				PlayeraimY = (Playeraim.y * 1000 )


				self.Owner:SetVelocity( Vector( PlayeraimX, PlayeraimY, 250 ) )

				self:SetNextSecondaryFire(CurTime()+5)
				self:SetIdleTime( CurTime() + 5 )
				self.Owner.OnLeap = true
			end
		end
	end
end

function SWEP:Reload()
	if SERVER then
	if ( IsFirstTimePredicted() ) then
		if (CurTime() > self:GetInspectTime()) then
			local ent = ents.Create( "plazma_shot" )
			if ( IsValid( ent )  ) then
			local ang = self.Owner:EyeAngles()
				local vmpos, vmang = self:GetOwner():GetBonePosition( self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand") )
				local posn = self.Owner:EyePos() + self.Owner:EyePos():Angle():Forward() * 4
				local angle = self.Owner:GetEyeTraceNoCursor()
				ent:SetPos( posn )
				//ent:SetAngles( angle.HitPos:Angle())
				ent:SetAngles( (angle.HitPos-posn):Angle() +self.Owner:GetViewPunchAngles() )
				ent:SetOwner( self.Owner )
				ent:Spawn()
				ent:Activate()
				self:GetOwner():EmitSound("plasma_shoot.wav")
				local phys = ent:GetPhysicsObject()
				if ( IsValid( phys ) ) then phys:Wake() phys:AddVelocity( ent:GetForward() * 2000 ) end
				
			end
			self:SetInspectTime( CurTime() + 15 )
		end
	end
	end
end


function SWEP:Deploy()	
	
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )	
	timer.Simple( 0.23, function() 
		if IsValid(self) then
			self.Weapon:EmitSound("bladesout.wav")
		end
	end)	
	
	return true
end

function SWEP:Holster()	

	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end

	timer.Stop( "LeapAttack" )
	if self.Owner.OnLeap == true then
		self.Owner.OnLeap = false
	end	
	return true
end


function SWEP:OnDrop()	
	
	timer.Stop( "LeapAttack" )
	if 	self.Owner.OnLeap == true then
	self.Owner.OnLeap = false
	end		
	
	if SERVER then
	self.Owner:SetNoTarget(true)	
	self.Owner:SetColor( Color(255, 255, 255, 255) ) 		
	self.Owner:SetMaterial("models/glass")
	self.Weapon:SetMaterial("models/glass")	
	end
	self.Owner.Cloak = false	
end

if CLIENT then
	function SWEP:PreDrawPlayerHands( hands, vm, pl )
	
		//if pl ~= self.Owner then return end

		//self:CloakThink()
		//if self.Owner.CloakFactor <= 0 then return end
		//local aa = math.Clamp((260-self.Owner:Health())/255, 0, 1)
		local aa = math.Clamp(((self.Owner:GetMaxHealth()+5)-self.Owner:Health())/self.Owner:GetMaxHealth(), 0, 1)
		//print(aa)
		render.SetBlend( aa )
	end

	function SWEP:PostDrawPlayerHands( hands, vm, pl )
		//if pl ~= self.Owner or self.Owner.CloakFactor <= 0 then return end

		render.SetBlend( 1 )
	end
	
end


 