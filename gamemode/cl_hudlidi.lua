
surface.CreateFont("lidi_hud_Medium_clock", {
	font = "Default",
	size = 20,
	antialias = true,
	weight = 800
})

surface.CreateFont("lidi_hud_Small_clock", {
	font = "Default",
	size = 13,
	antialias = true,
})


surface.CreateFont("lidi_hud_Large", {
	font = "Default",
	size = 48,
	antialias = true,
	weight = 800
})

surface.CreateFont("lidi_hud_25", {
	font = "Default",
	size = 25,
	antialias = true,
	weight = 800
})

surface.CreateFont("lidi_hud_29", {
	font = "Default",
	size = 29,
	antialias = true,
	weight = 800
})

surface.CreateFont("lidi_hud_30", {
	font = "Default",
	size = 30,
	antialias = true,
	weight = 800
})

surface.CreateFont("lidi_hud_32", {
	font = "Default",
	size = 32,
	antialias = true,
	weight = 800
})

surface.CreateFont("lidi_hud_35", {
	font = "Default",
	size = 35,
	antialias = true,
	weight = 800
})

surface.CreateFont("lidi_hud_38", {
	font = "Default",
	size = 38,
	antialias = true,
	weight = 800
})

surface.CreateFont("lidi_hud_40", {
	font = "Default",
	size = 40,
	antialias = true,
	weight = 800
})

surface.CreateFont("lidi_hud_Medium", {
	font = "Default",
	size = 20,
	antialias = true,
	weight = 800
})

surface.CreateFont( "LiDiRadial" , {
	font = "Default",
	size = math.ceil(ScrW() / 34),
	weight = 500,
	antialias = true,
	italic = false
})

surface.CreateFont( "LiDiRadialBig" , {
	font = "Default",
	size = math.ceil(ScrW() / 24),
	weight = 500,
	antialias = true,
	italic = false
})

surface.CreateFont( "LiDiRadialSmall" , {
	font = "Default",
	size = math.ceil(ScrW() / 60),
	weight = 100,
	antialias = true,
	italic = false
})

surface.CreateFont("lidi_hud_Small", {
	font = "Default",
	size = 14,
	antialias = true,
	weight = 800
})


function normalize_time(typein)
	if typein == 1 then
		return tostring(os.date("%d.%m.%Y",os.time()))
	end
	if typein == 2 then
		return tostring(os.date("%H:%M",os.time()))
	end
end 

function drawTextShadow(text, font,x,y, color, alignx, aligny)
	local a = color.a
		draw.SimpleText(text, font, x+1, y+1, Color(0,0,0, a), alignx, aligny)
		draw.SimpleText(text, font, x, y, color, alignx, aligny)
end 
local last_pulse_succub = 0
local lerp_pulse_succub = 0
function GM:HUDLiDi(ply)
 local nick, desc, color = Totor.GetInfo(ply:GetRole())
 local byscol = ply:GetBystanderColor(true)

 if !color then
	color = byscol
 end
 local dy = ScrH() - 90
 	
	if LocalPlayer() == ply && (ply:GetRole(MURDER) or ply:GetRole(SCIENTIST)) then
		if ply:GetNWBool("MurderFog") then
			surface.SetDrawColor(10,10,10,50)
			surface.DrawRect(-1, -1, ScrW() + 2, ScrH() + 2)
	
		
			drawTextShadow('Убейте же кого-нибудь!', "LiDiRadial", ScrW() * 0.5, ScrH() - 140, Color(90,20,20), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		//color = Color(200, 50, 50)
			local tabl = 0
			local All = 0
			for _, ply in pairs(team.GetPlayers(2))do
				if ply:GetRole(MURDER) or ply:GetRole(MURDER_HELPER) or ply:GetRole(VOR) or ply:GetRole(DED) or ply:GetRole(DINARA) or ply:GetRole(PSYCHNAUTOR) or ply:GetRole(MOSHENNIK) or ply:GetRole(PRODAVEC) or ply:GetRole(CHICKEN) or ply:GetRole(MINER) then continue end
				All = All + 1
				if not ply:Alive() then 
					tabl = tabl + 1
				end
			end
			
		surface.SetDrawColor( color )
		surface.DrawRect( ScrW()/2-25, dy-7, 50, 27 )
		draw.SimpleText(tabl.."|"..All,"lidi_hud_Medium_clock",ScrW()/2,dy-7+12,Color(255,255,255,255),TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		
		surface.SetDrawColor( Color(255,255,255,150) )

	end	
	
	local tr = ply:GetEyeTraceNoCursor()
	if IsValid(tr.Entity) && (tr.Entity:IsPlayer() || tr.Entity:GetClass() == "prop_ragdoll") && tr.HitPos:Distance(tr.StartPos) < 500 then
	
		if EVENTS:Get('ID') == EVENT_SLENDER and tr.Entity:IsPlayer() and tr.Entity:GetRole(MURDER) then
		else
			self.LastLooked = tr.Entity
		end
		if self.LastLooked:IsPlayer() and self.LastLooked:Alive() and not self.LastLooked:GetRole(HEADCRAB) and not self.LastLooked:GetRole(HEADCRAB_BLACK) and not self.LastLooked:GetRole(CHICKEN) and not self.LastLooked:GetNWBool("hooked") then
			LocalPlayer():SetNWString("LastLooked",tr.Entity:GetNWString("SteamidOw"))
		end
					
		if self.LastLooked:IsPlayer() and (self.LastLooked:GetRole(HEADCRAB_BLACK) or self.LastLooked:GetRole(HEADCRAB) or self.LastLooked:GetRole(CHICKEN)) then
			LocalPlayer():SetNWString("LastLooked","")
			if self.LastLooked:IsPlayer() and self.LastLooked:GetNWBool("hooked") and self.LastLooked:GetNWEntity("hooked_ply"):IsValid() then
				LocalPlayer():SetNWString("LastLooked",self.LastLooked:GetNWEntity("hooked_ply"):SteamID())
			end
		end
		
		self.LookedFade = CurTime()
	end	

	
	//print(self.LootCollected)
	if LocalPlayer():GetRole(MURDER) && self.LootCollected && self.LootCollected >= 1 and LocalPlayer():Alive() then
		if IsValid(tr.Entity) && tr.Entity:GetClass() == "prop_ragdoll" && tr.HitPos:Distance(tr.StartPos) < 80 then
			if tr.Entity:GetBystanderName() != ply:GetBystanderName() || colorDif(tr.Entity:GetBystanderColor(true), ply:GetBystanderColor(true)) > 10 then 
				drawTextShadow('[E] замаскироваться (1 улика)', "LiDiRadialSmall", ScrW() / 2, ScrH() / 2 + 120, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	end
	
	if LocalPlayer():GetRole(MINER) && self.LootCollected && self.LootCollected >= 1 and LocalPlayer():Alive() and tr.HitPos:Distance(tr.StartPos) < 100 then
		drawTextShadow('[E] поставить заминированную улику (1 улика)', "LiDiRadialSmall", ScrW() / 2, ScrH() / 2 + 120, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	if LocalPlayer():GetRole(0) && self.LootCollected && self.LootCollected >= 1 and LocalPlayer():Alive()  then
		if IsValid(tr.Entity) && tr.Entity:IsPlayer() && tr.Entity:Alive() && (tr.Entity:GetRole(MOSHENNIK) or tr.Entity:GetRole(PRODAVEC)) && tr.HitPos:Distance(tr.StartPos) < 80 then
			drawTextShadow('[E] купить магнум (1 улика)', "LiDiRadialSmall", ScrW() / 2, ScrH() / 2 + 120, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
	
	if LocalPlayer():GetRole(MURDER) && self.LootCollected && self.LootCollected >= 1 and LocalPlayer():Alive()  then
		if IsValid(tr.Entity) && tr.Entity:IsPlayer() && tr.Entity:Alive() && (tr.Entity:GetRole(MOSHENNIK) or tr.Entity:GetRole(PRODAVEC)) && tr.HitPos:Distance(tr.StartPos) < 80 then
			drawTextShadow('[E] купить броню (1 улика)', "LiDiRadialSmall", ScrW() / 2, ScrH() / 2 + 120, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
	if LocalPlayer():GetRole(MURDER_HELPER) && self.LootCollected && self.LootCollected >= 1 and LocalPlayer():Alive()  then
		if IsValid(tr.Entity) && tr.Entity:IsPlayer() && tr.Entity:Alive() && (tr.Entity:GetRole(MOSHENNIK) or tr.Entity:GetRole(PRODAVEC)) && tr.HitPos:Distance(tr.StartPos) < 80 then
			drawTextShadow('[E] купить бомбу (1 улика)', "LiDiRadialSmall", ScrW() / 2, ScrH() / 2 + 120, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
	
	if LocalPlayer():GetRole(SHUT) and LocalPlayer():Alive() then
		if IsValid(tr.Entity) && tr.Entity.Alive && tr.Entity:Alive() && tr.HitPos:Distance(tr.StartPos) < 80 then
			drawTextShadow('[E] сдублировать роль', "LiDiRadialSmall", ScrW() / 2, ScrH() / 2 + 120, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
		
	if IsValid(self.LastLooked) && self.LookedFade + 2 > CurTime() then
	
		local name = self.LastLooked:GetBystanderName() or "error"
		local col = self.LastLooked:GetBystanderColor(true) 
		local seethis = true
		
		if self.LastLooked:IsPlayer() and (self.LastLooked:GetRole(HEADCRAB_BLACK) or self.LastLooked:GetRole(HEADCRAB) or self.LastLooked:GetRole(CHICKEN)) then
			seethis = false
			if self.LastLooked:IsPlayer() and self.LastLooked:GetNWBool("hooked") and self.LastLooked:GetNWEntity("hooked_ply"):IsValid()  then
				name = self.LastLooked:GetNWEntity("hooked_ply"):GetBystanderName()
				col = self.LastLooked:GetNWEntity("hooked_ply"):GetBystanderColor(true) 
				seethis = true
			end
		end
		
		if seethis then
			local ORISTATUS = ''
			if ply:GetActiveWeapon():IsValid() and ply:GetActiveWeapon():GetClass() == 'weapon_mu_mercynope' then
				ORISTATUS = " ".. self.LastLooked:Health().." hp."
			end
			col.a = (1 - (CurTime() - self.LookedFade) / 2) * 255
			drawTextShadow(name..ORISTATUS, "DermaLarge", ScrW() / 2, ScrH() / 2 + 80, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			
			if self.LastLooked:IsPlayer() then
				if LocalPlayer():hasPerm('admin') or  LocalPlayer():GetNWBool("Restrikted") then
					drawTextShadow(self.LastLooked:Nick(), "default", ScrW() / 2, (ScrH() / 2) + 105, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end		
			end
			if LocalPlayer():GetRole(SCIENTIST) and LocalPlayer():Alive() then
				local viewdead = false
				local col2 = Color(255,255,255,0)
					  col2.a = (1 - (CurTime() - self.LookedFade) / 2) * 255
					if (self.LastLooked:GetPos():Distance(tr.StartPos) < 80) then
						viewdead = true
					end
				if IsValid(self.LastLooked) && self.LastLooked:GetClass() == "prop_ragdoll" && viewdead  then
					draw.DrawText( string.ToMinutesSeconds( math.Clamp(self.LastLooked:GetNWInt("OwnerTimeDeath"), 0, 99999 ) - ROUND:GetTimer() ), "lidi_hud_Medium_clock", ScrW() / 2, ScrH() / 2 + 120, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end
		end
	end
	
	local namebys = ply:GetBystanderName()
	
	if ply:GetRole(HEADCRAB) or ply:GetRole(HEADCRAB_BLACK) then
		if ply:GetNWBool("hooked") then
			if ply:GetNWEntity("hooked_ply"):IsValid() then
				tcol = ply:GetNWEntity("hooked_ply"):GetPlayerColor(true)
				namebys = ply:GetNWEntity("hooked_ply"):GetBystanderName().." (захвачен)"
			end
		end
	end
	
	
	local tcol = table.Copy(byscol)
	local original_color = table.Copy(tcol)
	if ply:GetRole(SUCCUB) then
		tcol = table.Copy(color)
		tcol.r = lerp_pulse_succub - 1.8
		lerp_pulse_succub = tcol.r
		if lerp_pulse_succub < 1.8 then
			lerp_pulse_succub = 1.8
		end
		-- print(lerp_pulse_succub)
		if last_pulse_succub < CurTime() then
			local kills = ply:GetNWInt("MeEatSouls")
				if kills ~= 0 then
				if kills > 4 then
					kills = 4
				end
				local delay = 0.5*(5 - kills)
				last_pulse_succub = CurTime() + delay
				-- print(delay)
				lerp_pulse_succub = 255
				timer.Simple(0.5, function()
					lerp_pulse_succub = 255
				end)
			end
		end
		surface.SetDrawColor( tcol )
		byscol = Color(255,255,255)
	else
		tcol = original_color
		surface.SetDrawColor( Color(255,255,255,150) )
	end
	
	surface.DrawRect( 50, dy, 200, 16 )
	draw.SimpleText( namebys, "Default", 50+4,  dy + 16/2, byscol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	
	if LocalPlayer() == ply then
		surface.DrawRect( ScrW()/2-20-5, dy+20, 50, 27 )	
		if EVENTS:Get('ID') == EVENT_SLENDER then
			draw.SimpleText(game.GetWorld():GetDTInt( 1 ) or "0","lidi_hud_Medium_clock",ScrW()/2,dy+20+12,color,TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			local textcolor = color
			if ply:GetRole(SUCCUB) then
				textcolor = Color(255,255,255)
			end
			draw.SimpleText(self.LootCollected or "0","lidi_hud_Medium_clock",ScrW()/2,dy+20+12,textcolor,TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
	
	local curhp = math.Clamp( ply:Health(), 0, 100 )
	local curhpout = ply:Health()
	dy = dy+16
	
	if ply:GetRole(SUCCUB) then
		surface.SetDrawColor( tcol )
	else
		surface.SetDrawColor( Color(255,255,255,150) )
	end
	surface.DrawRect( 50, dy, 200, 50 )
	surface.SetDrawColor( tcol )
	surface.DrawRect( 50+(100-curhp), dy, curhp*2, 50 )
	
	if ply:GetNWBool("armormurder") then
		local triangle1 = {
			{ x = 50, y = dy },
			{ x = 50+35, y = dy+25 },
			{ x = 50, y = dy+50 },	
		}
		local triangle2 = {
			{ x = 50-35+200, y = dy+25 },
			{ x = 50+200, y = dy },
			{ x = 50+200, y = dy+50 }
		}
		surface.SetDrawColor( Color(0,0,0,150) )
		draw.NoTexture()
		surface.DrawPoly( triangle2 )
		surface.DrawPoly( triangle1 )
	end
	
	if curhpout < 1 then
		draw.SimpleText( "0", "lidi_hud_Large", 150, dy+23,  tcol , TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, tcol )
	elseif curhpout > 300 then
		draw.SimpleText( 'OVER300~', "lidi_hud_38", 150, dy+23,  Color(255,255,255,255) , TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, tcol )
	else
		draw.SimpleTextOutlined( curhpout, "lidi_hud_Large", 150, dy+23,  Color(255,255,255,255) , TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, tcol )
	end
	
	local textcolor = tcol
	if ply:GetRole(SUCCUB) then
		surface.SetDrawColor( tcol )
		textcolor = Color(255,255,255)
	else
		surface.SetDrawColor( Color(255,255,255,150) )
	end
	surface.DrawRect( ScrW()/2-35, 50-13.4, 70, 25 )
	draw.SimpleText(string.ToMinutesSeconds( math.Clamp( ROUND:GetTimer() , 0, 99999 ) ),"lidi_hud_Medium",ScrW()/2,48,textcolor,TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
	
	surface.SetDrawColor( tcol )
	
	surface.DrawRect( ScrW()/2-35, 75-13.4, 70, 30 )
	draw.SimpleText(normalize_time(2),"lidi_hud_Medium_clock",ScrW()/2,69.5,Color(255,255,255,255),TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(normalize_time(1),"lidi_hud_Small_clock",ScrW()/2,83,Color(255,255,255,255),TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	surface.SetDrawColor( Color(255,255,255,150) )
	
	if !LocalPlayer():Alive() then
		local trans = {
		   [MUTE_NONE]   = "НИКОГО",
		   [MUTE_ALIVE]    = "ЖИВЫЕ",
		   [MUTE_NOTALIVE] = "МЕРТВЫЕ",
		}
		surface.DrawRect( ScrW()/2-35, 75-13.4+30, 70, 25 )
		draw.SimpleText('В МУТЕ',"default",ScrW()/2,75-13.4+36,tcol,TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText( trans[GetCycleMute()],"default",ScrW()/2,75-13.4+35+11,tcol,TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)	
	end
	
	local textcolor = color
	if ply:GetRole(SUCCUB) then
		surface.SetDrawColor( tcol )
		textcolor = Color(255,255,255)
	else
		surface.SetDrawColor( Color(255,255,255,150) )
	end
	surface.DrawRect( ScrW()-200-50, dy-16, 200, 16 )
	draw.SimpleText(  ply:Name(), "Default", ScrW()-200-50+4,  dy-16 + 16/2, textcolor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	
	font = "lidi_hud_32"
	if ply:GetRole(MURDER) or ply:GetRole(SCIENTIST) or  ply:GetRole(MEDIC) or  ply:GetRole(HEADCRAB) or ply:GetRole(HEADCRAB_BLACK) or ply:GetRole(SUCCUB)  or ply:GetRole(DED)  or ply:GetRole(VOR)  or ply:GetRole(SHUT) or ply:GetRole(MINER) then
		font = "lidi_hud_40"
	elseif ply:GetRole(PSYCHNAUTOR)  then
		font = "lidi_hud_29"
	elseif ply:GetRole(DRESSIROVSHIK)  then
		font = "lidi_hud_25"
	end
	colorbyst = Color(255,255,255)
	if ply:GetRole(SUCCUB) then
		surface.SetDrawColor( tcol )
		textcolor = Color(255,255,255)
	else
		surface.SetDrawColor( color )
	end
	surface.DrawRect( ScrW()-200-50, dy, 200, 50 )
		
	draw.SimpleText(nick, font, ScrW()-100-50, dy+23, colorbyst, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	
	if LocalPlayer() == ply then
		local size = ScrW() * 0.08
		local x = size * 1.2

		local w = ScrW() * 0.08
		local h = ScrH() * 0.03
		surface.SetDrawColor(255,255,255,150)
		surface.DrawRect( ScrW()/2-20-5, ScrH() - 90+63-16, 50, 2 )

		local charge = self:GetFlashlightCharge()
		
		surface.SetDrawColor(color)
		
		surface.DrawRect( ScrW()/2-25, ScrH() - 90+63-16, math.Round(100*charge/4), 2 )
		surface.DrawRect( ScrW()/2+(25-math.Round(100*charge/4)), ScrH() - 90+63-16, math.Round(100*charge/4), 2 )
		surface.SetDrawColor(255,255,255,150)

		//end

	end
	if LocalPlayer() ~= ply then
		drawTextShadow("Наблюдение", "LiDiRadial", ScrW()/2, ScrH()-100, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		if ply:Alive() then
			LocalPlayer():SetPos( ply:EyePos() )
		end
	end
	
	if LocalPlayer():GetNWBool("HeChecking") then
		drawTextShadow("Вас обыскивают", "LiDiRadial", ScrW() - 20, 20, color_white, 2)
	end
	-- if TTS.UsersStatus != 0 then
	-- 	surface.SetDrawColor( tcol )
	-- 	surface.DrawRect( 50, 50-13.4, 270, 20 )
	-- 	draw.SimpleText("Статусы игроков","lidi_hud_Small",50+4,50-13.4+8, Color(255,255,255,255) ,TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	-- end
	local xa = 50-13.4
	if LocalPlayer():hasPerm('admin') or LocalPlayer():GetNWBool("Restrikted") then
		
		
		
		if rdmsPlayers == nil then
			rdmsPlayers = {}
		end
		
		local i = 0
		for _, v in pairs(rdmsPlayers) do
			i= i+1
		end
		if i != 0 then
			surface.DrawRect( ScrW()-(200+50-13.4), 50-13.4, 200, 20 )
			draw.SimpleText("РДМ-лист","deathrun_hud_Small",ScrW()-(200-4+50-13.4),50-13.4+8, Color(255,255,255,255) ,TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			
			surface.SetDrawColor( Color(255,255,255,150) )
			
			for k, v in pairs(rdmsPlayers) do
				xa = xa + 20
				surface.DrawRect( ScrW()-(200+50-13.4), xa, 200, 20 )
				draw.SimpleText(v['nick']..' ('..v['kill']..')',"deathrun_hud_Small",ScrW()-(100+50-13.4),xa+8,tcol,TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
			xa = xa + 28
		end
	end
	local spectatePlayers = {}
	
	if ply:Alive() and ply != LocalPlayer() then
	//if ply:Alive() then
		for k,v in pairs(player.GetAll()) do
			if v:GetObserverTarget() == ply then
				table.insert(spectatePlayers, v:Name())
			end
		end	
			
		if #spectatePlayers != 0 then
			surface.SetDrawColor( tcol )
			surface.DrawRect( ScrW()-(200+50-13.4), xa, 200, 20 )
			draw.SimpleText("Наблюдатели","deathrun_hud_Small",ScrW()-(200-4+50-13.4),xa+8, Color(255,255,255,255) ,TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			
			//xa = xa+8
			
			surface.SetDrawColor( Color(255,255,255,150) )
			for k, v in pairs(spectatePlayers) do
				xa = xa + 20
				surface.DrawRect( ScrW()-(200+50-13.4), xa, 200, 20 )
				draw.SimpleText(v, "deathrun_hud_Small", ScrW()-(100+50-13.4), xa+8, tcol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	end
	
	surface.SetDrawColor( Color(255,255,255,150) )
	if LocalPlayer():GetNWBool("ulx_gagged") and LocalPlayer():GetNWBool("ulx_muted") then
	surface.SetFont("deathrun_hud_Small")
	//local x = surface.GetTextSize("Вам был отключен микрофон: Остался 1 час до включения")
	//local x2 = x/2
	
		if LocalPlayer():GetNWInt('gagend') == 0 and LocalPlayer():GetNWInt('muteend') == 0 then
			surface.DrawRect( 0, 0, ScrW(), 20 )
			draw.SimpleText('Вам были отключены средства связи навсегда.',"deathrun_hud_Small",ScrW()/2,8, Color(148,0,0,255) ,TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			surface.DrawRect( 0, 0, ScrW(), 35 )
			draw.SimpleText('Вам были отключены средства связи',"deathrun_hud_Small",ScrW()/2,6, Color(148,0,0,255) ,TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			if LocalPlayer():GetNWInt('gagend') == 0 then
				draw.SimpleText('Микрофон отключен навсегда',"deathrun_hud_Small",ScrW()/2,6+10, Color(148,0,0,255) ,TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			else
				draw.SimpleText(sec2Min(LocalPlayer():GetNWInt('gagtime'))..' до включения микрофона',"deathrun_hud_Small",ScrW()/2,6+10, Color(148,0,0,255) ,TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
			
			if LocalPlayer():GetNWInt('muteend') == 0 then
				draw.SimpleText('Чат отключен навсегда',"deathrun_hud_Small",ScrW()/2,6+20, Color(148,0,0,255) ,TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			else
				draw.SimpleText(sec2Min(LocalPlayer():GetNWInt('mutetime'))..' до включения чата',"deathrun_hud_Small",ScrW()/2,6+20, Color(148,0,0,255) ,TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
elseif LocalPlayer():GetNWBool("ulx_gagged") then
	surface.SetFont("deathrun_hud_Small")
	surface.DrawRect( 0, 0, ScrW(), 20 )
		if LocalPlayer():GetNWInt('gagend') == 0 then
			draw.SimpleText('Вам был отключен микрофон навсегда, сасайти.',"deathrun_hud_Small",ScrW()/2,8, Color(148,0,0,255) ,TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText('Вам был отключен микрофон: '..sec2Min(LocalPlayer():GetNWInt('gagtime'))..' до включения',"deathrun_hud_Small",ScrW()/2,8, Color(148,0,0,255) ,TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
elseif LocalPlayer():GetNWBool("ulx_muted") then
	surface.SetFont("deathrun_hud_Small")
	//local x = surface.GetTextSize("Вам был отключен микрофон: Остался 1 час до включения")
	//local x2 = x/2
	
	surface.DrawRect( 0, 0, ScrW(), 20 )
		if LocalPlayer():GetNWInt('muteend') == 0 then
			draw.SimpleText('Вам был отключен чат навсегда.',"deathrun_hud_Small",ScrW()/2,8, Color(148,0,0,255) ,TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText('Вам был отключен чат: '..sec2Min(LocalPlayer():GetNWInt('mutetime'))..' до включения',"deathrun_hud_Small",ScrW()/2,8, Color(148,0,0,255) ,TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
end


end

function GM:HUDWeaponPickedUpLiDi( name, color )
	if IsValid(PickFrame) then
		PickFrame:Remove()
	end 

	local nick, desc, color2 = Totor.GetInfo(LocalPlayer():GetRole())
	
	 if !color2 then
		color2 = Color(0,0,0)
	 end
	PickFrame = vgui.Create("Panel", self)
	PickFrame:ParentToHUD()
	PickFrame.Alp = 150
	PickFrame.TextAlp = 255
	PickFrame.Cur = CurTime()
	PickFrame:SetPos( ScrW()-400-60, ScrH()-50 )
	PickFrame:SetSize( 200 , 25 )
	PickFrame.Paint = function(s, w, h)
		surface.SetFont( "lidi_hud_Medium" )
		
		local width, height = surface.GetTextSize( "ПОДОБРАН " )
		color2.a = s.TextAlp
		surface.SetDrawColor(Color(255,255,255,s.Alp))  
		surface.DrawRect(0,0,w,h)
		draw.SimpleText("ПОДОБРАН ", 'lidi_hud_Medium', 5, (h-1)/2, color2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText(name, 'lidi_hud_Medium', width+7, (h-1)/2, color2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	PickFrame.Think = function(s)
		if s.Cur+2.1 > CurTime() then return end
		s.Alp = s.Alp - 0.5
		s.TextAlp = s.TextAlp - 0.8
		if s.Alp == 0 then
			s:Remove()
		end
	end
end
//GAMEMODE:HUDWeaponPickedUpLiDi( "NANI?", Color(0,0,255) )
window = {}

window.panels = vgui.Create("Panel", self)
window.panels:ParentToHUD()
window.panels:SetPos( ScrW() - 250, 100 )
window.panels:SetSize( 200 , ScrH() - 200 )

PANEL = {}

AccessorFunc( PANEL, "Padding", "Padding", FORCE_NUMBER )

AccessorFunc( PANEL, "alpha", "Alphas", FORCE_NUMBER )
AccessorFunc( PANEL, "destroytime", "DestroyTime", FORCE_NUMBER )

function PANEL:Init()
	self:SetTall(28)
	self:SetWide(200)
	self.Padding = 2
	self.alpha = 255
	self.destroytime = 0.7
	self:Dock( BOTTOM )
end 

function PANEL:Setup(ply)
	self.dend = 0
	self.trigger = 0
	self.ply = ply
		
	self.ava = vgui.Create( "AvatarImage", self )
	self.ava:SetSize( 28, 28 )
	self.ava:SetPos( 0, 0 )
	self.ava:SetPlayer( ply, 28 )
end
 
function PANEL:CheckBystanderState(state)
	if IsValid(self.ply) then
		local newBystanderState = false
		local client = LocalPlayer()
		if !IsValid(client) then
			newBystanderState = true
		else
			if client:Team() == 2 && client:Alive() then
				newBystanderState = true
			else
				if self.ply:Team() == 2 && self.ply:Alive() then
					newBystanderState = true
				end
			end
		end

		if self.Bystander != newBystanderState then
			self:SetBystanderState(newBystanderState)
		end
		if newBystanderState then
			local col = self.ply:GetBystanderColor(true)
			if col != self.PrevColor then
				self.Color = col
			end
			self.PrevColor = col
		end
	end
end

function PANEL:SetBystanderState(state)
	self.Color = self.ply:GetBystanderColor(true)

	self.Bystander = state
	if state then
		self.plyname = self.ply:GetBystanderName()
		self.Color = color
		self.Paddinglol = self.Padding*2
		self.ava:SetVisible(false)
	else			
		self.plyname = self.ply:Nick() 
		self.Paddinglol = self.Padding*2+32
		self.Color = team.GetColor(self.ply:Team())
		self.ava:SetVisible(true)
	end
end

function PANEL:Paint(w,h)
	if !self.ply then return end
	 vv = 100
	if not IsValid(self.ply) then return end
	surface.SetDrawColor(self.Color)
	local zz = 0
	if !self.Bystander then
		zz = 28
	end
	surface.DrawRect(zz,0,w,h)
	if (LocalPlayer():hasPerm('admin') or LocalPlayer():GetNWBool("Restrikted")) and self.ply:Alive()  then
		if self.ply:GetNWBool('micon') and groupsAllowVoice[LocalPlayer():GetUserGroup()] then
			draw.SimpleText(self.plyname.." "..self.ply:Nick().." ".."(SILENT)","lidi_hud_Medium",self.Paddinglol,h/2 -1,Color(255,255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
		else
			draw.SimpleText(self.plyname.." "..self.ply:Nick(),"lidi_hud_Medium",self.Paddinglol,h/2 -1,Color(255,255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
		end
	else
		if self.ply:GetNWBool('micon') and groupsAllowVoice[LocalPlayer():GetUserGroup()] then
			draw.SimpleText(self.plyname.." ".."(SILENT)","lidi_hud_Medium",self.Paddinglol,h/2 -1,Color(255,255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
		else		
			draw.SimpleText(self.plyname,"lidi_hud_Medium",self.Paddinglol,h/2 -1,Color(255,255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
		end
	end

end

function PANEL:SetDestroy(func)
	if self.trigger != 1 then
		self.dend = CurTime()+self.destroytime
		self.trigger = 1
	end
end
function PANEL:UnSetDestroy()
	self:SetAlpha(self.alpha)
	self.dend = 0
end

function PANEL:Think()
	self:CheckBystanderState()
	if self.dend == nil then return end
	if self.dend == 0 then 
		self:SetAlpha(self.alpha)
		self.ava:SetAlpha(self.alpha)
		return
	end
	self:SetAlpha((self.alpha/(self.destroytime*100))*(math.Round(self.dend-CurTime(),2)*100))
	
	self.ava:SetAlpha(math.min((self.alpha/(self.destroytime*100))*(math.Round(self.dend-CurTime(),2)*100)+50,255))
	
	if self.dend < CurTime() then
		self.ava:Remove()
		self:Remove() 
	end
end

vgui.Register("VoicePanelLiDi",PANEL,"Panel")
	