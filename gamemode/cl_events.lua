EVENTS = EVENTS or {}

net.Receive("RoundADS", function (len)
	local table = net.ReadTable()
	if type(EVENTS.data) ~= 'table' then
	EVENTS.data = {}
	end
	
	for k,v in pairs(table) do
		EVENTS.data[k] = v
	end
	
	hook.Run("EVENTS.Refreshed")
end)


function EVENTS:Get(key)
	if EVENTS.data == nil then
		return false
	end
	return EVENTS.data[key]
end

function EVENTS:Call()
	net.Start("GetInfoADS")
	net.SendToServer()
end

function EVENTS:GetID(key)
	return key != nil and (EVENTS.data and EVENTS.data["ID"] or 0) == key or (EVENTS.data and EVENTS.data["ID"] or 0)
end

/* Клиент конфиги */


local function AddSlenderFog()

	render.FogMode( 1 ) 
	render.FogStart( 0 )
	render.FogEnd( 10000  )
	render.FogMaxDensity( 0.9 )

	
	render.FogColor( 1 * 255, 0.1 * 255, 0.1 * 255 )

	return true

end

local function AddSlenderFogSkybox(skyboxscale)

	render.FogMode( 1 ) 
	render.FogStart( 0*skyboxscale )
	render.FogEnd( 10000*skyboxscale  )
	render.FogMaxDensity( 0.9 )

	
	render.FogColor( 1 * 255, 0.1 * 255, 0.1 * 255 )

	return true

end

local function AddNightFog()

	render.FogMode( 1 ) 
	render.FogStart( 0 )
	render.FogEnd( 650  )
	render.FogMaxDensity( 1 )

	
	render.FogColor( 0.0 * 255, 0.0 * 255, 0.0 * 255 )

	return true

end

local function AddNightFogSkybox(skyboxscale)

	render.FogMode( 1 ) 
	render.FogStart( 0*skyboxscale )
	render.FogEnd( 650*skyboxscale  )
	render.FogMaxDensity( 1 )

	
	render.FogColor( 0.0 * 255, 0.0 * 255, 0.0 * 255 )

	return true

end

local drawfog = false
local drawnight = false
local closeup_sound = Sound("camera_static/closeup_short.wav")

hook.Add("Think","SlenderFog",function()
	if EVENTS and EVENTS:Get('ID') == EVENT_SLENDER then
		if LocalPlayer():GetRole(MURDER) then
			if drawnight then
				hook.Remove( "SetupWorldFog","AddNightFog" )
				hook.Remove( "SetupSkyboxFog","AddNightFogSkybox" )
				drawnight = false
			end
			if not drawfog then
				hook.Add( "SetupWorldFog","AddSlenderFog", AddSlenderFog )
				hook.Add( "SetupSkyboxFog","AddSlenderFogSkybox", AddSlenderFogSkybox )
				drawfog = true
			end
		else
			if drawfog then
				hook.Remove( "SetupWorldFog","AddSlenderFog" )
				hook.Remove( "SetupSkyboxFog","AddSlenderFogSkybox" )
				drawfog = false
			end
			if not drawnight then
				hook.Add( "SetupWorldFog","AddNightFog", AddNightFog )
				hook.Add( "SetupSkyboxFog","AddNightFogSkybox", AddNightFogSkybox )
				drawnight = true
			end
		end
	else
		if drawfog then
			hook.Remove( "SetupWorldFog","AddSlenderFog" )
			hook.Remove( "SetupSkyboxFog","AddSlenderFogSkybox" )
			drawfog = false
		end
		if drawnight then
			hook.Remove( "SetupWorldFog","AddNightFog" )
			hook.Remove( "SetupSkyboxFog","AddNightFogSkybox" )
			drawnight = false
		end
	end
end)

local redownloaded_lightmaps = false
hook.Add("EVENTS.Refreshed", "LightMapRefresh", function()
	if !redownloaded_lightmaps then
		timer.Simple(1, function()
			render.RedownloadAllLightmaps( true ) 
		end)
		redownloaded_lightmaps = true
	end
end)
local function CloseupCalcView(pl, origin, angles, fov, znear, zfar)

	if GAMEMODE.CloseupTime and GAMEMODE.CloseupTime + 5 > CurTime()then
	
		local topos, toang
		
		local slender = Entity(0):GetDTEntity(2) ~= MySelf and Entity(0):GetDTEntity(2) or NULL
		
		if IsValid(slender) then
			local bone = slender:LookupBone("ValveBiped.Bip01_Head1")
			if bone then
				local pos,ang = slender:GetBonePosition(bone)
				
				if pos and ang then
					pos = pos+ang:Right() * 20+ang:Forward()*3
					ang.p = ang.p + 70
					ang.y = ang.y + 180
					ang.r = ang.r - 90
					
					topos, toang = pos, ang
				end	
			end
		end
		
		if topos and toang then
			local l = math.Clamp((CurTime() - GAMEMODE.CloseupTime)/0.22, 0, 1)
			return {origin = LerpVector( l, origin, topos ), angles = LerpAngle( l, angles, toang )}
		end

		return
	end

	hook.Remove("CalcView", "CloseupCalcView")
	
end

function ShowCloseup()
	
	GAMEMODE.CloseupTime = CurTime()
	
	LocalPlayer():EmitSound(closeup_sound,0,100,1)
	LocalPlayer():EmitSound(closeup_sound,0,100,1)
	
	hook.Add("CalcView", "CloseupCalcView", CloseupCalcView)
	
end

