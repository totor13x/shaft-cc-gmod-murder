GM.Name 	= "Murder"
GM.Author 	= "Wajha"
GM.Email 	= ""
GM.Website 	= ""

function GM:SetupTeams()
	team.SetUp(1, 'Наблюдатели', Color(150, 150, 150))
	team.SetUp(2, 'Игроки', Color(26, 120, 245))
end

GM:SetupTeams()

Totor = {}
Totor.Roles = {}
--[[
Описание ролей
]]--

MURDER = 7 
Totor.Roles[MURDER] = {
	name = 'Убийца',
	desc = {'Убивайте других игроков, но будте аккуратны: среди них может быть помощник'},
	color = Color(200, 50, 50)
}

SCIENTIST = 8  
Totor.Roles[SCIENTIST] = {
	name = 'Учёный',
	desc = {'Вам дана возможность видеть время смерти, сколько осталось человек'},
	color = Color(112, 0, 204)
}

MEDIC = 9 
Totor.Roles[MEDIC] = {
	name = 'Врач',
	desc = {'У вас есть дефибриллятор'},
	color = Color(0, 112, 0)
}

MURDER_HELPER = 10
Totor.Roles[MURDER_HELPER] = {
	name = 'Пом. убийцы',
	desc = {'Старайтесь помочь убийце станя игрока шокером', 'С 5-ти улик Вы можете получить взрыв-пакет'},
	color = Color(238, 119, 51)
}

SHERIF = 11
Totor.Roles[SHERIF] = {
	name = 'Полицейский',
	desc = {'Вы можете обыскать игрока', 'Вам дана возможность единожды ошибиться в случайном убийстве невиновного'},
	color = Color(25,25,25)
}

WAJHA = 180 //Бессмысленно добавлять
Totor.Roles[WAJHA] = {
	name = 'Wajha',
	desc = {'ОПИСАНИЕ'},
	color = Color(255,255,255)
}

HEADCRAB = 181
Totor.Roles[HEADCRAB] = {
	name = 'Хедкраб',
	desc = {'Прыгни на человечка и получишь...',
					'',
					'R - открепить хедкраба от головы (если захватил)',},
	color = Color(141, 111, 54)
}

DRESSIROVSHIK = 182
Totor.Roles[DRESSIROVSHIK] = {
	name = 'Дрессировщик',
	desc = {'Поймай хедкраба тем самым помогая свидетелям...',
					'...ну или убийце',},
	color = Color(136, 17, 85)
}

DINARA = 183
Totor.Roles[DINARA] = {
	name = 'Карамелька',
	desc = false,
	color = false
}

DED = 186
Totor.Roles[DED] = {
	name = 'Санта',
	desc = {'Подарки'},
	color = false
}

ALKO = 187
Totor.Roles[ALKO] = {
	name = 'Алкоголик',
	desc = {'ОПИСАНИЕ'},
	color = Color(255,255,255)
}

VOR = 188
Totor.Roles[VOR] = {
	name = 'Вор',
	desc = {'У Вас имеется всевидящее око и все улики которые есть на карте вам видны','Вы можете обворовать игрока.', 'Доступны: дефибриллятор, нож, револьвер и бутыль водки'},
	color = Color(16,97,84)
}

CHICKEN = 189
Totor.Roles[CHICKEN] = {
	name = 'Курица',
	desc = {'Q'},
	color = false
}

PSYCHNAUTOR = 200
Totor.Roles[PSYCHNAUTOR] = {
	name = '@psychonautar',
	desc = {'Возвращает весь полученный урон.'},
	color = false
}

SUCCUB = 190
Totor.Roles[SUCCUB] = {
	name = 'Суккуб',
	desc = {'ОПИСАНИЕ'},
	color = Color(255,255,255)
}

SHUT = 191
Totor.Roles[SHUT] = {
	name = 'Шут',
	desc = {'ОПИСАНИЕ'},
	color = Color(190,100,100)
}

SUCCUB = 192
Totor.Roles[SUCCUB] = {
	name = 'Суккуб',
	desc = {'У тебя есть возможность пожирать души',
			'ЛКМ - Выбирает цель для поглощения',
			'Повторный ЛКМ - Убирает метку',},
	color = Color(0,0,0)
}

ALKO = 193
Totor.Roles[ALKO] = {
	name = 'Алкоголик',
	desc = false,
	color = Color(190,100,190)
}

MOSHENNIK = 194
Totor.Roles[MOSHENNIK] = {
	name = 'Мошенник',
	desc = false,
	color = Color(190,100,190)
}

PRODAVEC = 195
Totor.Roles[PRODAVEC] = {
	name = 'Продавец',
	desc = false,
	color = Color(190,100,190)
}

MINER = 196
Totor.Roles[MINER] = {
	name = 'Минер', 
	desc = false,
	color = Color(70,120,20)
}

HEADCRAB_BLACK = 197
Totor.Roles[HEADCRAB_BLACK] = Totor.Roles[HEADCRAB]

Disable_up = {
	[SCIENTIST] = true,
	[MEDIC] = true,
	[SHERIF] = true,
	[HEADCRAB] = true,
	[HEADCRAB_BLACK] = true,
	[DINARA] = true,
	[DRESSIROVSHIK] = true,
	[DED] = true,
	[CHICKEN] = true,
	[PSYCHNAUTOR] = true,
	[SUCCUB] = true,
	[PRODAVEC] = true,
	[MOSHENNIK] = true,
}

function Totor.DisableModelExpa(ply)
	if Disable_up[ply:GetRole()] then return false end
	if EVENTS:Get('ID') == EVENT_BUTCHER and ply:GetRole(MURDER_ROLE) then return false end
	if EVENTS:Get('ID') == EVENT_CVP then return false end
	if EVENTS:Get('ID') == EVENT_TD and ply:GetRole(MURDER) then return false end
	if EVENTS:Get('ID') == EVENT_SLENDER and ply:GetRole(MURDER) then return false end
	return true
end

function Totor.GetInfo(role)
	if Totor.Roles[role] then
		local inf = table.Copy(Totor.Roles[role])
		local boole, getinf = EventParsRoles(EVENTS:Get('ID'))
			if boole and getinf and getinf[role] then
				inf.name = getinf[role]
			end
		return inf.name, inf.desc, inf.color
	end
	
	return 'Невиновный', {'Найдите убийцу и убейте его'}, Color(50,50,203)
end


ROUND = {}
ROUND_TIMER = ROUND_TIMER or 0
function ROUND:GetTimer() 
	return ROUND_TIMER or 0
end

MUTE_NONE = 0
MUTE_NOTALIVE = 1
MUTE_ALIVE = 2

ROUNDTIMESET = 10*60

timer.Create("RoundTimerCalculate", 0.2, 0, function()
	if GAMEMODE.RoundStage != 1 then return end
	ROUND_TIMER = ROUND_TIMER - 0.2
	if ROUND_TIMER < 0 then ROUND_TIMER = 0 end
end)

if SERVER then
	util.AddNetworkString("DeathrunSyncRoundTimer")
	function ROUND:SyncTimer()
		net.Start("DeathrunSyncRoundTimer")
		net.WriteInt( ROUND:GetTimer(), 16 )
		net.Broadcast()
	end
	function ROUND:SyncTimerPlayer( ply )
		net.Start("DeathrunSyncRoundTimer")
		net.WriteInt( ROUND:GetTimer(), 16 )
		net.Send( ply )
	end
	function ROUND:SetTimer( s )
		ROUND_TIMER = s
		ROUND:SyncTimer()
	end
else
	net.Receive("DeathrunSyncRoundTimer", function( len, ply )
		ROUND_TIMER = net.ReadInt( 16 )
	end)
end
hook.Add("SetupMove", "DeathrunDisableSpectatorSpacebar", function( ply, mv, cmd )

	if ply:Alive() then
		if (GAMEMODE:GetRound( 1 ) and ply:GetNWInt("StartRoundCurTime")-CurTime() > 0) or ply:GetNWBool("DisabledWASD") then
					mv:SetSideSpeed( 0 )
					mv:SetUpSpeed( 0 )
					mv:SetForwardSpeed( 0 )
		end
	end
end)

hook.Add("StartCommand", "DeathrunDisableSpase", function( ply, mv, cmd )
	if ply:Alive() then

		if (GAMEMODE:GetRound( 1 ) and ply:GetNWInt("StartRoundCurTime")-CurTime() > 0) or ply:GetNWBool("DisabledWASD") then
				mv:ClearButtons()
				mv:ClearMovement()
		end
	end
end)
function PluralEdit(type, secs)
	local rounds_played2, tetd = ""
	if type == 'murds' then
		rounds_played2 = secs;
		local clear_explode = string.sub(rounds_played2, -1)
		clear_explode =	tonumber(clear_explode)
		
		if(clear_explode == 0) then
			tetd = 'убийц';
		elseif ((rounds_played2 == 11) or (rounds_played2 == 12) or (rounds_played2 == 13) or (rounds_played2 == 14)) then
			tetd = 'убийц';
		elseif (clear_explode == 1) then
			tetd = 'убийцы';
		elseif (clear_explode < 5) then
			tetd = 'убийц';
		else 
			tetd = 'убийц';
		end
	end
	return tetd
end

function sec2Min(secs)
local rounds_played2
local ostalost = "Осталось"

	if (secs < 60) then
	
	rounds_played2 = secs;
	local clear_explode = string.sub(rounds_played2, -1)
	clear_explode =	tonumber(clear_explode)
		if(clear_explode == 0) then
			tetd = 'секунд';
		elseif ((rounds_played2 == 11) or (rounds_played2 == 12) or (rounds_played2 == 13) or (rounds_played2 == 14)) then
			tetd = 'секунд';
		elseif (clear_explode == 1) then
			ostalost = "Осталась"
			tetd = 'секунда';
		elseif (clear_explode < 5) then
			tetd = 'секунды';
		else 
			tetd = 'секунд';
		end
	elseif (secs < 3600) then
		rounds_played2 = math.Round(secs / 60);
		
		local clear_explode = string.sub(rounds_played2, -1)
			  clear_explode =	tonumber(clear_explode)
		
		if(clear_explode == 0) then
			tetd = 'минут';
		elseif ((rounds_played2 == 11) or (rounds_played2 == 12) or (rounds_played2 == 13) or (rounds_played2 == 14)) then
			tetd = 'минут';
		elseif (clear_explode == 1) then
			ostalost = "Осталась"
			tetd = 'минута';
		elseif (clear_explode < 5) then
			tetd = 'минуты';
		else 
			tetd = 'минут';
		end
	elseif (secs < 86400) then
		rounds_played2 = math.Round(secs / 3600);
		
		local clear_explode = string.sub(rounds_played2, -1)
			  clear_explode =	tonumber(clear_explode)
		
		if(clear_explode == 0) then
			tetd = 'часов';
		elseif ((rounds_played2 == 11) or (rounds_played2 == 12) or (rounds_played2 == 13) or (rounds_played2 == 14)) then
			tetd = 'часов';
		elseif (clear_explode == 1) then
			ostalost = "Остался"
			tetd = 'час';
		elseif (clear_explode < 5) then
			tetd = 'часа';
		else 
			tetd = 'часов';
		end
	elseif (secs < 2629743) then
		rounds_played2 = math.Round(secs / 86400);
		
		local clear_explode = string.sub(rounds_played2, -1)
			  clear_explode =	tonumber(clear_explode)
		
		if(clear_explode == 0) then
			tetd = 'дней';
		elseif ((rounds_played2 == 11) or (rounds_played2 == 12) or (rounds_played2 == 13) or (rounds_played2 == 14)) then
			tetd = 'дней';
		elseif (clear_explode == 1) then
			ostalost = "Остался"
			tetd = 'день';
		elseif (clear_explode < 5) then
			tetd = 'дня';
		else 
			tetd = 'дней';
		end
	elseif (secs < 31556926) then
		rounds_played2 = math.Round(secs / 2629743);
		
		local clear_explode = string.sub(rounds_played2, -1)
			  clear_explode =	tonumber(clear_explode)
		
		if(clear_explode == 0) then
			tetd = 'месяцев';
		elseif ((rounds_played2 == 11) or (rounds_played2 == 12) or (rounds_played2 == 13) or (rounds_played2 == 14)) then
			tetd = 'месяцев';
		elseif (clear_explode == 1) then
			ostalost = "Остался"
			tetd = 'месяц';
		elseif (clear_explode < 5) then
			tetd = 'месяца';
		else 
			tetd = 'месяцев';
		end
	else
		rounds_played2 = math.Round(secs / 31556926);
		
		local clear_explode = string.sub(rounds_played2, -1)
			  clear_explode =	tonumber(clear_explode)
		
		if(clear_explode == 0) then
			tetd = 'лет';
		elseif ((rounds_played2 == 11) or (rounds_played2 == 12) or (rounds_played2 == 13) or (rounds_played2 == 14)) then
			tetd = 'лет';
		elseif (clear_explode == 1) then
			ostalost = "Остался"
			tetd = 'год';
		elseif (clear_explode < 5) then
			tetd = 'года';
		else 
			tetd = 'лет';
		end
	end
return ostalost..' '..rounds_played2..' '..tetd
end


function colorDif(col1, col2)
	local x = col1.r - col2.r
	local y = col1.g - col2.g
	local z = col1.b - col2.b
	x = x > 0 and x or -x
	y = y > 0 and y or -y
	z = z > 0 and z or -z
	return x + y + z
end

//Конфиг шерифа
SherifTableModels = {
	"models/portal/nypd/nypdmale_03.mdl",
	"models/portal/nypd/nypdmale_04.mdl",
	"models/portal/nypd/nypdmale_05.mdl",
	"models/portal/nypd/nypdmale_06.mdl",
	"models/portal/nypd/nypdmale_07.mdl",
	"models/portal/nypd/nypdmale_03_arm.mdl" ,
	"models/portal/nypd/nypdmale_04_arm.mdl",
	"models/portal/nypd/nypdmale_05_arm.mdl",
	"models/portal/nypd/nypdmale_06_arm.mdl",
	"models/portal/nypd/nypdmale_07_arm.mdl",
	"models/portal/nypd/nypdmale_03_b.mdl",
	"models/portal/nypd/nypdmale_04_b.mdl",
	"models/portal/nypd/nypdmale_05_b.mdl",
	"models/portal/nypd/nypdmale_06_b.mdl",
	"models/portal/nypd/nypdmale_07_b.mdl",
}

SherifTableModelsAcce = {
	["models/portal/nypd/nypdmale_03.mdl"] = "models/player/Group01/Male_05.mdl",
	["models/portal/nypd/nypdmale_04.mdl"] = "models/player/Group01/Male_06.mdl",
	["models/portal/nypd/nypdmale_05.mdl"] = "models/player/Group01/Male_07.mdl",
	["models/portal/nypd/nypdmale_06.mdl"] = "models/player/Group01/Male_08.mdl",
	["models/portal/nypd/nypdmale_07.mdl"] = "models/player/Group01/Male_08.mdl",
	["models/portal/nypd/nypdmale_03_arm.mdl"] = "models/player/Group01/Male_05.mdl",
	["models/portal/nypd/nypdmale_04_arm.mdl"] = "models/player/Group01/Male_06.mdl",
	["models/portal/nypd/nypdmale_05_arm.mdl"] = "models/player/Group01/Male_07.mdl",
	["models/portal/nypd/nypdmale_06_arm.mdl"] = "models/player/Group01/Male_08.mdl",
	["models/portal/nypd/nypdmale_07_arm.mdl"] = "models/player/Group01/Male_09.mdl",
	["models/portal/nypd/nypdmale_03_b.mdl"] = "models/player/Group01/Male_05.mdl",
	["models/portal/nypd/nypdmale_04_b.mdl"] = "models/player/Group01/Male_06.mdl",
	["models/portal/nypd/nypdmale_05_b.mdl"] = "models/player/Group01/Male_07.mdl",
	["models/portal/nypd/nypdmale_06_b.mdl"] = "models/player/Group01/Male_08.mdl",
	["models/portal/nypd/nypdmale_07_b.mdl"] = "models/player/Group01/Male_09.mdl",
}


local lp, ft, ct, cap = LocalPlayer, FrameTime, CurTime
local mc, mr, bn, ba, bo, gf = math.Clamp, math.Round, bit.bnot, bit.band, bit.bor, {}
--[[function GM:Move( ply, data )

	-- fixes jump and duck stop
	local og = ply:IsFlagSet( FL_ONGROUND )
	if og and not gf[ ply ] then
		gf[ ply ] = 0
	elseif og and gf[ ply ] then
		gf[ ply ] = gf[ ply ] + 1
		if gf[ ply ] > 4 then
			ply:SetDuckSpeed( 0.4 )
			ply:SetUnDuckSpeed( 0.2 )
		end
	end

	if og or not ply:Alive() then return end
	
	gf[ ply ] = 0
	ply:SetDuckSpeed(0)
	ply:SetUnDuckSpeed(0)

	if not IsValid( ply ) then return end
	if lp and ply ~= lp() then return end
	
	if ply:IsOnGround() or not ply:Alive() then return end
	
	local aim = data:GetMoveAngles()
	local forward, right = aim:Forward(), aim:Right()
	local fmove = data:GetForwardSpeed()
	local smove = data:GetSideSpeed()
	
	if data:KeyDown( IN_MOVERIGHT ) then smove = smove + 500 end
	if data:KeyDown( IN_MOVELEFT ) then smove = smove - 500 end
	
	forward.z, right.z = 0,0
	forward:Normalize()
	right:Normalize()

	local wishvel = forward * fmove + right * smove
	wishvel.z = 0

	local wishspeed = wishvel:Length()
	if wishspeed > data:GetMaxSpeed() then
		wishvel = wishvel * (data:GetMaxSpeed() / wishspeed)
		wishspeed = data:GetMaxSpeed()
	end

	local wishspd = wishspeed
	wishspd = mc( wishspd, 0, 30 )

	local wishdir = wishvel:GetNormal()
	local current = data:GetVelocity():Dot( wishdir )

	local addspeed = wishspd - current
	if addspeed <= 0 then return end

	local accelspeed = 1000 * ft() * wishspeed
	if accelspeed > addspeed then
		accelspeed = addspeed
	end
	
	local vel = data:GetVelocity()
	vel = vel + (wishdir * accelspeed)

	ply.SpeedCap = 99999
	
	if ply.SpeedCap and vel:Length2D() > ply.SpeedCap and SERVER then
		local diff = vel:Length2D() - ply.SpeedCap
		vel:Sub( Vector( vel.x > 0 and diff or -diff, vel.y > 0 and diff or -diff, 0 ) )
	end
	data:SetVelocity( vel )
	return false
end]]
/*
local function AutoHop( ply, data )

	if lp and ply ~= lp() then return end
	//if not ply:IsSuperAdmin() then return end
	//if ply:SteamID() != 'STEAM_0:1:68421988' then return end
	
	if !(EVENTS:GetID() == 0) then return end
	if !ply.allowbhop then return end	
	if ply:GetRole(HEADCRAB) then return end
	local ButtonData = data:GetButtons()
	if ba( ButtonData, IN_JUMP ) > 0 then
		if ply:WaterLevel() < 2 and ply:GetMoveType() ~= MOVETYPE_LADDER and not ply:IsOnGround() then
			data:SetButtons( ba( ButtonData, bn( IN_JUMP ) ) )
		end
	end
 //end  
end

hook.Add( "SetupMove", "AutoHop", AutoHop )
*/

/*
function ulx.movegroup( calling_ply, target_ply, team2 )
	local teamid
	if team2 == 'Игрок' then
		teamid = 2
	elseif team2 == 'Наблюдатель' then
		teamid = 1
	end
	
	local curTeam = target_ply:Team()
	local newTeam = teamid or 0
	if newTeam >= 1 && newTeam <= 2 && newTeam != curTeam then
	target_ply:SetTeam(newTeam)
	GAMEMODE:PlayerOnChangeTeam(target_ply, newTeam, curTeam)
		
		local femtext1
		local femtext2 = ""

		if newTeam == 1 then
			femtext2 = "наблюдатели"
		else
			femtext2 = "игроки"
		end
	ulx.fancyLogAdmin(calling_ply, "#A movegroup #T#s ", target_ply, femtext2)
	end
	
end

	//team.SetUp(1, 'Наблюдатели', Color(150, 150, 150))
	//team.SetUp(2, 'Игроки', Color(26, 120, 245))
local movegroup = ulx.command( "MURDER", "ulx movegroup", ulx.movegroup )
movegroup:addParam{ type=ULib.cmds.PlayerArg }
movegroup:addParam{ type=ULib.cmds.StringArg, hint="Перевод в", completes={'Игрок','Наблюдатель'}, ULib.cmds.restrictToCompletes } -- only allows 
movegroup:defaultAccess( ULib.ACCESS_SUPERADMIN )
movegroup:help( "Перевести в команду" )

function ulx.openSpisok( calling_ply )
	local a = util.JSONToTable(file.Read("endroundswrite.txt", "DATA"))
	net.Start('rounds_vgui')
		net.WriteTable(a)
	net.Send(calling_ply)
end

	//team.SetUp(1, 'Наблюдатели', Color(150, 150, 150))
	//team.SetUp(2, 'Игроки', Color(26, 120, 245))
local openSpisok = ulx.command( "MURDER", "ulx lastrounds", ulx.openSpisok )
openSpisok:defaultAccess( ULib.ACCESS_SUPERADMIN )
openSpisok:help( "Открывает список раундов. Пишет: игровой ник, роль, и реальный ник." )


function ulx.moveafk( calling_ply, target_ply)
	local tt = target_ply:Team()
	target_ply:SetTeam(1)
	GAMEMODE:PlayerOnChangeTeam(target_ply, 1, tt)
	net.Start("MovedAFKPlayer")
	net.Send(target_ply)
	
	ulx.fancyLogAdmin(calling_ply, "#A movegroup #T#s ", target_ply, 'наблюдатели из-за AFK')
end
	
	//team.SetUp(1, 'Наблюдатели', Color(150, 150, 150))
	//team.SetUp(2, 'Игроки', Color(26, 120, 245))
local moveafk = ulx.command( "MURDER", "ulx afk", ulx.moveafk, "!afk" )
moveafk:addParam{ type=ULib.cmds.PlayerArg }
moveafk:defaultAccess( ULib.ACCESS_SUPERADMIN )
moveafk:help( "Игрок AFK" )
*/

if SERVER then 
util.AddNetworkString("rdm_vgui")
util.AddNetworkString("rounds_vgui")
rdms = rdms or {}


hook.Add("PlayerDisconnected","Refresh_2rdms", function(ply) 
	if not (type(rdms) == 'table') then rdms = {} end 
		
	if rdms[ply:SteamID()] ~= nil then
		rdms[ply:SteamID()]=nil
	end
	
	net.Start("rdm_vgui")
	net.WriteTable(rdms)
	net.Broadcast()
	
end)

else
net.Receive("rounds_vgui",function(len, ply)
	local GlobalRoundTable = net.ReadTable()
	table.sort( GlobalRoundTable, function( a, b ) return a.id > b.id end )
	if IsValid(DFrameRoundBoard) then
	DFrameRoundBoard:Remove()
	end
		DFrameRoundBoard = vgui.Create('DFrame')
		DFrameRoundBoard:SetSize(600,400)
		DFrameRoundBoard:MakePopup()
		DFrameRoundBoard:SetTitle("Раунды")
		DFrameRoundBoard:Center()
		DFrameRoundBoard.ID = 1
		
		local buttonDock = vgui.Create('DPanel', DFrameRoundBoard)
		buttonDock:Dock( TOP )
		buttonDock.Paint = function(s,w,h)
			local bool, id, info = EventPars(GlobalRoundTable[DFrameRoundBoard.ID]['event'])
			
			local text = "Обычный раунд"
			if bool then
				text = "Ивент "..info.name
			end
			
			draw.SimpleText(text, "default", w/2, (h/2)-8, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(DFrameRoundBoard.ID.."|"..#GlobalRoundTable, "default", w/2, (h/2)+4, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		
		local DermaButton = vgui.Create( "DButton", buttonDock )
		DermaButton:Dock( LEFT ) 
		DermaButton:SetText("Назад") 
		DermaButton.Think = function(s)
			if DFrameRoundBoard.ID != 1 then
				s:SetDisabled(false)
			else	
				s:SetDisabled(true)
			end
			
		end
		DermaButton.DoClick = function()
		DFrameRoundBoard.ID = DFrameRoundBoard.ID - 1
		DFrameRoundBoard.RefreshDock()
		end
		
		
		local DermaButton = vgui.Create( "DButton", buttonDock )
		DermaButton:Dock( RIGHT )
		DermaButton:SetText("Вперед") 
		DermaButton.Think = function(s)
			if DFrameRoundBoard.ID != #GlobalRoundTable then
				s:SetDisabled(false)
			else	
				s:SetDisabled(true)
			end
			
		end
		DermaButton.DoClick = function()
		DFrameRoundBoard.ID = DFrameRoundBoard.ID + 1
		DFrameRoundBoard.RefreshDock()
		end
		
		
		local AppList = vgui.Create( "DListView", DFrameRoundBoard )
		AppList:Dock( FILL )
		AppList:SetMultiSelect( false )
		AppList:AddColumn( "Игровой ник" )
		AppList:AddColumn( "Реальный ник" )
		AppList:AddColumn( "Роль" )
		AppList:AddColumn( "Тип" )
		
		//for i,v in pairs() do
			//print(v)
		DFrameRoundBoard.RefreshDock = function()
			AppList:Clear()
			for _, ply in pairs(GlobalRoundTable[DFrameRoundBoard.ID]['plys']) do
				local nick, desc, color = Totor.GetInfo(ply.role)
				AppList:AddLine( ply.bname, ply.nick.." ("..ply.sid..")",nick, ply['team'] == 1 and "наблюдатель" or 'игрок' )
			end
		end
		DFrameRoundBoard.RefreshDock()
end)
//PrintTable(GlobalRoundTable)
	//end


net.Receive("rdm_vgui",function(len, ply)
	local rdms = net.ReadTable()
	
	rdmsPlayers = rdms
end)
end


if (CLIENT) then
	hook.Add("PostDrawOpaqueRenderables", "blink_Preview", function()
		local player = LocalPlayer();
		if player.GetActiveWeapon then
			local weapon = player:GetActiveWeapon();
			if (!IsValid(weapon)) then return; end;
			if !weapon.IsTP then return end
			if (weapon.Draw3D) then
				weapon:Draw3D();
			end;
		end
	end);
end;

hook.Add("Move", "blink_Move", function(player, data)
	if (player:GetNWBool("blink", false)) then
		if player.GetActiveWeapon then
		local weapon = player:GetActiveWeapon();
		
		if (!IsValid(weapon)) then
			player:SetNWBool("blink", false);
			return;
		end;
		
		if !weapon.IsTP then 
			player:SetNWBool("blink", false);
			return;
		end
		
		local targetPos = player:GetNWVector("blinkPos", vector_origin);
		local start = player:GetNWVector("blinkStart", data:GetOrigin());
		local travelTime = player:GetNWFloat("blinkTime", 4);
		local speed = weapon.TravelSpeed;

		if (!player.blinkNormal) then
			player.blinkNormal = (targetPos - start):GetNormalized();
			player.blinkStart = CurTime();
		end;

		local elapsed = CurTime() - player.blinkStart;

		local origin = start + player.blinkNormal * math.min((math.min(elapsed, travelTime) * speed), weapon.TravelDistance);

		data:SetOrigin(origin);
		data:SetVelocity(vector_origin);

		if (elapsed >= travelTime) then
			player:SetNWBool("blink", false);
			player:SetNotSolid(false);
			player:SetMoveType(MOVETYPE_WALK);
			data:SetVelocity(vector_origin);
			data:SetOrigin(targetPos);
			player:SetNWFloat("nextBlink", CurTime() + 0.5);
		end;

		return true;
	else
		player.blinkNormal = nil;
		player.blinkStart = nil;
	end;
	end;
end);

hook.Add("KeyPress", "blink_DoubleJump", function(player, key)
	if (player:OnGround() and key == IN_JUMP) then		
		if player.GetActiveWeapon then
			local weapon = player:GetActiveWeapon();
			if (!IsValid(weapon)) then return; end;
		

		if !weapon.IsTP then 
			return;
		end
		

		
		timer.Create("doubleJump_" .. player:EntIndex(), 0.25, 1, function()
			if (IsValid(player)) then
				local curVel = player:GetVelocity();
				curVel.z = player:GetJumpPower() * 1.2;

				player:SetLocalVelocity(curVel);
			end;
		end);
	end;
	end;
end);

hook.Add("KeyRelease", "blink_DoubleJump", function(player, key)
	if (key == IN_JUMP) then
		timer.Remove("doubleJump_" .. player:EntIndex());
	end;
end);


hook.Add('TTS.TFA::MakeSWEP', 'MakeSpecificEntities', function(class, base, name) 
	-- local 
	if string.find(class, 'mu_knife') then
		local swep = weapons.GetStored(class)
		-- print(class, base, name)
		local ent_class = string.Replace(class, 'weapon_', '')
		local ent_base = string.Replace(base, 'weapon_', '')
		
		swep.ENT = ent_class
		
		local ENT = {}
		ENT.Base = ent_base
		ENT.WeaponClass = class
		if TFA.CSGO.Skins[class] and TFA.CSGO.Skins[class][name] then
			local id = TFA.CSGO.Skins[class][name]['id']
			ENT.Skin = id
		end
		
		scripted_ents.Register(ENT, ent_class)
		-- SWEP.ENT = string.Replace(class, "weapon_", "") //mu_knife_bayonet_dopple
		
		-- base_ent = string.Replace(base, "weapon_", "")//mu_knife_bayonet
		
		-- local ENT = {}
		-- ENT.Base = base_ent		
		-- ENT.WeaponClass = class
		-- ENT.Skin = "!"
		
		-- scripted_ents.Register(ENT, SWEP.ENT)
	end
end)