local taunts = {}

function addTaunt(cat, soundFile, sex)
	if !taunts[cat] then
		taunts[cat] = {}
	end
	if !taunts[cat][sex] then
		taunts[cat][sex] = {}
	end
	local t = {}
	t.sound = soundFile
	t.sex = sex
	t.category = cat
	table.insert(taunts[cat][sex], t)
end
// male
addTaunt("help", "vo/rus/male/help01.wav", "male")
addTaunt("scream", "vo/rus/male/no01.wav", "male")
addTaunt("scream", "vo/rus/male/no02.wav", "male")
addTaunt("scream", "vo/rus/male/headsup01.wav", "male")
addTaunt("scream", "vo/rus/male/headsup02.wav", "male")
addTaunt("scream", "vo/rus/male/runforyourlife01.wav", "male")
addTaunt("scream", "vo/rus/male/strider_run.wav", "male")
addTaunt("scream", "vo/rus/male/watchout.wav", "male")
addTaunt("morose", "vo/rus/male/gordead_ans06.wav", "male")
addTaunt("morose", "vo/rus/male/gordead_ques07.wav", "male")
addTaunt("morose", "vo/rus/male/question21.wav", "male")
addTaunt("funny", "vo/rus/male/question02.wav", "male")
addTaunt("funny", "vo/rus/male/question29.wav", "male")
addTaunt("funny", "vo/rus/male/question30.wav", "male")
addTaunt("think", "vo/rus/male/wetrustedyou01.wav", "male")
addTaunt("think", "vo/rus/male/wetrustedyou02.wav", "male")

addTaunt("morose", "vo/rus/male/question04.wav", "male")
addTaunt("morose", "vo/rus/male/question11.wav", "male")
addTaunt("see", "vo/rus/male/gordead_ans17.wav", "male")
addTaunt("see", "vo/rus/male/hi01.wav", "male")
addTaunt("see", "vo/rus/male/vquestion03.wav", "male")
addTaunt("see", "vo/rus/male/whoops01.wav", "male")

// female
addTaunt("help", "vo/rus/female/help01.wav", "female")
addTaunt("scream", "vo/rus/female/gethellout.wav", "female")
addTaunt("scream", "vo/rus/female/headsup02.wav", "female")
addTaunt("scream", "vo/rus/female/watchout.wav", "female")
addTaunt("scream", "vo/rus/female/strider_run.wav", "female")
addTaunt("scream", "vo/rus/female/runforyourlife01.wav", "female")
addTaunt("scream", "vo/rus/female/runforyourlife02.wav", "female")
addTaunt("morose", "vo/rus/female/question21.wav", "female")
addTaunt("morose", "vo/rus/female/gordead_ans06.wav", "female")
addTaunt("morose", "vo/rus/female/gordead_ques10.wav", "female")
addTaunt("funny", "vo/rus/female/question29.wav", "female")
addTaunt("funny", "vo/rus/female/question02.wav", "female")
addTaunt("funny", "vo/rus/female/question30.wav", "female")
addTaunt("think", "vo/rus/female/wetrustedyou01.wav", "female")
addTaunt("think", "vo/rus/female/wetrustedyou02.wav", "female")

addTaunt("see", "vo/rus/female/gordead_ans17.wav", "female")
addTaunt("see", "vo/rus/female/hi01.wav", "female")
addTaunt("see", "vo/rus/female/hi02.wav", "female")
addTaunt("morose", "vo/rus/female/question04.wav", "female")
addTaunt("morose", "vo/rus/female/question11.wav", "female")
addTaunt("see", "vo/rus/female/vquestion03.wav", "female")

addTaunt("me", "vo/rus/male/startle01.wav", "male")
addTaunt("me", "vo/rus/male/startle02.wav", "male")
addTaunt("me", "vo/rus/female/startle01.wav", "female")
addTaunt("me", "vo/rus/female/startle02.wav", "female")

addTaunt("taunt_ps", "vo/rus/male/startle01.wav", "male")
addTaunt("taunt_ps", "vo/rus/male/startle02.wav", "male")
addTaunt("taunt_ps", "vo/rus/female/startle01.wav", "female")
addTaunt("taunt_ps", "vo/rus/female/startle02.wav", "female")


concommand.Add("mu_taunt", function (ply, com, args, full)
	if ply.LastTaunt && ply.LastTaunt > CurTime() then return end
	if !ply:Alive() then return end
	if ply:Team() != 2 then return end

	if EVENTS:Get('ID') == EVENT_BUTCHER then
		if ply:GetRole(MURDER) then
			return 
		end
	end
	
	if ply:GetRole(CHICKEN) then 
		AngleZ = ply:GetPos()
		AngleZ.z = AngleZ.z - 200
		local tr = util.TraceLine( {
			start = ply:GetPos(),
			endpos = AngleZ			,
		
		} )
		local data = {}
		data.model = 'models/props/cs_italy/orange.mdl'
		data.pos = tr.HitPos
		data.angle = ply:GetAngles()
		GAMEMODE:SpawnLootItem(data)
		if ply:SteamID() == 'STEAM_0:1:58105' or ply:SteamID() == 'STEAM_0:0:145469904' or ply:SteamID() == 'STEAM_0:1:48023335' then 
		ply.LastTaunt = CurTime() + 0.05
		else
		ply.LastTaunt = CurTime() + 7
		end
		return
	end
	if #args < 1 then return end
	local cat = args[1]:lower()
	if !taunts[cat] then return end

	local sex = string.lower(ply.ModelSex or "male")
	if !taunts[cat][sex] then return end
	-- if math.random(1,4) == 2 then
	-- //Death
	-- //OnKill
	-- //PriProhojdenii
	-- local table.Random
	if cat == 'taunt_ps' then
		local id, typ, taunt = ply:GetActualTauntRandom(table.Random({"OnKill", "Death", "PriProhojdenii"}))
		if id then
			local link = "https://storage.shaft.cc/taunts/"..id.."/"..typ.."/"..taunt
			netstream.Start(_, "TTS::PlayTaunt", ply, link)
			ply.LastTaunt = CurTime() + 4
			return 
		end
	end
	local taunt = table.Random(taunts[cat][sex])
	ply:EmitSound(taunt.sound)
	ply.LastTaunt = CurTime() + SoundDuration(taunt.sound) + 1.5
	
	if args[2] then
	local plymaybe = player.GetBySteamID( args[2] )
	if not plymaybe then return end
	if not plymaybe:IsValid() then return end
	local plyclr = ply:GetBystanderColor(true)
	local plymaybeclr = plymaybe:GetBystanderColor(true)
	local text = ''
	ply.LastTaunt = CurTime() + 5
	if cat == 'see' then
		text = 'Я вижу'
		local ct = ChatText()
		ct:Add(ply:GetBystanderName(), plyclr)
		ct:Add(": "..text, Color(255,255,255))
		ct:Add(" "..plymaybe:GetBystanderName(), plymaybeclr)
		ct:Broadcast()
	elseif cat == 'think' then
		text = 'Я думаю'
		local ct = ChatText()
		ct:Add(ply:GetBystanderName(), plyclr)
		ct:Add(": "..text, Color(255,255,255))
		ct:Add(" "..plymaybe:GetBystanderName(), plymaybeclr)
		ct:Add(" убийца", Color(255,255,255))
		ct:Broadcast()
	elseif cat == 'me' then
		if ply:GetNWBool("saysey") then
			local nick, desc, color = Totor.GetInfo(ply:GetRole())
			local byscol = ply:GetBystanderColor(true)

			if !color then
				color = byscol
			end
			text = 'Я '
			local ct = ChatText()
			ct:Add(ply:GetBystanderName(), plyclr)
			ct:Add(": "..text, Color(255,255,255))
			ct:Add(nick, color)
			ct:Broadcast()
			ply:SetNWBool("saysey", false)
			ply.LastTaunt = CurTime() + 0
		end
	end
	

    end
	
end)