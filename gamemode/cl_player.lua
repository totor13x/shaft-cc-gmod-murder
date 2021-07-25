local plyMeta = FindMetaTable("Player")
local entMeta = FindMetaTable("Entity")

function plyMeta:GetRole(role)
	local roleply = self:GetNWInt("role")
	if role ~= nil then
		return role == roleply
	end
	return roleply
end

function entMeta:GetBystanderName()
	local name = self:GetNWString("BystanderName")
	if name != "" then
		return self:GetNWString("BystanderName") 
	end
	return "Невиновный без ника"
end

function entMeta:GetBystanderColor(bool)
	local vector = self:GetNWVector("BystanderColor")
	if bool then
		return Color(vector.x*255,vector.y*255,vector.z*255) or Color(0,0,0)
	end
	return vector or Vector(0.25, 0.25, 0.25)
end


function GM:GetFlashlightCharge()
	return self.FlashlightCharge or 1
end

net.Receive("flashlight_charge", function (len)
	GAMEMODE.FlashlightCharge = net.ReadFloat()
end)

net.Receive("SetLoot", function (len)
	GAMEMODE.LootCollected = net.ReadUInt(32)
end)

net.Receive("mu_tker", function (len)
	GAMEMODE.TKerPenalty = net.ReadBool()
end)

local FootSteps = {}
if FootStepsG then
	FootSteps = FootStepsG
end
FootStepsG = FootSteps

local footMat = Material( "thieves/footprint" )
local maxDistance = 600 ^ 2
local function renderfoot(self)
	cam.Start3D(EyePos(), EyeAngles())
	render.SetMaterial( footMat )
	local pos = EyePos()
	local lifeTime = 30
	for k, footstep in pairs(FootSteps) do
		if footstep.curtime + lifeTime > CurTime() then
			if (footstep.pos - EyePos()):LengthSqr() < maxDistance then
				render.DrawQuadEasy( footstep.pos + footstep.normal * 0.01, footstep.normal, 10, 20, footstep.col, footstep.angle )  
			end
		else
			FootSteps[k] = nil
		end
	end
	cam.End3D()
end

function GM:DrawFootprints()


	local errored, retval = pcall(renderfoot, self)

	if ( !errored ) then
		DebugInfo(4, tostring(retval))
		ErrorNoHalt( retval )
	end

end

function GM:AddFootstep(ply, pos, ang) 
	ang.p = 0
	ang.r = 0
	local fpos = pos
	if ply.LastFoot then
		fpos = fpos + ang:Right() * 5
	else
		fpos = fpos + ang:Right() * -5
	end
	ply.LastFoot = !ply.LastFoot

	local trace = {}
	trace.start = fpos
	trace.endpos = trace.start + Vector(0,0,-10)
	trace.filter = ply
	local tr = util.TraceLine(trace)

	if tr.Hit then

		local tbl = {}
		tbl.pos = tr.HitPos
		tbl.plypos = fpos
		tbl.foot = foot
		tbl.curtime = CurTime()
		tbl.angle = ang.y
		tbl.normal = tr.HitNormal
		local col = ply:GetBystanderColor(true)
		tbl.col = col
		table.insert(FootSteps, tbl)
	end
end

function GM:PlayerFootstep(ply, pos, foot, sound, volume, filter)
	if EVENTS:Get('ID') == EVENT_SLENDER and ply:GetRole(MURDER) then return true end
	if ply != LocalPlayer() then return end
	if !ply:Alive() then return end
	if !self:CanSeeFootsteps() then return end
	self:AddFootstep(ply, pos, ply:GetAimVector():Angle())
end

function GM:CanSeeFootsteps()
	if LocalPlayer():GetRole(MURDER) && LocalPlayer():Alive() then return true end
	//if LocalPlayer():IsSuperAdmin() && LocalPlayer():Alive() then return true end
	return false
end

function GM:ClearFootsteps()
	table.Empty(FootSteps)
end

net.Receive("add_footstep", function ()
	local ply = net.ReadEntity()
	local pos = net.ReadVector()
	local ang = net.ReadAngle()

	if !IsValid(ply) then return end

	if ply == LocalPlayer() then return end

	if !GAMEMODE:CanSeeFootsteps() then return end

	GAMEMODE:AddFootstep(ply, pos, ang)
end)

net.Receive("clear_footsteps", function ()
	GAMEMODE:ClearFootsteps()
end)




local ViewOffsetUp = 0
local ViewOffsetForward = 3
local ViewOffsetForward2 = 0
local ViewOffsetLeftRight = 0
local RollDependency = 0.1
local CurView = nil
local holdType
local traceHit = false
local eyeAt, forwardVec, FT, EA, wep, ply
local view = {}
local mapp, mclamp = math.Approach, math.Clamp
local FVec = Vector(0, 0, 0)

local function FirstPersonPerspective(ply, pos, angles, fov)
	local entitymodel = ply:GetNWEntity("pk_pill_ent")
	
	if (ply:GetRole(HEADCRAB) or ply:GetRole(HEADCRAB_BLACK) or ply:GetRole(CHICKEN)) and LocalPlayer():Alive() then 	
			local view = {}
	
			local newpos = Vector(0,0,0)
			local dist = 100

			local tr = util.TraceHull(
				{
				start = pos, 
				endpos = pos + angles:Forward()*-dist + Vector(0,0,9) + angles:Right()+ angles:Up(),
				mins = Vector(-5,-5,-5),
				maxs = Vector(5,5,5),
				filter = player.GetAll(),
				mask = MASK_SHOT_HULL
				
			})

			newpos = tr.HitPos
			view.origin = newpos

			local newang = angles
			newang:RotateAroundAxis( ply:EyeAngles():Right(), 0 )
			newang:RotateAroundAxis( ply:EyeAngles():Up(), 0 )
			newang:RotateAroundAxis( ply:EyeAngles():Forward(), 0 )

			view.angles = newang
			view.fov = fov
			return view
	end

	 
	if (ply.GetActiveWeapon and ply:GetActiveWeapon():IsValid() and ply:GetActiveWeapon():GetClass() == 'weapon_mu_knife_lightsaber') then 
			local view = {}
			local newpos = Vector(0,0,0)
			local dist = 100
			local nije = 9
			
			local vR = 0
			local vF = 0
			local iai = false
			
			if iai then
				dist = -100
				nije = -9
				vR = 180
				vF = 180
			end
			local tr = util.TraceHull(
				{
				start = pos, 
				endpos = pos + angles:Forward()*-dist + Vector(0,0,nije) + angles:Right()+ angles:Up(),
				mins = Vector(-5,-5,-5),
				maxs = Vector(5,5,5),
				filter = player.GetAll(),
				mask = MASK_SHOT_HULL
				
			})

			newpos = tr.HitPos
			view.origin = newpos

			local newang = angles
			newang:RotateAroundAxis( ply:EyeAngles():Right(), vR )
			newang:RotateAroundAxis( ply:EyeAngles():Up(), 0 )
			newang:RotateAroundAxis( ply:EyeAngles():Forward(), vF )

			view.angles = newang
			view.fov = fov
			
			return view

	end
	
	
     if GAMEMODE.SpectateTime and GAMEMODE.SpectateTime > CurTime() and !ply:Alive() then
         // get their ragdoll
       local ragdoll = ply:GetNWEntity("DeathRagdoll");
	   GAMEMODE.IsCamNabled = true
       if( !ragdoll || ragdoll == NULL || !ragdoll:IsValid() ) then return; end
       
        // find the eyes
        local eyes = ragdoll:GetAttachment( ragdoll:LookupAttachment( "eyes" ) );
        if eyes and eyes.Pos and eyes.Ang then
         // setup our view
         local view = {
             origin = eyes.Pos,
             angles = eyes.Ang,
			 fov = 90, 
         };
          //
         return view;
		 end
     
      end

	if ( IsValid( ply:GetActiveWeapon() ) ) then

		local func = ply:GetActiveWeapon().CalcView
		if ( func ) then
			local view = {};
			view.origin, view.angles, view.fov = func( ply:GetActiveWeapon(), ply, pos, angles, fov)
			return view
		end
	end
	
	return GAMEMODE:CalcView(ply, view.origin, view.angles, view.fov, view.znear)
end

hook.Add("CalcView", "FirstPersonPerspective", FirstPersonPerspective)


net.Receive("DeathSpec",  function()
	GAMEMODE.SpectateTime = CurTime()+4
	LocalPlayer().DisableColour = 1
	LocalPlayer().DisableContrast = 1
end)
net.Receive("SpawnTime",  function()
	GAMEMODE.SpawnTime = CurTime()+7
end)
Sharped = Sharped or 0
net.Receive("SendSharpedHUD",  function()
	Sharped = net.ReadInt(4)
end)
	
net.Receive("TinkingClear.str", function()
	LocalPlayer().TinkingCountShar = 0
	LocalPlayer().TinkingCountSharS = 0
	LocalPlayer().TinkingCountSobel = 0
	LocalPlayer().TinkingCountSobelRedF = 0
	LocalPlayer().TinkingCountSobelRedS = 0
	LocalPlayer().TinkingCountSobelcolour = 1
	LocalPlayer().TinkingCountSobelcontrast = 1
end)

hook.Add( "RenderScreenspaceEffects", "DrawMotionBloom", function()
	if GAMEMODE.IsCamNabled and GAMEMODE.IsCamNabled == true  then
		LocalPlayer().DisableColour = Lerp(0.5*FrameTime() , LocalPlayer().DisableColour , 0 ) 
		LocalPlayer().DisableContrast = Lerp(0.6*FrameTime() , LocalPlayer().DisableContrast , 0 ) 

		local tab = {
			[ "$pp_colour_addr" ] = 0,
			[ "$pp_colour_addg" ] = 0,
			[ "$pp_colour_addb" ] = 0,
			[ "$pp_colour_brightness" ] = 0,
			[ "$pp_colour_contrast" ] = LocalPlayer().DisableContrast,
			[ "$pp_colour_colour" ] = LocalPlayer().DisableColour,
			[ "$pp_colour_mulr" ] = 0,
			[ "$pp_colour_mulg" ] = 0,
			[ "$pp_colour_mulb" ] = 0
		}
		DrawColorModify( tab )
	end
	if Sharped != 0 and LocalPlayer():Alive() then
		local tab = {
			[ "$pp_colour_addr" ] = 0,
			[ "$pp_colour_addg" ] = 0,
			[ "$pp_colour_addb" ] = 0,
			[ "$pp_colour_brightness" ] = 0,
			[ "$pp_colour_contrast" ] = 1/(Sharped+1),
			[ "$pp_colour_colour" ] = 1/(Sharped+1),
			[ "$pp_colour_mulr" ] = 0,
			[ "$pp_colour_mulg" ] = 0,
			[ "$pp_colour_mulb" ] = 0
		}
		DrawColorModify( tab )
	end
	if LocalPlayer():GetNWBool("MeSuccub") then
		if LocalPlayer():GetNWBool("MeSuccubTrig") then
			LocalPlayer().TinkingCountShar = Lerp(1.2*FrameTime() , LocalPlayer().TinkingCountShar , 100 )
			LocalPlayer().TinkingCountSharS = Lerp(0.3*FrameTime() , LocalPlayer().TinkingCountSharS , 1.2 )
			LocalPlayer().TinkingCountSobel = Lerp(5*FrameTime() , LocalPlayer().TinkingCountSobel , 2 )
			
			DrawSharpen(LocalPlayer().TinkingCountShar, LocalPlayer().TinkingCountSharS )
			DrawSobel( LocalPlayer().TinkingCountSobel )
			if LocalPlayer().TinkingCountSobel > 1.95 then

				LocalPlayer().TinkingCountSobelRedF = Lerp(0.5*FrameTime() , LocalPlayer().TinkingCountSobelRedF , 0.5 ) 
				LocalPlayer().TinkingCountSobelRedS = Lerp(0.5*FrameTime() , LocalPlayer().TinkingCountSobelRedS , 1 ) 
				LocalPlayer().TinkingCountSobelcolour = Lerp(0.5*FrameTime() , LocalPlayer().TinkingCountSobelcolour , 3 ) 
				//LocalPlayer().TinkingCountSobelcontrast = Lerp(0.4*FrameTime() , LocalPlayer().TinkingCountSobelcontrast , 0 ) 

				local tab = {
					[ "$pp_colour_addr" ] = LocalPlayer().TinkingCountSobelRedF,
					[ "$pp_colour_addg" ] = 0,
					[ "$pp_colour_addb" ] = 0,
					[ "$pp_colour_brightness" ] = 0,
					[ "$pp_colour_contrast" ] = 1,
					[ "$pp_colour_colour" ] = LocalPlayer().TinkingCountSobelcolour,
					[ "$pp_colour_mulr" ] = LocalPlayer().TinkingCountSobelRedS,
					[ "$pp_colour_mulg" ] = 0,
					[ "$pp_colour_mulb" ] = 0
				}
				DrawColorModify( tab )
			end
		else
			LocalPlayer().TinkingCountShar = Lerp(2*FrameTime() , LocalPlayer().TinkingCountShar , 0 )
			LocalPlayer().TinkingCountSharS = Lerp(2*FrameTime() , LocalPlayer().TinkingCountSharS , 0 )
			LocalPlayer().TinkingCountSobel = Lerp(2*FrameTime() , LocalPlayer().TinkingCountSobel , 2 )
			
			DrawSharpen(LocalPlayer().TinkingCountShar, LocalPlayer().TinkingCountSharS )
			DrawSobel( LocalPlayer().TinkingCountSobel )
			
			LocalPlayer().TinkingCountSobelRedF = Lerp(2*FrameTime() , LocalPlayer().TinkingCountSobelRedF , 0 ) 
			LocalPlayer().TinkingCountSobelRedS = Lerp(2*FrameTime() , LocalPlayer().TinkingCountSobelRedS ,0 ) 
			LocalPlayer().TinkingCountSobelcolour = Lerp(1.1*FrameTime() , LocalPlayer().TinkingCountSobelcolour , 1 ) 
			
			local tab = {
				[ "$pp_colour_addr" ] = LocalPlayer().TinkingCountSobelRedF,
				[ "$pp_colour_addg" ] = 0,
				[ "$pp_colour_addb" ] = 0,
				[ "$pp_colour_brightness" ] = 0,
				[ "$pp_colour_contrast" ] = 1,
				[ "$pp_colour_colour" ] = LocalPlayer().TinkingCountSobelcolour,
				[ "$pp_colour_mulr" ] = LocalPlayer().TinkingCountSobelRedS,
				[ "$pp_colour_mulg" ] = 0,
				[ "$pp_colour_mulb" ] = 0
			}
			DrawColorModify( tab )
			
			if LocalPlayer().TinkingCountSobelcolour < 1.03 then
				net.Start("TinkingClear.endW")
				net.SendToServer()
			end
		end
	end
	if LocalPlayer():GetNWBool("MeWajSuccub") then
		if LocalPlayer():GetNWBool("SuccubFog") then
			LocalPlayer().TinkingCountSobelcolour = Lerp(0.5*FrameTime() , LocalPlayer().TinkingCountSobelcolour , 0 ) 
			LocalPlayer().TinkingCountSobelcontrast = Lerp(0.6*FrameTime() , LocalPlayer().TinkingCountSobelcontrast , 0 ) 

			local tab = {
				[ "$pp_colour_addr" ] = 0,
				[ "$pp_colour_addg" ] = 0,
				[ "$pp_colour_addb" ] = 0,
				[ "$pp_colour_brightness" ] = 0,
				[ "$pp_colour_contrast" ] = LocalPlayer().TinkingCountSobelcontrast,
				[ "$pp_colour_colour" ] = LocalPlayer().TinkingCountSobelcolour,
				[ "$pp_colour_mulr" ] = 0,
				[ "$pp_colour_mulg" ] = 0,
				[ "$pp_colour_mulb" ] = 0
			}
			DrawColorModify( tab )
			if LocalPlayer().TinkingCountSobelcontrast < 0.05 then
			
				net.Start("TinkingClear.end")
				net.SendToServer()
			end
		else
			LocalPlayer().TinkingCountSobelcolour = Lerp(0.5*FrameTime() , LocalPlayer().TinkingCountSobelcolour ,1 ) 
			LocalPlayer().TinkingCountSobelcontrast = Lerp(0.6*FrameTime() , LocalPlayer().TinkingCountSobelcontrast , 1 ) 

			local tab = {
				[ "$pp_colour_addr" ] = 0,
				[ "$pp_colour_addg" ] = 0,
				[ "$pp_colour_addb" ] = 0,
				[ "$pp_colour_brightness" ] = 0,
				[ "$pp_colour_contrast" ] = LocalPlayer().TinkingCountSobelcontrast,
				[ "$pp_colour_colour" ] = LocalPlayer().TinkingCountSobelcolour,
				[ "$pp_colour_mulr" ] = 0,
				[ "$pp_colour_mulg" ] = 0,
				[ "$pp_colour_mulb" ] = 0
			}
			DrawColorModify( tab )
			if LocalPlayer().TinkingCountSobelcontrast > 0.95 then
				net.Start("TinkingClear.endWichout")
				net.SendToServer()
			end
		end
	end
end)

hook.Remove("ShouldDrawLocalPlayer", "deathrun_thirdperson_script")

local function DrawLocalPlayerThirdPerson()
	local ply = LocalPlayer()
	if ply:GetObserverMode() ~= OBS_MODE_NONE then
		if IsValid( ply:GetObserverTarget() ) then
			ply = ply:GetObserverTarget()
		end
	end
	
	if (ply.GetActiveWeapon and ply:GetActiveWeapon():IsValid() and ply:GetActiveWeapon():GetClass() == 'weapon_mu_knife_lightsaber') then 	
		return true
	end
	return false
end
hook.Add("ShouldDrawLocalPlayer", "deathrun_thirdperson_script", DrawLocalPlayerThirdPerson)

