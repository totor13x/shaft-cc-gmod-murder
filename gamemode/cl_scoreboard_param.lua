CreateClientConVar("avoid_boombox_play", "0", true, true)
CreateClientConVar("tts_avoid_boombox_play_self_only", "0", true, true)

hook.Add("TTS::Load","Load",function(panel1)
	scoreboard = panel1
	local tables_lerp = {}
	local function sidebarbuttons(data)
		data.name = data.name or ""
		local panel = scoreboard:AddPanel({
			-- FakeActivated = true,
			Text = data.name,
		})
		panel.Clicked = false
		panel.Think = function(s)
			if s.Clicked then
				s.onclick = true
				s.enabled = true
				s.LerpedColorAlphaBorders = 255 
				s.LerpedColorAlphaBlock = 255 
			else 
				s.onclick = false
				s.enabled = false
			end
		end
		panel.DoClick = function(s)
			for i,v in pairs(tables_lerp) do
				v.Clicked = false
			end
			s.Clicked = true
		end
		table.insert(tables_lerp, panel)
		return panel
	end
	
	--Text for admins
	
	local OnlineAdmins = {}
	for _, ply in pairs(player.GetAll())do
		if ply:GetUserGroup() ~= "user" and ply:GetUserGroup() ~= "vip" and ply:GetUserGroup() ~= "vip+" and ply:GetUserGroup() ~= "vip++" then
			table.insert(OnlineAdmins, ply)
		end
	end
	
	if #OnlineAdmins > 0 then
		local _ = scoreboard:AddPanel({
			vgui = "DPanel",
			tall = 30,
			type = "DownSidebar",
		})
		_.Paint = function(s,w,h)	
			draw.RoundedBox( 0, 0, 0, w, h, Color( 35, 35, 35,200) )
			draw.SimpleText("Администрация онлайн", "S_Light_20", 10, 14, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)	
		end
		
		local _ = scoreboard:AddPanel({
			vgui = "DScrollPanel",
			tall = 250,
			type = "DownSidebar",
		})
		_.Paint = function(s,w,h) end
		for i, ply in pairs(OnlineAdmins)do
			local button = scoreboard:AddPanel({
				type = "ply",
				tall = 40,
				ply = ply,
				Text = "",
				parent = _,
			})
			local a_ = button.Paint
			button.Paint = function(s,w,h)
				a_(s,w,h)
				local GroupData = serverguard.ranks:GetRank(serverguard.player:GetRank(s.Player))
				draw.SimpleText((s.Player:Nick() or "NO DATA"), "S_Light_20", 50, 10, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				draw.SimpleText(GroupData.name, "S_Light_20", 50, 26, GroupData.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
			
			local Davaus = vgui.Create( "AvatarImage", button)
			Davaus:SetPos( 0, 0 )
			Davaus:SetSize( 40, 40 )
			Davaus:SetPlayer( ply, 38 )	
			
			button:Dock( TOP )
		end
	end
	
	-- End text for admin
	
	-- Text for change TEAM
	local teambutton = scoreboard:AddPanel({
		FakeActivated = true,
		type = "DownSidebar",
	})
	
	teambutton.DoClick = function(s2)
		if LocalPlayer():Team() == 2 then
			RunConsoleCommand("mu_jointeam", 1)
		else
			RunConsoleCommand("mu_jointeam", 2)
		end
	end
	teambutton.Think = function(s2)
		if LocalPlayer():Team() == 2 then
			s2.Text = "В наблюдатели"
		else
			s2.Text = "В игроки"
		end
		s2.LerpedColor = team.GetColor(LocalPlayer():Team())
	end
	
	-- End text for change TEAM
	
	local function adduserteam(teamn) 
	for i, ply in pairs(team.GetPlayers(teamn))do
	//for i=0, 50 do
		local button = scoreboard:AddPanel({
			type = "ply",
			tall = 40,
			ply = ply,
			Text = "",
			parent = scoreboard.ContentPanel,
		})
		local text = 'PREMIUM'
		local color1 = Vector(94, 130, 158)
		local color2 = Vector(143, 217, 234)
		-- LerpSinusine
		button.textPrem = text
		button.LerpPrem = 0
		local tab = false
		local tag = ply:GetNWString("tag_id")
		if tag ~= '' then
			tab = {}
			local essence_tag = TTS.Tags:GetTag(tag)

			if essence_tag then
				for i,v in pairs(essence_tag) do
					table.insert( tab, v)
				end
				is_tag = true
			end
		end

		button.tag = tab
		button.Paint = function(s,w,h)
			local width = 0
			local width_second = 0
			if s.Player:IsPremium() then
				button.LerpPrem = LerpVector(math.abs( math.sin(CurTime() * 3) ), color1, color2)
				local color = Color(NormalizeColor(unpack(button.LerpPrem:ToTable())))
				surface.SetFont( "S_Light_20" )

				local text = s.textPrem
				width = surface.GetTextSize( text ) 
				width = width + 5
				draw.SimpleText(text, "S_Light_20", 50, 10, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
			draw.SimpleText((s.Player:Nick() or "NO DATA"), "S_Light_20", 50 + width, 10, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			-- draw.SimpleText(GroupData.name, "S_Light_20", 50, 26, GroupData.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			if s.tag then
				for i,v in pairs(s.tag) do
					local t_width = surface.GetTextSize( v.text ) 
					draw.SimpleText(v.text, "S_Light_20", 50 + width_second, 26, v.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					width_second = width_second + t_width + 1
				end
			end
		end
		
		local Davaus = vgui.Create( "AvatarImage", button)
		Davaus:SetPos( 0, 0 )
		Davaus:SetSize( 40, 40 )
		Davaus:SetPlayer( ply, 38 )	
		
		
		local MuteButton = scoreboard:AddPanel({
			Text = "",
			parent = button,
			FakeActivated = true,
			type = "",
		})
		
		local aw = (scoreboard.contentwrap and 10 or 24)
		MuteButton:SetPos( button:GetWide()-10-aw, 0 )
		MuteButton:SetSize(10,38 + 2)
		
		MuteButton.DoClick = function()
			if not IsValid(ply) then return end
			local t = GMute() 
			if not ply.SetMute then
				t[ply:SteamID()] = true
				TTS:AddNote( "Вы персонально отключили текстовый чат для "..ply:Nick(), NOTIFY_HINT, 3)
			else
				t[ply:SteamID()] = nil
				TTS:AddNote( "Вы персонально включили текстовый чат для "..ply:Nick(), NOTIFY_HINT, 3)
			end
			SMute(t)
			ply.SetMute = !ply.SetMute
		end
		
		MuteButton.Think = function(s)
			if not IsValid(ply) then
				s:Remove()
			else
				if ply.SetMute then
					s.LerpedColor = Color(232,12,41)
				else
					s.LerpedColor = Color(24,123,41)
				end
			end
		end
		
		
		local GagButton = scoreboard:AddPanel({
			Text = "",
			parent = button,
			FakeActivated = true,
			type = "",
		})
		
		local aw = (scoreboard.contentwrap and 10 or 24)
		GagButton:SetPos( button:GetWide()-aw, 0 )
		GagButton:SetSize(10,38 + 2)
		
		GagButton.DoClick = function()
			if not IsValid(ply) then return end
			local t = GGag() 
			if not ply:IsMuted() then
				t[ply:SteamID()] = true
				TTS:AddNote( "Вы персонально отключили голосовой чат для "..ply:Nick(), NOTIFY_HINT, 3)
			else
				t[ply:SteamID()] = nil
				TTS:AddNote( "Вы персонально включили голосовой чат для "..ply:Nick(), NOTIFY_HINT, 3)
			end
			SGag(t)
			ply:SetMuted(!ply:IsMuted())
		end
		
		GagButton.Think = function(s)
			if not IsValid(ply) then
				s:Remove()
			else
				if ply:IsMuted() then
					s.LerpedColor = Color(232,12,41)
				else
					s.LerpedColor = Color(24,123,41)
				end
			end
		end
		
		
		button:Dock( TOP )
	end
	end
	
--[[ CONTENT BLOCK - PLAYERS ]]--
	local tcolor = team.GetColor(2)
	local tname = team.GetName(2)
	local _ = scoreboard:AddPanel({
		vgui = "DPanel",
		tall = 30,
		parent = scoreboard.ContentPanel,
			type = "",
	})
	_.Paint = function(s,w,h)	
		draw.RoundedBox( 0, 0, 0, w, h, Color( 35, 35, 35,200) )
		draw.SimpleText(tname, "S_Bold_20", w/2, h/2, tcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)	
	end
	_:Dock( TOP )
	
	adduserteam(2) 
	
	local tcolor = team.GetColor(1)
	local tname = team.GetName(1)
	local _ = scoreboard:AddPanel({
		vgui = "DPanel",
		tall = 30,
		parent = scoreboard.ContentPanel,
			type = "",
	})
	_.Paint = function(s,w,h)	
		draw.RoundedBox( 0, 0, 0, w, h, Color( 35, 35, 35,200) )
		draw.SimpleText(tname, "S_Bold_20", w/2, h/2, tcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)	
	end
	_:Dock( TOP )
	
	adduserteam(1) 

--[[ END CONTENT BLOCK - PLAYERS ]] --

	local aa = sidebarbuttons({name = "Мои действия"})
	local aa_ = aa.DoClick
	aa.DoClick = function(s,w,h)
		aa_(s,w,h)
		
		scoreboard.ContentPanel:Clear()
		scoreboard.ContentPanel.Paint = function( s, w, h ) end
		
	if LocalPlayer():GetUserGroup() ~= "user" then
		local DPanel = vgui.Create( "DPanel", scoreboard.ContentPanel )
		DPanel:DockMargin(5,5,0,0)
		DPanel.Paint = function() end
		DPanel:Dock(TOP)
		local LabelEntry = vgui.Create( "DLabel", DPanel )
		LabelEntry:SetText( "" )
		LabelEntry:SetFont( "S_Light_20" )
		LabelEntry:SizeToContents( )
		//LabelEntry:DockMargin(5,5,600,0)	
		LabelEntry:Dock(LEFT)
		LabelEntry.Think = function(s)
			s:SetText("Ваша группа: ")
			s:SizeToContents( )
			DPanel:SizeToContents()
		end	
		local LabelEntry = vgui.Create( "DLabel", DPanel )
		LabelEntry:SetText( "" )
		LabelEntry:SetFont( "S_Light_20" )
		LabelEntry:SizeToContents( )
		-- LabelEntry:DockMargin(5,5,600,0)	
		LabelEntry:Dock(LEFT)
		LabelEntry.Think = function(s)
			local GroupData = serverguard.ranks:GetRank(serverguard.player:GetRank(LocalPlayer()))
			s:SetText(GroupData.name)
			s:SetColor(GroupData.color)
			s:SizeToContents( )
			DPanel:SizeToContents()
		end		
		local LabelEntry = vgui.Create( "DLabel", DPanel )
		LabelEntry:SetText( "" )
		LabelEntry:SetFont( "S_Light_20" )
		LabelEntry:SizeToContents( )
		-- LabelEntry:DockMargin(5,5,600,0)	
		LabelEntry:Dock(LEFT)
		LabelEntry.Think = function(s)
			s:SetText(", будет действовать "..util.sec2Min(LocalPlayer():GetNWInt("groupStart")+LocalPlayer():GetNWInt("groupLength")-os.time(), true))
			s:SizeToContents( )
			DPanel:SizeToContents()
		end			
		local LabelEntry = vgui.Create( "DLabel", DPanel )
		LabelEntry:SetText( "." )
		LabelEntry:SetFont( "S_Light_20" )
		LabelEntry:SizeToContents( )
		-- LabelEntry:DockMargin(5,5,600,0)	
		LabelEntry:Dock(LEFT)
		LabelEntry.Think = function(s)
			s:SetText(".")
			s:SizeToContents( )
			DPanel:SizeToContents()
		end			
		
	end
	if LocalPlayer():GetNWBool("serverguard_muted") then	
		local LabelEntry = vgui.Create( "DLabel", scoreboard.ContentPanel )
		LabelEntry:SetText( "" )
		LabelEntry:SetFont( "S_Light_20" )
		LabelEntry:DockMargin(5,0,0,0)	
		LabelEntry:Dock(TOP)
		LabelEntry.Think = function(s)
			local text = "Выдано навсегда."
			if LocalPlayer():GetNWInt("MuGamuteEnd") ~= 0 then
				text = util.sec2Min(LocalPlayer():GetNWInt("MuGamuteEnd")-os.time(), true, true).."."
			end
			s:SetText("У Вас блокировка текстового чата. "..text)
			s:SizeToContents( )
		end	
	end
	if LocalPlayer():GetNWBool("serverguard_gagged") then	
		local LabelEntry = vgui.Create( "DLabel", scoreboard.ContentPanel )
		LabelEntry:SetText( "" )
		LabelEntry:SetFont( "S_Light_20" )
		LabelEntry:DockMargin(5,0,0,0)	
		LabelEntry:Dock(TOP)
		LabelEntry.Think = function(s)
			local text = "Выдано навсегда."
			if LocalPlayer():GetNWInt("MuGagagEnd") ~= 0 then
				text = util.sec2Min(LocalPlayer():GetNWInt("MuGagagEnd")-os.time(), true, true).."."
			end
			s:SetText("У Вас блокировка голосового чата. "..text)
			s:SizeToContents( )
		end	
	end
		local LabelEntry = vgui.Create( "DLabel", scoreboard.ContentPanel )
		LabelEntry:SetText( "" )
		LabelEntry:SetFont( "S_Light_20" )
		LabelEntry:DockMargin(5,0,0,0)	
		LabelEntry:Dock(TOP)
		LabelEntry.Think = function(s)
			local time = (CurTime()-LocalPlayer():GetNWInt("PS::LimitCurTime"))
			
			if time < 0 then time = 0 end
			
			local limitTime = math.Round(time/5)
			local limitSend = LocalPlayer():GetNWInt("PS::LimitPoint")-limitTime //600-41
			
			if limitSend < 0 then limitSend = 0 end
			
			
			-- s:SetText("Для передачи доступно: "..PS.Config.MaxSendPoints-limitSend)
			-- //s:SetText(LocalPlayer():GetNWInt("PS::LimitTime").." | "..limitTime.." | "..PS.Config.MaxSendPoints-limitTime.." | "..LocalPlayer():GetNWInt("PS::LimitPoint")-limitTime.." | "..LocalPlayer():GetNWInt("PS::LimitTime"))
			s:SizeToContents( )
		end	
		
		
		-- local LabelEntry = vgui.Create( "DLabel", scoreboard.ContentPanel )
		-- LabelEntry:SetText( "Твой реферальный код: " .. TTS.MyData.referral_code )
		-- LabelEntry:SetFont( "S_Light_20" )
		-- LabelEntry:DockMargin(5,5,0,0)	
		-- LabelEntry:SizeToContents()			
		-- LabelEntry:Dock(TOP)
		-- local BAuttonchange = vgui.Create( "DButton", scoreboard.ContentPanel)
		-- BAuttonchange:SetText("Скопировать команду")
		-- BAuttonchange.DoClick = function(s2)
		-- 	SetClipboardText( "!referral " .. TTS.MyData.referral_code )
		-- end
		-- BAuttonchange:DockMargin(5,2,600,0)	
		-- BAuttonchange:Dock(TOP)
		-- local LabelEntry = vgui.Create( "DLabel", scoreboard.ContentPanel )
		-- LabelEntry:SetText( "Рефералу нужно написать !referral ".. TTS.MyData.referral_code ..", ему нужно иметь 16 часов минимум" )
		-- LabelEntry:SetFont( "S_Light_15" )
		-- LabelEntry:DockMargin(5,2,0,0)	
		-- LabelEntry:SizeToContents()			
		-- LabelEntry:Dock(TOP)
		
		local DermaCheckbox = vgui.Create( "DCheckBoxLabel", scoreboard.ContentPanel)
		DermaCheckbox:SetText( "Другой способ обводки игроков (тестовая)" )		
		DermaCheckbox:SetFont("S_Light_20")						
		DermaCheckbox.CommandEd = "render_outline_stencil"	
		DermaCheckbox:SetConVar( DermaCheckbox.CommandEd )	
		DermaCheckbox:SetValue( math.Clamp(GetConVarNumber( DermaCheckbox.CommandEd), 0, 1) )
		DermaCheckbox:SizeToContents()		
		DermaCheckbox:DockMargin(5,15,0,0)		
		DermaCheckbox:Dock(TOP)
		
		
		local DermaCheckbox = vgui.Create( "DCheckBoxLabel", scoreboard.ContentPanel)
		DermaCheckbox:SetText( "Активация курсора в ТАБ'е без нажатия ПКМ" )		
		DermaCheckbox:SetFont("S_Light_20")						
		DermaCheckbox.CommandEd = "scoreboard_rightclick"	
		DermaCheckbox:SetConVar( DermaCheckbox.CommandEd )	
		DermaCheckbox:SetValue( math.Clamp(GetConVarNumber( DermaCheckbox.CommandEd), 0, 1) )
		DermaCheckbox:SizeToContents()		
		DermaCheckbox:DockMargin(5,15,0,0)		
		DermaCheckbox:Dock(TOP)
		
		local DermaCheckbox = vgui.Create( "DCheckBoxLabel", scoreboard.ContentPanel)
		DermaCheckbox:SetText( "Оружие с правой руки" )		
		DermaCheckbox:SetFont("S_Light_20")						
		DermaCheckbox.CommandEd = "cl_righthand"	
		DermaCheckbox:SetConVar( DermaCheckbox.CommandEd )	
		DermaCheckbox:SetValue( math.Clamp(GetConVarNumber( DermaCheckbox.CommandEd), 0, 1) )		
		DermaCheckbox:SizeToContents()	
		DermaCheckbox:DockMargin(5,5,0,0)	
		DermaCheckbox:Dock(TOP)
		
		local DermaCheckbox = vgui.Create( "DCheckBoxLabel", scoreboard.ContentPanel)
		DermaCheckbox:SetText( "Отключить звуки бумбокса у всех (Вы также не можете включить трек)" )		
		DermaCheckbox:SetFont("S_Light_20")						
		DermaCheckbox.CommandEd = "avoid_boombox_play"	
		DermaCheckbox:SetConVar( DermaCheckbox.CommandEd )	
		DermaCheckbox:SetValue( math.Clamp(GetConVarNumber( DermaCheckbox.CommandEd), 0, 1) )		
		DermaCheckbox:SizeToContents()	
		DermaCheckbox:DockMargin(5,5,0,0)	
		DermaCheckbox:Dock(TOP)
		
		local DermaCheckbox = vgui.Create( "DCheckBoxLabel", scoreboard.ContentPanel)
		DermaCheckbox:SetText( "Отключить звуки бумбокса у всех (Вы можете включить трек) (PREMIUM)" )		
		DermaCheckbox:SetFont("S_Light_20")						
		DermaCheckbox.CommandEd = "tts_avoid_boombox_play_self_only"	
		DermaCheckbox:SetConVar( DermaCheckbox.CommandEd )	
		DermaCheckbox:SetValue( math.Clamp(GetConVarNumber( DermaCheckbox.CommandEd ), 0, 1) )		
		if not LocalPlayer():IsPremium() then
			DermaCheckbox:SetDisabled(true)
		end

		DermaCheckbox:SizeToContents()	
		DermaCheckbox:DockMargin(5,5,0,0)	
		DermaCheckbox:Dock(TOP)

		-- local DermaCheckbox = vgui.Create( "DCheckBoxLabel", scoreboard.ContentPanel)
		-- DermaCheckbox:SetText( "Отключить звуки бумбокса у всех (Вы также не можете включить трек)" )		
		-- DermaCheckbox:SetFont("S_Light_20")						
		-- DermaCheckbox.CommandEd = "avoid_boombox_play"	
		-- DermaCheckbox:SetConVar( DermaCheckbox.CommandEd )	
		-- DermaCheckbox:SetValue( math.Clamp(GetConVarNumber( DermaCheckbox.CommandEd), 0, 1) )		
		-- DermaCheckbox:SizeToContents()	
		-- DermaCheckbox:DockMargin(5,5,0,0)	
		-- DermaCheckbox:Dock(TOP)
		
		-- local DermaCheckbox = vgui.Create( "DCheckBoxLabel", scoreboard.ContentPanel)
		-- DermaCheckbox:SetText( "Отключить звуки бумбокса у всех (Вы можете включить трек) (V.I.P.)" )		
		-- DermaCheckbox:SetFont("S_Light_20")						
		-- DermaCheckbox.CommandEd = "tts_avoid_boombox_play_self_only"	
		-- DermaCheckbox:SetConVar( DermaCheckbox.CommandEd )	
		-- DermaCheckbox:SetValue( math.Clamp(GetConVarNumber( DermaCheckbox.CommandEd), 0, 1) )		
		-- if !AllowDisableSelfBoombox[LocalPlayer():GetUserGroup()] then
		-- 	DermaCheckbox:SetDisabled(true)
		-- end
		-- DermaCheckbox:SizeToContents()	
		-- DermaCheckbox:DockMargin(5,5,0,0)	
		-- DermaCheckbox:Dock(TOP)
		
		
	local LabelEntry = vgui.Create( "DLabel", scoreboard.ContentPanel )
	LabelEntry:SetText( "Выбор типа убийцы" )
	LabelEntry:SetFont( "S_Light_20" )
	LabelEntry:SizeToContents( )
	LabelEntry:DockMargin(5,15,600,0)	
	LabelEntry:Dock(TOP)
		
		local DComboBox = vgui.Create( "DComboBox", scoreboard.ContentPanel )
		DComboBox:SetValue( "Выбор типа убийцы" )
			DComboBox:AddChoice( "Тип убийцы: Стандартный","Стандартный",LocalPlayer():GetNWInt('murdertype') == 0 )
		if LocalPlayer():GetUserGroup() ~= 'user' then
			DComboBox:AddChoice( "Тип убийцы: Бенжи", "Бенжи",LocalPlayer():GetNWInt('murdertype') == 1 )
		end
			
		if LocalPlayer():GetNWBool("AddExtraFunctions") then
			DComboBox:AddChoice( "Тип убийцы: Убийцорожденный","Убийцорожденный",LocalPlayer():GetNWInt('murdertype') == 3 )
			DComboBox:AddChoice( "Тип убийцы: Ситх","Ситх",LocalPlayer():GetNWInt('murdertype') == 4 )
			DComboBox:AddChoice( "Тип убийцы: Невидимка","Невидимка",LocalPlayer():GetNWInt('murdertype') == 5 )
			DComboBox:AddChoice( "Тип убийцы: Teleport","Teleport",LocalPlayer():GetNWInt('murdertype') == 6 )
		end
		if LocalPlayer():GetUserGroup() ~= 'user' or LocalPlayer():GetNWBool("AddExtraFunctions") then
			DComboBox:AddChoice( "Тип убийцы: KamaPulya","KamaPulya",LocalPlayer():GetNWInt('murdertype') == 7 )
		end
			
		
		DComboBox.OnSelect = function( panel, index, value )
			//print(index, value, '---Sey')
			local _, data = panel:GetSelected()
			net.Start("ChangeTypeMurder")
			net.WriteString( data )
			net.SendToServer()
		end
			
		DComboBox:DockMargin(5,5,600,0)	
		DComboBox:Dock(TOP)
			
	local LabelEntry = vgui.Create( "DLabel", scoreboard.ContentPanel )
	LabelEntry:SetText( "Установка стандартного ножа" )
	LabelEntry:SetFont( "S_Light_20" )
	LabelEntry:SizeToContents( )
	LabelEntry:DockMargin(5,15,600,0)	
	LabelEntry:Dock(TOP)
	
	local DComboBox = vgui.Create( "DComboBox", scoreboard.ContentPanel )
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
		DComboBox:AddChoice( "Pickaxe", "weapon_mu_knife_pickaxe_wood", LocalPlayer():GetNWString('def_knife') == "weapon_mu_knife_pickaxe_wood" )
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
		DComboBox:DockMargin(5,5,600,0)	
		DComboBox:Dock(TOP)
		
		local LabelEntry = vgui.Create( "DLabel", scoreboard.ContentPanel )
		LabelEntry:SetText( "Установка тега для игрового чата" )
		LabelEntry:SetFont( "S_Light_20" )
		LabelEntry:SizeToContents( )
		-- LabelEntry:DockMargin(5,5,0,0)	
		LabelEntry:DockMargin(5,15,600,0)	
		LabelEntry:Dock(TOP)
		
		local DComboBox = vgui.Create( "DComboBox", scoreboard.ContentPanel )
		DComboBox.id = i
		DComboBox:SetValue( "" )
		DComboBox:AddChoice( "", "", LocalPlayer():GetNWString('tag_id') == '' )
		for _, v in pairs(TTS.Tags.Owned) do
			local name = v.text
			if string.sub( v.id, 1, 8 ) == "private." then name = "(private) " .. name end 
			DComboBox:AddChoice( name, v.id, v.id == LocalPlayer():GetNWString('tag_id') and true or false )
		end
		DComboBox:DockMargin(5,5,600,0)	
		DComboBox:Dock(TOP)
		DComboBox.OnSelect = function( panel, index, value )
			local prim, sec = panel:GetSelected()
			netstream.Start('TTS.ChangeTag', sec)
			-- net.Start("ChangeTypeKnife")
			-- net.WriteString( sec )
			-- net.SendToServer()
		end
	-- local LabelEntry = vgui.Create( "DLabel", scoreboard.ContentPanel )
	-- LabelEntry:SetText( "Установка тегов для игрового чата" )
	-- LabelEntry:SetFont( "S_Light_20" )
	-- LabelEntry:SizeToContents( )
	-- LabelEntry:DockMargin(5,15,600,0)	
	-- LabelEntry:Dock(TOP)
	-- local tabl = {}
	-- for i=1, TTS.MyTags.max do
	-- 	local DComboBox = vgui.Create( "DComboBox", scoreboard.ContentPanel )
	-- 	DComboBox.id = i
	-- 	DComboBox:SetValue( "" )
	-- 	DComboBox:AddChoice( "" )
	-- 	for id,v in pairs(TTS.MyTags.tags) do
	-- 		local obshayadata = TTS.Tags[id]
	-- 		if !obshayadata then continue end 
	-- 		local name = obshayadata['tags-beauty-text'] 
	-- 		if string.sub( id, 1, 8 ) == "private." then name = "(private) "..name end 
			
	-- 		DComboBox:AddChoice( name, id, v.Enabled == i and true or false )
	-- 	end
	-- 	DComboBox:DockMargin(5,5,600,0)	
	-- 	DComboBox:Dock(TOP)
	-- 	table.insert(tabl, DComboBox)
	-- end
	-- local BAuttonchange = vgui.Create( "DButton", scoreboard.ContentPanel)
	-- BAuttonchange:SetText("Change")
	-- BAuttonchange.DoClick = function(s2)
	-- 	local sen = {}
	-- 	for i,v in pairs(tabl) do
	-- 		local a,b = v:GetSelected()
	-- 		if !b then continue end
	-- 		sen[b] = v.id
	-- 	end 
	-- 	netstream.Start( "TTS::SetTags", sen )
	-- end
	-- BAuttonchange:DockMargin(5,5,600,0)	
	-- BAuttonchange:Dock(TOP)
		
		
	-- local LabelEntry = vgui.Create( "DLabel", scoreboard.ContentPanel )
	-- LabelEntry:SetText( "Установка тега для глобального чата" )
	-- LabelEntry:SetFont( "S_Light_20" )
	-- LabelEntry:SizeToContents( )
	-- LabelEntry:DockMargin(5,15,600,0)	
	-- LabelEntry:Dock(TOP)
	
	-- local DComboBoxForGlob = vgui.Create( "DComboBox", scoreboard.ContentPanel )
	-- DComboBoxForGlob.id = i
	-- DComboBoxForGlob:SetValue( "%какой-то тег%" )
	-- for id,v in pairs(TTS.MyTags.tags) do
	-- 	local obshayadata = TTS.Tags[id]
	-- 	if !obshayadata then continue end 
	-- 	local name = obshayadata['tags-beauty-text'] 
	-- 	if string.sub( id, 1, 8 ) == "private." then name = "(private) "..name end 
		
	-- 	DComboBoxForGlob:AddChoice( name, id )
	-- end
	-- DComboBoxForGlob:DockMargin(5,5,600,0)	
	-- DComboBoxForGlob:Dock(TOP)
		
	-- local BAuttonchange = vgui.Create( "DButton", scoreboard.ContentPanel)
	-- BAuttonchange:SetText("Change")
	-- BAuttonchange.DoClick = function(s2)
	-- 	local _,id = DComboBoxForGlob:GetSelected()
	-- 	if !id then return end
	-- 	netstream.Start("TTS::SetGlobalTag", id)
	-- end
	-- 	BAuttonchange:DockMargin(5,5,600,0)	
	-- 	BAuttonchange:Dock(TOP)
	
	-- local BAuttonchange = vgui.Create( "DButton", scoreboard.ContentPanel)
	-- BAuttonchange:SetText("Remove")
	-- BAuttonchange.DoClick = function(s2)
	-- 	netstream.Start("TTS::SetGlobalTag", "no")
	-- end
	-- BAuttonchange:DockMargin(5,5,600,0)	
	-- BAuttonchange:Dock(TOP)
	-- if serverguard.player:HasPermission(LocalPlayer(), "VIPSetIvent") then
	-- local LabelEntry = vgui.Create( "DLabel", scoreboard.ContentPanel )
	-- LabelEntry:SetText( "Функции V.I.P." )
	-- LabelEntry:SetFont( "S_Light_20" )
	-- LabelEntry:SizeToContents( )
	-- LabelEntry:DockMargin(5,15,600,0)	
	-- LabelEntry:Dock(TOP)
	
	-- local buttonchange = vgui.Create( "DButton", scoreboard.ContentPanel)
	-- buttonchange:DockMargin(5,15,600,0)	
	-- buttonchange:Dock(TOP)
	-- buttonchange:SetText("Форсировать ивент")
	-- buttonchange.DoClick = function(s2)
	
	-- 	local frame = vgui.Create( "DFrame" )
	-- 	frame:SetSize( 200, 30+5+25+5+25+5 )
	-- 	frame:Center()
	-- 	frame:SetTitle('Форс ивента')
	-- 	frame:MakePopup()
	-- 	frame.ids = -1
		
	-- 	local DComboBox = vgui.Create( "DComboBox", frame )
	-- 	DComboBox:SetPos( 10, 30 )
	-- 	DComboBox:SetSize( 180, 25 )
	-- 	DComboBox:AddChoice( "CV-47", 1)
	-- 	DComboBox:AddChoice( "Katanas", 2)
	-- 	DComboBox:AddChoice( "Crossbow", 3)
	-- 	DComboBox:AddChoice( "Crossbow hard", 4)
	-- 	DComboBox:AddChoice( "Ulika-picker", 5)
	-- 	DComboBox:AddChoice( "Katanas-hard", 6)
	-- 	if LocalPlayer():GetNWBool("AddExtraFunctions") then
	-- 		DComboBox:AddChoice( "CVP", 7)
	-- 		DComboBox:AddChoice( "Tails-Doll", 8)
	-- 	end
	-- 	DComboBox:AddChoice( "BOOM", 9)
	-- 	function DComboBox:OnSelect( index, value, data )
	-- 		frame.ids = data 
	-- 		BAuttonchange:SetDisabled(false)
	-- 	end
		
	-- 	BAuttonchange = vgui.Create( "DButton", frame)
	-- 	BAuttonchange:SetPos( 10, 30+25+5 )
	-- 	BAuttonchange:SetSize(180, 25)
	-- 	BAuttonchange:SetDisabled(true)
	-- 	BAuttonchange:SetText("Форсировать")
	-- 	BAuttonchange.DoClick = function(s2)
	-- 		net.Start("VIPPlusIvent")
	-- 		net.WriteUInt( frame.ids, 8 )
	-- 		net.SendToServer()
	-- 	end
		
	-- end
	-- end
	-- if serverguard.player:HasPermission(LocalPlayer(), "VIPSetBystanderName") then
	-- local LabelEntry = vgui.Create( "DLabel", scoreboard.ContentPanel )
	-- LabelEntry:SetText( "Функции V.I.P.+" )
	-- LabelEntry:SetFont( "S_Light_20" )
	-- LabelEntry:SizeToContents( )
	-- LabelEntry:DockMargin(5,15,600,0)	
	-- LabelEntry:Dock(TOP)
	
	-- local buttonchange = vgui.Create( "DButton", scoreboard.ContentPanel)
	-- buttonchange:SetText("Установить игровой ник")
	
	-- buttonchange:DockMargin(5,5,600,0)	
	-- buttonchange:Dock(TOP)
	-- buttonchange.DoClick = function(s2)
	
	-- 	local frame = vgui.Create( "DFrame" )
	-- 	frame:SetSize( 200, 30+25+5+25+5+25+5 )
	-- 	frame:Center()
	-- 	frame:SetTitle('Уст. игр. ника')
	-- 	frame:MakePopup()
		
		
	-- 	local TextEntry = vgui.Create( "DTextEntry", frame ) -- create the form as a child of frame
	-- 	TextEntry:SetPos( 10, 30 )
	-- 	TextEntry:SetSize( 180, 25 )
	-- 	TextEntry:SetText("Ваш игровой ник")
	-- 	TextEntry.textlen = 0
	-- 	TextEntry:SetUpdateOnType( true )
	-- 	TextEntry.OnValueChange = function( self )
	-- 		TextEntry.textlen = utf8.len(self:GetValue())	-- print the form's text as server text
	-- 	end
	-- 	TextEntry.AllowInput = function( self, stringValue )
	-- 		if TextEntry.textlen >= 8 then
	-- 			return true
	-- 		end
	-- 	end
	-- 	TextEntry.OnGetFocus = function( s )
	-- 		if s:GetValue() == 'Ваш игровой ник' then 
	-- 			s:SetText("")
	-- 		end
	-- 	end
	-- 	TextEntry.OnLoseFocus = function( s )
	-- 		if s:GetValue() == '' then 
	-- 			s:SetText("Ваш игровой ник")
	-- 		end
	-- 	end
		
	-- 	local DComboBox = vgui.Create( "DComboBox", frame )
	-- 	DComboBox:SetPos( 10, 30+25+5 )
	-- 	DComboBox:SetSize( 180, 25 )
	-- 	DComboBox:SetValue( "Мужской" )
	-- 	DComboBox:AddChoice( "Женский" )
	-- 	DComboBox:AddChoice( "Мужской" )
		
	-- 	local buttonchange = vgui.Create( "DButton", frame)
	-- 	buttonchange:SetPos( 10, 30+25+5+25+5 )
	-- 	buttonchange:SetSize(180, 25)
	-- 	buttonchange:SetText("Сохранить")
	-- 	buttonchange.DoClick = function(s2)
	-- 		if utf8.len(string.Trim(TextEntry:GetText())) == 0 then chat.AddText(Color(255,255,255),"Поле не может быть пустым") return end
	-- 		if TextEntry.textlen == 0 then chat.AddText(Color(255,255,255),"Поле не может быть пустым") return end
	-- 		if TextEntry.textlen > 9 then chat.AddText(Color(255,255,255),"Больше 8-ти символов нельзя.") return end
			
	-- 		net.Start("BystNVIP")
	-- 			net.WriteString( TextEntry:GetText() )
	-- 			net.WriteString( DComboBox:GetValue() )
	-- 		net.SendToServer()
			
	-- 	end
		
	-- end


	-- if LocalPlayer():GetNWBool("bystNW") then
	
	-- 	local buttonchange = vgui.Create( "DButton", scoreboard.ContentPanel)
	-- 	buttonchange:DockMargin(5,5,600,0)	
	-- 	buttonchange:Dock(TOP)
	-- 	buttonchange:SetText("Удалить  игровой ник")
		
	-- 	buttonchange.DoClick = function(s2)
	-- 		net.Start("BystNVIPre")
	-- 		net.SendToServer()
	-- 		s2:Remove()
	-- 	end
	-- end
	-- end
	
	
		
	end
	local aa = sidebarbuttons({name = "Описание нашего режима"})
	local aa_ = aa.DoClick
	aa.DoClick = function(s,w,h)
		aa_(s,w,h)
		
		scoreboard.ContentPanel:Clear()
		scoreboard.ContentPanel.Paint = function( s, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 35, 35, 35,200) )
			
			draw.SimpleText("Роли", "S_Bold_40", (w/2),(h/2)-30, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("Идет загрузка", "S_Light_30", (w/2),20+(h/2), Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		local html = vgui.Create( "DHTML" , scoreboard.ContentPanel )
		html:SetPos(0, 0)
		html:SetSize(scoreboard.ContentPanel:GetWide(), scoreboard.ContentPanel:GetTall())
		html:OpenURL("https://shaft.cc/!info/murder/roles")
	end
/*
	local aa = sidebarbuttons({name = "Список наказаний"})
	local aa_ = aa.DoClick
	aa.DoClick = function(s,w,h)
		aa_(s,w,h)
		
		scoreboard.ContentPanel:Clear()
		scoreboard.ContentPanel.Paint = function( s, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 35, 35, 35,200) )
			
			draw.SimpleText("Список наказаний", "S_Bold_40", (w/2),(h/2)-30, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("Идет загрузка", "S_Light_30", (w/2),20+(h/2), Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		local html = vgui.Create( "DHTML" , scoreboard.ContentPanel )
		html:SetPos(0, 0)
		html:SetSize(scoreboard.ContentPanel:GetWide(), scoreboard.ContentPanel:GetTall())
		html:OpenURL("https://shaft.cc/!penalties")
	end
	local aa = sidebarbuttons({name = "Правила сервера"})
	local aa_ = aa.DoClick
	aa.DoClick = function(s,w,h)
		aa_(s,w,h)
		
		scoreboard.ContentPanel:Clear()
		scoreboard.ContentPanel.Paint = function( s, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 35, 35, 35,200) )
			
			draw.SimpleText("Правила сервера", "S_Bold_40", (w/2),(h/2)-30, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("Идет загрузка", "S_Light_30", (w/2),20+(h/2), Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		local html = vgui.Create( "DHTML" , scoreboard.ContentPanel )
		html:SetPos(0, 0)
		html:SetSize(scoreboard.ContentPanel:GetWide(), scoreboard.ContentPanel:GetTall())
		html:OpenURL("https://shaft.cc/!rules/"..TTS.CFG.SERVER)
	end
*/

	
	local aa = sidebarbuttons({name = "Общие правила Shaft.CC"})
	local aa_ = aa.DoClick
	aa.DoClick = function(s,w,h)
		aa_(s,w,h)
		
		scoreboard.ContentPanel:Clear()
		scoreboard.ContentPanel.Paint = function( s, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 35, 35, 35,200) )
			
			draw.SimpleText("Общие правила Shaft.CC", "S_Bold_40", (w/2),(h/2)-30, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("Идет загрузка", "S_Light_30", (w/2),20+(h/2), Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		local html = vgui.Create( "DHTML" , scoreboard.ContentPanel )
		html:SetPos(0, 0)
		html:SetSize(scoreboard.ContentPanel:GetWide(), scoreboard.ContentPanel:GetTall())
		html:OpenURL("https://shaft.cc/!info/common")
	end
end)