include("sh_mv.lua")

util.AddNetworkString("MapvoteUpdateMapList")
util.AddNetworkString("MapvoteSendAllMaps")
util.AddNetworkString("MapvoteSetActive")
util.AddNetworkString("MapvoteSyncNominations")

MV.MapList = {}
MV.Players = {} -- store each player's vote - {Player, Map}
MV.PlayerNominations = {}
MV.Nominations = {}

MV.Active = false
MV.RTVLasted = false
MV.TimeLeft = MV.VotingTime

local defaultFlags = FCVAR_SERVER_CAN_EXECUTE + FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE

--commands

concommand.Add("mapvote_list_maps", function(ply)

	net.Start("MapvoteSendAllMaps")
	net.WriteTable({
		maps = MV:GetGoodMaps(),
		action = "openlist"
	})
	net.Send( ply )

end)

function MV:SyncMapList()
	net.Start( "MapvoteUpdateMapList" )
	net.WriteTable( MV.MapList )
	net.Broadcast()
end
function MV:GetGoodMaps()
	-- get a list of maps
	local mapfiles = file.Find("maps/*.bsp", "GAME", "nameasc")
	if TTS then
		mapfiles = table.Copy(TTS.Maps.mapListAllow)
	end
	-- cleanup the names
	for i = 1, #mapfiles do
		mapfiles[i] = string.sub( mapfiles[i], 1, -5 )
	end
	
	-- remove files that don't have the right prefix
	local goodmaps = {}

	local doubles = file.Read("last_maps.txt", "DATA") or "[]"
	doubles = util.JSONToTable(doubles)
	
	for k,map in ipairs( mapfiles ) do
		for _, filter in ipairs( MV.Filter ) do
			local length = string.len( filter )
			local mapname = string.sub( map, 1, length )

			if mapname == filter then
				if not table.HasValue( goodmaps, map ) then -- ignore duplicates
					if map == game.GetMap() then continue end
					
					
					if table.HasValue( doubles, map ) then continue end
					
					table.insert(goodmaps, map)
				end
			end
		end
	end
	return goodmaps
end


function MV:UpdateMapVote()

	net.Start("MapvoteUpdateMapList")
	net.WriteTable( MV.MapList )
	net.Broadcast()
end

function MV:BeginMapVote() -- initiates the mapvote, and syncs the maps once

	mapfiles = MV:GetGoodMaps()

	-- populate the maplist
	MV.MapList = {}

	for i = 1, MV.MaxMaps do -- add nominations
		if MV.Nominations[i] then
			MV.MapList[ MV.Nominations[i] ] = 0
		end
	end

	--print(#MV.MapList, MV.MaxMaps, #mapfiles)
	local totalloops = 0
	local numMaps = 0
	for k,v in pairs(MV.MapList) do 
		numMaps = numMaps + 1 
	end
	while numMaps < MV.MaxMaps and totalloops < 200 and #mapfiles > 0 do

		local r =  math.random( #mapfiles )
		local randmap = mapfiles[r]
		MV.MapList[ randmap ] = 0

		table.remove( mapfiles, r )

		totalloops = totalloops + 1

		numMaps = 0
		for k,v in pairs(MV.MapList) do 
			numMaps = numMaps + 1 
		end
	end

	numMaps = 0
	for k,v in pairs(MV.MapList) do 
		numMaps = numMaps + 1 
	end

	MV.MapList[ game.GetMap() ] = 0
	
	net.Start("MapvoteSetActive")
	net.WriteBit( true )
	net.WriteTable( MV.MapList )
	net.WriteFloat( MV.VotingTime )
	net.Broadcast()

	MV.Active = true
	MV.TimeLeft = MV.VotingTime
end

function MV:StopMapVote()
	net.Start("MapvoteSetActive")
	net.WriteBit( false )
	net.WriteTable( {} )
	net.WriteFloat( 9999 )
	net.Broadcast()

	MV.Active = false
	MV.TimeLeft = 9999
end

function MV:FinishMapVote()
	MV.Active = false
	MV.RTVLasted = true
	-- find winning map
	-- change to it

	local win = ""
	local winvotes = 0
	for k,v in pairs(MV.MapList) do
		if v > winvotes then
			winvotes = v
			win = k
		end
	end

	MV.VotingMapsNoVotes = {}
	local num = 0
	for k,v in pairs(MV.MapList) do
		num = num + 1
		table.insert(MV.VotingMapsNoVotes, k)
	end
		
	-- /*
	

	-- if win == "" then win = table.Random( MV.VotingMapsNoVotes ) end
	
	-- if win == game.GetMap() and ROUND.stopcontinue ~= true then
		-- DR:ChatBroadcast("Выбрана карта "..win..". Счетчик был перезагружен.")
		-- ROUND:SetRoundPlayed(0)
		-- ROUND.stopcontinue = true
		-- //rounds_played = 0
		-- MV.Players = {}
		-- ROUND:RoundSwitch( ROUND_WAITING )
	-- return
	-- end
	
	-- if win == game.GetMap() and ROUND.stopcontinue then 
	
		-- if table.HasValue( MV.VotingMapsNoVotes, game.GetMap() ) then
			-- table.RemoveByValue( MV.VotingMapsNoVotes, game.GetMap() )
		-- end
	-- //PrintTable(MV.VotingMapsNoVotes)
		-- win = table.Random( MV.VotingMapsNoVotes )
		 
		-- DR:ChatBroadcast("Продолжение игры на данной карте отключено.")
		-- DR:ChatBroadcast("Случайно выбрана "..win..". Смена через 5 секунд.")
		-- local nextmap = win

		-- timer.Simple(5, function()
			-- DR:ChatBroadcast("Смена карты...")
			-- RunConsoleCommand("changelevel", nextmap)
		-- end)
	-- return
	-- end	
	
	-- DR:ChatBroadcast("Выбрана карта "..win..". Смена через 5 секунд.")

	-- local nextmap = win

	-- timer.Simple(5, function()
		-- DR:ChatBroadcast("Смена карты...")
		-- RunConsoleCommand("changelevel", nextmap)
	-- end)
	-- */

	

	local nextmap = win
	if win == "" then win = table.Random( MV.VotingMapsNoVotes ) end
	
	if win == game.GetMap() and ROUND.stopcontinue ~= true then
		ROUND.stopcontinue = true
		MV.RTVLasted = false
		GAMEMODE:SetRound(1)
		GAMEMODE:SetRoundCound(0)
		//DR:ChatBroadcast()
		//ROUND:SetRoundPlayed(0)
		//rounds_played = 0
		MV.Players = {}
		//ROUND:RoundSwitch( ROUND_WAITING )
		
				local ms = ChatMsg()
				ms:Add("[", Color(255, 255, 255))
				ms:Add("SYSTEM", Color(11, 53, 114))
				ms:Add("] ", Color(255, 255, 255))
				ms:Add('Выбрано продолжение игры на данной карте.',Color(255,255,255))
				ms:Send()
	return
	end
			
	
	if win == game.GetMap() and ROUND.stopcontinue then 
	
		if table.HasValue( MV.VotingMapsNoVotes, game.GetMap() ) then
			table.RemoveByValue( MV.VotingMapsNoVotes, game.GetMap() )
		end
	//PrintTable(MV.VotingMapsNoVotes)
		win = table.Random( MV.VotingMapsNoVotes )
		
			local ms = ChatMsg()
			ms:Add("[", Color(255, 255, 255))
			ms:Add("SYSTEM", Color(11, 53, 114))
			ms:Add("] ", Color(255, 255, 255))
			ms:Add('Продолжение игры на данной карте отключено.',Color(255,255,255))
			ms:Send()
	
			
		if GAMEMODE:GetRound() == 1 then
			local nextmap = win
			ROUND.PlainMap = nextmap
			
			local ms = ChatMsg()
			ms:Add("[", Color(255, 255, 255))
			ms:Add("SYSTEM", Color(11, 53, 114))
			ms:Add("] ", Color(255, 255, 255))
			ms:Add("Выбрана карта "..win..". Смена в конце раунда.",Color(255,255,255))
			ms:Send()
		
		else
			local ms = ChatMsg()
			ms:Add("[", Color(255, 255, 255))
			ms:Add("SYSTEM", Color(11, 53, 114))
			ms:Add("] ", Color(255, 255, 255))
			ms:Add("Выбрана карта "..win..". Смена через 5 секунд.",Color(255,255,255))
			ms:Send()
			local nextmap = win

			timer.Simple(5, function()
				local ms = ChatMsg()
				ms:Add("[", Color(255, 255, 255))
				ms:Add("SYSTEM", Color(11, 53, 114))
				ms:Add("] ", Color(255, 255, 255))
				ms:Add("Смена карты...",Color(255,255,255))
				ms:Send()
				RunConsoleCommand("changelevel", nextmap)
			end)
		end
	return
	end	
	
	
	if GAMEMODE:GetRound() == 1 then
		ROUND.PlainMap = nextmap
		
		local ms = ChatMsg()
		ms:Add("[", Color(255, 255, 255))
		ms:Add("SYSTEM", Color(11, 53, 114))
		ms:Add("] ", Color(255, 255, 255))
		ms:Add("Выбрана карта "..win..". Смена в конце раунда.",Color(255,255,255))
		ms:Send()
	else
		
		local ms = ChatMsg()
		ms:Add("[", Color(255, 255, 255))
		ms:Add("SYSTEM", Color(11, 53, 114))
		ms:Add("] ", Color(255, 255, 255))
		ms:Add("Выбрана карта "..win..". Смена через 5 секунд.",Color(255,255,255))
		ms:Send()

		timer.Simple(5, function()
		
			local ms = ChatMsg()
			ms:Add("[", Color(255, 255, 255))
			ms:Add("SYSTEM", Color(11, 53, 114))
			ms:Add("] ", Color(255, 255, 255))
			ms:Add("Смена карты...",Color(255,255,255))
			ms:Send()
			RunConsoleCommand("changelevel", nextmap)
		end)
	end
end

timer.Create("MapvoteCountdownTimer", 0.2, 0, function()
	if MV.Active == true then
		MV.TimeLeft = MV.TimeLeft - 0.2
		if MV.TimeLeft < 0 then
			MV:FinishMapVote()
		end
	end
end)

concommand.Add("mapvote_begin_mapvote", function(ply, cmd, args)

	local cont = false
	if IsValid( ply ) then
	-- print(ply, ply:IsSuperAdmin())
		if ply:IsSuperAdmin() then
			cont = true
		end
	else
		cont = true
	end
	if cont then
		MV:BeginMapVote()
	end
end)


concommand.Add("mapvote_vote", function(ply, cmd, args)
	if MV.Active == false then return end
	if args[1] and IsValid( ply ) then
		vot = args[1]
		//print(vot)
		MV.Players[ ply:SteamID() ] = vot

		for k,v in pairs( MV.MapList ) do
			MV.MapList[k] = 0
		end
		for k,v in pairs( MV.Players ) do
			MV.MapList[v] = (MV.MapList[v] or 0) + 1
		end

		MV:UpdateMapVote()
	else
		if IsValid(ply) then
			local ms = ChatMsg()
			ms:Add("[", Color(255, 255, 255))
			ms:Add("SYSTEM", Color(11, 53, 114))
			ms:Add("] ", Color(255, 255, 255))
			ms:Add("Выберите карту.",Color(255,255,255))
			ms:Send(ply)
		end
	end
end)

concommand.Add("mapvote_nominate_map", function(ply, cmd, args)

	if args[1] then
		nom = args[1]
		
		ply.LastNominateTime = ply.LastNominateTime or 0
		if ply.LastNominateTime+15 > os.time() then
			local ms = ChatMsg()
			ms:Add("[", Color(255, 255, 255))
			ms:Add("SYSTEM", Color(11, 53, 114))
			ms:Add("] ", Color(255, 255, 255))
			local ti = os.time()-ply.LastNominateTime
			ms:Add("Подождите ".. ti .." "..(util.Plural(ti, {"секунд", "секунду", "секунды"})).." прежде чем выдвинуть новую карту.",Color(255,255,255))
			ms:Send(ply)
			return 
		end
		
		local goodmaps = MV:GetGoodMaps()
		if (!table.HasValue( goodmaps, nom )) then 
		
			local ms = ChatMsg()
			ms:Add("[", Color(255, 255, 255))
			ms:Add("SYSTEM", Color(11, 53, 114))
			ms:Add("] ", Color(255, 255, 255))
			ms:Add("Такая карта в маппуле отсутствует.",Color(255,255,255))
			ms:Send(ply)
			
			return
		end
		if nom == game.GetMap() then
			local ms = ChatMsg()
			ms:Add("[", Color(255, 255, 255))
			ms:Add("SYSTEM", Color(11, 53, 114))
			ms:Add("] ", Color(255, 255, 255))
			ms:Add("Нельзя выдвинуть карту, на которой вы играете.",Color(255,255,255))
			ms:Send(ply)
			
			return
		end

		MV.PlayerNominations[ ply:SteamID() ] = nom

		MV.Nominations = {}
		for k,v in pairs( MV.PlayerNominations ) do
			if not table.HasValue( MV.Nominations ) then
				table.insert( MV.Nominations, v )
			end
		end
		
		local female = "выдвинул"
		if ply:GetPData("woman") == "true" then
		female = 'выдвинула'
		end
		//DR:ChatBroadcast(ply:Nick().." "..female.." "..nom.." для голосования!")
		
		local ms = ChatMsg()
		ms:Add("[", Color(255, 255, 255))
		ms:Add("SYSTEM", Color(11, 53, 114))
		ms:Add("] ", Color(255, 255, 255))
		ms:Add(ply:Nick().." "..female.." "..nom.." для голосования!",Color(255,255,255))
		ms:Send()
		
		ply.LastNominateTime = os.time()
		
		net.Start("MapvoteSyncNominations")
		net.WriteTable( MV.Nominations )
		net.Broadcast()
	end

end)

concommand.Add("mapvote_update_mapvote", function(ply, cmd, args)

	local cont = false
	if IsValid( ply ) then
		if ply:IsAdmin() then
			cont = true
		end
	else
		cont = true
	end

	MV:UpdateMapVote()

end)

-- RTV Features

local RTVRatio = CreateConVar("mapvote_rtv_ratio", 0.5, defaultFlags, "The ratio between votes and players in order to initiate a mapvote.")

function MV:CheckRTV( suppress )

	if MV.Active then return end
	if MV.RTVLasted then return end

	local votes = 0
	local numplayers = #player.GetAll()

	for k,v in ipairs(player.GetAll()) do
		v.WantsRTV = v.WantsRTV or false
		if v.WantsRTV == true then
			votes = votes + 1
		end
	end

	local ratio = votes/numplayers
	if ratio > RTVRatio:GetFloat() then
		MV:BeginMapVote()
		
		
		local ms = ChatMsg()
		ms:Add("[", Color(255, 255, 255))
		ms:Add("SYSTEM", Color(11, 53, 114))
		ms:Add("] ", Color(255, 255, 255))
		ms:Add("Предел голосов достигнут. Запуск голосования",Color(255,255,255))
		ms:Send()
		
	else

		local needed = math.ceil(RTVRatio:GetFloat() * numplayers) - votes + 1
		if not suppress then	
			local ms = ChatMsg()
			ms:Add("[", Color(255, 255, 255))
			ms:Add("SYSTEM", Color(11, 53, 114))
			ms:Add("] ", Color(255, 255, 255))
			ms:Add(tostring(needed).." осталось для того чтобы сменить карту. Введите !rtv чтобы проголосовать.",Color(255,255,255))
			ms:Send()
		end
	end

end

concommand.Add( "mapvote_rtv", function( ply )

	local suppress = ply.WantsRTV

	ply.WantsRTV = true
	MV:CheckRTV( suppress )

end)
/*
DR:AddChatCommand("rtv",function( ply )
	ply:ConCommand( "mapvote_rtv" )
end)
*/
hook.Add("PlayerSay", "CheckRTVChat", function(ply, text, pub)
	local args = string.Split( text, " " )
	if #args == 1 then
		if args[1] == "rtv" or args[1] == "!rtv"  then
			ply:ConCommand( "mapvote_rtv" )
		end
		if args[1] == "nominate" or args[1] == "maps" or args[1] == "!nominate" or args[1] == "!maps" then
			ply:ConCommand( "mapvote_list_maps" )
		end
	end
end, -1)