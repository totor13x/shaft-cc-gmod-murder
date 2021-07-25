if SERVER then
	SWEP.Weight = 5
	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = false
elseif CLIENT then
	SWEP.Slot = 1
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end
if SERVER then
	util.AddNetworkString("kama_orrr")
else
	net.Receive("kama_orrr", function()
		local mus = net.ReadString()
		sound.PlayURL ( "https://shaft.cc/uploads/taunts/"..mus, "", function( station )
			if ( IsValid( station ) ) then
				if IsValid(GlobalOrrr2) then
					GlobalOrrr2:Pause()
				end
				station:Play()
				GlobalOrrr2 = station
			end
		end) 
	end)
end
 
SWEP.PrintName = "Нож"
SWEP.Author = "Totor"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.UseHands = true
SWEP.Spawnable = true  
SWEP.AdminSpawnable = true

SWEP.ENT = "mu_knife_def"

SWEP.ViewModel 			= "models/weapons/tfa_csgo/c_ct_knife_anim.mdl"
SWEP.WorldModel 		= "models/weapons/tfa_csgo/w_knife_default_ct.mdl" 
 
SWEP.Primary.Damage = 120
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
 
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.HoldType = "knife"
SWEP.TravelDistance = 600
SWEP.TravelTime = 0.12
SWEP.TravelSpeed = 4000
SWEP.GetMaxClip = 20
SWEP.IsTP = false
SWEP.IsINV = false

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	if self.v_skin and self.v_skin != "none" then
		local id = string.sub(self.v_skin, 1, 1)
		if id == '!' then
			print(self.tfabase, self.tfaname)
			local niceid = TFA.CSGO.Skins[self.tfabase][self.tfaname]['id']
			self.v_skin = niceid
			self.w_skin = niceid
			TFA.CSGO.LoadCachedVMT( string.sub(niceid, 2, -1) )
		end
	end
	self.Skin = self.v_skin
	
	if ( CLIENT ) then surface.SetMaterial(Material( self.Skin or "models/csgo_knife/cssource" )) end
	timer.Simple(0, function()
		if IsValid(self) then
			local getnw = self.Owner:GetNWString("murd_t")
			if getnw == "tp" then
				self.IsTP = true
				self.Primary.Damage = 90 
				if (CLIENT) then
					self.bottomVis = util.GetPixelVisibleHandle();
					self.topVis = util.GetPixelVisibleHandle();
				end;
			elseif getnw == 'inv' then
				self.IsINV = true
			elseif getnw == 'kama' then
				self.IsKama = true
			end;
		end;
	end);
end

function SWEP:SetupDataTables()
	self:NetworkVar( "Float",  0, "InspectTime" )
    self:NetworkVar( "Float",  1, "IdleTime" )
    self:NetworkVar( "Float",  2, "SecondaryTime" )
	self:NetworkVar( "Float",  3, "FistHit")
    self:NetworkVar( "String", 0, "Classname" ) --Do we need this?
    self:NetworkVar( "Bool",   0, "Thrown" )
    self:NetworkVar( "Entity", 2, "ViewModel" )
	self:NetworkVar("Bool", 1, "Charging");
	self:NetworkVar( "Int", 0, "Charge" )
	self:NetworkVar( "Int", 1, "Clip" )
end
 
 
function SWEP:Reload()
end
 
	local cyan = Color(150, 210, 255);

function SWEP:Think()
	
	if self.IsTP then

		local player = self.Owner;
		local bCharging = self:GetCharging();

		if (!player:KeyDown(IN_ATTACK2) and bCharging) then
			if (SERVER) then
				self:DoBlink();
			end;

			self:SetCharging(false);
		end;

		if (bCharging) then
			local bFoundEdge = false;

			local hullTrace = util.TraceHull({
				start = player:EyePos(),
				endpos = player:EyePos() + player:EyeAngles():Forward() * self.TravelDistance,
				filter = player,
				mins = Vector(-16, -16, 0),
				maxs = Vector(16, 16, 9)
			});

			self.groundTrace = util.TraceHull({
				start = hullTrace.HitPos + Vector(0, 0, 1),
				endpos = hullTrace.HitPos - Vector(0, 0, 1000),
				filter = player,
				mins = Vector(-16, -16, 0),
				maxs = Vector(16, 16, 1)
			});

			local edgeTrace;

			if (hullTrace.Hit and hullTrace.HitNormal.z <= 0) then
				local ledgeForward = Angle(0, hullTrace.HitNormal:Angle().y, 0):Forward();
				edgeTrace = util.TraceEntity({
					start = hullTrace.HitPos - ledgeForward * 33 + Vector(0, 0, 40),
					endpos = hullTrace.HitPos - ledgeForward * 33,
					filter = player
				}, player);

				if (edgeTrace.Hit and !edgeTrace.AllSolid) then
					local clearTrace = util.TraceHull({
						start = hullTrace.HitPos,
						endpos = hullTrace.HitPos + Vector(0, 0, 35),
						mins = Vector(-16, -16, 0),
						maxs = Vector(16, 16, 1),
						filter = player
					});

					if (!clearTrace.Hit) then
						self.groundTrace.HitPos = edgeTrace.HitPos;
						bFoundEdge = true;
					end;
				end;
			end;

			if (CLIENT) then
				if (!bFoundEdge) then
					local topLight = DynamicLight(1);

					if (topLight) then
						topLight.pos = hullTrace.HitPos;
						topLight.brightness = 0.5;
						topLight.Size = 200;
						topLight.Decay = 1000
						topLight.r = cyan.r;
						topLight.g = cyan.g;
						topLight.b = cyan.b;
						topLight.DieTime = CurTime() + 0.2;
						topLight.style = 0;
					end;
				end;

				local bottomLight = DynamicLight(2);

				if (bottomLight) then
					bottomLight.pos = self.groundTrace.HitPos;
					bottomLight.brightness = 0.5;
					bottomLight.Size = 200;
					bottomLight.Decay = 1000
					bottomLight.r = cyan.r;
					bottomLight.g = cyan.g;
					bottomLight.b = cyan.b;
					bottomLight.DieTime = CurTime() + 0.2;
					bottomLight.style = 0;
				end;
			end;
		end;

		self:NextThink(CurTime());

		return true;
	elseif self.IsINV then
		if CLIENT then
			self:CloakThink()
		end
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
end

function SWEP:EntityFaceBack(ent)
	local angle = self.Owner:GetAngles().y -ent:GetAngles().y
	if angle < -180 then angle = 360 +angle end
	if angle <= 90 and angle >= -90 then return true end
	return false
end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:SetNextPrimaryFire(CurTime()+self.Owner:GetViewModel():SequenceDuration())
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
			if self.IsKama and SERVER then

				local mp3 = "shaa.mp3"
				if ( math.random(1,2) == 2 ) then mp3 = "taa.mp3" end

				if not self.Owner:PlayTaunt("OnKill", false) then
					print('Let\' play')
					net.Start("kama_orrr")
					net.WriteString(mp3)
					net.Broadcast()
				end
			end
            
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
    
	self.HitBack = self.HitBack or ACT_VM_SWINGHARD
    self.HitCenter = self.HitCenter or ACT_VM_HITCENTER2
    self.Miss = self.Miss or ACT_VM_MISSCENTER
    self.Miss2 = self.Miss2 or ACT_VM_MISSCENTER2
	
    --Send animation to viewmodel
    Act = DidHit and ( Backstab and  self.HitBack or self.HitCenter ) or ( Altfire and self.Miss2 or self.Miss )
    if Act then
        Weapon:SendWeaponAnim( Act )
        self:SetIdleTime( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
    end
    
	local StabSnd    = "csgo_knife.Stab"
	local HitSnd     = "csgo_knife.Hit"
	local HitwallSnd = Oldsounds and "csgo_knife.HitWall_old" or "csgo_knife.HitWall"
    local SlashSnd   = Oldsounds and "csgo_knife.Slash_old" or "csgo_knife.Slash"

	if self.HitPlySound then
		if istable(self.HitPlySound) then
			StabSnd = table.Random(self.HitPlySound)
		else
			StabSnd = self.HitPlySound
		end
		HitSnd = StabSnd
	end
	if self.HitWallSound then
		if istable(self.HitWallSound) then
			HitwallSnd = table.Random(self.HitWallSound)
		else
			HitwallSnd = self.HitWallSound
		end
	end
	if self.MissSound then
		if istable(self.MissSound) then
			SlashSnd = table.Random(self.MissSound)
		else
			SlashSnd = self.MissSound
		end
	end
	
    Snd = DidHitPlrOrNPC and ( StabSnd or HitSnd) or DidHit and HitwallSnd or SlashSnd
	
	
	
    if Snd then Weapon:EmitSound( Snd ) end
    
end

function SWEP:ThrowKnife(force)
	-- print(self.ENT)
	local ent = ents.Create(self.ENT)
	ent:SetOwner(self.Owner)
	ent:SetPos(self.Owner:GetShootPos())
	local knife_ang = Angle(-28,0,0) + self.Owner:EyeAngles()
	knife_ang:RotateAroundAxis(knife_ang:Right(), -90)
	ent:SetAngles(knife_ang)
	ent:Spawn()


	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetVelocity(self.Owner:GetAimVector() * (force * 1000 + 200))
		phys:AddAngleVelocity(Vector(0, 1500, 0))
	else
		ent:PhysicsInitBox( Vector(-5,-10,-10), Vector(5,30,20) )
	end
	self:Remove()
end

function SWEP:GetEyeHeight()
	return self.Owner:EyePos() - self.Owner:GetPos();
end;

function SWEP:PrepBlink()
	local player = self.Owner;

	player:SetNWBool("showBlink", true);

	if (SERVER) then
		player:EmitSound("blink/enter" .. math.random(1, 2) .. ".wav");
	end;
end;

function SWEP:DoBlink()
	local player = self.Owner;
	if (self.Owner:GetNWFloat("nextBlink", 0) > CurTime()) then return; end;
	if (!player:GetNWBool("showBlink", false)) then return; end;
	local speed = self.TravelSpeed;
	local bFoundEdge = false;

	player:SetNWBool("showBlink", false);

	/*
	local hullTrace = util.TraceHull({
		start = player:EyePos(),
		endpos = player:EyePos() + player:EyeAngles():Forward() * self.TravelDistance,
		filter = player,
		mins = Vector(-16, -16, 0),
		maxs = Vector(16, 16, 9)
	});
	*/
		
	local tr = {
		start = player:EyePos(),
		endpos = player:EyePos() + player:EyeAngles():Forward() * self.TravelDistance,
		filter = ents.FindByClass('mappatcher_brush'),
		mins = Vector(-16, -16, 0),
		maxs = Vector(16, 16, 9)
	}

	//t.filter = ents.FindByClass('mappatcher_brush')
	table.insert(tr.filter, player)
	
	local hullTrace = util.TraceHull( tr )
	
	
	local groundTrace = util.TraceEntity({
		start = hullTrace.HitPos + Vector(0, 0, 1),
		endpos = hullTrace.HitPos - self:GetEyeHeight(),
		filter = player
	}, player);

	local edgeTrace;

	if (hullTrace.Hit and hullTrace.HitNormal.z <= 0) then
		local ledgeForward = Angle(0, hullTrace.HitNormal:Angle().y, 0):Forward();
		edgeTrace = util.TraceEntity({
			start = hullTrace.HitPos - ledgeForward * 33 + Vector(0, 0, 40),
			endpos = hullTrace.HitPos - ledgeForward * 33,
			filter = player,
		}, player);

		if (edgeTrace.Hit and !edgeTrace.AllSolid) then
			local clearTrace = util.TraceHull({
				start = hullTrace.HitPos,
				endpos = hullTrace.HitPos + Vector(0, 0, 10),
				mins = Vector(-16, -16, 0),
				maxs = Vector(16, 16, 1),
				filter = player
			});

			bFoundEdge = !clearTrace.Hit;
		end;
	end;

	if (!bFoundEdge and groundTrace.AllSolid) then
		self:CancelBlink();
		return;
	end;

	local endPos = bFoundEdge and edgeTrace.HitPos or groundTrace.HitPos;
	local travelTime = (endPos - player:EyePos()):Length() / (speed);

	player:SetNWBool("blink", true);
	player:SetNWVector("blinkPos", endPos);
	player:SetNWVector("blinkStart", player:GetPos());
	player:SetNWFloat("blinkTime", travelTime);
	
	player:SetNWInt("blinkTravelDistance", self.TravelDistance);
	player:SetNWInt("blinkTravelTime", self.TravelTime);
	player:SetNWInt("blinkTravelSpeed", self.TravelSpeed);

	player:SetGroundEntity(nil);
	player:SetNotSolid(true);
	-- player:SetMoveType(MOVETYPE_NOCLIP);
	player:EmitSound("blink/exit" .. math.random(1, 2) .. ".wav");

	player:SetNWFloat("nextBlink", CurTime() + 3);
end;

function SWEP:CancelBlink()
	self:SetCharging(false);
	self.Owner:SetNWBool("showBlink", false);
end;

function SWEP:SecondaryAttack()
	if self.IsTP then
		if (self.Owner:GetNWBool("blink", false)) then return; end;
		if (CurTime()-self.Owner:GetNWFloat("nextBlink") < 3) then return; end;

		self:PrepBlink();

		self:SetCharging(true);
		return 
	elseif self.IsINV then
		if self:IsCloaked() and self:GetClip() > 0 then self:Uncloak() else self:Cloak() end
		self:SetNextSecondaryFire( CurTime() + 1 )
		return
	end
	if SERVER then self:ThrowKnife(1) end
	self:SetNextSecondaryFire( CurTime() + 1 )
end


function SWEP:Holster()
	if self.IsINV then
		self:Uncloak( self.Owner )
		return not self:IsCloaked()
	end
	return true
end

function SWEP:OnRemove()
	if self.IsINV then
		self:Uncloak( self.Owner )
	end
end

function SWEP:IsCloaked()
	return self.Owner:GetNWBool( "StealthCamo", false )
end

function SWEP:Cloak( pl )
	if IsValid(self.Owner) then
	if SERVER then 
		TTS.Shop.EquippedItems[self.Owner] = TTS.Shop.EquippedItems[self.Owner] or {}
		
		for perm_id, _ in pairs(TTS.Shop.EquippedItems[self.Owner]) do
			local data = self.Owner.TTS.Pointshop.dataIDs[perm_id]
			local item = TTS.Shop.Data.Items[data.item_id]
			if tobool(item.always_equip) then continue end
			
			TTS.Shop.PS_HolsterItemController(self.Owner, perm_id, true, true)
		end
	end
	self.Primary.Damage = 40
	self.Owner:SetNWBool( "StealthCamo", true )
	self.Owner:DrawShadow( false )
	end
end
function SWEP:Uncloak( pl )
	if IsValid(self.Owner) then
	if SERVER then 
		TTS.Shop.EquippedItems[self.Owner] = TTS.Shop.EquippedItems[self.Owner] or {}
			
		
		for perm_id, _ in pairs(TTS.Shop.EquippedItems[self.Owner]) do
			TTS.Shop.PS_EquipItemController(self.Owner, perm_id, true, true)
		end
	end
	self.Primary.Damage = 120
	self.Owner:SetNWBool( "StealthCamo", false )
	self.Owner:DrawShadow( true )
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
		-- print(Mat)
		-- vm:SetMaterial(Mat)
		if IsValid(vm) and vm:GetModel() == self.ViewModel then vm:SetMaterial(Mat) end
		if IsValid(vm) and self.isPickaxe then vm:SetMaterial(Mat) end
	end
end


function SWEP:ClearMaterial()
    if IsValid(self.Owner) then
		local Viewmodel = self.Owner:GetViewModel()
		if IsValid(Viewmodel) then Viewmodel:SetMaterial("") end
	end
end

function SWEP:OwnerChanged()
    self:ClearMaterial()
	return true
end

function SWEP:OnRemove()
    self:ClearMaterial()
	return true
end


function SWEP:Holster()
    self:ClearMaterial()
    return true
end

function SWEP:Reload()
	//print(self.Skin)
	local getseq = self:GetSequence()
	local act = self:GetSequenceActivity(getseq) --GetActivity() method doesn't work :\
	if (act == ACT_VM_FIDGET and CurTime() < self:GetInspectTime()) then
        self:SetInspectTime( CurTime() + 0.1 ) -- We should press R repeately instead of holding it to loop
        return end

	self.Weapon:SendWeaponAnim(ACT_VM_FIDGET)
	self:SetIdleTime( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
    self:SetInspectTime( CurTime() + 0.1 )
	return true
end

function SWEP:CalcViewModelView(vm, opos, oang, pos, ang)
	
	if self.iSCustom then
		ang:RotateAroundAxis(ang:Up(),  -90)
	end
	return pos, ang
end

function SWEP:DrawHUD()
	-- print(self.IsTP)
	if self.IsTP then
		local charge = math.Clamp(CurTime()-self.Owner:GetNWFloat("nextBlink"),0,3)/3*100//(CurTime()-self.Owner:GetNWFloat("nextBlink")-CurTime()/100)
		//if charge > 0 then
		local aa = math.EaseInOut( charge, 0.1, 0.1 ) 
		surface.SetDrawColor( Color(255,255,255,150)  )
		surface.DrawRect( (ScrW()/2)-100, (ScrH()/2)+230, 200, 16 )
		local tcol = self.Owner:GetPlayerColor()
		local scc = string.Explode(".",charge)
		//draw.SimpleText('Cooldown: '..scc[1]..'%', "Default", (ScrW()/2)-100+5,  (ScrH()/2)+150-8, tcol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		surface.SetDrawColor( Color(tcol.x*255,tcol.y*255,tcol.z*255,255)  )
		surface.DrawRect( (ScrW()/2)-(charge), (ScrH()/2)+230, charge*2, 16 )
		draw.SimpleTextOutlined( 'Заряд: '..scc[1] ..'%', Default, (ScrW()/2)-100+5, (ScrH()/2)+230+8, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, tcol )
	elseif self.IsINV then
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
	end  
end  

-- timer.Simple(5, function()
if (CLIENT) then
		local mat = CreateMaterial("blinkGlow7", "UnlitGeneric", {
			["$basetexture"] = "particle/particle_glow_05",
			["$basetexturetransform"] = "center .5 .5 scale 1 1 rotate 0 translate 0 0",
			["$additive"] = 1,
			["$translucent"] = 1,
			["$vertexcolor"] = 1,
			["$vertexalpha"] = 1,
			["$ignorez"] = 0
		});

		local mat2 = CreateMaterial("blinkBottom", "UnlitGeneric", {
			["$basetexture"] = "particle/particle_glow_05",
			["$basetexturetransform"] = "center .5 .5 scale 1 1 rotate 0 translate 0 0",
			["$additive"] = 1,
			["$translucent"] = 1,
			["$vertexcolor"] = 1,
			["$vertexalpha"] = 1,
			["$ignorez"] = 1
		});

		function SWEP:Draw3D()
			if !self.IsTP then return end
			if (!self:GetCharging()) then return; end;
			local player = LocalPlayer();
			local bFoundEdge = false;

			local hullTrace = util.TraceHull({
				start = player:EyePos(),
				endpos = player:EyePos() + player:EyeAngles():Forward() * self.TravelDistance,
				filter = player,
				mins = Vector(-16, -16, 0),
				maxs = Vector(16, 16, 9)
			});

			local groundTrace = util.TraceHull({
				start = hullTrace.HitPos + Vector(0, 0, 1),
				endpos = hullTrace.HitPos - Vector(0, 0, 1000),
				filter = player,
				mins = Vector(-16, -16, 0),
				maxs = Vector(16, 16, 1)
			});

			local edgeTrace;

			if (hullTrace.Hit and hullTrace.HitNormal.z <= 0) then
				local ledgeForward = Angle(0, hullTrace.HitNormal:Angle().y, 0):Forward();
				edgeTrace = util.TraceEntity({
					start = hullTrace.HitPos - ledgeForward * 33 + Vector(0, 0, 40),
					endpos = hullTrace.HitPos - ledgeForward * 33,
					filter = player
				}, player);

				if (edgeTrace.Hit and !edgeTrace.AllSolid) then
					local clearTrace = util.TraceHull({
						start = hullTrace.HitPos,
						endpos = hullTrace.HitPos + Vector(0, 0, 35),
						mins = Vector(-16, -16, 0),
						maxs = Vector(16, 16, 1),
						filter = player
					});

					if (!clearTrace.Hit) then
						groundTrace.HitPos = edgeTrace.HitPos;
						bFoundEdge = true;
					end;
				end;
			end;

			local distToGround = math.abs(hullTrace.HitPos.z - groundTrace.HitPos.z);
			local upDist = vector_up * 1.1;
			local quadPos = groundTrace.HitPos + upDist;

			local quadTrace = util.TraceLine({
				start = EyePos(),
				endpos = quadPos,
				filter = player
			});

			local bottomVis = util.PixelVisible(quadPos, 3, self.bottomVis);

			if (bottomVis and bottomVis >= 0.1) then
				local visAlpha = math.Clamp(bottomVis * 255, 0, 255);

				if (visAlpha > 0 and !quadTrace.Hit) then
					render.SetMaterial(mat2);
					render.DrawSprite(quadPos, 150, 150, ColorAlpha(cyan, visAlpha), bottomVis);
				end;
			end;

			render.SetMaterial(mat);
			render.DrawQuadEasy(quadPos, vector_up, 150, 150, cyan, 0);
			render.DrawQuadEasy(quadPos + upDist, -vector_up, 150, 150, cyan, 0);

			if (distToGround >= 10 and !bFoundEdge) then
				local mappedAlpha = math.Remap(distToGround, 0, 400, 255, 0);
				local mappedUV = math.max(math.Remap(distToGround - 100, 0, 700, 0.5, 1), 0);
				local midPoint = LerpVector(0.5, hullTrace.HitPos, quadPos);

				render.DrawBeam(hullTrace.HitPos, midPoint, 50, 0.5, mappedUV, ColorAlpha(cyan, math.Clamp(mappedAlpha, 0, 255)));
				render.DrawBeam(midPoint, quadPos, 50, mappedUV, 0.5, ColorAlpha(cyan, math.Clamp(mappedAlpha, 0, 255)));

				local topVis = util.PixelVisible(hullTrace.HitPos, 3, self.topVis);

				if (topVis and topVis >= 0.1) then
					local visAlpha = math.Clamp(topVis * 255, 0, 255);

					if (visAlpha > 0) then
						local newCol = ColorAlpha(cyan, visAlpha);
						render.SetMaterial(mat2);
						render.DrawSprite(hullTrace.HitPos, 100, 100, newCol);
						render.DrawSprite(hullTrace.HitPos, 100, 100, newCol);
					end;
				end;
			else
				render.SetMaterial(mat);
				render.DrawBeam(quadPos, groundTrace.HitPos + Vector(0, 0, 300), 50, 0.5, 1, cyan);
			end;
		end;

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
		-- print(self:IsCloaked( self.Owner ), '------', self.Owner:GetNWBool("StealthCamo"))
		if not self.Owner.CloakFactor then self.Owner.CloakFactor = 0 end
		-- print(self.Owner.CloakFactor)
		self.Owner.CloakFactor = math.Approach(	self.Owner.CloakFactor, self:IsCloaked( self.Owner ) and 1 or 0, FrameTime() )
			
	end
	hook.Add("PrePlayerDraw", "SWEP.PrePlayerDrawKNIFE", function(pl)
		local act = pl:GetActiveWeapon()
		
		if IsValid(act) and act.PrepareMaterial then
			act:CloakThink()
			pl.CloakFactor = pl.CloakFactor or 0
			-- print(pl.CloakFactor)
			if pl.CloakFactor <= 0 then return end
			
			render.SetBlend( 1 - pl.CloakFactor )
			-- for k, v in ipairs( pl:GetMaterials() ) do
				-- if not Materials[ v ] then act:PrepareMaterial( v ) end
				-- render.MaterialOverrideByIndex( k - 1, Materials[ v ] )
			-- end
			return
		end
	end, 10)
	-- function SWEP:PrePlayerDraw( pl )
		-- if pl ~= self.Owner then return end
		
		-- self:CloakThink()

		-- print('123123')

		-- if self.Owner.CloakFactor <= 0 then return end

		-- render.UpdateRefractTexture() 

		-- for k, v in ipairs( self.Owner:GetMaterials() ) do
			-- if not Materials[ v ] then self:PrepareMaterial( v ) end
			-- render.MaterialOverrideByIndex( k - 1, Materials[ v ] )
		-- end
	-- end

	hook.Add("PostPlayerDraw", "SWEP.PrePlayerDrawKNIFE", function(pl)
		local act = pl:GetActiveWeapon()
		
		if IsValid(act) and act.PrepareMaterial then
			pl.CloakFactor = pl.CloakFactor or 0
			if pl.CloakFactor <= 0 then return end
			
			render.SetBlend( 1 )
			-- render.MaterialOverrideByIndex()
			return
		end
	end, 10)
	-- function SWEP:PostPlayerDraw( pl )
		-- if pl ~= self.Owner or self.Owner.CloakFactor <= 0 then return end

		-- render.MaterialOverrideByIndex()
	-- end

	-- function SWEP:PreDrawPlayerHands( hands, vm, pl )
	
		-- if pl ~= self.Owner then return end

		-- self:CloakThink()

		-- if self.Owner.CloakFactor <= 0 then return end
		
		-- render.SetBlend( 1 - self.Owner.CloakFactor )
	-- end
	hook.Add("PreDrawPlayerHands", "SWEP.PreDrawPlayerHands", function(hands, vm, pl, wep)
		-- local act = pl:GetActiveWeapon()
		-- print(wep.PrepareMaterial, 'Prepare')
		if IsValid(wep) and wep.PrepareMaterial then
			wep:CloakThink()
			-- print(pl)
			
			-- print(pl.CloakFactor, '-----')
			
			if (pl.CloakFactor or 0) <= 0 then return end
			
			-- hands:SetColor(Color(255,255,255, math.Remap( 1 - pl.CloakFactor, 0, 1, 0, 255 )))
			render.SetBlend( 1 - pl.CloakFactor )
		end
	end)

	-- function SWEP:PostDrawPlayerHands( hands, vm, pl )
		-- if pl ~= self.Owner or self.Owner.CloakFactor <= 0 then return end

		-- render.SetBlend( 1 )
	-- end
	hook.Add("PostDrawPlayerHands", "SWEP.PostDrawPlayerHands", function(hands, vm, pl, wep)
		-- local act = pl:GetActiveWeapon()
		
		if IsValid(wep) and wep.PrepareMaterial then
			-- act:CloakThink()

			if (pl.CloakFactor or 0) <= 0 then return end
			
			render.SetBlend( 1 )
		end
	end)

	end;
-- end)