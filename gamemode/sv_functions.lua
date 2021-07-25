function RainbowColors()
	local frequency, time = .9, RealTime()
	local red = math.sin( frequency * time ) * 64 + 64
	local green = math.sin( frequency * time + 2) * 64 + 64
	local blue = math.sin( frequency * time + 4 ) * 64 + 64
	return Color( red, green, blue )
end

function lootDrop(ply,ent)
	if EVENTS:Get('ID') == EVENT_CROSSBOWHARD then
		ply:GiveAmmo( 5, "XBowBolt", true )
		ply:SetLoot(0)
		return
	elseif EVENTS:Get('ID') == EVENT_ULIKIPICKUP then
		return true
	elseif EVENTS:Get('ID') == EVENT_SLENDER then
		local ent = game.GetWorld()
		local loots = ent:GetDTInt( 1 )
		ent:SetDTInt( 1, (loots or 0) + 1 )
		
		if ((loots or 0) + 1) >= 8 then
			for i,v in pairs(player.GetAll()) do
				if v:GetRole(MURDER) then
					v:KillSilent()
				end
			end
		end
		return true
	end
	
	if ply:GetRole(MURDER) then
		if ply:GetLoot() == 5 then
		if ply:GetNWInt("murdertype") == 2 and !ply:HasWeapon('weapon_mine_turtle_virus') then
			ply:Give("weapon_mine_turtle_virus")
		end
		if not ply:GetNWBool('armormurder') then
			ply:SetNWBool('armormurder',true)
		end
		ply:SetLoot(0)
		end
	elseif ply:GetRole(0) or ply:GetRole(SHERIF) or ply:GetRole(DRESSIROVSHIK) or ply:GetRole(VOR) then
		if ply:GetLoot() >= 5 then
			giveMagnum(ply)
			ply:SetLoot(0)
		end
	elseif ply:GetRole(SCIENTIST) then
		if ply:GetLoot() == 3 then
			giveMagnum(ply)
			ply:SetLoot(0)
		end
	elseif ply:GetRole(MINER) then
		ply.lootpicked = ply.lootpicked or {}
		table.insert( ply.lootpicked, ent:GetModel() ) 
	elseif ply:GetRole(ALKO) then
		local named = ent:GetModel()
		if named == LootModels["beer1"] or named == LootModels["beer2"] then
			ply:Give('weapon_mu_vodka')
		end
		ply:SetLoot(0)
	elseif ply:GetRole(SHUT) then
		if ply:GetLoot() >= 2 then
			ply.allowShuting = true
			ply:SetLoot(0)
		end
	elseif ply:GetRole(HEADCRAB_BLACK) or ply:GetRole(HEADCRAB) or ply:GetRole(CHICKEN) then
		ply:SetLoot(0)
	elseif ply:GetRole(DED) then
		//if ply:GetNWBool("podariluliku") then
		if ply.LootCollected >= 6 then 
		
			local players = team.GetPlayers(2)
			table.RemoveByValue(players, ply)
			local as = table.Random(players)
			
			-- local drop = as:GenerateSpinList('alice')[0] 
			
			-- local ITEM = PS.Items[drop.psid]
			-- local name = ITEM and ITEM.Name or drop.psid.." "..PS.Config.PointsName
			local mathra = math.random(5, 200)
			local name = mathra .. ' поинтов'
			if ITEM then
				-- as:PS_GiveItem(drop.psid)
			else
				-- as:PS_GivePoints(drop.psid)
				-- as:PS_GivePoints(mathra)
				TTS.Shop.PS_PlusPoints(as, mathra)
			end
			
			local col = as:GetBystanderColor(true)
			local col2 = ply:GetBystanderColor(true)
									
			/*local msgs = Translator:AdvVarTranslate("{gifter} обменял свою душу на {gifted}.", {
				gifter = {text = v:GetBystanderName(), color = col2},
				gifted = {text = drop.itemName, color = drop.itemColor},
			})*/
			
			local ct = ChatText()
			ct:Add("[", Color(255, 255, 255))
			ct:Add("SYSTEM", Color(11, 53, 114))
			ct:Add("] ", Color(255, 255, 255))
			//ct:AddParts(msgs)
			ct:Add("Санта", col2)
			ct:Add(" собрал 6 улик и передал подарок ", Color(255,255,255))
			ct:Add(as:Nick(), col)
			ct:Broadcast()
			
			local ct = ChatText()
			ct:Add("Санта", col2)
			ct:Add(" подарил вам ", Color(255,255,255))
			-- ct:Add(name, drop.color)
			ct:Add(name, col2)
			ct:Send(as)
			ply:SetLoot(0)
		end
	elseif ply:GetRole(MEDIC) then
		if ply:GetLoot() == 5 then
			ply:Give( 'weapon_mu_adr' )
			ply:SelectWeapon( 'weapon_mu_adr' )
			ply:SetLoot(0)
		end
	elseif ply:GetRole(MURDER_HELPER) then
		if ply:GetLoot() == 5 then
			ply:Give( 'weapon_mu_secretbomb' )
			ply:SetLoot(0)
		end
	elseif ply:GetRole(PSYCHNAUTOR) then
		ply:SetLoot(0)
	end
end
function RewardPlayer( ply, amt, reason )
	amt = amt or 0
	-- ply:PS_GivePoints( amt )
	TTS.Shop.PS_PlusPoints(ply, 10)
	ply:Notify("Ты получил "..tostring( amt ).." поинтов "..(reason or "playing").."!", NOTIFY_GENERIC, 3)
	-- ply:PS_Notify("Вы получили "..tostring( amt ).." поинтов "..(reason or "playing").."!")
end

function RDMPSPlayer( ply, amt, reason )
	amt = amt or 0
	
	TTS.Shop.PS_MinusPoints(ply, amt)
	ply:Notify("Ты потерял "..tostring( amt ).." поинтов "..(reason or "playing").."!", NOTIFY_ERROR, 3)
	-- ply:PS_TakePoints( amt )
	-- ply:PS_Notify("У вас забрали "..tostring( amt ).." поинтов "..(reason or "playing").."!")
end

function TriggerRoundStateOutputs(r)
   r = r or GetRoundState()

   for _, ent in pairs(ents.FindByClass("ttt_map_settings")) do
      if IsValid(ent) then
         ent:RoundStateTrigger(r)
      end
   end
end

util.AddNetworkString("ChangeTypeMurder")
util.AddNetworkString("ChangeTypeKnife")


sql.Query("CREATE TABLE IF NOT EXISTS extrafunctions ( sid64 STRING )")

function TTS.OplataExtra(ply)
	if !ply then return end
	local isset = sql.Query("SELECT * FROM extrafunctions WHERE sid64 =  '"..ply:SteamID().."'")
	local ostime = os.time()
	if isset then
		TTS.RemoveExtra(ply)
	end
	
	sql.Query("INSERT INTO extrafunctions (sid64) VALUES ('"..ply:SteamID().."')")
	ply:SetNWBool("AddExtraFunctions", true)
end
function TTS.RemoveExtra(ply)
	ply:SetNWBool("AddExtraFunctions", false)
	sql.Query("DELETE FROM extrafunctions WHERE sid64 = '"..ply:SteamID().."'")
end
function TTS.RemoveExtraSID(sid)
	ply:SetNWBool("AddExtraFunctions", false)
	sql.Query("DELETE FROM extrafunctions WHERE sid64 = '"..sid.."'")
end

net.Receive( "ChangeTypeMurder", function(len, ply)
	local allow = ply:GetNWBool("AddExtraFunctions") 
	local data = net.ReadString()
	local ID = 0
	if (data == "Стандартный" ) then
		ID = 0
	elseif ( data == "Бенжи" ) then
		ID = 1
	elseif ( data == "Virus" ) then
		ID = 2
	elseif ( data == "Убийцорожденный" and allow ) then
		ID = 3
	elseif ( data == "Ситх" and allow ) then
		ID = 4
	elseif ( data == "Невидимка" and allow ) then
		ID = 5
	elseif ( data == "Teleport" and allow ) then
		ID = 6
	elseif ( data == "KamaPulya" ) then
		ID = 7
	end
	ply:SetTypeM(ID)
end)
net.Receive( "ChangeTypeKnife", function(len, ply)
	local data = net.ReadString()
	ply:SetNWString('def_knife', data)
	ply:SetPData('def_knife', data)
end)


function MesopotamiMurder(ply)
	local gr = ply:GetUserGroup()
	local can = 0
	if gr == 'vip++' then
		can = 1
	else
		can = 3
	end
	
	local usedply = TheGlobalTableUseForMurderVIPPlus[ply:SteamID()] or 0
	if usedply < can then
		TheGlobalTableUseForMurderVIPPlus[ply:SteamID()] = usedply + 1
		return true
	else
		return false
	end
	
end

TheGlobalTableUslesVIPPlus = {} 
TheGlobalTableUseIventsVIPPlus = {}
TheGlobalTableUseForMurderVIPPlus = {}

ROUNDIVENTLAST = 0

net.Receive( "VIPPlusIvent", function(len, ply)
	//print(GAMEMODE.ForceIvent)
	if (serverguard.player:HasPermission(ply, "VIPSetIvent") ) then
	
		local gr = ply:GetUserGroup()
		local can = 0
		if gr == 'vip++' then
			can = 1
		else
			can = 3
		end
		
		local usedply = TheGlobalTableUseIventsVIPPlus[ply:SteamID()] or 0
		
		if #team.GetPlayers(2) > 10 then
			if !GAMEMODE.ForceIvent then
				if usedply < can then
				
					local Unsigned = net.ReadUInt(8)
					
					if GAMEMODE:GetRound() == 1 then
						if ROUNDIVENTLAST+2 < GAMEMODE.RoundCount then
							TheGlobalTableUseIventsVIPPlus[ply:SteamID()] = usedply + 1
							ROUNDIVENTLAST = GAMEMODE.RoundCount
							GAMEMODE:SetForceIvent(Unsigned)
							local ct = ChatMsg()
							ct:Add('Осталось возможностей: '..can-usedply-1, Color(58, 190, 58))
							ct:Send(ply)
						else
							local ct = ChatMsg()
							ct:Add('Запрещено ставить часто ивенты', Color(190, 20, 20))
							ct:Send(ply)
						end
					else
						local ct = ChatMsg()
						ct:Add('Возможно форсировать ивент только во время игры', Color(190, 20, 20))
						ct:Send(ply)
					end
				else
					local ct = ChatMsg()
					ct:Add('Вы исчерпали свой лимит установок ивентов.', Color(190, 20, 20))
					ct:Send(ply)
				end
			else
				local ct = ChatMsg()
				ct:Add('Уже назначен форс ивент.', Color(190, 20, 20))
				ct:Send(ply)
			end
		else
			local ct = ChatMsg()
			ct:Add('Необходимо мин. 10 игроков.', Color(190, 20, 20))
			ct:Send(ply)
		end
	end
end)

net.Receive( "VIPPlusRole", function(len, ply)
	if (ply:GetUserGroup() != 'user' and ply:GetUserGroup() != 'vip' ) then
		local Unsigned = net.ReadUInt(8)
			if ply:Alive() && !ply:GetRole(MURDER) && !ply:GetRole(HEADCRAB) && EVENTS:Get('SpawnRoles') && !ply:GetRole(CHICKEN) && ply:GetRole() != Unsigned then
			if !TheGlobalTableUslesVIPPlus[ply:SteamID()] or ply:IsUserGroup('founder') then
				ply:SettingRoleSpecial(Unsigned)
				local ct = ChatMsg()
				ct:Add('Использовано', Color(20, 190, 20))
				ct:Send(ply)
				TheGlobalTableUslesVIPPlus[ply:SteamID()] = true
			else
				local ct = ChatMsg()
				ct:Add('Уже использовано', Color(190, 20, 20))
				ct:Send(ply)
			end
		else
			local ct = ChatMsg()
			ct:Add('Произошла ошибка', Color(190, 20, 20))
			ct:Send(ply)
		end
		
	end
end)


sql.Query("CREATE TABLE IF NOT EXISTS bystandernicks ( sid64 STRING, nick STRING, sexa STRING )")

function SetBystN(ply, nick, sexa)//sid64 STRING, status STRING
	if !ply then return end
	
	local allow = util.JSONToTable(file.Read("used_nicks_bystanders.txt", "DATA") or '[]') or {}
	if allow[ply:SteamID()] and allow[ply:SteamID()]+60*60*24 > os.time() then 
	
		ply:SendLua([[
			chat.AddText(Color(255, 100, 100),"Смена ника разрешена раз в день")
		]])
		return
	end
	
	local isset = sql.Query("SELECT * FROM bystandernicks WHERE sid64 =  '"..ply:SteamID().."'")
	if isset then
		RemoveBystN(ply)
	end
	
	allow[ply:SteamID()] = os.time()
	file.Write("used_nicks_bystanders.txt", util.TableToJSON(allow))
	
	sql.Query("INSERT INTO bystandernicks VALUES ('"..ply:SteamID().."', '"..nick.."', '"..sexa.."')")
	
	ply:SetNWBool('bystNW', true)
	ply:SetNWString('bystNWNick', nick)
	ply:SetNWString('bystNWSex', sexa)
	
	
	ply:SendLua([[
		chat.AddText(Color(100,255,100),"Ник установлен")
		surface.PlaySound( "garrysmod/content_downloaded.wav" )
	]])
end 

function RemoveBystN(ply)
	ply:SetNWBool('bystNW', false)
	ply:SetNWString('bystNWNick', nil)
	ply:SetNWString('bystNWSex', nil)
	sql.Query("DELETE FROM bystandernicks WHERE sid64 = '"..ply:SteamID().."'")
end


function PlayerInitialBystN( ply )
	if (serverguard.player:HasPermission(ply, "VIPSetBystanderName") ) then
		local isset = sql.Query("SELECT * FROM bystandernicks WHERE sid64 =  '"..ply:SteamID().."'")
	
		if isset then	
			local count = table.Count(isset or {})
			if count > 0 then
			
				local data = isset[1]
				
				timer.Simple(5, function()
					if IsValid(ply) then 
						ply:SetNWBool('bystNW', true)
						ply:SetNWString('bystNWNick', data['nick'])
						ply:SetNWString('bystNWSex', data['sexa'])
					end
				end)
			else
				ply:SetNWBool('bystNW', false)
				ply:SetNWString('bystNWNick', nil)
				ply:SetNWString('bystNWSex', nil)
			end
		end
	end
end


net.Receive( "BystNVIP", function(len, ply)
	if ply:GetUserGroup() != "user" and ply:GetUserGroup() != "vip" then
		local stringa = net.ReadString()
		local color = net.ReadString()
		if color == 'Мужской' then
			color = "male"
		else
			color = "female"
		end
		SetBystN(ply, stringa, color)
	end
end)

net.Receive( "BystNVIPre", function(len, ply)
	if ply:GetUserGroup() != "user" and ply:GetUserGroup() != "vip"  and ply:GetNWBool('bystNW') then
		RemoveBystN(ply)
	end
end)

function TTS.PlayerInitialGroupCheckExtra( ply )
	local isset = sql.Query("SELECT * FROM extrafunctions WHERE sid64 =  '"..ply:SteamID().."'")
	
	if isset then
		ply:SetNWBool("AddExtraFunctions", true)
	end
end
hook.Add( "PlayerInitialSpawn", "PlayerInitialGroupCheckExtra", TTS.PlayerInitialGroupCheckExtra )
hook.Add( "PlayerInitialSpawn", "PlayerSpawnAndInitTypeM", function(ply)
	timer.Simple(2, function()
		print(ply.InitTypeM)
		if ply.InitTypeM then
			ply:InitTypeM()
		end
	end)
end )
-- hook.Add("TTS::InitializeToken", "Donate_Murder.Init", function()
-- 	if !TTS.CFG.ModulesOn['donate_murder'] then return end
-- 	hook.Add( "serverguard.LoadedPlayerData", "PlayerInitialBystN", PlayerInitialBystN )
-- 	hook.Add( "PlayerInitialSpawn", "PlayerInitialGroupCheckExtra", TTS.PlayerInitialGroupCheckExtra )
-- 	hook.Add( "PlayerInitialSpawn", "PlayerSpawnAndInitTypeM", function(ply)
-- 		timer.Simple(2, function()
-- 			print(ply.InitTypeM)
-- 			if ply.InitTypeM then
-- 				ply:InitTypeM()
-- 			end
-- 		end)
-- 	end )
-- end )