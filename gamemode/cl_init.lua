//Загрузка ХУДА
include( "cl_hudlidi.lua" )
include( "3d2dvgui.lua" )
include( "cl_scoreboard_param.lua" )

include( "sh_config.lua" )
include( "shared.lua" )
include( "sh_events.lua" )
include( "cl_events.lua" )
include( "cl_hud.lua" )
include( "cl_player.lua" )
include( "cl_fixplayercolor.lua" )
include( "cl_loot.lua" )
include( "cl_qmenu.lua" )
include( "cl_communicating.lua" )
include( "cl_crosshair.lua" )

include( "cl__outline.lua" )

include( "mv/cl_mv.lua" )

surface.CreateFont("deathrun_hud_Small", {
	font = "Default",
	size = 14,
	antialias = true,
	weight = 800
})

surface.CreateFont("deathrun_derma_Tiny", {
	font = "Default",
	size = 18,
	antialias = true,
	weight = 500
})


function GM:Initialize()
	self.SpawnTime = 0
	self.ForceIvent = false
end

net.Receive("SendInfoIvent", function()
	local id = net.ReadUInt(8)
	GAMEMODE.ForceIvent = id
end)

local OutlineStencil = CreateClientConVar("render_outline_stencil", 0, true, false)
function GM:PostDrawTranslucentRenderables()

	self:DrawFootprints()
	if (EVENTS:Get('ID') == EVENT_SLENDER) then
	-- if true then
		local pos = LocalPlayer():EyePos()+LocalPlayer():EyeAngles():Forward()*10
		local ang = LocalPlayer():EyeAngles()
			ang = Angle(ang.p+90,ang.y,0)
		for k,v in pairs(player.GetAll()) do
			if LocalPlayer():GetRole(MURDER) && v:Alive() and (!v:GetRole(MURDER) and !v:GetRole(MURDER_HELPER)) then
			-- if v:Alive() and (!v:GetRole(MURDER) and !v:GetRole(MURDER_HELPER)) then
				render.ClearStencil()
				render.SetStencilEnable(true)
				render.SetStencilWriteMask(255)
				render.SetStencilTestMask(255)
			render.SetStencilReferenceValue(10)
			render.SetStencilFailOperation(STENCILOPERATION_KEEP)
			render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
			render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
				
				render.SetBlend(0) --don't visually draw, just stencil
				v:DrawModel()
				render.SetBlend(1)
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
				cam.Start3D2D(pos,ang,1)
				
				local health = v:Health() / 100
				health = math.Remap( health, 0, 1, 0, 255 )
				-- cam.IgnoreZ(true)
				-- render.SuppressEngineLighting( true )
				-- render.SetColorModulation(255 - health, health, 0)
				
				surface.SetDrawColor(Color(255-health, health, 0))
				surface.DrawRect(-ScrW(),-ScrH(),ScrW()*2,ScrH()*2)
				cam.End3D2D()
				
				render.SetStencilEnable(false)
			end
		end
		return
	end
	if LocalPlayer():Alive() and LocalPlayer():GetRole(SUCCUB) then
		-- local color = Color(math.Rand(50,60),math.Rand(50,60),math.Rand(200,255), 0)
		
		-- if LocalPlayer():GetRole(MURDER_HELPER) and v:GetRole(MURDER) then
			-- color = Color(math.Rand(200,255),math.Rand(50,60),  math.Rand(50,60))					
		-- elseif LocalPlayer():GetRole(MURDER) and v:GetRole(MURDER) then
			-- color = Color(math.Rand(200,255),math.Rand(50,60),  math.Rand(50,60))					
		-- elseif LocalPlayer():GetRole(MURDER) and v:GetRole(MURDER_HELPER) then
			-- color = Color(math.Rand(238,255),math.Rand(119,140),math.Rand(51,60))
		-- elseif LocalPlayer():GetRole(MURDER_HELPER) and v:GetRole(MURDER_HELPER) then
			-- color = Color(math.Rand(238,255),math.Rand(119,140),math.Rand(51,60))
		-- elseif v:GetNWBool("Marked_ply") then
			-- color.a = 255
		-- end
		for k,v in pairs(player.GetAll()) do
			if  v:Alive() then
				if v:GetNWBool("SuccubFog") then
					local remap = math.Remap(v:Health(), 0, 100, 0, 255)
					local color = Color(255, remap, remap)
					local model = v
					if v:GetRole(HEADCRAB) or v:GetRole(HEADCRAB_BLACK) or v:GetRole(CHICKEN) then
						if v:GetNWEntity("pk_pill_ent"):IsValid() then
							model = v:GetNWEntity("pk_pill_ent")
						end
					end
					outline.Add(model, color, OUTLINE_MODE_VISIBLE)
				end
			end
		end
	end
	if LocalPlayer():Alive() and (LocalPlayer():GetRole(MURDER) or LocalPlayer():GetRole(MURDER_HELPER)) then
		
		local pos = LocalPlayer():EyePos()+LocalPlayer():EyeAngles():Forward()*10
		local ang = LocalPlayer():EyeAngles()
			  ang = Angle(ang.p+90,ang.y,0)
		for k,v in pairs(player.GetAll()) do
			if v == LocalPlayer() then continue end
			if v:Alive() and (v:GetRole(MURDER) or v:GetRole(MURDER_HELPER) or v:GetNWBool("Marked_ply")) then
				if (OutlineStencil:GetBool() == true) then
					local color = Color(math.Rand(50,60),math.Rand(50,60),math.Rand(200,255), 0)
					if LocalPlayer():GetRole(MURDER_HELPER) and v:GetRole(MURDER) then
						color = Color(math.Rand(200,255),math.Rand(50,60),  math.Rand(50,60))					
					elseif LocalPlayer():GetRole(MURDER) and v:GetRole(MURDER) then
						color = Color(math.Rand(200,255),math.Rand(50,60),  math.Rand(50,60))					
					elseif LocalPlayer():GetRole(MURDER) and v:GetRole(MURDER_HELPER) then
						color = Color(math.Rand(238,255),math.Rand(119,140),math.Rand(51,60))
					elseif LocalPlayer():GetRole(MURDER_HELPER) and v:GetRole(MURDER_HELPER) then
						color = Color(math.Rand(238,255),math.Rand(119,140),math.Rand(51,60))
					elseif v:GetNWBool("Marked_ply") then
						color.a = 255
					end
					
					local model = v
					if v:GetRole(HEADCRAB) or v:GetRole(HEADCRAB_BLACK) or v:GetRole(CHICKEN) then
						if v:GetNWEntity("pk_pill_ent"):IsValid() then
							model = v:GetNWEntity("pk_pill_ent")
						end
					end
					outline.Add(model, color, OUTLINE_MODE_VISIBLE)
				else
					render.ClearStencil()
					render.SetStencilEnable(true)
					render.SetStencilWriteMask(255)
					render.SetStencilTestMask(255)
					render.SetStencilReferenceValue(15)
					render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
					render.SetStencilZFailOperation(STENCILOPERATION_REPLACE)

					render.SetBlend(0) --don't visually draw, just stencil
				
					local color = Color(math.Rand(50,60),math.Rand(50,60),math.Rand(200,255), 0)
					if LocalPlayer():GetRole(MURDER_HELPER) and v:GetRole(MURDER) then
						color = Color(math.Rand(200,255),math.Rand(50,60),  math.Rand(50,60))					
					elseif LocalPlayer():GetRole(MURDER) and v:GetRole(MURDER) then
						color = Color(math.Rand(200,255),math.Rand(50,60),  math.Rand(50,60))					
					elseif LocalPlayer():GetRole(MURDER) and v:GetRole(MURDER_HELPER) then
						color = Color(math.Rand(238,255),math.Rand(119,140),math.Rand(51,60))
					elseif LocalPlayer():GetRole(MURDER_HELPER) and v:GetRole(MURDER_HELPER) then
						color = Color(math.Rand(238,255),math.Rand(119,140),math.Rand(51,60))
					elseif v:GetNWBool("Marked_ply") then
						color.a = 255
					end
					
					local model = v
					local pos2 = model:GetPos()
					if v:GetRole(HEADCRAB) or v:GetRole(HEADCRAB_BLACK) or v:GetRole(CHICKEN) then
						if v:GetNWEntity("pk_pill_ent"):IsValid() then
							model = v:GetNWEntity("pk_pill_ent")
						end
					end
					
					model:SetModelScale(1.03, 0)
					model:SetPos(pos2+Vector(0,0,-1.6))
					model:DrawModel()
					
					model:SetPos(pos2)
					model:SetModelScale(1,0)
					render.SetBlend(1)
					render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
					render.SetStencilZFailOperation(STENCILCOMPARISONFUNCTION_EQUAL)
					render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
					cam.Start3D2D(pos,ang,1)
					surface.SetDrawColor(color)
					surface.DrawRect(-ScrW(),-ScrH(),ScrW()*2,ScrH()*2)
					cam.End3D2D()
					model:DrawModel()

					render.SetStencilEnable(false)
				end
			end
		end
	end
return
	/*
	if LocalPlayer():Alive() then
		local pos = LocalPlayer():EyePos()+LocalPlayer():EyeAngles():Forward()*10
		local ang = LocalPlayer():EyeAngles()
			  ang = Angle(ang.p+90,ang.y,0)
			for k,v in pairs(player.GetAll()) do
				if v:Alive() then
					render.ClearStencil()
					render.SetStencilEnable(true)
					render.SetStencilWriteMask(255)
					render.SetStencilTestMask(255)
					render.SetStencilReferenceValue(15)
					render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
					render.SetStencilZFailOperation(STENCILOPERATION_REPLACE)

					render.SetBlend(0) --don't visually draw, just stencil
					local pos2 = v:GetPos()
					v:SetModelScale(1.03, 0)
					v:SetPos(pos2+Vector(0,0,-1.4))
					v:DrawModel()
					v:SetPos(pos2)
					v:SetModelScale(1,0)
					render.SetBlend(1)
					render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
					render.SetStencilZFailOperation(STENCILCOMPARISONFUNCTION_EQUAL)
					render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
					cam.Start3D2D(pos,ang,1)
					surface.SetDrawColor(math.Rand(50,60),math.Rand(50,60),math.Rand(200,255))
					surface.DrawRect(-ScrW(),-ScrH(),ScrW()*2,ScrH()*2)
					cam.End3D2D()
					v:DrawModel()

				
				render.SetStencilEnable(false)
			end
		end
	end
*/
end



function GM:PreDrawViewModel( vm, ply, wep )
	local ply = LocalPlayer()
	if ply:GetObserverMode() == OBS_MODE_CHASE or ply:GetObserverMode() == OBS_MODE_ROAMING then
		return true
	end
	if ( !IsValid( wep ) ) then return false end



	player_manager.RunClass( ply, "PreDrawViewModel", vm, wep )
	
	if ( wep.PreDrawViewModel == nil ) then return false end
	-- print(wep.Skin)
	-- wep:SetRenderMode( RENDERMODE_TRANSALPHA )
	-- vm:SetMaterial('models/wireframe')
	-- render.SetMaterial(Material('models/wireframe'))
	return wep:PreDrawViewModel( vm, wep, ply )
end
function GM:PreDrawPlayerHands( hands, vm, ply, wep )
	if ply:GetObserverMode() == OBS_MODE_CHASE or ply:GetObserverMode() == OBS_MODE_ROAMING then
		return true
	end
end

timer.Simple(1, function() hook.Remove("PostDrawViewModel", "Set player hand skin") end)

GM.FogEmitters = {}
if GAMEMODE then GM.FogEmitters = GAMEMODE.FogEmitters end
function GM:Think()
	for k, ply in pairs(team.GetPlayers(2)) do
		if ply:Alive() && ply:GetNWBool("MurderFog") then
			if !IsValid(ply.FogEmitter) then
				ply.FogEmitter = ParticleEmitter(ply:GetPos())
				self.FogEmitters[ply] = ply.FogEmitter
			end
			if !ply.FogNextPart then ply.FogNextPart = CurTime() end

			local pos = ply:GetPos() + Vector(0,0,30)
			local client = LocalPlayer()

			if ply.FogNextPart < CurTime() then

				if client:GetPos():Distance(pos) > 1000 then return end

				ply.FogEmitter:SetPos(pos)
				ply.FogNextPart = CurTime() + math.Rand(0.01, 0.03)
				local vec = Vector(math.Rand(-8, 8), math.Rand(-8, 8), math.Rand(10, 55))
				local pos = ply:LocalToWorld(vec)
				local particle = ply.FogEmitter:Add( "particle/snow.vmt", pos)
				particle:SetVelocity(  Vector(0,0, 4) + VectorRand() * 3 )
				particle:SetDieTime( 5 )
				particle:SetStartAlpha( 180 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 6 )
				particle:SetEndSize( 7 )   
				particle:SetRoll( 0 )
				particle:SetRollDelta( 0 )
				particle:SetColor( 0, 0, 0 )
				//particle:SetGravity( Vector( 0, 0, 10 ) )
			end
		else
			if IsValid(ply.FogEmitter) then
				ply.FogEmitter:Finish()
				ply.FogEmitter = nil
				self.FogEmitters[ply] = nil
			end
		end
		if ply:Alive() && ply:GetNWBool("SuccubFog") then
			if !IsValid(ply.FogEmitter) then
				ply.FogEmitter = ParticleEmitter(ply:GetPos())
				self.FogEmitters[ply] = ply.FogEmitter
			end
			if !ply.FogNextPart then ply.FogNextPart = CurTime() end

			local pos = ply:GetPos() + Vector(0,0,30)
			local client = LocalPlayer()

			if ply.FogNextPart < CurTime() then
				local scale = 1
				
				if ply:GetNWBool("IsEated") then
					scale = 3
				end
				local alpha = 155 + (100 - ply:Health())
				
				if !ply:GetNWBool("IsEated") then
					alpha = alpha - 100
				end
				
				-- local velo = Vector(0,0,0)
				-- if ply:GetNWBool("IsEated") then
					-- if IsValid(ply:GetNWEntity("whoEatSouls")) then
						
						-- local posstart = ply:GetPos()
						-- posstart:Normalize()
						-- local posend = ply:GetNWEntity("whoEatSouls"):GetPos()
						-- posend:Normalize()
						-- print(posstart, posend)
						-- local ans = math.acos(posstart:Dot(posend) / (posstart:Length() * posend:Length()))
						-- local ans = math.acos(posstart:Dot(posend))
						-- print(math.deg(ans))
					-- end
				-- end
				if client:GetPos():Distance(pos) > 1000 then return end

				ply.FogEmitter:SetPos(pos)
				ply.FogNextPart = CurTime() + ply:Health()/100
				local vec = Vector(math.Rand(-8, 8), math.Rand(-8, 8), math.Rand(10, 55))
				local pos = ply:LocalToWorld(vec)
				local particle = ply.FogEmitter:Add( "particle/snow.vmt", pos)
				particle:SetVelocity(  Vector(0,0, 4) + VectorRand() * 3 )
				particle:SetDieTime( 5 )
				particle:SetStartAlpha( alpha )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( scale )
				particle:SetEndSize( scale+1 )   
				particle:SetRoll( 0 )
				particle:SetRollDelta( 0 )
				particle:SetColor( 170, 0, 0 )
				//particle:SetGravity( Vector( 0, 0, 10 ) )
			end
		else
			if IsValid(ply.FogEmitter) then
				ply.FogEmitter:Finish()
				ply.FogEmitter = nil
				self.FogEmitters[ply] = nil
			end
		end
	end

	// clean up old fog emitters
	for ply, emitter in pairs(self.FogEmitters) do
		if !IsValid(ply) || !ply:IsPlayer() then
			emitter:Finish()
			self.FogEmitters[ply] = nil
		end
	end
end


function GM:GetRound(id)
	if id ~= nil then
		return self.RoundStage == id
	end
	return self.RoundStage or 0
end

net.Receive("SetRound", function (len)
	GAMEMODE.RoundStage = net.ReadUInt(32)
	GAMEMODE.FogEmitters = {}
	if GAMEMODE:GetRound(1) then
		if IsValid(LocalPlayer()) and LocalPlayer():Alive() then
			mute_state = MUTE_NONE			
		end
		GAMEMODE.IsCamNabled = false
		GAMEMODE.focus_stick = 0
		GAMEMODE:ClearFootsteps()
	end
	
end)


net.Receive("MovedAFKPlayer", function (len)
	if IsValid(FrameAFK3) then
		FrameAFK3:Remove()
	end

	FrameAFK3 = vgui.Create( "DFrame" )
	FrameAFK3:SetSize( 350, 130 )
	FrameAFK3:SetPos((ScrW() / 2) - (FrameAFK3:GetWide() / 2), (ScrH() / 2) - (FrameAFK3:GetTall() / 2))
	FrameAFK3:SetTitle( "" )
	FrameAFK3:SetVisible( true ) 
	FrameAFK3:SetDraggable( false )
	FrameAFK3:SetDeleteOnClose(true)
	FrameAFK3:MakePopup()
	FrameAFK3.Paint = function( s, w, h )
    DLib.blur.DrawPanel(w, h, s:LocalToScreen(0, 0))
		draw.RoundedBox( 0, 0, 0, w, h,Color( 35, 35, 35,200) )
		
		draw.SimpleText("Вы были переведены в наблюдатели.", "S_Light_15", (w)/2, 35+5, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
		draw.SimpleText("Для того чтобы зайти в игру", "S_Light_15", (w)/2, 35+20+5, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
		//draw.SimpleText("Для того чтобы зайти в игру", "SpinButton4def2", (w)/2, 35+20, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
	end
	 
	FrameAFK3.OnClose = function(self) end

	local AcceptTrade = vgui.Create("DButton" , FrameAFK3)
	AcceptTrade:SetPos(0 , 100-20)
	AcceptTrade:SetSize(350, 50)
	AcceptTrade:SetText("")
	AcceptTrade.tt = 0
	AcceptTrade.Paint = function(s , w , h)

		draw.RoundedBox(0,0,0,w,h,Color( 85 , 125 , 37, s.tt))

		draw.SimpleText("НАЖМИТЕ НА МЕНЯ", "S_Light_20", (w)/2, (h-4)/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end		
	AcceptTrade.OnCursorEntered = function(s)
			s.tt = 230
	end
	AcceptTrade.OnCursorExited = function(s)
			s.tt = 0
	end 
	AcceptTrade.DoClick = function(s)
		RunConsoleCommand("mu_jointeam", 2)
		FrameAFK3:Remove()
	end 
end)

net.Receive("SpawnHasPlayer", function (len)
	if IsValid(FrameAFK) then
		FrameAFK:Remove()
	end

	FrameAFK = vgui.Create( "DFrame" )
	FrameAFK:SetSize( 350, 180 )
	FrameAFK:SetPos((ScrW() / 2) - (FrameAFK:GetWide() / 2), (ScrH() / 2) - (FrameAFK:GetTall() / 2))
	FrameAFK:SetTitle( "" )
	FrameAFK:SetVisible( true ) 
	FrameAFK:SetDraggable( false )
	FrameAFK:SetDeleteOnClose(true)
	FrameAFK:MakePopup()
	FrameAFK.Paint = function( s, w, h )
    DLib.blur.DrawPanel(w, h, s:LocalToScreen(0, 0))
		draw.RoundedBox( 0, 0, 0, w, h,Color( 35, 35, 35,200) )
		
		draw.SimpleText("Добро пожаловать на shaft.cc!", "S_Light_15", (w)/2, 35+5, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
		draw.SimpleText("Сейчас вы находитесь в наблюдателях.", "S_Light_15", (w)/2, 35+20+5, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
		draw.SimpleText("Для того чтобы зайти в игру", "S_Light_15", (w)/2, 35+20+20+5, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
		//draw.SimpleText("Для того чтобы зайти в игру", "SpinButton4def2", (w)/2, 35+20, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
	end	
	 
	FrameAFK.OnClose = function(self)
		local FrameAFK2 = vgui.Create( "DFrame" )
		FrameAFK2:SetSize( 350, 150 )
		FrameAFK2:SetPos((ScrW() / 2) - (FrameAFK2:GetWide() / 2), (ScrH() / 2) - (FrameAFK2:GetTall() / 2))
		FrameAFK2:SetTitle( "" )
		FrameAFK2:SetVisible( true ) 
		FrameAFK2:SetDraggable( false )
		FrameAFK2:SetDeleteOnClose(true)
		FrameAFK2:MakePopup()
		FrameAFK2.Paint = function( s, w, h )
      DLib.blur.DrawPanel(w, h, s:LocalToScreen(0, 0))
			draw.RoundedBox( 0, 0, 0, w, h,Color( 35, 35, 35,200) )
			
			draw.SimpleText("Вы уверены, что хотите выйти?", "S_Light_15", (w)/2, 35+5, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
			draw.SimpleText("После того как вы закроете это окно", "S_Light_15", (w)/2, 35+20+5, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
			draw.SimpleText("Вы покинете сервер!", "S_Light_15", (w)/2, 35+20+20+5, Color(255,150,150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
			//draw.SimpleText("Для того чтобы зайти в игру", "SpinButton4def2", (w)/2, 35+20, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
		end	
		 
		FrameAFK2.OnClose = function(self)
			RunConsoleCommand("disconnect")
		end
		AcceptTrade = vgui.Create("DButton" , FrameAFK2)
		AcceptTrade:SetPos(0 , 100)
		AcceptTrade:SetSize(350, 50)
		AcceptTrade:SetText("")
		AcceptTrade.tt = 0
		AcceptTrade.Paint = function(s , w , h)

			draw.RoundedBox(0,0,0,w,h,Color( 85 , 125 , 37, s.tt))
			local col = Color( 85 , 255 , 37, 255)
			if s.tt == 255 then
				col = Color(255,255,255)
			end
			
			draw.SimpleText("ПРИСОЕДИНИТЕ МЕНЯ К ИГРЕ!", "S_Light_20", (w)/2, (h-4)/2, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end		
		AcceptTrade.OnCursorEntered = function(s)
				s.tt = 255
		end
		AcceptTrade.OnCursorExited = function(s)
				s.tt = 0
		end 
		AcceptTrade.DoClick = function(s)
			RunConsoleCommand("mu_jointeam", 2)
			FrameAFK2:Remove()
		end 
	end
	local AcceptTrade = vgui.Create("DButton" , FrameAFK)
	AcceptTrade:SetPos(0 , 100)
	AcceptTrade:SetSize(350, 50)
	AcceptTrade:SetText("")
	AcceptTrade.tt = 0
	AcceptTrade.Paint = function(s , w , h)

		draw.RoundedBox(0,0,0,w,h,Color( 85 , 125 , 37, s.tt))

		draw.SimpleText("НАЖМИТЕ НА МЕНЯ", "S_Light_20", (w)/2, (h-4)/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end		
	AcceptTrade.OnCursorEntered = function(s)
			s.tt = 230
	end
	AcceptTrade.OnCursorExited = function(s)
			s.tt = 0
	end 
	AcceptTrade.DoClick = function(s)
		RunConsoleCommand("mu_jointeam", 2)
		FrameAFK:Remove()
	end 
	
	local AcceptTrade = vgui.Create("DButton" , FrameAFK)
	AcceptTrade:SetPos(0 , 150)
	AcceptTrade:SetSize(350, 30)
	AcceptTrade:SetText("")
	AcceptTrade.tt = 0
	AcceptTrade.Paint = function(s , w , h)

		draw.RoundedBox(0,0,0,w,h,Color( 50 , 50 , 185, s.tt))

		local col = Color( 150, 150, 255, 255)
		if s.tt == 255 then
			col = Color(255,255,255)
		end
		
		draw.SimpleText("Крайне рекомендуем ознакомиться с правилами сервера.", "default", (w)/2, ((h-4)/2)-6, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("Это можно сделать, написав в чат !motd или нажав на меня.", "default", (w)/2, ((h)/2)+6, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end		
	AcceptTrade.OnCursorEntered = function(s)
			s.tt = 255
	end
	AcceptTrade.OnCursorExited = function(s)
			s.tt = 0
	end 
	AcceptTrade.DoClick = function(s)
		RunConsoleCommand("say", "!motd")
	end 
end)

local MuteText = {
   [MUTE_NONE]   = "",
   [MUTE_ALIVE]    = "mute_all",
   [MUTE_NOTALIVE] = "mute_living",
};

local mute_state = MUTE_NONE
function CycleMute(state)
   mute_state = next(MuteText, mute_state)

   if not mute_state then mute_state = MUTE_NONE end

   return mute_state
end 

function SetCycleMute(state)
   if mute_state then mute_state = state end
end

function GetCycleMute()
   return mute_state or MUTE_NONE
end

lastTimeF1 = CurTime()

hook.Add("PlayerBindPress",'BindsPyLeft', function(ply, bind, pressed)
	if !IsValid(ply) then return end
	if LocalPlayer():Alive() and GAMEMODE.SpawnTime and GAMEMODE.SpawnTime > CurTime() and (bind == '+forward' or bind == '+moveleft' or bind == '+moveright'  or bind == '+back' ) then
		return true 
	end
	if ply:Alive() and bind == '+use' and HasButtonFocused() and pressed then
		return UseFocused()
	end
end)

hook.Add("CreateMove",'ByCheckClientsideKeyBinds', function(cmd)

	local ply = LocalPlayer()
	/*
	if input.WasKeyPressed(KEY_F3) then
		ply:ConCommand("mu_adminpanel")
	end
	*/
	if input.WasKeyPressed(KEY_F4) then
		ply:ConCommand("unbox")
	end
	//print( cmd:KeyDown( IN_SPEED ))
	if input.WasKeyPressed(KEY_F1) and cmd:KeyDown( IN_SPEED ) and not ply.Opened then
		ply.Opened = true
		//ply:ConCommand("F1")
		return
	//	openendroundboard()
	end
	if input.WasKeyReleased(KEY_F1) and ply.Opened then
		ply.Opened = false
		//ply:ConCommand("F1")
		return
		//ply:ConCommand("F1")
	//	openendroundboard()
	end
	
	if input.WasKeyReleased(KEY_F1) and !ply:Alive() and !ply.Opened and lastTimeF1+0.5 < CurTime() then
		local m = CycleMute()
		lastTimeF1 = CurTime()
		RunConsoleCommand("MuteWhenIDead", m)
	end

end)

GM.buttonsTTT = GM.buttonsTTT or {}
GM.buttons_countTTT = GM.buttons_countTTT or 0

function CacheButtons()
   if IsValid(LocalPlayer()) and LocalPlayer():GetRole(MURDER) then
      GAMEMODE.buttonsTTT = {}
      for _, ent in pairs(ents.FindByClass("ttt_traitor_button")) do
         if IsValid(ent) then
            GAMEMODE.buttonsTTT[ent:EntIndex()] = ent
         end
      end
   else
      GAMEMODE.buttonsTTT = {}
   end
   GAMEMODE.buttons_countTTT = table.Count(GAMEMODE.buttonsTTT)
end
function IsOffScreen(scrpos)
	return not scrpos.visible or scrpos.x < 0 or scrpos.y < 0 or scrpos.x > ScrW() or scrpos.y > ScrH()
end

function HasButtonFocused()
   return IsValid(LocalPlayer()) and LocalPlayer():GetRole(MURDER) and IsValid(GAMEMODE.focus_ent)
end

function UseFocused()
   if IsValid(GAMEMODE.focus_ent) and GAMEMODE.focus_stick >= CurTime() then
      RunConsoleCommand("ttt_use_tbutton", tostring(GAMEMODE.focus_ent:EntIndex()))

      GAMEMODE.focus_ent = nil
      return true
   else
      return false
   end
end

hook.Add("InitPostEntity", "InitLoad", function()
	
   timer.Create("cache_buttons", 1, 0, CacheButtons)

end)

hook.Add('AddTabsScoreboard', 'panelAdd', function(panel)
local self = panel
local buttonchange2 = vgui.Create( "DButton", panel.DermaPanelTextSidebar)
	buttonchange2:SetPos( 0, 0 )
	buttonchange2:SetSize(panel.DermaPanelTextSidebar:GetWide(),38 + 2)
	buttonchange2:SetText("")
	buttonchange2.selected = false
	
	buttonchange2.DoClick = function(s2)
	self.buttonmode.Moved = 1
	s2.selected = true
	panel.DermaPanelTextex:Remove()
		panel.DermaPanelTextex = vgui.Create("DFrame",panel.DermaPanelText)
		panel.DermaPanelTextex:SetPos(5, 30)
		panel.DermaPanelTextex:SetSize(panel.DermaPanelText:GetWide()-10-300, panel.DermaPanelText:GetTall()-35)
		panel.DermaPanelTextex.clr = Color(255,255,255,100)
		panel.DermaPanelTextex:SetTitle( "" )
		panel.DermaPanelTextex:SetVisible( true )
		panel.DermaPanelTextex:SetDraggable( false )
		panel.DermaPanelTextex:ShowCloseButton( false )
		
		panel.DermaPanelTextex.Paint = function( s, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0,200) )
			draw.RoundedBox( 0, 0, 0, w, 25, Color( 5, 5, 5,255) )
			
			draw.SimpleText("Ваши настройки", "Defaultfont", 10, 2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)


		if LocalPlayer():GetNWInt('murdertype') == 0 then
			draw.SimpleText("Выбран Стандартный", "Defaultfont", 35+200, 130+30, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)						
		end
		if LocalPlayer():GetNWInt('murdertype') == 1 then
			draw.SimpleText("Выбран Бенжи", "Defaultfont", 35+200, 130+30, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)						
		end
		if LocalPlayer():GetNWInt('murdertype') == 2 then
			draw.SimpleText("Выбран класс Virus'a", "Defaultfont", 35+200, 130+30, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)						
		end
		if LocalPlayer():GetNWInt('murdertype') == 3 then
			draw.SimpleText("Выбран Убийцорожденный", "Defaultfont", 35+200, 130+30, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)						
		end
		if LocalPlayer():GetNWInt('murdertype') == 4 then
			draw.SimpleText("Выбран ситх", "Defaultfont", 35+200, 130+30, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)						
		end
		if LocalPlayer():GetNWInt('murdertype') == 5 then
			draw.SimpleText("Выбран невидимка", "Defaultfont", 35+200, 130+30, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)						
		end
		if LocalPlayer():GetNWInt('murdertype') == 6 then
			draw.SimpleText("Выбран teleport", "Defaultfont", 35+200, 130+30, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)						
		end	
		if LocalPlayer():GetNWInt('murdertype') == 7 then
			draw.SimpleText("Выбран KamaPulya", "Defaultfont", 35+200, 130+30, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)						
		end					
		end
/*
		local DermaCheckbox = vgui.Create( "DCheckBoxLabel", self.DermaPanelTextex)
		DermaCheckbox:SetPos( 25, 40 )						
		DermaCheckbox:SetText( "Вид от 3-его лица" )				
		DermaCheckbox:SetFont("Defaultfont")				
		DermaCheckbox.CommandEd = "deathrun_thirdperson_enabled"	
		DermaCheckbox:SetConVar( DermaCheckbox.CommandEd )	
		DermaCheckbox:SetValue( math.Clamp(GetConVarNumber( DermaCheckbox.CommandEd), 0, 1) )		
		DermaCheckbox:SizeToContents()

		local DermaCheckbox = vgui.Create( "DCheckBoxLabel", self.DermaPanelTextex)
		DermaCheckbox:SetPos( 25, 70 )						
		DermaCheckbox:SetText( "Auto-jump" )			
		DermaCheckbox:SetFont("Defaultfont")					
		DermaCheckbox:SetSize( 20,20 )							
		DermaCheckbox.CommandEd = "deathrun_autojump"	
		DermaCheckbox:SetConVar( DermaCheckbox.CommandEd )	
		DermaCheckbox:SetValue( math.Clamp(GetConVarNumber( DermaCheckbox.CommandEd), 0, 1) )		
		DermaCheckbox:SizeToContents()		
*/
		local DermaCheckbox = vgui.Create( "DCheckBoxLabel", panel.DermaPanelTextex)
		DermaCheckbox:SetPos( 25, 40 )						
		DermaCheckbox:SetText( "Убрать отображение хвостов" )		
		DermaCheckbox:SetFont("Defaultfont")						
		DermaCheckbox.CommandEd = "hidetrails"	
		DermaCheckbox:SetConVar( DermaCheckbox.CommandEd )	
		DermaCheckbox:SetValue( math.Clamp(GetConVarNumber( DermaCheckbox.CommandEd), 0, 1) )		
		DermaCheckbox:SizeToContents()	
/*				
		local DermaCheckbox = vgui.Create( "DCheckBoxLabel", self.DermaPanelTextex)
		DermaCheckbox:SetPos( 25, 160 )						
		DermaCheckbox:SetText( "Режим наблюдателя" )		
		DermaCheckbox:SetFont("Defaultfont")						
		DermaCheckbox.CommandEd = "deathrun_spectate_only"	
		DermaCheckbox:SetConVar( DermaCheckbox.CommandEd )	
		DermaCheckbox:SetValue( math.Clamp(GetConVarNumber( DermaCheckbox.CommandEd), 0, 1) )		
		DermaCheckbox:SizeToContents()		
*/			
		local DermaCheckbox = vgui.Create( "DCheckBoxLabel", panel.DermaPanelTextex)
		DermaCheckbox:SetPos( 25, 70 )						
		DermaCheckbox:SetText( "Активация курсора в ТАБ'е без нажатия ПКМ" )		
		DermaCheckbox:SetFont("Defaultfont")						
		DermaCheckbox.CommandEd = "scoreboard_rightclick"	
		DermaCheckbox:SetConVar( DermaCheckbox.CommandEd )	
		DermaCheckbox:SetValue( math.Clamp(GetConVarNumber( DermaCheckbox.CommandEd), 0, 1) )		
		DermaCheckbox:SizeToContents()	
			
		local DermaCheckbox = vgui.Create( "DCheckBoxLabel", panel.DermaPanelTextex)
		DermaCheckbox:SetPos( 25, 100 )						
		DermaCheckbox:SetText( "Отображение модели" )		
		DermaCheckbox:SetFont("Defaultfont")						
		DermaCheckbox.CommandEd = "cl_ec_enabled"	
		DermaCheckbox:SetConVar( DermaCheckbox.CommandEd )	
		DermaCheckbox:SetValue( math.Clamp(GetConVarNumber( DermaCheckbox.CommandEd), 0, 1) )		
		DermaCheckbox:SizeToContents()	
		
		
		
		local DermaCheckbox = vgui.Create( "DCheckBoxLabel", panel.DermaPanelTextex)
		DermaCheckbox:SetPos( 25, 130 )						
		DermaCheckbox:SetText( "Оружие с правой руки" )			
		DermaCheckbox:SetFont("Defaultfont")					
		DermaCheckbox.CommandEd = "cl_righthand"	
		DermaCheckbox:SetConVar( DermaCheckbox.CommandEd )	
		DermaCheckbox:SetValue( math.Clamp(GetConVarNumber( DermaCheckbox.CommandEd), 0, 1) )		
		DermaCheckbox:SizeToContents()	

		local DermaCheckbox = vgui.Create( "DCheckBoxLabel", panel.DermaPanelTextex)
		DermaCheckbox:SetPos( 25, 130+30+30+30 )						
		DermaCheckbox:SetText( "Отключить звуки бумбокса" )			
		DermaCheckbox:SetFont("Defaultfont")					
		DermaCheckbox.CommandEd = "avoid_boombox_play"
		DermaCheckbox:SetConVar( DermaCheckbox.CommandEd )	
		DermaCheckbox:SetValue( math.Clamp(GetConVarNumber( DermaCheckbox.CommandEd), 0, 1) )		
		DermaCheckbox:SizeToContents()	

		
		
		local DComboBox = vgui.Create( "DComboBox", panel.DermaPanelTextex )
		DComboBox:SetPos( 25, 130+30 )
		DComboBox:SetSize( 200, 20 )
		DComboBox:SetValue( "Выбор типа убийцы" )
			DComboBox:AddChoice( "Стандартный" )
		if LocalPlayer():GetUserGroup() ~= 'user' then
			DComboBox:AddChoice( "Бенжи" )
		end
		
		if LocalPlayer():SteamID() == 'STEAM_0:0:62377801' then DComboBox:AddChoice( "Virus" ) end
		
		if LocalPlayer():GetNWBool("AddExtraFunctions") then
			DComboBox:AddChoice( "Убийцорожденный" )
			DComboBox:AddChoice( "Ситх" )
			DComboBox:AddChoice( "Невидимка" )
			DComboBox:AddChoice( "Teleport" )
			DComboBox:AddChoice( "KamaPulya" )
		end
		
		DComboBox.OnSelect = function( panel, index, value )
			net.Start("ChangeTypeMurder")
			net.WriteString( value )
			net.SendToServer()
		end
		
	local DComboBox = vgui.Create( "DComboBox", panel.DermaPanelTextex )
		DComboBox:SetPos( 25, 130+30+30 )
		DComboBox:SetSize( 200, 20 )
		DComboBox:SetValue( "Выбор стандартного ножа" )
		DComboBox:AddChoice( "КТ", "weapon_mu_knife_def", LocalPlayer():GetNWString('def_knife') == "weapon_mu_knife_def" )
		DComboBox:AddChoice( "Bowie", "weapon_mu_knife_bowie", LocalPlayer():GetNWString('def_knife') == "weapon_mu_knife_bowie" )
		DComboBox:AddChoice( "Bayonet", "weapon_mu_knife_bayonet", LocalPlayer():GetNWString('def_knife') == "weapon_mu_knife_bayonet" )
		DComboBox:AddChoice( "Butterfly", "weapon_mu_knife_butterfly", LocalPlayer():GetNWString('def_knife') == "weapon_mu_knife_butterfly" )
		DComboBox:AddChoice( "Daggers", "weapon_mu_knife_daggers", LocalPlayer():GetNWString('def_knife') == "weapon_mu_knife_daggers" )
		DComboBox:AddChoice( "Falchion", "weapon_mu_knife_falchion", LocalPlayer():GetNWString('def_knife') == "weapon_mu_knife_falchion" )
		DComboBox:AddChoice( "Flip", "weapon_mu_knife_flip", LocalPlayer():GetNWString('def_knife') == "weapon_mu_knife_flip" )
		DComboBox:AddChoice( "Gut", "weapon_mu_knife_gut", LocalPlayer():GetNWString('def_knife') == "weapon_mu_knife_gut" )
		DComboBox:AddChoice( "Huntsman", "weapon_mu_knife_huntsman", LocalPlayer():GetNWString('def_knife') == "weapon_mu_knife_huntsman" )
		DComboBox:AddChoice( "Karambit", "weapon_mu_knife_karambit", LocalPlayer():GetNWString('def_knife') == "weapon_mu_knife_karambit" )
		DComboBox:AddChoice( "M9", "weapon_mu_knife_m9", LocalPlayer():GetNWString('def_knife') == "weapon_mu_knife_m9" )
		DComboBox:AddChoice( "Pickaxe", "weapon_mu_knife_pickaxe", LocalPlayer():GetNWString('def_knife') == "weapon_mu_knife_pickaxe" )
		DComboBox:AddChoice( "Tridagger", "weapon_mu_knife_tridagger", LocalPlayer():GetNWString('def_knife') == "weapon_mu_knife_tridagger" )
		DComboBox:AddChoice( "Stiletto", "weapon_mu_knife_stiletto", LocalPlayer():GetNWString('def_knife') == "weapon_mu_knife_stiletto" )
		DComboBox:AddChoice( "Jackknife", "weapon_mu_knife_gypsy", LocalPlayer():GetNWString('def_knife') == "weapon_mu_knife_gypsy" )
		DComboBox:AddChoice( "Ursus", "weapon_mu_knife_ursus", LocalPlayer():GetNWString('def_knife') == "weapon_mu_knife_ursus" )
		DComboBox:AddChoice( "Widowmaker", "weapon_mu_knife_widowmaker", LocalPlayer():GetNWString('def_knife') == "weapon_mu_knife_widowmaker" )
		
		DComboBox.OnSelect = function( panel, index, value )
			local prim, sec = panel:GetSelected()
			net.Start("ChangeTypeKnife")
			net.WriteString( sec )
			net.SendToServer()
		end
		
		
		local DBut = vgui.Create( "DButton", panel.DermaPanelTextex )
			DBut:SetPos(25, 130+30+30)
			DBut:SetSize(200,20)
			DBut:SetText("Настройка хищника")
			DBut.DoClick = function(s2)
				local DEd = vgui.Create("DFrame")
				
				DEd.Think = function()
					if DEd:IsValid() then
						gui.EnableScreenClicker(true)
					end
				end


	local r, g, b		
			r = LocalPlayer():GetNWInt("predator_mask_r")
			g = LocalPlayer():GetNWInt("predator_mask_g")
			b = LocalPlayer():GetNWInt("predator_mask_b")
					DEd:SetTitle("")
					DEd.MaskModel = 0
					DEd.VectorMe = Color(r,g,b)
					//self:SetSize(700, 500)
					DEd:SetSize( math.Clamp( 1290, 0, ScrW() ), math.Clamp( 768, 0, ScrH() ) )
					
					local pmodel = vgui.Create("DPointShopPreview", DEd)
					pmodel:SetSize( pmodel:GetParent():GetWide()*(2/3) - 10, pmodel:GetParent():GetTall() - 35 )
					pmodel:SetPos( 5, 30 )
					pmodel.RewriteModel = 'models/player/youngbloodfphands.mdl'
					pmodel.DisableOther = true
					pmodel:SetModel( Model('models/player/youngbloodfphands.mdl') )

					pmodel:SetLookAt( Vector(0,0,72/2) )
					pmodel:SetCamPos( Vector(64,0,72/2))
					--pmodel:SetLookAng( Angle(0,0,0) )

					//pmodel.Entity:SetEyeTarget( pmodel.Entity:GetPos() + Vector(200,0,64) )

					pmodel:SetAmbientLight( Color(10,15,50) )
					pmodel:SetDirectionalLight( BOX_TOP, Color(220,190,100) )

					pmodel.movefov = 10


					//BODYMAN.ClientModelPanel = pmodel

					//pmodel.Entity:SetSkin( LocalPlayer():GetSkin() )

					-- set pmodel's bodygroups
					local curgroups = pmodel.Entity:GetBodyGroups()
					//print( pmodel.Entity:GetModel() )
					//PrintTable( curgroups )
					/*
					for k,v in pairs( curgroups ) do
						local ent = pmodel.Entity
						local cur_bgid = pmodel.Entity:GetBodygroup( v.id )
						ent:SetBodygroup( v.id, cur_bgid )
					end
					*/
					DEd.MaskModel = LocalPlayer():GetNWInt("predator_mask")
					pmodel.Entity:SetBodygroup( 2, DEd.MaskModel )
								pmodel.curgroups[2] = DEd.MaskModel
					
					function pmodel.Entity:GetPlayerColor()
						return LocalPlayer():GetPlayerColor()
					end
					
					pmodel.EntAngle = 21
					pmodel.EntPos = Vector(0,0,-28)
					local vec = pmodel:GetCamPos()
					local x,y,z = vec.x,vec.y,vec.z
					pmodel:SetCamPos(Vector(25, vec.y, vec.z) )
					local _oldpaint = pmodel.Paint
					pmodel.Paint = function( s, w, h )
						draw.RoundedBox( 0, 0, 0, w, h, Color(35, 35, 35,150))
						_oldpaint( s, w, h )
					end
					
					local cpanscroll = vgui.Create("DScrollPanel", DEd)
					cpanscroll:SetSize( DEd:GetWide()*(1/3)-5,DEd:GetTall() - 35-60-150 )
					cpanscroll:SetPos( DEd:GetWide()*(2/3),30 )
					cpanscroll.Paint = function( s, w, h )
						draw.RoundedBox( 0, 0, 0, w, h, Color(35, 35, 35,150))
					end
					
					local Extra = vgui.Create("DPanel", DEd)
					Extra:SetSize( DEd:GetWide()*(1/3)-5,150 )
					Extra:SetPos( DEd:GetWide()*(2/3),DEd:GetTall() - 35-60-150+30)
					Extra.Paint = function( s, w, h )
						//draw.RoundedBox( 0, 0, 0, w, h, Color(199, 135, 35,150))
					end
										-- Color label
					//local color_label = Label( "Color( 255, 255, 255 )", Extra )
					//color_label:SetPos( 200, 20 )
					//color_label:SetSize( 130, 20 )
					//color_label:SetHighlight( true )
					//color_label:SetColor( Color( 0, 0, 0 ) )

					-- Color picker
					local color_picker = vgui.Create( "DRGBPicker", Extra )
					color_picker:SetPos( 0, 0 )
					color_picker:SetSize( 30, 150 )

					-- Color cube
					local color_cube = vgui.Create( "DColorCube", Extra )
					color_cube:SetPos( 40, 0 )
					color_cube:SetSize( 150, 150 )

					-- When the picked color is changed...
					function color_picker:OnChange( col )

						-- Get the hue of the RGB picker and the saturation and vibrance of the color cube
						local h = ColorToHSV( col )
						local _, s, v = ColorToHSV( color_cube:GetRGB() )

						-- Mix them together and update the color cube
						col = HSVToColor( h, s, v )
						color_cube:SetColor( col )

						-- Lastly, update the background color and label
						UpdateColors( col )

					end

					function color_cube:OnUserChanged( col )
						-- Update background color and label
						UpdateColors( col )
					end
			
	local camo_overlay = Material("avp_hud/camo_overlay.png", "noclamp smooth")
	local avp_hud = Material("avp_hud/avp_hud.png", "noclamp smooth")
					local DColorButton = vgui.Create( "DPanel", Extra )
					DColorButton:SetSize( (DEd:GetWide()*(1/3)-5)-40-150, 150-10 )
					DColorButton:SetPos( (DEd:GetWide()*(1/3)-5)-40-40-150, 0 )
					DColorButton.Paint = function(s,w,h)
						draw.RoundedBox( 0, 0, 0, w, h, Color(0, 0, 0,255))
					end
					local DColorButton1 = vgui.Create( "DImage", Extra )
					DColorButton1:SetSize( (DEd:GetWide()*(1/3)-5)-40-150, 150-10 )
					DColorButton1:SetPos( (DEd:GetWide()*(1/3)-5)-40-40-150, 0 )
					DColorButton1:SetMaterial( camo_overlay )	-- Path to material VMT
					DColorButton1:SetImageColor( Color( r, g, b, 148 ) )
					local DColorButton2 = vgui.Create( "DImage", Extra )
					DColorButton2:SetSize( (DEd:GetWide()*(1/3)-5)-40-150, 150-10 )
					DColorButton2:SetPos( (DEd:GetWide()*(1/3)-5)-40-40-150, 0 )
					DColorButton2:SetMaterial( avp_hud )	-- Path to material VMT
					DColorButton2:SetImageColor( Color( r, g, b, 32 ) )
					-- Updates display colors, label, and clipboard text
					function UpdateColors( col )
						DEd.VectorMe = col
						local to1 = col
						to1.a = 148
						local to2 = col
						to2.a = 32
						DColorButton1:SetImageColor( to1 )
						DColorButton2:SetImageColor( to2 )
					end
	
					local allowedbodygroups = {}
					
					for i = 3, #pmodel.Entity:GetBodyGroups() do
						local bg = pmodel.Entity:GetBodyGroups()[i]
						if bg then
							for k,v in pairs( bg ) do
								if k == "id" then
									allowedbodygroups[v] = {}
									for k2, v2 in pairs( bg["submodels"] ) do
										table.insert( allowedbodygroups[v], k2 )
									end
								end
							end	
						end
					end
					local y = 5
					
					if allowedbodygroups ~= {} then
						for k,v in pairs( allowedbodygroups ) do
							local DLabel = vgui.Create( "DLabel", cpanscroll )
							DLabel:SetPos( 5, y )
							DLabel:SetText( pmodel.Entity:GetBodygroupName( k ) )
							cpanscroll:AddItem(DLabel)
							y = y+25
							local DComboBox = vgui.Create( "DComboBox", cpanscroll )
							DComboBox:SetPos( 5, y )
							DComboBox:SetSize( 100, 20 )
							for k2,v2 in pairs( v ) do
								DComboBox:AddChoice( v2, k, pmodel.curgroups[k] == v2 )
							end
							DComboBox.OnSelect = function( panel, index, aa )
								local data, sec = panel:GetSelected()
								DEd.MaskModel = data
								pmodel.curgroups[sec] = data
								pmodel.Entity:SetBodygroup(sec, data)
							end
							y = y+25
							cpanscroll:AddItem(DComboBox)
						end
					end
					
					
					local VerTrade = vgui.Create("DButton" , DEd)
					VerTrade:SetSize( DEd:GetWide()*(1/3)-5,60 )
					VerTrade:SetPos( DEd:GetWide()*(2/3), DEd:GetTall() - 65 )
					VerTrade:SetText("")
					VerTrade.tt = 0
					VerTrade.c = Color(35, 35, 35,150)
					VerTrade.Paint = function(s , w , h)
						draw.RoundedBox(0,0,0,w,h,s.c)
						draw.SimpleText("ПРИНЯТЬ ИЗМЕНЕНИЯ", "S_Light_20", (w)/2, (h-4)/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					end		
					VerTrade.OnCursorEntered = function(s)
						s.c = Color( 85 , 125 , 37, 200)
					end
					VerTrade.OnCursorExited = function(s)
						s.c = Color(35, 35, 35,150)
						
					end
					VerTrade.DoClick = function()
						net.Start('PredatorMaskHUD')
							net.WriteVector(Vector(DEd.VectorMe.r/255,DEd.VectorMe.g/255,DEd.VectorMe.b/255))
							net.WriteUInt(DEd.MaskModel, 8)
						net.SendToServer()
						/*
						local id = PS.CacheModels[PS.ModelNow]
						
						if id then
							net.Start("PS_BodyGroupTTIntegration")
								net.WriteString(id)
								net.WriteTable(pmodel.curgroups)
							net.SendToServer()
						end
						*/
					end
					DEd.pmodel = pmodel
					DEd:Center()

				DEd.OnRemove = function(self)
					/*
					local curgroups = LocalPlayer():GetBodyGroups()
					
					local id = PS.CacheModels[self.pmodel:GetEntity():GetModel()]
					if id and LocalPlayer():PS_GetItems()[id] and LocalPlayer():PS_GetItems()[id]['Modifiers'] and LocalPlayer():PS_GetItems()[id]['Modifiers']['bodygroup'] then
						self.pmodel.curgroups = table.Copy(LocalPlayer():PS_GetItems()[id]['Modifiers']['bodygroup'])
					end
					*/
					//PrintTable(LocalPlayer():PS_GetItems()[id]['Modifiers']['bodygroup'])
					//PrintTable(self.pmodel.curgroups)
					gui.EnableScreenClicker(false)
					//PS:ToggleMenu()
				end

				DEd.Paint = function( self, w, h )
          DLib.blur.DrawPanel(w, h, s:LocalToScreen(0, 0))
					draw.RoundedBox( 0, 0, 0, w, h, Color( 35, 35, 35,200) )		
					draw.RoundedBox( 0, 0, 0, w, 25, Color( 5, 5, 5,255) )

					draw.SimpleText("Настройка хищника", "Defaultfont", 10, 2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)		

				end

			end
					y = 130+30+30+30+30
			local tabl = {}
					//PrintTable(TTS.MyTags)
		for i=1, TTS.MyTags.max do
			local DComboBox = vgui.Create( "DComboBox", panel.DermaPanelTextex )
			DComboBox:SetPos( 25, y+(30*i) )
			DComboBox:SetSize( 200, 20 )
			DComboBox.id = i
			DComboBox:SetValue( "" )
			DComboBox:AddChoice( "" )
			for id,v in pairs(TTS.MyTags.tags) do
				local obshayadata = TTS.Tags[id]
				if !obshayadata then continue end 
				local name = obshayadata['tags-beauty-text'] 
				if string.sub( id, 1, 8 ) == "private." then name = "(private) "..name end 
				
				DComboBox:AddChoice( name, id, v.Enabled == i and true or false )
			end
			table.insert(tabl, DComboBox)
		end
		local BAuttonchange = vgui.Create( "DButton", panel.DermaPanelTextex)
		BAuttonchange:SetPos( 25, y+(30*(TTS.MyTags.max+1))-5 )
		BAuttonchange:SetSize(200, 20)
		BAuttonchange:SetText("Change")
		BAuttonchange.DoClick = function(s2)
			local sen = {}
			for i,v in pairs(tabl) do
				local a,b = v:GetSelected()
				if !b then continue end
				sen[b] = v.id
			end 
			netstream.Start( "TTS::SetTags", sen )
		end
		
		
		local LabelEntry = vgui.Create( "DLabel", panel.DermaPanelTextex ) -- create the form as a child of frame
		LabelEntry:SetPos( 200+5+25, y+(30*0)+25+5+3 )
		LabelEntry:SetText( "Глобальный тег" )
		LabelEntry:SizeToContents( )

		local DComboBoxForGlob = vgui.Create( "DComboBox", panel.DermaPanelTextex )
		DComboBoxForGlob:SetPos( 200+5+25, y+(30*0)+25+20+10+5 )
		DComboBoxForGlob:SetSize( 200, 20 )
		DComboBoxForGlob.id = i
		DComboBoxForGlob:SetValue( "%какой-то тег%" )
		for id,v in pairs(TTS.MyTags.tags) do
			local obshayadata = TTS.Tags[id]
			if !obshayadata then continue end 
			local name = obshayadata['tags-beauty-text'] 
			if string.sub( id, 1, 8 ) == "private." then name = "(private) "..name end 
			
			DComboBoxForGlob:AddChoice( name, id )
		end
			
		local BAuttonchange = vgui.Create( "DButton", panel.DermaPanelTextex)
		BAuttonchange:SetPos( 25+5+200, y+(30*0)+25+20+10+5+25 )
		BAuttonchange:SetSize(200, 20)
		BAuttonchange:SetText("Change")
		BAuttonchange.DoClick = function(s2)
			local _,id = DComboBoxForGlob:GetSelected()
			if !id then return end
			netstream.Start("TTS::SetGlobalTag", id)
		end
		
		local BAuttonchange = vgui.Create( "DButton", panel.DermaPanelTextex)
		BAuttonchange:SetPos( 25+5+200, y+(30*0)+25+20+10+5+25+25 )
		BAuttonchange:SetSize(200, 20)
		BAuttonchange:SetText("Remove")
		BAuttonchange.DoClick = function(s2)
			netstream.Start("TTS::SetGlobalTag", "no")
		end
	end	
		
						
	
		
						
	

	buttonchange2.Paint = function( s2, w, h )
		draw.RoundedBox( 0, 0, 0, w-5, h-1, s2.asd )
		draw.RoundedBox( 0, w-5, 0, 5, h-1, s2.asd2 )
		draw.SimpleText("Мои настройки", "Defaultfont", 20, h/2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)	
			

	end

	buttonchange2.OnCursorEntered = function(s2) s2.s = true end
	buttonchange2.OnCursorExited = function(s2) s2.s = false end
	buttonchange2.Think = function(s2)
	
	if s2.s then
		s2.asd = Color(0,0,0,150)
		s2.asd2 = Color(colorLocalPlayer.r,colorLocalPlayer.g,colorLocalPlayer.b,150)
	else
		s2.asd = Color(0,0,0,0)
		s2.asd2 = Color(0,0,0,0)
	end
	end
	//////////////////////////

local buttonchange2 = vgui.Create( "DButton", panel.DermaPanelTextSidebar)
	buttonchange2:SetPos( 0, 40 )
	buttonchange2:SetSize(panel.DermaPanelTextSidebar:GetWide(),40)
	buttonchange2:SetText("")
	buttonchange2.selected = false
	
	buttonchange2.DoClick = function(s2)
		self.buttonmode.Moved = 2
		s2.selected = true
		panel.DermaPanelTextex:Remove()
		panel.DermaPanelTextex = vgui.Create("DFrame",panel.DermaPanelText)
		panel.DermaPanelTextex:SetPos(5, 30)
		panel.DermaPanelTextex:SetSize(panel.DermaPanelText:GetWide()-10-300, panel.DermaPanelText:GetTall()-35)
		panel.DermaPanelTextex.clr = Color(255,255,255,100)
		panel.DermaPanelTextex:SetTitle( "" )
		panel.DermaPanelTextex:SetVisible( true )
		panel.DermaPanelTextex:SetDraggable( false )
		panel.DermaPanelTextex:ShowCloseButton( false )
		panel.DermaPanelTextex.Paint = function( s, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0,200) )
			draw.RoundedBox( 0, 0, 0, w, 25, Color( 5, 5, 5,255) )
			
			draw.SimpleText("Роли", "Defaultfont", 10, 2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
			draw.SimpleText("Идет загрузка", "largeDefaultfont300", (w/2),10+(h/2), Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		local html = vgui.Create( "DHTML" , panel.DermaPanelTextex )
		html:SetPos(0, 25)
		html:SetSize(panel.DermaPanelText:GetWide()-10-300, panel.DermaPanelText:GetTall()-35-25)
		html:OpenURL("https://shaft.cc/!murder/roles")
	

	end
	buttonchange2.Paint = function( s2, w, h )
		draw.RoundedBox( 0, 0, 0, w-5, h-1, s2.asd )
		draw.RoundedBox( 0, w-5, 0, 5, h-1, s2.asd2 )
		draw.SimpleText("Описание ролей", "Defaultfont", 20, h/2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)	

	end

	buttonchange2.OnCursorEntered = function(s2) s2.s = true end
	buttonchange2.OnCursorExited = function(s2) s2.s = false end
	buttonchange2.Think = function(s2)
	
		if s2.s then
			s2.asd = Color(0,0,0,150)
			s2.asd2 = Color(colorLocalPlayer.r,colorLocalPlayer.g,colorLocalPlayer.b,150)
		else
			s2.asd = Color(0,0,0,0)
			s2.asd2 = Color(0,0,0,0)
		end
	end
local buttonchange2 = vgui.Create( "DButton", panel.DermaPanelTextSidebar)
	buttonchange2:SetPos( 0, 40+40 )
	buttonchange2:SetSize(panel.DermaPanelTextSidebar:GetWide(),40)
	buttonchange2:SetText("")
	buttonchange2.selected = false
	
	buttonchange2.DoClick = function(s2)
		self.buttonmode.Moved = 3
		s2.selected = true
		panel.DermaPanelTextex:Remove()
		panel.DermaPanelTextex = vgui.Create("DFrame",self.DermaPanelText)
		panel.DermaPanelTextex:SetPos(5, 30)
		panel.DermaPanelTextex:SetSize(self.DermaPanelText:GetWide()-10-300, self.DermaPanelText:GetTall()-35)
		self.DermaPanelTextex.clr = Color(255,255,255,100)
		self.DermaPanelTextex:SetTitle( "" )
		self.DermaPanelTextex:SetVisible( true )
		self.DermaPanelTextex:SetDraggable( false )
		self.DermaPanelTextex:ShowCloseButton( false )
		self.DermaPanelTextex.Paint = function( s, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0,200) )
			draw.RoundedBox( 0, 0, 0, w, 25, Color( 5, 5, 5,255) )
			
			draw.SimpleText("Список наказаний", "Defaultfont", 10, 2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
			draw.SimpleText("Идет загрузка", "largeDefaultfont300", (w/2),10+(h/2), Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		local html = vgui.Create( "DHTML" , self.DermaPanelTextex )
		html:SetPos(0, 25)
		html:SetSize(self.DermaPanelText:GetWide()-10-300, self.DermaPanelText:GetTall()-35-25)
		html:OpenURL("https://shaft.cc/!penalties")
	

	end
	buttonchange2.Paint = function( s2, w, h )
		draw.RoundedBox( 0, 0, 0, w-5, h-1, s2.asd )
		draw.RoundedBox( 0, w-5, 0, 5, h-1, s2.asd2 )
		draw.SimpleText("Список наказаний", "Defaultfont", 20, h/2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)	

	end

	buttonchange2.OnCursorEntered = function(s2) s2.s = true end
	buttonchange2.OnCursorExited = function(s2) s2.s = false end
	buttonchange2.Think = function(s2)
	
		if s2.s then
			s2.asd = Color(0,0,0,150)
			s2.asd2 = Color(colorLocalPlayer.r,colorLocalPlayer.g,colorLocalPlayer.b,150)
		else
			s2.asd = Color(0,0,0,0)
			s2.asd2 = Color(0,0,0,0)
		end
	end
local buttonchange2 = vgui.Create( "DButton", panel.DermaPanelTextSidebar)
	buttonchange2:SetPos( 0, 40+40+40 )
	buttonchange2:SetSize(panel.DermaPanelTextSidebar:GetWide(),40)
	buttonchange2:SetText("")
	buttonchange2.selected = false
	
	buttonchange2.DoClick = function(s2)
		self.buttonmode.Moved = 4
		s2.selected = true
		panel.DermaPanelTextex:Remove()
		panel.DermaPanelTextex = vgui.Create("DFrame",self.DermaPanelText)
		panel.DermaPanelTextex:SetPos(5, 30)
		panel.DermaPanelTextex:SetSize(self.DermaPanelText:GetWide()-10-300, self.DermaPanelText:GetTall()-35)
		self.DermaPanelTextex.clr = Color(255,255,255,100)
		self.DermaPanelTextex:SetTitle( "" )
		self.DermaPanelTextex:SetVisible( true )
		self.DermaPanelTextex:SetDraggable( false )
		self.DermaPanelTextex:ShowCloseButton( false )
		self.DermaPanelTextex.Paint = function( s, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0,200) )
			draw.RoundedBox( 0, 0, 0, w, 25, Color( 5, 5, 5,255) )
			
			draw.SimpleText("Правила", "Defaultfont", 10, 2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
			draw.SimpleText("Идет загрузка", "largeDefaultfont300", (w/2),10+(h/2), Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		local html = vgui.Create( "DHTML" , self.DermaPanelTextex )
		html:SetPos(0, 25)
		html:SetSize(self.DermaPanelText:GetWide()-10-300, self.DermaPanelText:GetTall()-35-25)
		html:OpenURL("https://shaft.cc/!rules/"..TTS.CFG.SERVER)
	

	end
	buttonchange2.Paint = function( s2, w, h )
		draw.RoundedBox( 0, 0, 0, w-5, h-1, s2.asd )
		draw.RoundedBox( 0, w-5, 0, 5, h-1, s2.asd2 )
		draw.SimpleText("Правила", "Defaultfont", 20, h/2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)	

	end

	buttonchange2.OnCursorEntered = function(s2) s2.s = true end
	buttonchange2.OnCursorExited = function(s2) s2.s = false end
	buttonchange2.Think = function(s2)
	
		if s2.s then
			s2.asd = Color(0,0,0,150)
			s2.asd2 = Color(colorLocalPlayer.r,colorLocalPlayer.g,colorLocalPlayer.b,150)
		else
			s2.asd = Color(0,0,0,0)
			s2.asd2 = Color(0,0,0,0)
		end
	end
if LocalPlayer():GetUserGroup() != "user" then
local buttonchange2 = vgui.Create( "DButton", self.DermaPanelTextSidebar)
	buttonchange2:SetPos( 0, 40+40+40+40 )
	buttonchange2:SetSize(self.DermaPanelTextSidebar:GetWide(),40)
	buttonchange2:SetText("")
	buttonchange2.selected = false
	
	buttonchange2.DoClick = function(s2)
		self.buttonmode.Moved = 5
		s2.selected = true
		self.DermaPanelTextex:Remove()
		self.DermaPanelTextex = vgui.Create("DFrame",self.DermaPanelText)
		self.DermaPanelTextex:SetPos(5, 30)
		self.DermaPanelTextex:SetSize(self.DermaPanelText:GetWide()-10-300, self.DermaPanelText:GetTall()-35)
		self.DermaPanelTextex.clr = Color(255,255,255,100)
		self.DermaPanelTextex:SetTitle( "" )
		self.DermaPanelTextex:SetVisible( true )
		self.DermaPanelTextex:SetDraggable( false )
		self.DermaPanelTextex:ShowCloseButton( false )
		
		self.DermaPanelTextex.Paint = function( s, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0,200) )
			draw.RoundedBox( 0, 0, 0, w, 25, Color( 5, 5, 5,255) )
			
			draw.SimpleText("Настройки VIP", "Defaultfont", 10, 2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)						
			draw.SimpleText("Срок действия: "..sec2Min( LocalPlayer():GetNWInt("timeleftrest") ), "Defaultfont", 10, 30, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)						
			if LocalPlayer():GetUserGroup() != "vip" then
				draw.SimpleText("Функции для VIP+", "Defaultfont", 10, 120+30+35, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)		
				if LocalPlayer():GetUserGroup() != "vip+" then	
					draw.SimpleText("Функции для VIP++", "Defaultfont", 10, 120+30+35+25+30+30, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)					
				end
			end
			
			if (LocalPlayer():GetNWInt("allowbhop.time") == 0) then
				draw.SimpleText("BHop отключен", "Defaultfont", 250+5+10, 120+30, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)	
			else
				draw.SimpleText("BHop: "..sec2Min( LocalPlayer():GetNWInt("allowbhop.time")-os.time()), "Defaultfont", 250+5+10, 120+30, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)	
			end
			
			//if 		
			//buttonchange:SetPos( 5, 120+30 )
			//buttonchange:SetSize(250 ,20)
			
			if LocalPlayer():GetNWInt('murdertype') == 0 then
				draw.SimpleText("Выбран Стандартный", "Defaultfont", 10, 80, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)						
			end
			if LocalPlayer():GetNWInt('murdertype') == 1 then
				draw.SimpleText("Выбран Бенжи", "Defaultfont", 10, 80, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)						
			end
			if LocalPlayer():GetNWInt('murdertype') == 2 then
				draw.SimpleText("Выбран класс Virus'a", "Defaultfont", 10, 80, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)						
			end
			if LocalPlayer():GetNWInt('murdertype') == 3 then
				draw.SimpleText("Выбран Убийцорожденный", "Defaultfont", 10, 80, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)						
			end
			if LocalPlayer():GetNWInt('murdertype') == 4 then
				draw.SimpleText("Выбран ситх", "Defaultfont", 10, 80, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)						
			end
			if LocalPlayer():GetNWInt('murdertype') == 5 then
				draw.SimpleText("Выбран невидимка", "Defaultfont", 10, 80, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)						
			end
			if LocalPlayer():GetNWInt('murdertype') == 6 then
				draw.SimpleText("Выбран teleport", "Defaultfont", 10, 80, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)						
			end
			if LocalPlayer():GetNWInt('murdertype') == 7 then
				draw.SimpleText("Выбран KamaPulya", "Defaultfont", 10, 80, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)						
			end	
		end
		
		local DComboBox = vgui.Create( "DComboBox", self.DermaPanelTextex )
		DComboBox:SetPos( 5, 60 )
		DComboBox:SetSize( 200, 20 )
		DComboBox:SetValue( "Выбор типа убийцы" )
		DComboBox:AddChoice( "Стандартный" )
		DComboBox:AddChoice( "Бенжи" )
		
		//if LocalPlayer():SteamID() == 'STEAM_0:0:62377801' then DComboBox:AddChoice( "Virus" ) end
		
		if LocalPlayer():GetNWBool("AddExtraFunctions") then
			DComboBox:AddChoice( "Убийцорожденный" )
			DComboBox:AddChoice( "Ситх" )
			DComboBox:AddChoice( "Невидимка" )
			DComboBox:AddChoice( "Teleport" )
			DComboBox:AddChoice( "KamaPulya" )
		end
		
		DComboBox.OnSelect = function( panel, index, value )
			net.Start("ChangeTypeMurder")
			net.WriteString( value )
			net.SendToServer()
		end
		
		local buttonchange = vgui.Create( "DButton", self.DermaPanelTextex)
		buttonchange:SetPos( 5, 120 )
		buttonchange:SetSize(250 ,20)
		buttonchange:SetText("Открыть меню редактирования статуса")
		
		buttonchange.DoClick = function(s2)
			local colorAAA = Color(250,0,0)
			local frame = vgui.Create( "DFrame" )
			frame:SetSize( 200, 180+60+30 )
			frame:Center()
			frame:MakePopup()

			local TextEntry = vgui.Create( "DTextEntry", frame ) -- create the form as a child of frame
			TextEntry:SetPos( 10, 30 )
			TextEntry:SetSize( 180, 25 )
			TextEntry:SetText( "Введите статус" )
			TextEntry.OnEnter = function( self )
				//chat.AddText( self:GetValue() )	-- print the form's text as server text
			end
			
			local fra = vgui.Create( "DPanel", frame )
			fra:SetPos( 10, 60 )
			fra:SetSize( 180, 170 )
			
			colorpicker = vgui.Create('DColorMixer', fra)
			--colorpicker:DockMargin(0, 0, 0, 60)
			colorpicker:Dock(FILL)
			colorpicker:SetWangs( false )
			colorpicker:SetPalette( false )
			colorpicker:SetAlphaBar( false )
			colorpicker.ValueChanged = function(color)
				color = colorpicker:GetColor()
				colorAAA = Color( ( color.r ), ( color.g ), ( color.b ) )
				TextEntry:SetTextColor( color )
			end
			
			
			local buttonchange = vgui.Create( "DButton", frame)
			buttonchange:SetPos( 10, 180+60 )
			buttonchange:SetSize(180, 25)
			buttonchange:SetText("Сохранить")
			buttonchange.DoClick = function(s2)
				if colorAAA.r > 150 or colorAAA.g > 150 or colorAAA.b > 150 then chat.AddText(Color(255,255,255),"Разрешено брать темные цвета") return end
				if TextEntry.textlen == 0 then chat.AddText(Color(255,255,255),"Поле не может быть пустым") return end
				net.Start("StatusVIP")
					net.WriteString( TextEntry:GetText() )
					net.WriteColor( colorAAA )
				net.SendToServer()
				chat.AddText(Color(100,255,100),"Статус установлен")
			surface.PlaySound( "garrysmod/content_downloaded.wav" )
			end
		end
		
		if LocalPlayer():GetNWBool("status") then
		
			local buttonchange = vgui.Create( "DButton", self.DermaPanelTextex)
			buttonchange:SetPos( 5+5+250, 120 )
			buttonchange:SetSize(150 ,20)
			buttonchange:SetText("Удалить статус")
			
			buttonchange.DoClick = function(s2)
				net.Start("StatusVIPre")
				net.SendToServer()
				s2:Remove()
			end
		end
		if LocalPlayer():GetUserGroup() != "vip" then
		
		local buttonchange = vgui.Create( "DButton", self.DermaPanelTextex)
		buttonchange:SetPos( 5, 120+30 )
		buttonchange:SetSize(250 ,20)
		buttonchange:SetDisabled(false)
		
		if LocalPlayer().allowbhop == nil then
			LocalPlayer().allowbhop = false
		end
		local textbhop = ""
		if LocalPlayer().allowbhop then
			textbhop = "Выключить BHOP"
		else
			textbhop = "Включить BHOP"
		end
		buttonchange:SetText(textbhop)
		buttonchange.DoClick = function(s2)
		
			local textbhop2 = ""
			if LocalPlayer().allowbhop then
				textbhop2 = "Включить BHOP"
			else
				textbhop2 = "Выключить BHOP"
			end
			s2:SetText(textbhop2)
			net.Start('BhopVIPRes')
				net.WriteBool( LocalPlayer().allowbhop )
			net.SendToServer()
		end
		
		local buttonchange = vgui.Create( "DButton", self.DermaPanelTextex)
		buttonchange:SetPos( 5, 120+30+35+25 )
		buttonchange:SetSize(250 ,20)
		buttonchange:SetText("Выбрать роль")
		buttonchange.DoClick = function(s2)
			local colorAAA = Color(250,0,0)
			local frame = vgui.Create( "DFrame" )
			frame:SetSize( 200, 150 )
			frame:Center()
			frame:SetTitle('Выбор роли')
			frame:MakePopup()
				
			local list = vgui.Create("DPanelList",frame)
			list:SetPos(5, 25)
			list:SetSize(200-20,150-25)
			list:EnableHorizontal( false ) -- Only vertical items
			list:EnableVerticalScrollbar( true ) -- Allow scrollbar if you exceed the Y axis

			function list:AddMusic(id)
				Dbut = vgui.Create( "DButton",frame)
				Dbut:SetSize(200-20,20)
				Dbut:SetPos(20,20+20)
				local name, desc, col = Totor.GetInfo(id)
				Dbut:SetText(name)
				Dbut.DoClick = function() 
					net.Start("VIPPlusRole")
					net.WriteUInt( id, 8 )
					net.SendToServer()
				end
				self:AddItem(Dbut)
			end
			list:AddMusic(SCIENTIST)
			list:AddMusic(MEDIC)
			list:AddMusic(MURDER_HELPER)
			list:AddMusic(SHERIF)
			list:AddMusic(HEADCRAB)
			list:AddMusic(DRESSIROVSHIK)
			list:AddMusic(DINARA)
			//list:AddMusic(PODRIVNIK_ROLE)
			//list:AddMusic(SAPER_ROLE)
			list:AddMusic(DED)
			list:AddMusic(ALKO)
			list:AddMusic(VOR)
			
			if LocalPlayer():GetNWBool("AddExtraFunctions") then
				list:AddMusic(HEADCRAB_BLACK)
				list:AddMusic(PRODAVEC)
				list:AddMusic(MOSHENNIK)
				list:AddMusic(CHICKEN)
				//list:AddMusic(SUCCUB)
			end
		end
		
		local buttonchange = vgui.Create( "DButton", self.DermaPanelTextex)
		buttonchange:SetPos( 5, 120+30+35+25+30 )
		buttonchange:SetSize(250 ,20)
		buttonchange:SetText("Установить тег")
		buttonchange.DoClick = function(s2)
			local colorAAA = Color(250,0,0)
			local frame = vgui.Create( "DFrame" )
			frame:SetSize( 200, 180+60+30 )
			frame:Center()
			frame:SetTitle('Установка тега')
			frame:MakePopup()
			
			
			local TextEntry = vgui.Create( "DTextEntry", frame ) -- create the form as a child of frame
			TextEntry:SetPos( 10, 30 )
			TextEntry:SetSize( 180, 25 )
			TextEntry.textlen = 0
			TextEntry:SetUpdateOnType( true )
			TextEntry.OnValueChange = function( self )
				TextEntry.textlen = utf8.len(self:GetValue())	-- print the form's text as server text
			end
			TextEntry.AllowInput = function( self, stringValue )
				if TextEntry.textlen >= 6 then
					return true
				end
			end
			
			local fra = vgui.Create( "DPanel", frame )
			fra:SetPos( 10, 60 )
			fra:SetSize( 180, 170 )
			
			colorpicker = vgui.Create('DColorMixer', fra)
			--colorpicker:DockMargin(0, 0, 0, 60)
			colorpicker:Dock(FILL)
			colorpicker:SetWangs( false )
			colorpicker:SetPalette( false )
			colorpicker:SetAlphaBar( false )
			colorpicker.ValueChanged = function(color)
				color = colorpicker:GetColor()
				colorAAA = Color( ( color.r ), ( color.g ), ( color.b ) )
				TextEntry:SetTextColor( color )
			end
			
			
			local buttonchange = vgui.Create( "DButton", frame)
			buttonchange:SetPos( 10, 180+60 )
			buttonchange:SetSize(180, 25)
			buttonchange:SetText("Сохранить")
			buttonchange.DoClick = function(s2)
				if colorAAA.r > 150 or colorAAA.g > 150 or colorAAA.b > 150 then chat.AddText(Color(255,255,255),"Разрешено брать темные цвета") return end
				if utf8.len(string.Trim(TextEntry:GetText())) == 0 then chat.AddText(Color(255,255,255),"Поле не может быть пустым") return end
				if TextEntry.textlen == 0 then chat.AddText(Color(255,255,255),"Поле не может быть пустым") return end
				if TextEntry.textlen > 6 then chat.AddText(Color(255,255,255),"Тег") return end
				net.Start("TagVIP")
					net.WriteString( TextEntry:GetText() )
					net.WriteColor( colorAAA )
				net.SendToServer()

				chat.AddText(Color(100,255,100),"Тег установлен")
				surface.PlaySound( "garrysmod/content_downloaded.wav" )
			end
			
		end
		
		
		if LocalPlayer():GetNWBool("tags") then
		
			local buttonchange = vgui.Create( "DButton", self.DermaPanelTextex)
			buttonchange:SetPos( 5+5+250, 120+30+35+25+30 )
			buttonchange:SetSize(150 ,20)
			buttonchange:SetText("Удалить тег")
			
			buttonchange.DoClick = function(s2)
				net.Start("TagVIPre")
				net.SendToServer()
				s2:Remove()
			end
		end
		
			if LocalPlayer():GetUserGroup() != "vip+" then
				local buttonchange = vgui.Create( "DButton", self.DermaPanelTextex)
				buttonchange:SetPos( 5, 120+30+35+25+30+30+30 )
				buttonchange:SetSize(250 ,20)
				buttonchange:SetText("Установить игровой ник")
				buttonchange.DoClick = function(s2)
				
					local frame = vgui.Create( "DFrame" )
					frame:SetSize( 200, 30+25+5+25+5+25+5 )
					frame:Center()
					frame:SetTitle('Уст. игр. ника')
					frame:MakePopup()
					
					
					local TextEntry = vgui.Create( "DTextEntry", frame ) -- create the form as a child of frame
					TextEntry:SetPos( 10, 30 )
					TextEntry:SetSize( 180, 25 )
					TextEntry:SetText("Ваш игровой ник")
					TextEntry.textlen = 0
					TextEntry:SetUpdateOnType( true )
					TextEntry.OnValueChange = function( self )
						TextEntry.textlen = utf8.len(self:GetValue())	-- print the form's text as server text
					end
					TextEntry.AllowInput = function( self, stringValue )
						if TextEntry.textlen >= 9 then
							return true
						end
					end
					TextEntry.OnGetFocus = function( s )
						if s:GetValue() == 'Ваш игровой ник' then 
							s:SetText("")
						end
					end
					TextEntry.OnLoseFocus = function( s )
						if s:GetValue() == '' then 
							s:SetText("Ваш игровой ник")
						end
					end
					
					local DComboBox = vgui.Create( "DComboBox", frame )
					DComboBox:SetPos( 10, 30+25+5 )
					DComboBox:SetSize( 180, 25 )
					DComboBox:SetValue( "Мужской" )
					DComboBox:AddChoice( "Женский" )
					DComboBox:AddChoice( "Мужской" )
					
					local buttonchange = vgui.Create( "DButton", frame)
					buttonchange:SetPos( 10, 30+25+5+25+5 )
					buttonchange:SetSize(180, 25)
					buttonchange:SetText("Сохранить")
					buttonchange.DoClick = function(s2)
						if utf8.len(string.Trim(TextEntry:GetText())) == 0 then chat.AddText(Color(255,255,255),"Поле не может быть пустым") return end
						if TextEntry.textlen == 0 then chat.AddText(Color(255,255,255),"Поле не может быть пустым") return end
						if TextEntry.textlen > 9 then chat.AddText(Color(255,255,255),"Больше 9-ти символов нельзя.") return end
						
						net.Start("BystNVIP")
							net.WriteString( TextEntry:GetText() )
							net.WriteString( DComboBox:GetValue() )
						net.SendToServer()
						
					end
					
				end
			
			
				if LocalPlayer():GetNWBool("bystNW") then
				
					local buttonchange = vgui.Create( "DButton", self.DermaPanelTextex)
					buttonchange:SetPos( 5+5+250, 120+30+35+25+30+30+30 )
					buttonchange:SetSize(150 ,20)
					buttonchange:SetText("Удалить  игровой ник")
					
					buttonchange.DoClick = function(s2)
						net.Start("BystNVIPre")
						net.SendToServer()
						s2:Remove()
					end
				end
				
				local buttonchange = vgui.Create( "DButton", self.DermaPanelTextex)
				buttonchange:SetPos( 5, 120+30+35+25+30+30+30+30 )
				buttonchange:SetSize(250 ,20)
				buttonchange:SetText("Форсировать ивент")
				buttonchange.DoClick = function(s2)
				
					local frame = vgui.Create( "DFrame" )
					frame:SetSize( 200, 30+5+25+5+25+5 )
					frame:Center()
					frame:SetTitle('Форс ивента')
					frame:MakePopup()
					frame.ids = -1
					
					local DComboBox = vgui.Create( "DComboBox", frame )
					DComboBox:SetPos( 10, 30 )
					DComboBox:SetSize( 180, 25 )
					DComboBox:AddChoice( "CV-47", 1)
					DComboBox:AddChoice( "Katanas", 2)
					DComboBox:AddChoice( "Crossbow", 3)
					DComboBox:AddChoice( "Crossbow hard", 4)
					DComboBox:AddChoice( "Ulika-picker", 5)
					DComboBox:AddChoice( "Katanas-hard", 6)
					if LocalPlayer():GetNWBool("AddExtraFunctions") then
						DComboBox:AddChoice( "CVP", 7)
						DComboBox:AddChoice( "Tails-Doll", 8)
					end
					DComboBox:AddChoice( "BOOM", 9)
					function DComboBox:OnSelect( index, value, data )
						frame.ids = data 
						BAuttonchange:SetDisabled(false)
					end
					
					BAuttonchange = vgui.Create( "DButton", frame)
					BAuttonchange:SetPos( 10, 30+25+5 )
					BAuttonchange:SetSize(180, 25)
					BAuttonchange:SetDisabled(true)
					BAuttonchange:SetText("Форсировать")
					BAuttonchange.DoClick = function(s2)
						net.Start("VIPPlusIvent")
						net.WriteUInt( frame.ids, 8 )
						net.SendToServer()
					end
					
				end
			end
		end
	end

	buttonchange2.Paint = function( s2, w, h )
		draw.RoundedBox( 0, 0, 0, w-5, h-1, s2.asd )
		draw.RoundedBox( 0, w-5, 0, 5, h-1, s2.asd2 )
		draw.SimpleText("Настройки VIP", "Defaultfont", 20, h/2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)	

	end

	buttonchange2.OnCursorEntered = function(s2) s2.s = true end
	buttonchange2.OnCursorExited = function(s2) s2.s = false end
	buttonchange2.Think = function(s2)
	
	if s2.s then
		s2.asd = Color(0,0,0,150)
		s2.asd2 = Color(colorLocalPlayer.r,colorLocalPlayer.g,colorLocalPlayer.b,150)
	else
		s2.asd = Color(0,0,0,0)
		s2.asd2 = Color(0,0,0,0)
	end
	end
end
	
local buttonchange = vgui.Create( "DButton", self.DermaPanelTextSidebar)
	buttonchange:SetPos( 0, self.DermaPanelTextSidebar:GetTall()-40 )
	buttonchange:SetSize(self.DermaPanelTextSidebar:GetWide(),38 + 2)
	buttonchange:SetText("")
	buttonchange.selected = false
	
	buttonchange.DoClick = function(s2)
		if LocalPlayer():Team() == 2 then
			RunConsoleCommand("mu_jointeam", 1)
		else
			RunConsoleCommand("mu_jointeam", 2)
		end
	end
	

	buttonchange.Paint = function( s2, w, h )
		draw.RoundedBox( 0, 0, 0, w-5, h-1, s2.asd )
		draw.RoundedBox( 0, w-5, 0, 5, h-1, s2.asd2 )
		draw.SimpleText(s2.trert, "Defaultfont", 20, h/2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)	

	end

	buttonchange.OnCursorEntered = function(s2) s2.s = true end
	buttonchange.OnCursorExited = function(s2) s2.s = false end
	buttonchange.Think = function(s2)
		if LocalPlayer():Team() == 2 then
			s2.trert = "В наблюдатели"
		else
			s2.trert = "В игроки"
		end
	if s2.s then
		s2.asd = Color(0,0,0,150)
		s2.asd2 = Color(colorLocalPlayer.r,colorLocalPlayer.g,colorLocalPlayer.b,150)
	else
		s2.asd = Color(0,0,0,0)
		s2.asd2 = Color(0,0,0,0)
	end
	end
end)


hook.Add("AddInfoScoreboard", "LoadInfo", function(self)
	self:AddUser('string',2)
	for _, ply in pairs(team.GetPlayers(2))do
		self:AddUser('ply',ply)
	end
	self:AddUser('string',1)
	for _, ply in pairs(team.GetPlayers(1))do
		self:AddUser('ply',ply)
	end
end)