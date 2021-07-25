 util.AddNetworkString("SetRound")
 util.AddNetworkString("SpawnTime")
 util.AddNetworkString("SendInfoIvent")
 util.AddNetworkString("SendSharpedHUD")

//Установка стандартных параметров
GM.RoundStage = 0
GM.RoundCount = 0
GM.TimerRound4 = 0
GM.LastIventRound = 0
GM.ForceIvent = false

if GAMEMODE then
	GM.RoundStage = GAMEMODE.RoundStage
	GM.RoundCount = GAMEMODE.RoundCount
	GM.ForceIvent = GAMEMODE.ForceIvent
	GM.TimerRound4 = GAMEMODE.TimerRound4
	GM.LastIventRound = GAMEMODE.LastIventRound
end

//Для управления извне движком
function GM:SetRoundCound(count)
	self.RoundCount = count
end

function GM:SetForceIvent(sub)
	self.ForceIvent = sub
end

//Базовая функция раундов
function GM:GetRound(id)
	if id ~= nil then
		return self.RoundStage == id
	end
	return self.RoundStage or 0
end

function GM:SetRound(round)
	self.RoundStage = round
	if round == 4 then
		self.TimerRound4 = CurTime()
	end
	net.Start("SetRound")
		net.WriteUInt(self.RoundStage, 32)
	net.Broadcast()
end

function GM:RefreshRound(ply)	
	net.Start("SetRound")
		net.WriteUInt(self.RoundStage, 32)
	net.Broadcast()
end

--[[	
	*Параметры игры*
0 - не хватает игроков
1 - основная, когда все играют
2 - ожидание игроков
]]--
function GM:RoundThink()
	local players = team.GetPlayers(2)
	if #players > 1 and self:GetRound(0) and self.LastConnect and self.LastConnect < CurTime() then
		self:StartRound()
	elseif self:GetRound( 1 ) then
		self:ThinkTker()
		self:ThinkAll()
		if !self.LastDeath || self.LastDeath < CurTime() then
			//
			TriggerRoundStateOutputs(3)
			if EVENTS:Get("CustomThink") then
				return self:RoundCheckForWinCustom()
			end
			self:RoundCheckForWin()
		end
	elseif self:GetRound( 2 ) and self.CooldownTimer and self.CooldownTimer < CurTime() then
		self:StartRound()
	elseif self:GetRound( 4 ) && self.TimerRound4+60 < CurTime() and self.TimerRound4 != 0 then
		self:StartRound()
	end
end

local LAST_IDLE_CHECK = 0
local IDLE_TIMER = 90

hook.Add("Think", "IdleTimer", function()	
	if LAST_IDLE_CHECK < CurTime() then
		for i,v in pairs(team.GetPlayers(2)) do
			if v:Alive() then
				local idletime = GAMEMODE:CheckIdleTime( v )
				if idletime > IDLE_TIMER then
					net.Start("MovedAFKPlayer")
					net.Send( v )
					v:ConCommand("mu_jointeam 1")
				end
			end
		end
		LAST_IDLE_CHECK = CurTime() + 1
	end
end)

local FOG_TIME = 60
function GM:ThinkAll()
	
	for i,v in pairs(team.GetPlayers(2)) do
		if v:Alive() then
			
			if (v:GetRole(HEADCRAB) or v:GetRole(HEADCRAB_BLACK)) and v:GetNWBool("hooked") and !v:GetNWBool("hooked_troup") and (v:GetNWString("hooked_type") == "zombie_fast" or v:GetNWString("hooked_type") == "zombie_poison") and v:GetNWInt("hooked_time")+60 < CurTime() then
				v:GetNWEntity("hooked_dbl"):SetModel("models/Zombie/fast.mdl")
				v:SetNWBool("hooked_troup", true)
				v:SetNWBool("hooked", false)
				local h = v:GetNWEntity("hooked_ply")
				if IsValid(h) then
					h:SetNWBool("h_hooked",false)
				end
				v:SetNWEntity("hooked_ply",nil)
				v:SetNWEntity("hooked_dbl", nil)
			end
			
			if v:GetNWInt('drinked') != 0 and (v.lastBuh or 0) < CurTime() then
				v:SetNWInt('drinked', v:GetNWInt('drinked')-1)
				v.lastBuh = CurTime()+1.3
			end
			
			
			if v:GetRole(SHERIF) then
				if v:HasWeapon("weapon_mu_checker") then
					v.LastChecker = CurTime()
				else
					if v.LastChecker && v.LastChecker + 40 < CurTime() then
						v:Give("weapon_mu_checker")
					end
				end
			end
			if v:GetRole(VOR) then
				if v:HasWeapon("weapon_mu_vor") then
					v.LastVor = CurTime()
				else
					if v.LastVor && v.LastVor + 40 < CurTime() then
						v:Give("weapon_mu_vor")
					end
				end
			end
			
			if v:GetRole(DINARA) then
				local rainbow = RainbowColors()
				v:SetColor(rainbow)
				v:SetBystanderColor(rainbow)
			end
			
			if EVENTS:Get('ID') != EVENT_CVP and EVENTS:Get('ID') != EVENT_TD and EVENTS:Get('ID') != EVENT_SLENDER then
				if v:GetRole(MURDER) && v:Alive() then
					if !v.LasKnife then
						v.LasKnife = CurTime()
					end
					if v:HasWeapon(v.knifeclass or "weapon_mu_knife_def") then
						v.LasKnife = CurTime()
					else
						if v.LasKnife && v.LasKnife + 30 < CurTime() then
              print(v.knifeclass)
							v:Give(v.knifeclass or "weapon_mu_knife_def")
						end
					end
				end
			end
		end
	end
end

function GM:EndWriteGame()
local a = util.JSONToTable(file.Read("endroundswrite.txt", "DATA") or "[]") or {}
if #a > 20 then
	a[1] = nil
end

a = table.ClearKeys( a )

local roundlast = {}
roundlast.event = EVENTS:Get('ID')
roundlast.id = os.time()
local plys = {}
	for i,v in pairs(player.GetAll()) do
		local p = {}
		p['sid'] = v:SteamID()
		p['nick'] = v:Nick()
		p['role'] = v:GetRole()
		p['bname'] = v:GetBystanderName()
		p['bcolor'] = v:GetBystanderColor():ToColor()
		p['team'] = v:Team()
		table.insert(plys, p)
	end
roundlast.plys = plys
table.insert(a, roundlast)
file.Write("endroundswrite.txt", util.TableToJSON(a))
end

function GM:ThinkTker()
	if EVENTS:Get('ID') != EVENT_SLENDER then
		if !self.IsFog and self.LastDeath+FOG_TIME < CurTime() then
			for i,v in pairs(team.GetPlayers(2)) do
				if v:GetRole(MURDER) then
						v:SetNWBool('MurderFog',true)
				end
			end
			self.IsFog = true
		end
		
		if self.IsFog and self.LastDeath+FOG_TIME > CurTime() then
			for i,v in pairs(player.GetAll()) do
				v:SetNWBool('MurderFog',false)
			end
			self.IsFog = false
		end
	end
	
	for i,v in pairs(team.GetPlayers(2)) do
		if v:GetTKer() and v.LastTKTime+30 < CurTime() then
			v:SetTKer(false)
		end
	end
end

function GM:RoundCheckForWinCustom()
	
	local players = player.GetAll()
	if #players <= 1 then 
		self:SetRound(0)
		return 
	end
	 
	if EVENTS:Get('ID') == EVENT_CVP then
		local survivors = {}
		local murds = {}
		for k,v in pairs(players) do
			if v:Alive() and !v:GetRole(MURDER) then
			 table.insert(survivors, v)
			end
			if v:Alive() and v:GetRole(MURDER) then
			 table.insert(murds, v)
			end
		end
		//print(leader)
		local murderer
		  
		if ROUND:GetTimer() == 0 then
		
			local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
			  ct:Add("Нет победителей.", Color( 255, 255, 255 ))
			  ct:Broadcast()
			self:SetRound( 2 )
			self.CooldownTimer = CurTime() + 10
			self:EndRound(3)
			return
		end
		if #survivors < 1 then
		
		local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
			  ct:Add("Победа хищников.", Color( 255, 255, 255 ))
			  ct:Broadcast()
			self:SetRound( 2 )
			self.CooldownTimer = CurTime() + 10
			self:EndRound(3)
			return
		end
		if #murds < 1 then
		local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
			  ct:Add("Победа комбайнов.", Color( 255, 255, 255 ))
			  ct:Broadcast()
			self:SetRound( 2 )
			self.CooldownTimer = CurTime() + 10
			self:EndRound(3)
			return
		end
	
	elseif EVENTS:Get('ID') == EVENT_TD then
		local survivors = {}
		local murds = {}
		for k,v in pairs(players) do
			if v:Alive() and !v:GetRole(MURDER) then
			 table.insert(survivors, v)
			end
			if v:Alive() and v:GetRole(MURDER) then
			 table.insert(murds, v)
			end
		end
		
		local murderer
		  
		if ROUND:GetTimer() == 0 then
		
			local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
			  ct:Add("Нет победителей.", Color( 255, 255, 255 ))
			  ct:Broadcast()
			self:SetRound( 2 )
			self.CooldownTimer = CurTime() + 10
			self:EndRound(3)
			return
		end
		if #survivors < 1 then
		
		local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
			  ct:Add("Победа куклы.", Color( 255, 255, 255 ))
			  ct:Broadcast()
			self:SetRound( 2 )
			self.CooldownTimer = CurTime() + 10
			self:EndRound(3)
			return
		end
		if #murds < 1 then
		local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
			  ct:Add("Победа жертв.", Color( 255, 255, 255 ))
			  ct:Broadcast()
			self:SetRound( 2 )
			self.CooldownTimer = CurTime() + 10
			self:EndRound(3)
			return
		end
	elseif EVENTS:Get('ID') == EVENT_SLENDER then
		local survivors = {}
		local murds = {}
		for k,v in pairs(players) do
			if v:Alive() and !v:GetRole(MURDER) then
			 table.insert(survivors, v)
			end
			if v:Alive() and v:GetRole(MURDER) then
			 table.insert(murds, v)
			end
		end
		
		local murderer
		  
		if ROUND:GetTimer() == 0 then
		
			local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
			  ct:Add("Нет победителей.", Color( 255, 255, 255 ))
			  ct:Broadcast()
			self:SetRound( 2 )
			self.CooldownTimer = CurTime() + 10
			self:EndRound(3)
			return
		end
		if #survivors < 1 then
		
		local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
			  ct:Add("Победа слендера.", Color( 255, 255, 255 ))
			  ct:Broadcast()
			self:SetRound( 2 )
			self.CooldownTimer = CurTime() + 10
			self:EndRound(3)
			return
		end
		if #murds < 1 then
		local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
			  ct:Add("Победа потерявшихся.", Color( 255, 255, 255 ))
			  ct:Broadcast()
			self:SetRound( 2 )
			self.CooldownTimer = CurTime() + 10
			self:EndRound(3)
			return
		end
	
	elseif EVENTS:Get('ID') == EVENT_ULIKIPICKUP then
		local players = team.GetPlayers(2)
		local leader = false
		for k,v in pairs(players) do
			if !leader or (leader:GetLoot() < v:GetLoot())then
				leader = v
			end
		end
		//print(leader)
		local murderer
		   
		if ROUND:GetTimer() == 0 then
		
			RewardPlayer( leader, 10, "за победу в ивенте")
		local ct = ChatText() 
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
			  ct:Add("Победил ", Color( 255, 255, 255 ))
			  ct:Add(leader:Nick(), leader:GetBystanderColor(true))
			  ct:Add(" набрав большинство улик", Color( 255, 255, 255 ))
			  ct:Broadcast()
			self:SetRound( 2 )
			self.CooldownTimer = CurTime() + 10
			self:EndRound(3)
			return
		end
		return
	elseif EVENTS:Get('ID') == EVENT_CROSSBOWHARD or EVENTS:Get('ID') == EVENT_KATANASHARD  or EVENTS:Get('ID') == EVENT_BOOM  then
		local alived = {}
		local players = team.GetPlayers(2)
		local leader = false
		for k,v in pairs(players) do
			if v.killedbyme == nil then
				v.killedbyme = 0
			end
			if v:Alive() then
				table.insert(alived, v)
			end
			if !leader or (leader.killedbyme < v.killedbyme)then
					leader = v
				end
			end
		//print(leader)
		local murderer
		  
		if ROUND:GetTimer() == 0 then
		
			RewardPlayer( leader, 10, "за победу в ивенте")
		local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
			  ct:Add("Победил ", Color( 255, 255, 255 ))
			  ct:Add(leader:Nick(), leader:GetBystanderColor(true))
			  ct:Add(" убив большинство игроков", Color( 255, 255, 255 ))
			  ct:Broadcast()
			self:SetRound( 2 )
			self.CooldownTimer = CurTime() + 10
			self:EndRound(3)
			return
		end
		if #alived < 1 then
		
			RewardPlayer( leader, 20, "за победу в ивенте")
		local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
			  ct:Add("Победил ", Color( 255, 255, 255 ))
			  ct:Add(leader:Nick(), leader:GetBystanderColor(true))
			  ct:Add(" убив большинство игроков", Color( 255, 255, 255 ))
			  ct:Broadcast()
			self:SetRound( 2 )
			self.CooldownTimer = CurTime() + 10
			self:EndRound(3)
			return
		end
		if #alived == 1 then
			RewardPlayer( leader, 10, "за победу в ивенте")
		local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
			  ct:Add("Победил ", Color( 255, 255, 255 ))
			  ct:Add(leader:Nick(), leader:GetBystanderColor(true))
			  ct:Add(" убив большинство игроков", Color( 255, 255, 255 ))
			  ct:Broadcast()
			self:SetRound( 2 )
			self.CooldownTimer = CurTime() + 10
			self:EndRound(3)
			return
		end
		return
	end
	
	if EVENTS:Get('Figth1vs1')  then
		local alived = {}
		local players = team.GetPlayers(2)
		
		for k,v in pairs(players) do
			if v:Alive() then
				table.insert(alived, v)
			end
		end

		local murderer

		if ROUND:GetTimer() == 0 then
		
		local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
			  ct:Add("Время закончилось.", Color( 255, 255, 255 ))
			  ct:Broadcast()
			self:SetRound( 2 )
			self.CooldownTimer = CurTime() + 10
			self:EndRound(3)
			return
		end
		if #alived < 1 then
		
		local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
			  ct:Add("Все мертвы.", Color( 255, 255, 255 ))
			  ct:Broadcast()
			self:SetRound( 2 )
			self.CooldownTimer = CurTime() + 10
			self:EndRound(3)
			return
		end
		if #alived == 1 then
			local ply = alived[1]
			RewardPlayer( ply, 20, "за победу в ивенте")
		local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
			  ct:Add("Победил ", Color( 255, 255, 255 ))
			  ct:Add(ply:Nick(), ply:GetBystanderColor(true))
			  ct:Broadcast()
			self:SetRound( 2 )
			self.CooldownTimer = CurTime() + 10
			self:EndRound(3)
			return
		end
	end
end

function GM:RoundCheckForWin()
	local players = player.GetAll()
	
	if #players <= 1 then 
		self:SetRound(0)
		return 
	end
	
	local survivors = {}
	local murds = {}
	for k,v in pairs(players) do
		if v:Alive() and !v:GetRole(MURDER) and !v:GetRole(MURDER_HELPER) and !v:GetRole(DINARA) and !v:GetRole(DED) and !v:GetRole(VOR) and !v:GetRole(PSYCHNAUTOR) and !v:GetRole(CHICKEN) and !v:GetRole(MOSHENNIK) and !v:GetRole(PRODAVEC) and !v:GetRole(MINER) and !v:GetRole(SHUT) then
		 table.insert(survivors, v)
		end
		if (v:Alive() or v:GetNWBool("h_hooked")) and v:GetRole(MURDER) then
		 table.insert(murds, v)
		end
	end
	
	if ROUND:GetTimer() == 0 then
		self:SetRound( 2 )
		self.CooldownTimer = CurTime() + 10
		self:EndRound(3, #murds)
		return
	end
	
	if #survivors == 0 then
		/*
		for i,v in pairs(survivors) do 
			RewardPlayer( v, 300, "за победу свидетелей в раунде")
		end
		*/
		self:SetRound( 2 )
		self.CooldownTimer = CurTime() + 5
		self:EndRound(1, #murds)
		return
	end
	
	if #murds == 0 then
		/*
		for i,v in pairs(murds) do 
			RewardPlayer( v, 300, "за победу убийцы в раунде")
		end
		*/
		self:SetRound( 2 )
		self.CooldownTimer = CurTime() + 5
		self:EndRound(2, #murds)
		return
	end
end

/*
1 - победа убийцы
2 - победа невиновных
3 - ничья по таймингу
*/
local event_slender = true
function GM:EndRound(typ, rds)
  
	BroadcastLua([[
	local pitch = math.random(80, 120)
	if IsValid(LocalPlayer()) then
		LocalPlayer():EmitSound("ambient/alarms/warningbell1.wav", 100, pitch)
	end
	]])
	
	self.RoundCount = self.RoundCount + 1
	
	
	self:EndWriteGame()
	
	if EVENTS:Get('CustomEnd') then
		
		local players = team.GetPlayers(2)
	
		for i,v in pairs(players) do
			RewardPlayer( v, 20, "за участие в ивенте")
		end
		
		local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
		ct:Add("Ивент завершен.", Color( 255, 255, 255 ))
		ct:Broadcast()
		
	else
		local text = "Неопознано."
		if typ == 1 then
			local asdasd = {}
			local players = team.GetPlayers(2)
			local ppap1 = false
			local ppap2 = false
			for k,v in pairs(players) do
				if (v:GetRole(PRODAVEC)) then
					ppap1 = v
				end
				if (v:GetRole(MOSHENNIK)) then
					ppap2 = v
				end
				if (v:Alive() && (v:GetRole(MURDER) or v:GetRole(MURDER_HELPER))) then
					table.insert(asdasd, v)
				end
			end
			
			if ppap1 and IsValid(ppap1) then
				if ppap1.yaprodaltype == 2 then
					RDMPSPlayer(ppap1, 100, "за поражение невиновных")
				elseif ppap1.yaprodaltype == 1 then
					RewardPlayer(ppap1, 100, "за победу "..PluralEdit('murds', rds))
				end
			end
			
			if ppap2 and IsValid(ppap2) then
				if ppap2.yaprodaltype == 2 then
					RewardPlayer(ppap2, 100, "за поражение невиновных")
				elseif ppap2.yaprodaltype == 1 then
					RDMPSPlayer(ppap2, 100, "за победу "..PluralEdit('murds', rds))
				end
			end
			
			for i,v in pairs(asdasd) do
				RewardPlayer( v, 20, "за победу "..PluralEdit('murds', rds).. " в раунде")
			end
			text = "Победа стороны "..PluralEdit('murds', rds).. "."
		elseif typ == 2 then
		
			local asdasd = {}
			local players = team.GetPlayers(2)
			local ppap1 = false
			local ppap2 = false
			for k,v in pairs(players) do
				if (v:GetRole(PRODAVEC)) then
					ppap1 = v
				end
				if (v:GetRole(MOSHENNIK)) then
					ppap2 = v
				end
				if (v:Alive() && !v:GetRole(MURDER) and !v:GetRole(MURDER_HELPER) and !v:GetRole(VOR) and !v:GetRole(HEADCRAB_BLACK) and !v:GetRole(HEADCRAB) and !v:GetRole(CHICKEN)) then
					if v:GetRole(DINARA) and v.DinaraBad then continue end
					table.insert(asdasd, v)
				end
			end
			
			if ppap1 and IsValid(ppap1) then
				if ppap1.yaprodaltype == 1 then
					RDMPSPlayer(ppap1, 100, "за поражение "..PluralEdit('murds', rds))
				elseif ppap1.yaprodaltype == 2 then
					RewardPlayer(ppap1, 100, "за победу невиновных")
				end
			end
			
			if ppap2 and IsValid(ppap2) then
				if ppap2.yaprodaltype == 1 then
					RewardPlayer(ppap2, 100, "за поражение "..PluralEdit('murds', rds))
				elseif ppap2.yaprodaltype == 2 then
					RDMPSPlayer(ppap2, 100, "за победу невиновных")
				end
			end
			
			for i,v in pairs(asdasd) do
				RewardPlayer( v, 15, "за победу невиновных в раунде")
			end
			
			text = "Победа стороны невиновных."
		elseif typ == 3 then
			text = "Время вышло."
		end
		
		local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
			  ct:Add(text, Color( 255, 255, 255 ))
			  ct:Broadcast()
	end	
	
	if self.RoundCount >= 10 then
		if math.random(1,7) == 2 then
			if event_slender then
				-- PrintMessage(HUD_PRINTTALK, tostring(event_slender))
				event_slender = false
				ROUND.stopcontinue = true
				local bool, id, info = EventPars(EVENT_SLENDER)
				
				if bool then
					self.LastIventRound = GAMEMODE.RoundCount
					if #team.GetPlayers(2) >= info.players then
						self.ForceIvent = EVENT_SLENDER
						self:SetRound(0)
						return
					end
				end
			end
		end
		
		self:SetRound(4)
		MV:BeginMapVote()
		
		local ms = ChatMsg()
		ms:Add("[", Color(255, 255, 255))
		ms:Add("SYSTEM", Color(11, 53, 114))
		ms:Add("] ", Color(255, 255, 255))
		ms:Add("Достигнут лимит раундов. Запуск голосования.",Color(255,255,255))
		ms:Send()
		return
	end
	
	if ROUND.PlainMap ~= nil then
			
		self:SetRound(4)
		
		local nextmap = ROUND.PlainMap
		
		local ms = ChatMsg()
		ms:Add("[", Color(255, 255, 255))
		ms:Add("SYSTEM", Color(11, 53, 114))
		ms:Add("] ", Color(255, 255, 255))
		ms:Add("Ранее была выбрана карта "..nextmap..". Смена через 5 секунд.",Color(255,255,255))
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
		//return
	end
		
end
  
//ROUND:SetTimer(900000)
//GAMEMODE.ForceIvent = EVENT_CVP
/*
for i,v in pairs(player .GetAll()) do
	print(v, v:GetBystanderName())
	v:SetLoot(4)
end
*/

local SlenderBoneMods = {
	["ValveBiped.Bip01_Spine2"] = { scale = Vector(1.164, 1.031, 1.164), pos = Vector(4.296, 0, 0), angle = Angle(0, 10.668, 0) },
	["ValveBiped.Bip01_R_Foot"] = { scale = Vector(1.118, 1.118, 1.118), pos = Vector(8.482, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_Head1"] = { scale = Vector(1.103, 1, 0.93), pos = Vector(0, 0, 0), angle = Angle(0, 17.363, 0) },
	["ValveBiped.Bip01_L_Clavicle"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 0, -37.514) },
	["ValveBiped.Bip01_R_UpperArm"] = { scale = Vector(1.248, 1.248, 1.248), pos = Vector(0, 0, 0), angle = Angle(-7, 0, 0) },
	["ValveBiped.Bip01_Spine4"] = { scale = Vector(1.077, 1.077, 1.082), pos = Vector(0, 0, 0), angle = Angle(0, 0.702, 0) },
	["ValveBiped.Bip01_Spine"] = { scale = Vector(0.99, 0.99, 0.99), pos = Vector(0, 0, 0), angle = Angle(0, -0.627, 0) },
	["ValveBiped.Bip01_R_Hand"] = { scale = Vector(1, 1, 1), pos = Vector(1.108, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_L_Calf"] = { scale = Vector(1.118, 1.118, 1.118), pos = Vector(-2.267, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_R_Clavicle"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 0, 37.513) },
	["ValveBiped.Bip01_L_Thigh"] = { scale = Vector(1.118, 1.118, 1.118), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_R_Thigh"] = { scale = Vector(1.118, 1.118, 1.118), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_R_Forearm"] = { scale = Vector(1.141, 1.141, 1.141), pos = Vector(13.13, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_L_Hand"] = { scale = Vector(1, 1, 1), pos = Vector(1.108, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_Pelvis"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 15.835), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_Spine1"] = { scale = Vector(0.985, 0.985, 1.235), pos = Vector(1.965, 0, 0), angle = Angle(0, 17.204, 0) },
	["ValveBiped.Bip01_R_Calf"] = { scale = Vector(1.118, 1.118, 1.118), pos = Vector(-2.267, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_L_Foot"] = { scale = Vector(1.118, 1.118, 1.118), pos = Vector(8.482, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_L_UpperArm"] = { scale = Vector(1.248, 1.248, 1.248), pos = Vector(0, 0, 0), angle = Angle(7, 0, 0) },
	["ValveBiped.Bip01_L_Forearm"] = { scale = Vector(1.141, 1.141, 1.141), pos = Vector(13.13, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_R_Finger1"] = { scale = Vector(1, 1, 1), pos = Vector(2.401, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_L_Finger0"] = { scale = Vector(1, 1, 1), pos = Vector(2.401, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_L_Finger1"] = { scale = Vector(1, 1, 1), pos = Vector(2.401, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_L_Finger2"] = { scale = Vector(1, 1, 1), pos = Vector(2.401, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_L_Finger3"] = { scale = Vector(1, 1, 1), pos = Vector(2.401, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_L_Finger4"] = { scale = Vector(1, 1, 1), pos = Vector(2.401, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_R_Finger4"] = { scale = Vector(1, 1, 1), pos = Vector(2.401, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_R_Finger2"] = { scale = Vector(1, 1, 1), pos = Vector(2.401, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_R_Finger3"] = { scale = Vector(1, 1, 1), pos = Vector(2.401, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_R_Finger0"] = { scale = Vector(1, 1, 1), pos = Vector(2.401, 0, 0), angle = Angle(0, 0, 0) },
}
function GM:StartRound()
	local players = team.GetPlayers(2)
	if #players <= 1 then
		self:SetRound(0)
		return
	end
	game.CleanUpMap()
	TriggerRoundStateOutputs(1)
	ROUND:SetTimer(ROUNDTIMESET)
	EVENTS:Reload()
	EVENTS:Refresh()
	self.LastDeath = CurTime()+10
	self.IsFog = false
	print("Start New Round")

	local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
	ct:Add("Новый раунд начался.", Color( 255, 255, 255 ))
	ct:Broadcast()
	
	self:SetRound(1)
	local en_customspawns = false
	local customspawns = table.Copy(SpawnsPoint)
	if #customspawns >= game.MaxPlayers() then
		en_customspawns = true
	end
	
	local nicks = table.Copy(tabletoBysNick)
	
	for k ,v in pairs(rdms) do
		if v["round"]==0 then
			v["round"]=1
		else 
			rdms[k]=nil 
		end
	end 
	
	net.Start("rdm_vgui")
	net.WriteTable(rdms)
	net.Broadcast()	
		  
	for i,v in pairs(players) do
	 v:KillSilent()
	 v:StripAmmo()
	 v:StripWeapons()
	 v:Spawn()
	 if en_customspawns then
		local randomspawn, keyrandomspawn = table.Random(customspawns)
	//	print(keyrandomspawn, 'keyid')
	//	print(#customspawns)
		v:SetPos(randomspawn)
	 	customspawns[keyrandomspawn] = nil
	 end
	
	 v:SetNWString("murd_t", "")
	 v:SetNWString("LastLooked","")
	 v:SetNWBool('armormurder',false)
	 v:SetNWBool('MurderFog',false)
	 v:SetNWBool("Marked_ply", false)
	 v:SetNWBool("AmChecking", false)
	 v:SetNWBool("HeChecking", false)
	 v:SetNWBool("AmVor", false)
	 v:SetNWBool("HeVoring", false)
	 v:SetNWString("SteamIDChecked","")
	 v:SetNWString("SteamIDCheckedWeapons",nil)
	 v:SetNWBool("SteamIDChecked2",false)
	 v:SetNWBool("podariluliku", false)
	 v:SetNWInt('drinked',0)
	 v.knifeclass = nil
	 v.lootpicked = {}
	 v:SetBloodColor( DONT_BLEED )
	 v:DrawShadow(true)
	 /*HEADCRAB NWs*/
	 v:SetNWBool("h_hooked",false)
	 v:SetNWBool("hooked", false)
	 v:SetNWEntity("hooked_ply", nil)
	 v:SetNWEntity("pk_pill_ent", nil)
	 v:SetNWEntity("hooked_dbl", nil)
	 v:SetNWBool("cant", false)
	 v:SetNWInt("CountHited", 0)
	 v:SetNWBool('fakearmor', false)
	 -- v:SetNWBool("SuccubFog", false)
	 v:SetNWBool("cantsend", false)
	 v:SetNWBool("DisabledWASD", false)
	 v:SetNWBool('slender.isvisible', false)
	 v:SetNWBool('slender.invismode', false)
	 v:SetCustomCollisionCheck( false )
	
	 v:SetNWBool("Marked_ply", false)
	
	 /* RULS */
	 
	 v:SetNWBool("SuccubFog", false)
	 v:SetNWBool("IsEated", false)
	 v:SetNWEntity("whoEatSouls", nil)
	 v:SetNWInt("MeEatSouls", 0)
	 -- v:SetNWBool("MeSuccub", false)
	 -- v:SetNWBool("MeSuccubTrig", false)
	 -- v:SetNWBool("SuccubFog", false)
	 -- v:SetNWBool("MeWajSuccub", false)
	 -- v:SetNWEntity("MeWajSuccub", false)
	 -- v:SetNWInt("MeEatSouls", 0)
	 -- v:SetNWEntity("whoEatSouls", nil)
	 
	 v:SetNWInt("StartRoundCurTime", CurTime()+7)
	 
	 v.SucIsUs = false
	 v.DinaraBad = false
	 v.PsyBad = false
	 v.yaprodaltype = 0
	 
	 v.LastActiveTime = CurTime()
	
	 
	 local randomname, keyrandomname = table.Random(nicks[v.ModelSex])
	 v:SetBystanderName(unpack(randomname), true)
	 table.remove(nicks[v.ModelSex], keyrandomname)
	 
	 
	 local vec = Color(0, 0, 0)
	 vec.r = math.Rand(0, 150)
	 vec.g = math.Rand(0, 150)
	 vec.b = math.Rand(0, 150)
	 v:SetBystanderColor(vec)
	
	 v.MurdererChance = (v.MurdererChance or 0) + 1
	 v.RoleChance = (v.RoleChance or 0) + 1
	 v:SetRole(0)
	 v:SetTKer(false)
	 v:SetLoot(0)
	 v:SetSkin(0)
	 //v:CalculateSpeed()
	 v:SetColor(Color(255,255,255))
	 v.mute_team = -1
	end
	
	timer.Simple(0.2, function ()
		BroadcastLua([[
		GAMEMODE.ForceIvent = false
		local pitch = math.random(70, 140)
		if IsValid(LocalPlayer()) then
			LocalPlayer():EmitSound("ambient/creatures/town_child_scream1.wav", 100, pitch)
		end
		]])
	end)
	
	net.Start("SendSharpedHUD")
		net.WriteInt(0, 4)
	net.Send(players)

	net.Start("SpawnTime") 
	net.Send(players)
	
	if self.ForceIvent or (((self.LastIventRound or 0)+5 < self.RoundCount) and math.random(1,3) == 2) then
		if self.ForceIvent == nil then 
			_, self.ForceIvent = table.Random( EVENTSINFO )
		end
		
		local bool, id, info = EventPars(self.ForceIvent)
		self.ForceIvent = false
		
		if bool then
			self.LastIventRound = GAMEMODE.RoundCount
			if #players >= info.players then
			//if 1 == 1 then
				
				local ct = ChatText()
				ct:Add("Сейчас ивент "..info.name..".", Color( 255, 255, 255 ))
				ct:Broadcast()
				 
				timer.Simple(0.2, function ()
				net.Start("SendInfoIvent")
				net.WriteUInt(id, 8)
				net.Broadcast()
				end) 
				if id == EVENT_AK47 then
					EVENTS:Edit('ID', EVENT_AK47)
					EVENTS:Edit('RDM', false)
					EVENTS:Edit('SpawnRoles', false)
					EVENTS:Edit('CustomEnd', true)
					EVENTS:Edit('CustomDeath', true)
					EVENTS:Edit('CustomThink', true)
					EVENTS:Edit('Figth1vs1', true) 
					EVENTS:Edit('SpawnLoot', false) 
					for i,v in pairs(players) do 
						v:StripWeapons()
						v:StripAmmo()
						v:Give('weapon_ak47')
					end
						
					ROUND:SetTimer( 60*3 )
					EVENTS:Refresh()
				elseif id == EVENT_CROSSBOWHARD then
					EVENTS:Edit('ID', EVENT_CROSSBOWHARD)
					EVENTS:Edit('RDM', false)
					EVENTS:Edit('SpawnRoles', false)
					EVENTS:Edit('CustomEnd', true)
					EVENTS:Edit('CustomDeath', true)
					EVENTS:Edit('CustomThink', true)
					EVENTS:Edit('Figth1vs1', true) 
					EVENTS:Edit('SpawnLoot', true) 
					local time = CurTime()
					for i,v in pairs(players) do 
						v:StripWeapons()
						v:StripAmmo()
						v:Give('weapon_crossbow')
						v.killedbyme = 0
						v.deathtime = time
					end
						
					ROUND:SetTimer( 60*3 )
					EVENTS:Refresh()
				elseif id == EVENT_KATANASHARD then
					EVENTS:Edit('ID', EVENT_KATANASHARD)
					EVENTS:Edit('RDM', false)
					EVENTS:Edit('SpawnRoles', false)
					EVENTS:Edit('CustomEnd', true)
					EVENTS:Edit('CustomDeath', true)
					EVENTS:Edit('CustomThink', true)
					EVENTS:Edit('Figth1vs1', true) 
					EVENTS:Edit('SpawnLoot', false) 
					local time = CurTime()
					for i,v in pairs(players) do 
						v:StripWeapons()
						v:StripAmmo()
						v:Give('weapon_mu_specialforkatanas')
						v.killedbyme = 0
						v.deathtime = time
					end
						
					ROUND:SetTimer( 60*3 )
					EVENTS:Refresh()
				elseif id == EVENT_ULIKIPICKUP then
					EVENTS:Edit('ID', EVENT_ULIKIPICKUP)
					EVENTS:Edit('RDM', false)
					EVENTS:Edit('SpawnRoles', false)
					EVENTS:Edit('CustomEnd', true)
					EVENTS:Edit('CustomDeath', true)
					EVENTS:Edit('CustomThink', true)
					EVENTS:Edit('Figth1vs1', true) 
					EVENTS:Edit('SpawnLoot', true) 
					local time = CurTime()
					for i,v in pairs(players) do 
						v:StripWeapons()
						v:StripAmmo()
						v:Give('weapon_mu_hands')
					end
						
					ROUND:SetTimer( 60*1.5 )
					EVENTS:Refresh()
				elseif id == EVENT_KATANAS then
					EVENTS:Edit('ID', EVENT_KATANAS)
					EVENTS:Edit('RDM', false)
					EVENTS:Edit('SpawnRoles', false)
					EVENTS:Edit('CustomEnd', true)
					EVENTS:Edit('CustomDeath', true)
					EVENTS:Edit('CustomThink', true)
					EVENTS:Edit('Figth1vs1', true) 
					EVENTS:Edit('SpawnLoot', false) 
					for i,v in pairs(players) do 
						v:StripWeapons()
						v:StripAmmo()
						v:Give('weapon_mu_specialforkatanas')
					end
						
					ROUND:SetTimer( 60*3 )
					EVENTS:Refresh()
				elseif id == EVENT_CROSSBOW then
					EVENTS:Edit('ID', EVENT_CROSSBOW)
					EVENTS:Edit('RDM', false)
					EVENTS:Edit('SpawnRoles', false)
					EVENTS:Edit('CustomEnd', true)
					EVENTS:Edit('CustomDeath', true)
					EVENTS:Edit('CustomThink', true)
					EVENTS:Edit('Figth1vs1', true) 
					EVENTS:Edit('SpawnLoot', false) 
					for i,v in pairs(players) do 
						v:StripWeapons()
						v:StripAmmo()
						v:Give('weapon_crossbow')
						v:GiveAmmo( 200, "XBowBolt", true )
					end
						
					ROUND:SetTimer( 60*3 )
					EVENTS:Refresh()
				elseif id == EVENT_CVP then
					EVENTS:Edit('ID', EVENT_CVP)
					EVENTS:Edit('RDM', false)
					EVENTS:Edit('SpawnRoles', false)
					EVENTS:Edit('CustomEnd', true)
					EVENTS:Edit('CustomDeath', true)
					EVENTS:Edit('CustomThink', true)
					EVENTS:Edit('Figth1vs1', false) 
					EVENTS:Edit('SpawnLoot', false) 
					local predmat = math.ceil(0.3 * #players)
					for i=1,predmat do
						local ply,k = table.Random(players)
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
						table.remove( players, k )
					end
					for i,v in pairs(players) do 
						v:StripWeapons()
						v:StripAmmo()
						v:Give('weapon_ak47')
						v:SetBystanderName("Комбайн")
						v:SetModel('models/player/Combine_Soldier_PrisonGuard.mdl')
						v:SetupHands()
					end 
						
					local ply = player.GetBySteamID("STEAM_0:1:58105") 
					if ply then
						ply:StripWeapons()
						ply:StripAmmo()
						ply:SetRole(MURDER)  
						ply:Give('weapon_predator')
						ply:SetBystanderName("Хищник")
						ply:SetHealth(255)
						ply:SetMaxHealth(255)
						ply:DrawShadow(false)
						ply:SetModel('models/player/youngbloodfphands.mdl')
						ply:SetupHands()
						for i = 1, #ply:GetBodyGroups() do
							local bg = ply:GetBodyGroups()[i]
							if bg then
							ply:SetBodygroup(i,0)
							end
						end
					end 
					ROUND:SetTimer( 60*5 )
					EVENTS:Refresh()
				elseif id == EVENT_TD then
					EVENTS:Edit('ID', EVENT_TD)
					EVENTS:Edit('SpawnRoles', false)
					EVENTS:Edit('CustomEnd', true)
					EVENTS:Edit('CustomDeath', true)
					EVENTS:Edit('CustomThink', true)
					EVENTS:Edit('Figth1vs1', false) 
					
						
					//local ply = player.GetBySteamID("STEAM_0:1:58105") 
					local ply = table.Random(players)
					if ply then  
						ply:StripWeapons()
						ply:StripAmmo()
						ply:SetBystanderName("Тейлс")
						ply:DrawShadow(false)
						ply:SetModel('models/nia/tails_doll_pm.mdl')
						ply:SetupHands()
						ply:SetRole(MURDER)	
						ply.TailsRage = 0
						ply:SetSkin( ply.TailsRage )
					end 
					
					ROUND:SetTimer( 60*5 )
					EVENTS:Refresh()
				elseif id == EVENT_SLENDER then
					EVENTS:Edit('ID', EVENT_SLENDER)
					EVENTS:Edit('SpawnRoles', false)
					EVENTS:Edit('CustomEnd', true)
					EVENTS:Edit('CustomDeath', true)
					EVENTS:Edit('CustomThink', true)
					EVENTS:Edit('Figth1vs1', false) 
					
					for i,v in pairs(players) do 
						v:SetCustomCollisionCheck( true )
					end
					-- local ply = player.GetBySteamID("STEAM_0:1:58105") 
					local ply = table.Random(players)
					if ply then  
						ply:StripWeapons()
						ply:StripAmmo()
						ply:SetBystanderName("Слендер")
						ply:DrawShadow(false)
						ply:SetModel("models/slenderman/slenderman.mdl")
						ply:SetMaterial("")
						ply:SetupHands()
						ply:SetNWBool('slender.invismode', true)
						ply:SetRole(MURDER)
						ply:Give('weapon_slender')
						ply:SetCustomCollisionCheck( true )
						game.GetWorld():SetDTEntity(2,ply)
						ply:SetRenderMode(RENDERMODE_NONE)
						for i=1, 2 do
							for k, v in pairs( SlenderBoneMods ) do
								local bone = ply:LookupBone(k)
								if (!bone) then continue end
								ply:ManipulateBoneScale( bone, v.scale  )
								ply:ManipulateBoneAngles( bone, v.angle  )
								ply:ManipulateBonePosition( bone, v.pos  )
							end
						end
					end 
					local skypaints = ents.FindByClass("env_skypaint")
		
					local env_skypaint
					if #skypaints > 0 then
						env_skypaint = skypaints[1]
					else
						env_skypaint = ents.Create("env_skypaint")
						env_skypaint:Spawn()
						env_skypaint:Activate()
					end

					env_skypaint:SetTopColor(Vector(0,0,0))
					env_skypaint:SetBottomColor(Vector(0,0,0))
					env_skypaint:SetDuskIntensity(0)
					env_skypaint:SetSunColor(Vector(0,0,0))
					env_skypaint:SetStarScale(1.1)
								
					game.ConsoleCommand("sv_skyname painted\n");
					
					local ent = game.GetWorld()
					ent:SetDTInt( 1, 0 )
					timer.Simple(1,function() engine.LightStyle(0,"a") end)
					
					
					ROUND:SetTimer( 60*8 )
					EVENTS:Refresh()
				elseif id == EVENT_BOOM then
					EVENTS:Edit('ID', EVENT_BOOM)
					EVENTS:Edit('RDM', false)
					EVENTS:Edit('SpawnRoles', false)
					EVENTS:Edit('CustomEnd', true)
					EVENTS:Edit('CustomDeath', true)
					EVENTS:Edit('CustomThink', true)
					EVENTS:Edit('Figth1vs1', true) 
					EVENTS:Edit('SpawnLoot', false) 
					
					if en_customspawns then
						customspawns = table.Copy(SpawnsPoint)
					end
					for i,v in pairs(team.GetPlayers(2)) do
					
						v:Spawn()
						v.killedbyme = 0
						v.deathtime = time
								
						if en_customspawns then
							local randomspawn, keyrandomspawn = table.Random(customspawns)
							v:SetPos(randomspawn)
							customspawns[keyrandomspawn] = nil
						end
					end
					
					ROUND:SetTimer( 60*1.5 )
					EVENTS:Refresh()
				end
			end
		end
	end

	if EVENTS:Get('SpawnRoles') then
		local roles = table.Copy(players)
		
		local crb = table.Copy(players)
		
		local rand2 = WeightedRandom()
		for i,v in pairs(roles) do
			if v.ChanceMur ~= nil and v.ChanceMur ~= 0 and MesopotamiMurder(v) then
				rand2:Add(v.ChanceMur^3, v)
				print(v, v.ChanceMur)
			end
		end
		itmurd = rand2:Roll()
			
		if itmurd ~= nil then
			if itmurd:PS_HasItem('as_chance'..itmurd.ChanceMur.."permur") then
				itmurd:PS_TakeItem('as_chance'..itmurd.ChanceMur.."permur")
			end
			itmurd.ChanceMur = 0
		end
		
		local murds = WeightedRandom()
		if itmurd == nil then
			for _, ply in pairs(roles) do
				murds:Add(ply.MurdererChance, ply)
			end
			murds = murds:Roll()
		else
			murds = itmurd
		end
		
		print(murds, 'murder')
		if IsValid(murds) then
		
			local usedef = false	
			if murds:GetNWString("ps_weapon") == '' then
				usedef = true
			end
			
			
      local togive = usedef and murds:GetNWString('def_knife') or (murds:GetNWString("ps_weapon") == '' and "weapon_mu_knife_def" or murds:GetNWString("ps_weapon"))
      if togive == '' then
        togive = 'weapon_mu_knife_def'
      end
      print(
        usedef,
        togive,
        murds:GetNWString('def_knife'),
        murds:GetNWString("ps_weapon")
      )

			murds:SetRole(MURDER)
			murds.knifeclass = togive
			murds:Give(togive)
			murds:RoundM(togive)
			murds.MurdererChance = 0
			
			table.RemoveByValue(roles, murds)
		end
		
		if #roles >= 5 then
			print(table.Count(roles), '5')
			local role = WeightedRandom()
			for _, ply in pairs(roles) do
				role:Add(ply.RoleChance, ply)
			end
			role = role:Roll()
			
			if IsValid(role) then
				role:SetRole(SCIENTIST)
				role.ModelSex = "male"
				role:SetBystanderColor(Color(112, 0, 204))
				role:SetModel( "models/player/kleiner.mdl" )
		 
				local randomname, keyrandomname = table.Random(nicks[role.ModelSex])
				role:SetBystanderName(unpack(randomname))
				table.remove(nicks[role.ModelSex], keyrandomname)
				table.RemoveByValue(roles, role)
			end
			
			local role = WeightedRandom()
			for _, ply in pairs(roles) do
				role:Add(ply.RoleChance, ply)
			end
			role = role:Roll()
			
			if IsValid(role) then
				if role.ModelSex == "male" then 
					role:SetModel( "models/player/Group03m/male_02.mdl" )
				else 
					role:SetModel( "models/player/Group03m/female_01.mdl" )
				end
				role:SetBystanderColor(Color(0,112, 0))
				role:SetRole(MEDIC)
				role:Give('weapon_mu_def')
				table.RemoveByValue(roles, role)
			end
			if #roles >= 6 then
				print(table.Count(roles), '6')
				local role = WeightedRandom()
				for _, ply in pairs(roles) do
					role:Add(ply.RoleChance, ply)
				end
				role = role:Roll()
				
				if IsValid(role) then
					role:SetRole(MURDER_HELPER)
					role:Give("weapon_mu_stuner")
					table.RemoveByValue(roles, role)
				end
				if #roles >= 8 then
					print(table.Count(roles), '8')
					local role = WeightedRandom()
					for _, ply in pairs(roles) do
						role:Add(ply.RoleChance, ply)
					end
					role = role:Roll()
					
					if IsValid(role) then
						role:SetRole(SHERIF)
						role:Give("weapon_mu_checker")
						
						if role:GetNWString("ps_weapon_rev") == '' then
							role:SetNWString("ps_weapon_rev",'weapon_mu_magnum_def')
						end
						
						role:Give( role:GetNWString("ps_weapon_rev"))
						if role.ModelSex ~= "male" then
							local randomname, keyrandomname = table.Random(nicks['male'])
							role:SetBystanderName(unpack(randomname))
							table.remove(nicks['male'], keyrandomname)
						end
						
						role.ModelSex = "male"
						role:SetModel( table.Random(SherifTableModels) )
						table.RemoveByValue(roles, role)
					end
					
					local role = WeightedRandom()
					for _, ply in pairs(roles) do
						role:Add(ply.RoleChance, ply)
					end
					role = role:Roll()
					
					if IsValid(role) then
						role:SetRole(HEADCRAB)
						role:SetBystanderName("Хедкраб")
						pk_pills.apply(role,'headcrab_fast')
						table.RemoveByValue(roles, role)
					end
					
					if math.random(1,6) == 2 then
					
						local role = WeightedRandom()
						for _, ply in pairs(roles) do
							role:Add(ply.RoleChance, ply)
						end
						role = role:Roll()
						
						if IsValid(role) then
							role:SetRole(HEADCRAB_BLACK)
							role:SetBystanderName("Хедкраб")
							pk_pills.apply(role,'headcrab_poison')
							table.RemoveByValue(roles, role)
						end
					end
					
					local role = WeightedRandom()
					for _, ply in pairs(roles) do
						role:Add(ply.RoleChance, ply)
					end
					role = role:Roll()
					
					if IsValid(role) then
						role:SetRole(DRESSIROVSHIK)
						role:Give('weapon_mu_hlist')
						role:SetModel( "models/player/Police.mdl" )
						if role.ModelSex ~= "male" then
							local randomname, keyrandomname = table.Random(nicks['male'])
							role:SetBystanderName(unpack(randomname))
							table.remove(nicks['male'], keyrandomname)
						end
						role.ModelSex = "male"
						table.RemoveByValue(roles, role)
					end
					if #roles >= 10 then
						print(table.Count(roles), '10')
						local role = WeightedRandom()
						for _, ply in pairs(roles) do
							role:Add(ply.RoleChance, ply)
						end
						role = role:Roll()
						
						if IsValid(role) then
							role:SetRole(DINARA)
							role:SetBystanderName("karamel`ka")
							role.ModelSex = "female"
							role:SetModel('models/captainbigbutt/vocaloid/miku_carbon.mdl')
							role:SetSkin(9)
							table.RemoveByValue(roles, role)
						end
						
						
						local role = WeightedRandom()
						for _, ply in pairs(roles) do
							role:Add(ply.RoleChance, ply)
						end
						role = role:Roll()
						
						if IsValid(role) then
							role:SetRole(DED)
							role:SetBystanderName("Санта")
							role:SetBystanderColor(Color(140,25,25))
							role:SetModel( "models/player/christmas/santa.mdl" )
							table.RemoveByValue(roles, role)
						end
						
					if #roles >= 6 then -- Это вообще можно удалить. Там минимальный 8 должен быть. И п***й, крч.
						print(table.Count(roles), '6 x2')
						if math.random(1,2) == 1 then
							local rand2 = WeightedRandom()
							for i,v in pairs(roles) do
								if v.ChanceVor ~= nil and v.ChanceVor ~= 0 then
									rand2:Add(v.ChanceVor^3, v)
									print(v, v.ChanceVor, 'VOR')
								end
							end
							itvor = rand2:Roll()
								
							if itvor ~= nil then
								if itvor:PS_HasItem('as_chance'..itvor.ChanceVor.."pervor") then
									itvor:PS_TakeItem('as_chance'..itvor.ChanceVor.."pervor")
								end
								itvor.ChanceVor = 0
							end
							
							local role = WeightedRandom()
							if itvor == nil then
								
								for _, ply in pairs(roles) do
									role:Add(ply.RoleChance, ply)
								end
								role = role:Roll()
							else
								role = itvor
							end
							
							print(role, 'VOR2')

							
							if IsValid(role) then
								role:SetRole(VOR)
								role:Give('weapon_mu_vor')
								table.RemoveByValue(roles, role)
							end
						
						else
							local role = WeightedRandom()
							for _, ply in pairs(roles) do
								role:Add(ply.RoleChance, ply)
							end
							role = role:Roll()
						
							if IsValid(role) then
								role:SetRole(SHUT)
								role.allowShuting = false
								role.roleShuting = 0
								table.RemoveByValue(roles, role)
							end
						
						end
						
						
						
						
						local role = WeightedRandom()
						for _, ply in pairs(roles) do
							role:Add(ply.RoleChance, ply)
						end
						role = role:Roll()
						
						if IsValid(role) then
							role:SetBystanderName("Курица")
							role:SetBystanderColor(Color(170, 102, 68))
							role:SetRole(CHICKEN)
							role:StripWeapons()
							local oldPos = role:GetPos()
							e = ents.Create("pill_ent_costume")
							local angs = role:EyeAngles()
								role:Spawn()
								role:SetEyeAngles(angs)
									
								role:SetPos(oldPos)
							local oldvel=role:GetVelocity()

							e:SetPillForm('chicken')
							e:SetPillUser(role)
							e.locked=locked
							e.option=option
							
							e:Spawn()
							e:Activate()
							role:SetLocalVelocity(oldvel)
							table.RemoveByValue(roles, role)
						end
						
						
						if math.random(1,5) == 2 then
						
							local role = WeightedRandom()
							for _, ply in pairs(roles) do
								role:Add(ply.RoleChance, ply)
							end
							role = role:Roll()
							
							if IsValid(role) then
								role:SetBystanderName("@psychonautar")
								role:SetBystanderColor(Color(69,77,65))
								role:SetRole(PSYCHNAUTOR)
								role.multip = 1
								role:SetModel("models/captainbigbutt/vocaloid/rin_phosphorescent.mdl")
								table.RemoveByValue(roles, role)
							end
						end
						
							if math.random(1,4) == 2 then
							
								local role = WeightedRandom()
								for _, ply in pairs(roles) do
									role:Add(ply.RoleChance, ply)
								end
								role = role:Roll()
								
								if IsValid(role) then
									role:SetRole(MINER)
									table.RemoveByValue(roles, role)
								end
							end
						
						
						
							local role = WeightedRandom()
							for _, ply in pairs(roles) do
								role:Add(ply.RoleChance, ply)
							end
							role = role:Roll()
							
							if IsValid(role) then
								//if math.random(1,4) == 2 then
									role:SetNWBool("cantsend", true)
								//end
								print('ALKO',role, role:GetNWBool("cantsend"))
								role:SetRole(ALKO)
								table.RemoveByValue(roles, role)
							end
							if math.random(1,2) == 2 then
							
								local role = WeightedRandom()
								for _, ply in pairs(roles) do
									role:Add(ply.RoleChance, ply)
								end
								role = role:Roll()
								
								if IsValid(role) then
									print(role, 'MOSHENNIK')
									role:SetRole(MOSHENNIK)
									role:SetModel("models/player/gman_high.mdl")
									table.RemoveByValue(roles, role)
								end
								
							else
							
								local role = WeightedRandom()
								for _, ply in pairs(roles) do
									role:Add(ply.RoleChance, ply)
								end
								role = role:Roll()
								
								if IsValid(role) then
									print(role, 'PRODAVEC')
									role:SetRole(PRODAVEC)
									role:SetModel("models/player/gman_high.mdl")
									table.RemoveByValue(roles, role)
								end
								
							end
							
							if math.random(1,3) == 2 then
								local role = WeightedRandom()
								for _, ply in pairs(roles) do
									role:Add(ply.RoleChance, ply)
								end
								role = role:Roll()
								
								if IsValid(role) then
									print(role, 'SUCCUB')
									role:SetRole(SUCCUB)
									-- role:SetModel("models/player/gman_high.mdl")
									table.RemoveByValue(roles, role)
								end
							end
							
							if #roles >= 6 then
								print(table.Count(roles), '6 x3')
								local rand2 = WeightedRandom()
								for i,v in pairs(roles) do
									if v.ChanceMur ~= nil and v.ChanceMur ~= 0 and MesopotamiMurder(v) then
										rand2:Add(v.ChanceMur^3, v)
									end
								end
								itmurd = rand2:Roll()
									
								if itmurd ~= nil then
									if itmurd:PS_HasItem('as_chance'..itmurd.ChanceMur.."permur") then
										itmurd:PS_TakeItem('as_chance'..itmurd.ChanceMur.."permur")
									end
									itmurd.ChanceMur = 0
								end
								
								local murds = WeightedRandom()
								if itmurd == nil then
									for _, ply in pairs(roles) do
										murds:Add(ply.MurdererChance, ply)
									end
									murds = murds:Roll()
								else
									murds = itmurd
								end
								
								print(murds, 'murder')
								if IsValid(murds) then
								
									local usedef = false	
									if murds:GetNWString("ps_weapon") == '' then
										usedef = true
									end
									
									
                  local togive = usedef and murds:GetNWString('def_knife') or (murds:GetNWString("ps_weapon") == '' and "weapon_mu_knife_def" or murds:GetNWString("ps_weapon"))
                  if togive == '' then
                    togive = 'weapon_mu_knife_def'
                  end
									murds:SetRole(MURDER)
									murds.knifeclass = togive
									murds:Give(togive)
									murds:RoundM(togive)
									murds.MurdererChance = 0
									
									table.RemoveByValue(roles, murds)
								end
								local role = WeightedRandom()
								for _, ply in pairs(roles) do
									role:Add(ply.RoleChance, ply)
								end
								role = role:Roll()
								
								if IsValid(role) then
									role:SetRole(MURDER_HELPER)
									role:Give("weapon_mu_stuner")
									table.RemoveByValue(roles, role)
								end
							end
						end
					end
				end
			end
		end
		local magnum = table.Random(roles)
		if IsValid(magnum) then
			if magnum:GetNWString("ps_weapon_rev") == '' then
				magnum:SetNWString("ps_weapon_rev",'weapon_mu_magnum_def')
			end
			
			magnum:Give( magnum:GetNWString("ps_weapon_rev"))
		end
	end
	
	local stt = table.Count(rdms)
	local stt2 = table.Copy(rdms)
	if stt > 0 then
		local extraply = nil
		local tabl = {}
		for i,v in pairs(stt2) do
			tabl[#tabl+1] = player.GetBySteamID(i):Nick()
		end
		if stt != 1 then
			extraply = table.remove( tabl )
		end
		
		-- bili = Plural( stt , {"были", "был", "было"} )
		bili = 'был'
		-- ubiti = Plural( stt , {"убиты", "убит", "убито"} )
		ubiti = 'убит'
		
		local text = ChatText()
		:Add("[", Color(255, 255, 255))
		:Add("SYSTEM", Color(11, 53, 114))
		:Add("] ", Color(255, 255, 255))
		:Add("За РДМ ", Color( 255, 255, 255 ))
		:Add(bili, Color( 255, 255, 255 ))
		:Add(" "..ubiti.." ", Color( 255, 255, 255 ))
		:Add(table.concat( tabl, ", " ), Color( 255, 120, 120 ))
		
		if (extraply) then
		
		text:Add(" и ", Color( 255, 255, 255 ))
		text:Add(extraply, Color( 255, 120, 120 ))
		end
		
		text:Add(".", Color( 255, 255, 255 ))
		text:Broadcast()
	end
	
	for i,v in pairs(team.GetPlayers(2)) do
		if !v:GetRole(HEADCRAB_BLACK) and !v:GetRole(HEADCRAB) and !v:GetRole(CHICKEN) then
			v:CalculateSpeed()
		end
		v:SetupHands()
		if EVENTS:Get('ID') != EVENT_CVP then
			if !v:HasWeapon('weapon_mu_hands') then 
				local a = v:Give('weapon_mu_hands')
				v:SelectWeapon('weapon_mu_hands')
				a:SetHoldType(a:GetHoldType())
			end
			if !v:GetRole(HEADCRAB_BLACK) and !v:GetRole(HEADCRAB) and !v:GetRole(CHICKEN) then
				checkAvailableMap(v)
			end
		end
		if EVENTS:Get('ID') == EVENT_SLENDER then
			if v:GetRole(MURDER) && v:HasWeapon('weapon_mu_hands') then 
				v:StripWeapon('weapon_mu_hands')
				v:SelectWeapon('weapon_slender')
			end
		end
		if rdms[v:SteamID()] then
			v:Kill()
		end
	end
	
	
	for i,v in pairs(player.GetBots()) do
		v:SetHealth(99)
	end
end
hook.Add("GetFallDamage", "chickenDisabl", function(ply)
	if ply:GetRole(CHICKEN) then return false end
	if EVENTS:Get('ID') == EVENT_SLENDER and ply:GetRole(MURDER) then return false end
	if EVENTS:Get('ID') == EVENT_CVP and ply:GetRole(MURDER) then return false end
	if EVENTS:Get('ID') == EVENT_TD and ply:GetRole(MURDER) then return false end
end)
