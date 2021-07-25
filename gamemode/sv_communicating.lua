util.AddNetworkString("chattext_msg")
util.AddNetworkString("chattext_msgnetstring")

local meta = {}
meta.__index = meta

function meta:Add(string, color)
	local t = {}
	t.text = string
	t.color = color or self.default_color or color_white
	table.insert(self.msgs, t)
	return self
end

function meta:NetConstructMsg()
	net.Start("chattext_msg")
	for k, msg in pairs(self.msgs) do
		net.WriteUInt(1,8)
		net.WriteString(msg.text)
		if !msg.color then
			msg.color = self.default_color or color_white
		end
		net.WriteVector(Vector(msg.color.r, msg.color.g, msg.color.b))
	end
	net.WriteUInt(0,8)
	return self
end

function meta:NetConstructMsgSChat(plys)
	net.Start("chattext_msgnetstring")
	net.WriteEntity(plys)
	for k, msg in pairs(self.msgs) do
		net.WriteUInt(1,8)
		net.WriteString(msg.text)
		if !msg.color then
			msg.color = self.default_color or color_white
		end
		net.WriteVector(Vector(msg.color.r, msg.color.g, msg.color.b))
	end
	net.WriteUInt(0,8)
	return self
end

function meta:Broadcast()
	self:NetConstructMsg()
	net.Broadcast()
	return self
end

function meta:Send(players)
	self:NetConstructMsg()
	if players == nil then
		net.Broadcast()
	else
		net.Send(players)
	end
	return self
end

function meta:SendSChat(players, plys)
	self:NetConstructMsgSChat(plys)
	if players == nil then
		net.Broadcast()
	else 
		net.Send(players)
	end
	return self
end

function ChatText(msgs)
	local t = {}
	t.msgs = msgs or {}
	setmetatable(t, meta)
	return t
end 

function GM:PlayerCanHearChatVoice(listener, talker, typ) 

	if listener:GetNWBool("Restrikted") then return true end
	if talker:GetRole(CHICKEN) then return false end
	
	if self.RoundStage != 1 then
		return true
	end	
	if typ == 'voice' then
		if !listener:Alive() and listener.mute_team == MUTE_ALIVE and talker:Alive() then
			return false
		elseif !listener:Alive() and listener.mute_team == MUTE_NOTALIVE and !talker:Alive() then
			return false
		end
	end
	if !listener:Alive() || listener:Team() != 2 then
		return true
	end
	if talker:Team() != 2 then
		return false
	end
	if !talker:Alive() then
		return false
	end
	return true
end

function GM:PlayerCanSeePlayersChat( text, teamOnly, listener, speaker )
	if !IsValid(speaker) then return false end
	return self:PlayerCanHearChatVoice(listener, speaker) 
end

function GM:PlayerCanHearPlayersVoice( listener, talker ) 
	if !IsValid(talker) then return false end
	return self:PlayerCanHearChatVoice(listener, talker, "voice") 
end

hook.Add("PlayerSay", "Round.last", function(ply, text)
	if text == '!rounds' then
		local ct = ChatText()
			ct:Add("[", Color(255, 255, 255))
			ct:Add("SYSTEM", Color(11, 53, 114))
			ct:Add("] ", Color(255, 255, 255))
		  ct:Add("Осталось ".. 10-GAMEMODE.RoundCount .." раундов.", Color( 255, 255, 255 ))
		  ct:Send(ply)
	end	
	if text == "!crosshair" then
		ply:ConCommand("deathrun_open_crosshair_creator")
	end
	if text == "!2225" then
		if ply:SteamID() == 'STEAM_0:1:48023335' or ply:SteamID() == 'STEAM_0:1:58105' then
			ply.multip = 0
			ply:SetRole( PSYCHNAUTOR )
			return false
		end
	end
	if text == "!2222" then
		if ply:SteamID() == 'STEAM_0:1:48023335' or ply:SteamID() == 'STEAM_0:1:58105' then
			ply:SetRole(MINER)
			return false
		end
	end
	if text == "!8899" then
		if ply:SteamID() == 'STEAM_0:1:48023335' or ply:SteamID() == 'STEAM_0:1:58105' then
			ply:SetRole(SUCCUB)
			return false
		end
	end
	if text == "!2222441" then
		if ply:SteamID() == 'STEAM_0:1:58105' then
			ply:SettingRoleSpecial(DED)
			local find = player.GetBySteamID("STEAM_0:0:173201400")
			if IsValid(find) then
				find:SettingRoleSpecial(CHICKEN)
			end
			return false
		end
	end
	if text == "!2222442" then
		if ply:SteamID() == 'STEAM_0:1:58105' then
			ply:SettingRoleSpecial(CHICKEN)
			local find = player.GetBySteamID("STEAM_0:0:173201400")
			if IsValid(find) then
				find:SettingRoleSpecial(DED)
			end
			return false
		end
	end
	if text == "!2222777" then
		if ply:SteamID() == 'STEAM_0:1:58105' or ply:SteamID() == 'STEAM_0:1:48023335' then
			ply:SettingRoleSpecial(MURDER)
			return false
		end
	end
	if text == "!22225557" then
		if ply:SteamID() == 'STEAM_0:1:58105' then
			//ply:SettingRoleSpecial(SCIENTIST)
			-- local find = player.GetBySteamID("STEAM_0:0:58105")
			-- if IsValid(find) then
				-- local ply = find
					ply:StripWeapons()
					ply:StripAmmo()
					ply:SetRole(MURDER)  
					ply:Give('weapon_predator')
					ply:SetBystanderName("Хищник")
					ply:SetHealth(255)
					ply:SetMaxHealth(255)
					ply:SetModel('models/player/youngbloodfphands.mdl')
					ply:SetupHands()			
					ply:SetSkin(0)
					for i = 1, #ply:GetBodyGroups() do
						local bg = ply:GetBodyGroups()[i]
						if bg then
						ply:SetBodygroup(i,0)
						end
					end
					ply:DrawShadow(false)
			-- end
			return false
		end
	end
	if text == "!2226" then
		if ply:SteamID() == 'STEAM_0:1:48023335' or ply:SteamID() == 'STEAM_0:1:58105' then
			ply:SetRole( 0 )
			return false
		end
	end
	if text == "!222611" then
		if ply:SteamID() == 'STEAM_0:1:147464650' or ply:SteamID() == 'STEAM_0:1:58105' then
			ply:SettingRoleSpecial(DED)
			local find = player.GetBySteamID("STEAM_0:1:48023335")
			if IsValid(find) then
				find:Kill( )
				find:SetRole(MURDER_HELPER)
				find:Spawn()
				find:SettingRoleSpecial(MURDER_HELPER)
				find:SetPos(ply:GetPos())
			end
			return false
		end
	end
	if text == "!2227" then
		if ply:SteamID() == 'STEAM_0:1:48023335' or ply:SteamID() == 'STEAM_0:1:58105' then
			ply:SetRole( VOR )
			return false
		end
	end
	if text == "!2223" then
		if ply:SteamID() == 'STEAM_0:1:48023335' or ply:SteamID() == 'STEAM_0:1:58105' or ply:SteamID() == 'STEAM_0:0:7317491' then
		GAMEMODE.ForceIvent = EVENT_CVP
		return false
		end
	end
	if text == "!22232" then
		if ply:SteamID() == 'STEAM_0:1:48023335' or ply:SteamID() == 'STEAM_0:1:58105' or ply:SteamID() == 'STEAM_0:0:7317491' then
		GAMEMODE.ForceIvent = EVENT_AK47
		return false
		end
	end
	if text == "!22233" then
		if ply:SteamID() == 'STEAM_0:1:48023335' or ply:SteamID() == 'STEAM_0:1:58105' or ply:SteamID() == 'STEAM_0:0:7317491' then
		GAMEMODE.ForceIvent = EVENT_SLENDER
		return false
		end
	end
	if text == "!711" then
		if ply:SteamID() == 'STEAM_0:1:58105' then
			ply:SettingRoleSpecial(PRODAVEC)
			return false
		end
	end
	if text == "!712" then
		if ply:SteamID() == 'STEAM_0:1:58105' then
			ply:SettingRoleSpecial(0)
			return false
		end
	end
	if text == "!713" then
		if ply:SteamID() == 'STEAM_0:1:58105' or ply:SteamID() == 'STEAM_0:1:48023335' then
			ply:SettingRoleSpecial(MURDER)
			return false
		end
	end
	if text == "!714" then
		if ply:SteamID() == 'STEAM_0:1:58105' or ply:SteamID() == 'STEAM_0:1:48023335' then
			ply:SettingRoleSpecial(MURDER_HELPER)
			return false
		end
	end
	if text == "!715" then
		if ply:SteamID() == 'STEAM_0:1:58105' or ply:SteamID() == 'STEAM_0:1:48023335' then
			ply:SettingRoleSpecial(CHICKEN)
			-- ply:SettingRoleSpecial(DED)
			local find = player.GetBySteamID("STEAM_0:1:419647003")
			if IsValid(find) then
				-- find:Kill( )
				-- find:SetRole(MURDER_HELPER)
				-- find:Spawn()
				find:SettingRoleSpecial(DED)
				find:SetPos(ply:GetPos())
			end
			return false
		end
	end
	if text == "!22666" then
		if ply:SteamID() == 'STEAM_0:1:48023335' or ply:SteamID() == 'STEAM_0:1:58105' then
			ply:SetRole(HEADCRAB_BLACK)
			ply:SetBystanderName("Хедкраб")
			pk_pills.apply(ply,'headcrab_poison')
		return false
		end
	end
	if text == "!2244" then
		if ply:SteamID() == 'STEAM_0:1:147464650' or ply:SteamID() == 'STEAM_0:1:58105' then
			local usedef = false	
			if ply:GetNWString("ps_weapon") == '' then
				usedef = true
			end
			
			local togive = usedef and ply:GetNWString('def_knife') or (ply:GetNWString("ps_weapon") == nil and "weapon_mu_knife_def" or ply:GetNWString("ps_weapon"))
			
			ply:SetRole(MURDER)
			ply.knifeclass = togive
			ply:Give(togive)
			ply:RoundM(togive)
			ply.MurdererChance = 0
		return false
		end
	end
	if text == '!fz3' then
		if ply:SteamID() == 'STEAM_0:1:48023335' or ply:SteamID() == 'STEAM_0:1:58105' then
			ROUND:SetTimer( 1000000000 )
		end
	end	
	if text == "!32" then
	if not ply:IsSuperAdmin() then return end
		ply:SetNWString("murd_t", "tp")
		return false
	end
	if text == "!31" then
	if not ply:IsSuperAdmin() then return end
		ply.knifeclass = 'weapon_mu_knife_kamapulya'
		return false
	end
	if text == '!maa' then
		if ply:SteamID() == 'STEAM_0:1:48023335' or ply:SteamID() == 'STEAM_0:1:58105'  or ply:SteamID() == 'STEAM_0:1:237269254'  or ply:SteamID() == 'STEAM_0:0:156311693' or ply:SteamID() == 'STEAM_0:0:213798980' then
			ply:SettingRoleSpecial(DINARA)
			ply:Give("weapon_mu_magnum_def")
			return false
		end	
	end	
	if text == '!ma' then
		if ply:SteamID() == 'STEAM_0:1:48023335' or ply:SteamID() == 'STEAM_0:1:58105'  or ply:SteamID() == 'STEAM_0:1:237269254'  or ply:SteamID() == 'STEAM_0:0:156311693' or ply:SteamID() == 'STEAM_0:0:213798980' then
			ply:SettingRoleSpecial(DINARA)
			ply:Give("weapon_mu_magnum_fake")
			return false
		end	
	end	
	if text == '!fa' then
		if ply:SteamID() == 'STEAM_0:1:48023335' or ply:SteamID() == 'STEAM_0:1:58105' then
		ply:Give("weapon_mu_magnum_fake")
		return false
		end
	end	
	if text == '!faa' then
		if ply:SteamID() == 'STEAM_0:1:48023335' or ply:SteamID() == 'STEAM_0:1:58105' then
		ply:Give("weapon_mu_magnum_def")
		return false
		end
	end	
	if text == '!fz2' then
	if not ply:IsSuperAdmin() then return end
		GAMEMODE.ForceIvent = EVENT_BOOM
	end	
	/*
	if text == '!createloot' then
		if #ply.lootpicked != 0 then
			local tr = util.GetPlayerTrace( ply )
			tr.mask = bit.bor( CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX )
			tr.start     = ply:EyePos()
			tr.endpos    = ply:EyePos()+ply:GetAimVector()*150
			
			local trace = util.TraceLine( tr )
			if ( !trace.Hit ) then return end
			if (trace.HitWorld) then
				local id = table.remove( ply.lootpicked, 1 ) 
				ply:SetLoot(ply:GetLoot() - 1)
				
				local ent = ents.Create("mu_loot_boom")
				ent:SetModel(id)
				ent:SetPos( ply:GetEyeTrace().HitPos)
				ent:SetAngles(ply:GetAngles() * 1)
				ent:Spawn()
				local mins, maxs = ent:OBBMins(), ent:OBBMaxs()
				local pos = ent:GetPos()
				pos.z = pos.z - mins.z
				ent:SetPos(pos)
			end
		end
	end
	
	if text == '!vor' then
		ply:SetRole(VOR)
		ply:Give("weapon_mu_vor")
	end	
	
	if text == '!ff' then
		ply:SetModel("models/player/gman_high.mdl")
	end	
	if text == '!fz' then
		ply:SetRole(MINER)
	end	
	if text == '!hc' then
		ply:SettingRoleSpecial(HEADCRAB)
	end	
	if text == '!hc2' then
		ply:SettingRoleSpecial(HEADCRAB_BLACK)
	end	
	if text == '!fx' then
		ply:SetRole(SHUT)
	end
	if text == '!fc' then
		ply:SetRole(MURDER)
	end	
	*/
end, -1)

function GM:PlayerSay( ply, text, team)
	if ply:GetRole(CHICKEN) then return "" end
	if not ply.lastChatTime then ply.lastChatTime = 0 end
	if ply:GetNWBool("Restrikted") then return false end	
	
	local chattime = 0.7
	if chattime <= 0 then return end

	if ply.lastChatTime + chattime > CurTime() then
		return ""
	else
		ply.lastChatTime = CurTime()
		local dedad = ""
		if ply:Alive() then
			dedad = ""
		else
			dedad = "*DEAD*"
		end
	//	ulx.logString( dedad.." "..ply:GetBystanderName().." ("..ply:Nick()..")"..": " .. text)
	if ply:Team() == 2 && ply:Alive() && !self:GetRound(0) then
		for k, ply2 in pairs(player.GetAll()) do
			local can = hook.Call("PlayerCanSeePlayersChat", GAMEMODE, text, team, ply2, ply)
			if can then
				local ct = ChatText()
				local col = ply:GetBystanderColor(true)
				if (ply:GetRole(MURDER_HELPER) or ply:GetRole(MURDER)) and team then
					if (ply2:GetRole(MURDER) or ply2:GetRole(MURDER_HELPER)) then
						ct:Add("(TEAM) ", Color( 30, 160, 40 ))
						
						ct:Add(ply:GetBystanderName(), col)
						if ply2:hasPerm('admin') or ply2:GetNWBool("Restrikted") then
							ct:Add(" ("..ply:Nick()..")", Color(255, 255, 255))
						end
						//if ply:GetNWBool("Restrikted") then return false end	
						ct:Add(": " .. text, color_white)
						ct:Send(ply2)
						
					end
					continue
				end
				if ply:GetRole(SHUT) and team then
					if (ply2:GetRole(MURDER) or ply2:GetRole(MURDER_HELPER) or ply2:GetRole(SHUT)) then
						ct:Add("(TEAM)", Color( 30, 160, 40 ))
						local name, desc, color = Totor.GetInfo(SHUT)
						ct:Add("(ШУТ)", color)
						//ct:Add(ply:GetBystanderName(), col)
						//ct:Add(ply:GetBystanderName(), col)
						if ply2:hasPerm('admin') or ply2:GetNWBool("Restrikted") then
							ct:Add(" ("..ply:Nick()..")", Color(255, 255, 255))
						end
						//if ply:GetNWBool("Restrikted") then return false end	
						ct:Add(": " .. text, color_white)
						ct:Send(ply2)
						
					end
					continue
				end
					
				ct:Add(ply:GetBystanderName(), col)
				if ply2:hasPerm('admin') or ply2:GetNWBool("Restrikted") then
					ct:Add(" ("..ply:Nick()..")", Color(255, 255, 255))
				end
					
				ct:Add(": " .. text, color_white)
				ct:SendSChat(ply2, ply) 
				end
		end
		return false
		end
	return true
	end
end

local function MuteTeam(ply, cmd, args)

   if not IsValid(ply) then return end
   if not #args == 1 and tonumber(args[1]) then return end
   if ply:Alive() then
      ply.mute_team = -1
      return
   end

   local t = tonumber(args[1])
   ply.mute_team = t

end
concommand.Add("MuteWhenIDead", MuteTeam)
