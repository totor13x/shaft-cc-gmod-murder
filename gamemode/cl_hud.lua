surface.CreateFont('Defaultfont', { font = 'Default', size = 18, weight = 500 })
surface.CreateFont( "MersText1" , {
	font = "Tahoma",
	size = 16,
	weight = 1000,
	antialias = true,
	italic = false
})

surface.CreateFont( "MersHead1" , {
	font = "coolvetica",
	size = 24,
	weight = 500,
	antialias = true,
	italic = false
})

local HUD = {
		hud = function(ply) GAMEMODE:HUDLiDi(ply) end,
		voice = "VoicePanelLiDi",
		voicelist = window.panels,
		pickup = function(name, color) GAMEMODE:HUDWeaponPickedUpLiDi(name, color) end,
	  }
	  
function GM:HUDLoadRoles(ply)
	local sw, sh = ScrW(), ScrH()
	local nick, desc, color = Totor.GetInfo(ply:GetRole())
	local bool, id, info = EventPars(self.ForceIvent)
	
	surface.SetDrawColor(0,0,0, 255)
	surface.DrawRect(0, 0, sw, sh)
	
	if bool then
		draw.DrawText( "Ивент "..info.name, "LiDiRadial", ScrW() / 2, ScrH() / 2 - 170 , color or Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		return
	end
	
	
	draw.DrawText( "Вы "..nick, "LiDiRadial", ScrW() / 2, ScrH() / 2 - 170 , color or Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	
	local y = -100
	
	if desc then
		for i,v in pairs(desc) do
			draw.DrawText( v, "LiDiRadialSmall", ScrW() / 2, ScrH() / 2 - y , Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			y=y-20
		end
	end
end

local camo_overlay = Material("avp_hud/camo_overlay.png", "noclamp smooth")
local avp_hud = Material("avp_hud/avp_hud.png", "noclamp smooth")
local r, g, b

function GM:DrawHUDCVP(ply)	
	if !ply:GetRole(MURDER) then return end
	local ScrW, ScrH = ScrW(), ScrH()
		r = ply:GetNWInt("predator_mask_r")
		g = ply:GetNWInt("predator_mask_g")
		b = ply:GetNWInt("predator_mask_b")
	if ply:GetNWInt("predator_mask") != 0 then
		surface.SetDrawColor(Color(r, g, b, 148))
		surface.SetMaterial(camo_overlay)
		surface.DrawTexturedRect(0, 0, ScrW, ScrH)
		surface.SetDrawColor(Color(r, g, b, 32))
		surface.SetMaterial(avp_hud)
		surface.DrawTexturedRect(0, 0, ScrW, ScrH)
	end
end
	
local size = 32
local mid  = size / 2
local focus_range = 25
local distortamount = 0
local lens = Material( "effects/strider_pinch_dudv" )
local static = surface.GetTextureID("filmgrain")
local staticamount = 0
  
function GM:HUDPaint()
	local ply = LocalPlayer()
	if (ply:GetNWInt("StartRoundCurTime")-CurTime() > 0) then return self:HUDLoadRoles(ply) end
	//if self.SpawnTime and self.SpawnTime > CurTime() then return self:HUDLoadRoles(ply) end
	if !ply:Alive() and IsValid(ply:GetNWEntity("SpectateEntity")) and ply:GetNWEntity("SpectateEntity"):IsPlayer() then ply = ply:GetNWEntity("SpectateEntity") end
	if self:GetRound(1) then
		local dest = 0
		if self.TKerPenalty then
			-- dest = (math.sin(CurTime()) + 1) * 30 / 2 + 230
			dest = 254
		end
		self.ScreenDarkness = math.Clamp(math.Approach(self.ScreenDarkness or 0, dest, FrameTime() * 120), 0, 255)

		if self.ScreenDarkness > 0 then
			local sw, sh = ScrW(), ScrH()
			surface.SetDrawColor(0,0,0, self.ScreenDarkness)
			surface.DrawRect(-1, -1, sw + 2, sh + 2)
		end
	else
		self.ScreenDarkness = 0
	end
	if LocalPlayer():Alive() then
		local plypos = ply:GetPos()
		local midscreen_x = ScrW() / 2
		local midscreen_y = ScrH() / 2
		local pos, scrpos, d
		local focus_ent = nil
		local focus_d, focus_scrpos_x, focus_scrpos_y = 0, midscreen_x, midscreen_y

		-- draw icon on HUD for every button within range
		for k, but in pairs(self.buttonsTTT) do
		 if IsValid(but) and but.IsUsable then
			pos = but:GetPos()
			scrpos = pos:ToScreen()

			if (not IsOffScreen(scrpos)) and but:IsUsable() then
			   d = pos - plypos
			   d = d:Dot(d) / (but:GetUsableRange() ^ 2)
			   -- draw if this button is within range, with alpha based on distance
			   if d < 1 then
				  surface.SetDrawColor(255, 255, 255, 200 * (1 - d))
				  surface.DrawTexturedRect(scrpos.x - mid, scrpos.y - mid, size, size)

				  if d > focus_d then
					 local x = math.abs(scrpos.x - midscreen_x)
					 local y = math.abs(scrpos.y - midscreen_y)
					 if (x < focus_range and y < focus_range and
						 x < focus_scrpos_x and y < focus_scrpos_y) then

						-- avoid constantly switching focus every frame causing
						-- 2+ buttons to appear in focus, instead "stick" to one
						-- ent for a very short time to ensure consistency
						if self.focus_stick or 0 < CurTime() or but == self.focus_ent then
						   focus_ent = but
						end
					 end
				  end
			   end
			end
		 end
		if IsValid(focus_ent) then
			self.focus_ent = focus_ent
			self.focus_stick = CurTime() + 0.1

			local scrpos = focus_ent:GetPos():ToScreen()

			local sz = 16

			-- redraw in-focus version of icon
			//surface.SetTexture(tbut_focus)
			surface.SetDrawColor(255, 255, 255, 200)
			surface.DrawTexturedRect(scrpos.x - mid, scrpos.y - mid, size, size)

			surface.SetTextColor(255, 50, 50, 255)
			-- description
			surface.SetFont("default")

			local x = scrpos.x + sz + 10
			local y = scrpos.y - sz - 3
				surface.SetTextPos(x+1, y+1)
				surface.SetTextColor(25, 25, 25, 255)
			surface.DrawText(focus_ent:GetDescription())
			surface.SetTextPos(x, y)
			surface.SetTextColor(255, 50, 50, 255)
			surface.DrawText(focus_ent:GetDescription())

			y = y + 12
			surface.SetTextPos(x, y)
			if focus_ent:GetDelay() < 0 then
				surface.SetTextPos(x+1, y+1)
				surface.SetTextColor(25, 25, 25, 255)
			   surface.DrawText('Возможно использовать один раз')
			surface.SetTextColor(255, 50, 50, 255)
			surface.SetTextPos(x, y)
			   surface.DrawText('Возможно использовать один раз')
			elseif focus_ent:GetDelay() == 0 then
				surface.SetTextPos(x+1, y+1)
				surface.SetTextColor(25, 25, 25, 255)
			   surface.DrawText('Возможно использовать сейчас!')
			surface.SetTextColor(255, 50, 50, 255)
			surface.SetTextPos(x, y)
			   surface.DrawText('Возможно использовать сейчас!')
			else
				surface.SetTextPos(x+1, y+1)
				surface.SetTextColor(25, 25, 25, 255)
			   surface.DrawText('Возможно использовать через '..focus_ent:GetDelay())
			surface.SetTextColor(255, 50, 50, 255)
			surface.SetTextPos(x, y)
			   surface.DrawText('Возможно использовать через '..focus_ent:GetDelay())
			end

			y = y + 12
				surface.SetTextPos(x+1, y+1)
				surface.SetTextColor(25, 25, 25, 255)
			   surface.DrawText('[E] использовать')
			surface.SetTextColor(255, 50, 50, 255)
			surface.SetTextPos(x, y)
		   surface.DrawText('[E] использовать')
		 end
		end
	end
	if (/*EVENTS:Get('ID') != EVENT_CVP and */ply:Alive()) then
		self.IsCamNabled = false
		HUD.hud(ply)
		self:DrawRadialMenu()
		/*
	elseif (EVENTS:Get('ID') == EVENT_CVP) then
		self.IsCamNabled = false
		if LocalPlayer():Alive() then
			self:DrawHUDCVP(ply)
		else
			HUD.hud(ply)
		end
		*/
	end
	if (EVENTS:Get('ID') == EVENT_SLENDER) then
		local MySelf = LocalPlayer()
		local w,h = ScrW(), ScrH()
		local ToWatch = IsValid(MySelf:GetObserverTarget()) and MySelf:GetObserverTarget():IsPlayer() and MySelf:GetObserverTarget():Team() == TEAM_HUMENS and MySelf:GetObserverTarget() or MySelf
		
		local addstatic = 0
		
		local am = math.Clamp(ToWatch:Health()/100,0,1)
		
		if am <= 0.3 and am > 0 then
			addstatic = math.Clamp(0.5 - am,0,0.5)
		end
		
		local staticX, staticY = w/2,h/2
		
		local nodistort = false
		
		if screenblackout and screenblackout >= CurTime() then
			addstatic = 3
			nodistort = true
		end
		
		staticamount = math.Approach ( staticamount, addstatic, FrameTime()/2 )
		local adddistort = math.Rand(-0.09,0.09)*staticamount
		
		distortamount = math.Approach ( math.Clamp(distortamount,-0.09,0.09), adddistort, FrameTime()*10 )

		if staticloop then
			staticloop:PlayEx(staticamount^1.1,math.Rand(75,145))
		end

		local distortions = render.GetDXLevel() > 81
		
		if util.tobool(GetConVarNumber("slender_filmgrain")) then
			distortions = false
		end
		

		if distortions then
			if staticamount > 0 and !nodistort then
				
				lens:SetFloat("$refractamount",	distortamount)
				
				surface.SetMaterial( lens )
				surface.SetDrawColor(Color(255,255,255,1))
				surface.DrawTexturedRectRotated(staticX+math.Rand(-15,15),staticY+math.Rand(-15,15),w*math.Rand(0.8,2),h*math.Rand(0.8,2),0)//w*math.Rand(0.8,2),h*math.Rand(0.8,2)
			end
		else
			if staticamount > 0 and !nodistort then
				surface.SetTexture( static )
				surface.SetDrawColor(Color(255,255,255,staticamount * 10 ))
				for x = 0, w, 1024 do
					for y = 0, h, 512 do
						surface.DrawTexturedRect( x, y, 1024, 512 )
					end
				end
			end
		end
	
		if !LocalPlayer():GetRole(MURDER) then
			DrawBloom( 0.03, 0.75, 6, 0, 1, 1, 47/255, 196/255, 255/255 )
		end
	end
	
	//if GetConVar("deathrun_thirdperson_enabled"):GetBool() == true then
	//	local x,y = 0,0
	//	local tr = LocalPlayer():GetEyeTrace()
	//	x = tr.HitPos:ToScreen().x
	//	y = tr.HitPos:ToScreen().y

	//	DR:DrawCrosshair( x,y )
	//else
		self:DrawCrosshair( ScrW()/2, ScrH()/2 )
	//end
end

function GM:DrawCrosshair(x,y)
	local thick = XHairThickness:GetInt()
	local gap = XHairGap:GetInt()
	local size = XHairSize:GetInt()

	surface.SetDrawColor(XHairRed:GetInt(), XHairGreen:GetInt(), XHairBlue:GetInt(), XHairAlpha:GetInt())
	surface.DrawRect(x - (thick/2), y - (size + gap/2), thick, size )
	surface.DrawRect(x - (thick/2), y + (gap/2), thick, size )
	surface.DrawRect(x + (gap/2), y - (thick/2), size, thick )
	surface.DrawRect(x - (size + gap/2), y - (thick/2), size, thick )
end

net.Receive("PickingNotif", function()
	local name = net.ReadString()
	local color = net.ReadVector()

	HUD.pickup(name, color)
end)

local hide = {
	CHudHealth = true,
	CHudBattery = true,
	CHudAmmo = true,
	CHudDeathNotice = true,
	CHudSecondaryAmmo = true,
	CHudZoom = true,
	CHudCrosshair = true,
}

hook.Add("HUDShouldDraw", "disable.huds", function( name )
	if ( hide[ name ] ) then return false end
end )
	
function GM:PlayerStartVoice() end
function GM:PlayerEndVoice() end


timer.Simple(2,function()
	hook.Add("PlayerStartVoice","hud2",function( ply )
		if !IsValid(LocalPlayer()) or !LocalPlayer():IsPlayer() then return end
		if LocalPlayer() == ply && ply:GetNWBool('micon') then 
			if !aaatriiigg and !groupsAllowVoice[ply:GetUserGroup()] then
				return
			end
		end
		if IsValid(ply.vp) and ispanel(ply.vp) then
			ply.vp:Remove()
		end
		ply.vp = vgui.Create(HUD.voice,HUD.voicelist)
		if !IsValid(ply.vp) or !ispanel(ply.vp) then return end

		ply.vp:Setup(ply)
	end)
end)

hook.Add("Tick","destroy",function()
	for _,ply in pairs(player.GetAll())do
		if !ply.vp or !ispanel(ply.vp) then continue end
		if !ply:IsSpeaking() and IsValid(ply.vp) then
			ply.vp:SetDestroy(EndVoice)
		end
	end
end)


hook.Add( "InitPostEntity", "zaprostoads", function()
	net.Start("zaprostoads")
	net.SendToServer()
end )

net.Receive('BuyMagnumWindow', function()
	if IsValid(FrameBuyingMagnum) then return end
		local nick = net.ReadEntity()
		FrameBuyingMagnum = vgui.Create("DFrame")
		FrameBuyingMagnum:SetSize(200,100)
		FrameBuyingMagnum:MakePopup()
		FrameBuyingMagnum:SetTitle("")
		FrameBuyingMagnum:Center()
		FrameBuyingMagnum.Paint = function(s,w,h)
      DLib.blur.DrawPanel(w, h, s:LocalToScreen(0, 0))
			draw.RoundedBox( 0, 0, 0, w, h, Color( 35, 35, 35,200) )		
			draw.RoundedBox( 0, 0, 0, w, 25, Color( 5, 5, 5,255) )
			
			draw.SimpleText("Покупка", "Defaultfont", 10, 2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
		end
			
		local DLabel = vgui.Create( "DLabel", FrameBuyingMagnum )
		DLabel:Dock(FILL)
		DLabel:SetContentAlignment( 5 )
		local text = 'магнум'
		
		if nick:GetRole(MURDER) then
			text = 'броню'
		end
		
		DLabel:SetText( nick:GetBystanderName().." хочет купить "..text )
			
		local DPanel = vgui.Create( "DPanel", FrameBuyingMagnum )
		DPanel:Dock(BOTTOM)
		DPanel.Paint = function( ss, w, h )
		end
		
		local DermaButton1 = vgui.Create( "DButton", DPanel ) 
		DermaButton1:SetText( "" )
		DermaButton1:Dock(FILL)
		DermaButton1.Paint = function( ss, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, ss.asd)
			draw.SimpleText('Продать', 'PS_CatName', w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			
		 end
		DermaButton1.OnCursorEntered = function(s2) s2.s = true end
		DermaButton1.OnCursorExited = function(s2) s2.s = false end
		DermaButton1.Think = function(s2)
			
			if s2.s then
				s2.asd = Color(100,253,100, 150)
			else
				s2.asd = Color(100,253,100, 0)
			end
		end
		DermaButton1.DoClick = function()
			net.Start('BuyMagnumQuer')
				net.WriteBool(true)
				net.WriteEntity(nick or Entity(1))
			net.SendToServer()
			FrameBuyingMagnum:Remove()
		end
		
		local DermaButton2 = vgui.Create( "DButton", DPanel )
		DermaButton2:SetText( "" )
		DermaButton2:Dock(RIGHT)
		DermaButton2.Paint = function( ss, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, ss.asd)
			draw.SimpleText('Отказать', 'PS_CatName', w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			
		 end
		DermaButton2.OnCursorEntered = function(s2) s2.s = true end
		DermaButton2.OnCursorExited = function(s2) s2.s = false end
		DermaButton2.Think = function(s2)
			
			if s2.s then
				s2.asd = Color(253,100,100, 150)
			else
				s2.asd = Color(253,100,100, 0)
			end
		end
		DermaButton2.DoClick = function()
			net.Start('BuyMagnumQuer')
				net.WriteBool(false)
				net.WriteEntity(nick or Entity(1))
			net.SendToServer()
			FrameBuyingMagnum:Remove()
		end
end)
				
	
net.Receive("ads_panel",function(len, ply)
	if IsValid(AAFrame) then
		AAFrame:Remove()
	end
 end)