if (SERVER) then
	AddCSLuaFile();
end
if CLIENT then
	killicon.AddFont("weapon_mu_knife", "HL2MPTypeDeath", "5", Color(0, 0, 255, 255))
	
	function SWEP:DrawWeaponSelection( x, y, w, h, alpha )
		local name = "Hож"
		surface.SetFont("MersText1")
		local tw, th = surface.GetTextSize(name:sub(2))
		
		surface.SetFont("MersHead1")
		local twf, thf = surface.GetTextSize(name:sub(1, 1))
		tw = tw + twf + 1
		
		draw.DrawText(name:sub(2), "MersText1", x + w * 0.5 - tw / 2 + twf + 1, y + h * 0.51, Color(255, 150, 0, alpha), 0)
		draw.DrawText(name:sub(1, 1), "MersHead1", x + w * 0.5 - tw / 2 , y + h * 0.49, Color(255, 50, 50, alpha), 0)
	end
	
end
if (CLIENT) then
	SWEP.Slot = 1
	SWEP.SlotPos = 5
	SWEP.DrawAmmo = false
end

SWEP.WorldModel = ""
SWEP.ViewModel 			= "models/weapons/v_csgo_default_t.mdl"
SWEP.WorldModel 		= "models/weapons/w_csgo_default_t.mdl" 
SWEP.HoldType = "none"
SWEP.AdminSpawnable = false
SWEP.Spawnable = true;
SWEP.UseHands = true;
SWEP.Primary.NeverRaised = true
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.Damage = 90
SWEP.Primary.Delay = 0.7
SWEP.Primary.Ammo = ""
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Delay = 0
SWEP.Secondary.Ammo = ""
SWEP.NoIronSightFovChange = true
SWEP.NoIronSightAttack = true
SWEP.LoweredAngles = Angle(60, 60, 60)
SWEP.IronSightPos = Vector(0, 0, 0)
SWEP.IronSightAng = Vector(0, 0, 0)
SWEP.NeverRaised = true
SWEP.TravelDistance = 600
SWEP.TravelTime = 0.12
SWEP.TravelSpeed = 4000

function SWEP:Holster(switchingTo)
	return true;
end;

function SWEP:EntityFaceBack(ent)
	local angle = self.Owner:GetAngles().y -ent:GetAngles().y
	if angle < -180 then angle = 360 +angle end
	if angle <= 90 and angle >= -90 then return true end
	return false
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Charging");
	self:NetworkVar("Float", 3, "FistHit")
	self:NetworkVar( "Float", 0, "InspectTime" )
    self:NetworkVar( "Float", 1, "IdleTime" )
    self:NetworkVar( "String", 0, "Classname" ) --Do we need this?
    self:NetworkVar( "Bool", 0, "Thrown" )
    -- self:NetworkVar( "Entity", 0, "Attacker" ) --Do we need this?
    -- self:NetworkVar( "Entity", 1, "Victim" ) --Do we need this?
    self:NetworkVar( "Entity", 2, "ViewModel" )
	self:NetworkVar( "Int", 0, "Charge" )
end;

function SWEP:Initialize()
	if (CLIENT) then
		self.bottomVis = util.GetPixelVisibleHandle();
		self.topVis = util.GetPixelVisibleHandle();
	end;

	self:SetHoldType("knife");
end;

function SWEP:PreDrawViewModel()
	//render.SetBlend(0);
end;

function SWEP:PostDrawViewModel()
	//render.SetBlend(1);
end;

function SWEP:PrepBlink()
	local player = self.Owner;

	player:SetNWBool("showBlink", true);

	if (SERVER) then
		player:EmitSound("blink/enter" .. math.random(1, 2) .. ".wav");
	end;
end;

function SWEP:GetEyeHeight()
	return self.Owner:EyePos() - self.Owner:GetPos();
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

	player:SetGroundEntity(nil);
	player:SetNotSolid(true);
	player:SetMoveType(MOVETYPE_NOCLIP);
	player:EmitSound("blink/exit" .. math.random(1, 2) .. ".wav");

	player:SetNWFloat("nextBlink", CurTime() + 3);
end;

function SWEP:CancelBlink()
	self:SetCharging(false);
	self.Owner:SetNWBool("showBlink", false);
end;

do
	local cyan = Color(150, 210, 255);

	function SWEP:Think()
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
	end;

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
	end;
end;

function SWEP:SecondaryAttack()
	//print(CurTime()-self.Owner:GetNWFloat("nextBlink"))
	if (self.Owner:GetNWBool("blink", false)) then return; end;
	if (CurTime()-self.Owner:GetNWFloat("nextBlink") < 3) then return; end;

	self:PrepBlink();

	self:SetCharging(true);
end;

function SWEP:PrimaryAttack()
	self:CancelBlink();
	
    local Weapon    = self.Weapon
    local Attacker  = self:GetOwner()
    local Range     = Altfire and 48 or 64
    local Forward 	= Attacker:GetAimVector()
	local AttackSrc = Attacker:EyePos()
	local AttackEnd = AttackSrc + Forward * Range
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
            if self.virus then Damage = Backstab and self.Primary.Damage or self.Primary.Damage/2 end
			
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
            -- Old bullet's mechanic. Caused an one hilarious bug. Left for history.
            
            --local Dir = ( trHitPos - AttackSrc )
            --local Bulletinfo = {}
            --Bulletinfo.Attacker = Attacker
            --Bulletinfo.Num      = 1
            --Bulletinfo.Damage   = 0 
            --Bulletinfo.Distance = Range
            --Bulletinfo.Force    = 10
            --Bulletinfo.Tracer   = 0
            --Bulletinfo.Dir      = Dir
            --Bulletinfo.Src      = AttackSrc
            --self:FireBullets( Bulletinfo )
        end
    end
    
    --Change next attack time
    local NextAttack = self.Primary.Delay
    Weapon:SetNextPrimaryFire( CurTime() + NextAttack )
	Weapon:SetNextSecondaryFire( CurTime() + NextAttack )
    
    --Send animation to attacker
    Attacker:SetAnimation( PLAYER_ATTACK1 )
    
    --Send animation to viewmodel
    Act = DidHit and ( Backstab and ACT_VM_SWINGHARD or ACT_VM_HITCENTER2 ) or ( Altfire and ACT_VM_MISSCENTER2 or ACT_VM_MISSCENTER)
    if Act then
        Weapon:SendWeaponAnim( Act )
        self:SetIdleTime( CurTime() + self.Owner:GetViewModel():SequenceDuration() )
    end
    
    --Play sound
    local Oldsounds
    if GetConVar("csgo_knives_oldsounds") then Oldsounds = GetConVar("csgo_knives_oldsounds"):GetBool() else Oldsounds = false end
    local StabSnd    = "csgo_knife.Stab"
    local HitSnd     = "csgo_knife.Hit"
    local HitwallSnd = Oldsounds and "csgo_knife.HitWall_old" or "csgo_knife.HitWall"
    local SlashSnd   = Oldsounds and "csgo_knife.Slash_old" or "csgo_knife.Slash"
    Snd = DidHitPlrOrNPC and ( StabSnd or HitSnd) or DidHit and HitwallSnd or SlashSnd
    if Snd then Weapon:EmitSound( Snd ) end
    
    return true
end;

function SWEP:Reload()

end;

function SWEP:DrawHUD()
	
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
	
	//end
end  