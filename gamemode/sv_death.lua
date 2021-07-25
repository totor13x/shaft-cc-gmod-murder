function GM:DeathRoles(ply, attacker)
	
	if rdms[ply:SteamID()] ~= nil and rdms[ply:SteamID()]["round"]~=0 then
		rdms[ply:SteamID()]=nil
		net.Start("rdm_vgui")
		net.WriteTable(rdms)
		net.Broadcast()
	end

	local isrdm = true
	
	if EVENTS:Get('ID') == EVENT_CROSSBOWHARD or EVENTS:Get('ID') == EVENT_KATANASHARD or EVENTS:Get('ID') == EVENT_BOOM then
		if ( ply:IsPlayer() and attacker:IsPlayer() ) then
			attacker.killedbyme = attacker.killedbyme + 1
			ply.deathtime = CurTime()
		end
	end
	if 
		EVENTS:Get('ID') == EVENT_CROSSBOWHARD or 
		EVENTS:Get('ID') == EVENT_KATANASHARD or  
		EVENTS:Get('ID') == EVENT_KATANAS or 
		EVENTS:Get('ID') == EVENT_CROSSBOW or 
		EVENTS:Get('ID') == EVENT_AK47 
			then
			attacker:PlayTaunt("OnKill") 
			ply:PlayTaunt("Death") 
	end
	if EVENTS:Get('ID') == EVENT_CVP then
		if !attacker:GetRole(MURDER) then
			attacker:PlayTaunt("OnKill") 
		end
		ply:PlayTaunt("Death") 
	end

	if EVENTS:Get('ID') == EVENT_CROSSBOWHARD then
		attacker:GiveAmmo( 5, "XBowBolt", true )
	end
	
	local sf = ply:GetNWInt("MeEatSouls")
	if sf > 0 then
		timer.Simple(1, function()
			ply:Spawn()
			ply:SetNWInt("MeEatSouls", ply:GetNWInt("MeEatSouls") - 1)
		end)
	end
	
	if !EVENTS:Get('CustomEnd') then
		if ( ply:IsPlayer() and attacker:IsPlayer() ) then
		if ( ply != attacker ) then
			
			local textrer = 'убил'
			local sherif, cansherif, uprsherif = false, false, false
			
			if attacker.ModelSex ~= "male" then
				textrer = 'убила'
			end
			
			if ply:GetNWBool("SuccubFog") then
				local owner = ply:GetNWEntity("whoEatSouls")
				if IsValid(owner) then
					owner.SucIsUs = false
				end
			end
			
			if attacker:GetRole(MURDER) then //Первостепенно!
				attacker:UnDisquise()
				isrdm = false
				
				if ply:GetRole(MURDER_HELPER) then
					
					if type(rdms[attacker:SteamID()]) ~= 'table' then 
						rdms[attacker:SteamID()] = {
							['round'] = 0,
							['kill'] = 0,
							['nick'] = attacker:Nick(),
						}
					end 
					rdms[attacker:SteamID()]['kill'] = rdms[attacker:SteamID()]['kill'] + 1
					rdms[attacker:SteamID()]['round'] = 0
					net.Start("rdm_vgui")
					net.WriteTable(rdms)
					net.Broadcast()
					RDMPSPlayer( attacker, 250, "за убийство "..ply:Nick())

				elseif ply:GetRole(CHICKEN) then
				else
					RewardPlayer( attacker, 5, "за убийство "..ply:Nick())	
				end
				
			elseif attacker:GetRole(SUCCUB) then 
				isrdm = false
				attacker:SetNWInt("MeEatSouls", attacker:GetNWInt("MeEatSouls") + 1)
				attacker.SucIsUs = false
				attacker:CalculateSpeed()
			elseif attacker:GetRole(VOR) then 
				isrdm = false
			elseif attacker:GetRole(SHUT) then 
				isrdm = false
			elseif attacker:GetRole(MINER) then 
				RewardPlayer( attacker, 5, "за убийство "..ply:Nick())	
				isrdm = false
			elseif attacker:GetRole(MURDER_HELPER) then 
				isrdm = false
			elseif attacker:GetRole(HEADCRAB) then
				isrdm = false
			elseif attacker:GetRole(HEADCRAB_BLACK) then
				isrdm = false
			elseif attacker:GetRole(DINARA) then
				isrdm = false
			elseif attacker:GetRole(PSYCHNAUTOR) then
				isrdm = false
			elseif ply:GetRole(0) then
				local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
				ct:Add(attacker:GetBystanderName(), attacker:GetBystanderColor(true))
				ct:Add(" "..textrer.." невиновного.", Color( 255, 255, 255 ))
				ct:Broadcast()
			elseif ply:GetRole(DRESSIROVSHIK) then
				local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
				ct:Add(attacker:GetBystanderName(), attacker:GetBystanderColor(true))
				ct:Add(" "..textrer.." дрессировщика.", Color( 255, 255, 255 ))
				ct:Broadcast()
				uprsherif = true
			elseif ply:GetRole(SUCCUB) then
				local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
				ct:Add(attacker:GetBystanderName(), attacker:GetBystanderColor(true))
				ct:Add(" "..textrer.." суккуба.", Color( 255, 255, 255 ))
				ct:Broadcast()
				isrdm = false
				-- uprsherif = true
				local sf = ply:GetNWInt("MeEatSouls")
				if sf > 0 then
					ply:Spawn()
				end
			elseif ply:GetRole(MEDIC) then
				local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
				ct:Add(attacker:GetBystanderName(), attacker:GetBystanderColor(true))
				ct:Add(" "..textrer.." врача.", Color( 255, 255, 255 ))
				ct:Broadcast()
				uprsherif = true
			elseif ply:GetRole(MINER) then
				cansherif = true
				isrdm = false
				local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
				ct:Add(attacker:GetBystanderName(), attacker:GetBystanderColor(true))
				ct:Add(" "..textrer.." минера.", Color( 255, 255, 255 ))
				ct:Broadcast()				
			elseif ply:GetRole(SCIENTIST) then
				local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
				ct:Add(attacker:GetBystanderName(), attacker:GetBystanderColor(true))
				ct:Add(" "..textrer.." ученого.", Color( 255, 255, 255 ))
				ct:Broadcast()
				uprsherif = true
			elseif ply:GetRole(PRODAVEC) then
				isrdm = false
				local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
				ct:Add(attacker:GetBystanderName(), attacker:GetBystanderColor(true))
				ct:Add(" "..textrer.." продавца.", Color( 255, 255, 255 ))
				ct:Broadcast()
			elseif ply:GetRole(MOSHENNIK) then
				isrdm = false
				local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
				ct:Add(attacker:GetBystanderName(), attacker:GetBystanderColor(true))
				ct:Add(" "..textrer.." мошенника.", Color( 255, 255, 255 ))
				ct:Broadcast()
			elseif ply:GetRole(DINARA) then
				if ply.DinaraBad then
					isrdm = false
					cansherif = true
				end
				local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
				ct:Add(attacker:GetBystanderName(), attacker:GetBystanderColor(true))
				ct:Add(" "..textrer.." карамельку.", Color( 255, 255, 255 ))
				ct:Broadcast()
			elseif ply:GetRole(MURDER) then
				cansherif = true
				isrdm = false
				RewardPlayer( attacker, 5, "за убийство убийцы")
				local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
				ct:Add(attacker:GetBystanderName(), attacker:GetBystanderColor(true))
				ct:Add(" "..textrer.." убийцу.", Color( 255, 255, 255 ))
				ct:Broadcast()
				
				if ply:GetNWString("murd_t") == "kama" then
					ply:PlayTaunt("Death", false)
				end
				
				for i,v in pairs(team.GetPlayers(2)) do
					if !v:Alive() then continue end
					if v:GetRole(SHUT) and math.random(1,2) == 2 then
						v:SettingRoleSpecial(MURDER)
					end
				end
				
			elseif ply:GetRole(SHUT) then
				cansherif = true
				isrdm = false
				local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
				ct:Add(attacker:GetBystanderName(), attacker:GetBystanderColor(true))
				ct:Add(" "..textrer.." шута.", Color( 255, 255, 255 ))
				ct:Broadcast()
			elseif ply:GetRole(VOR) then
				cansherif = true
				isrdm = false
				local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
				ct:Add(attacker:GetBystanderName(), attacker:GetBystanderColor(true))
				ct:Add(" "..textrer.." вора.", Color( 255, 255, 255 ))
				ct:Broadcast()
			elseif ply:GetRole(MURDER_HELPER) then
				cansherif = true
				isrdm = false
				local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
				ct:Add(attacker:GetBystanderName(), attacker:GetBystanderColor(true))
				ct:Add(" "..textrer.." помощника убийцы.", Color( 255, 255, 255 ))
				ct:Broadcast()
			elseif ply:GetRole(HEADCRAB) or ply:GetRole(HEADCRAB_BLACK) then
				cansherif = true
				isrdm = false
				local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
				ct:Add(attacker:GetBystanderName(), attacker:GetBystanderColor(true))
				ct:Add(" "..textrer.." хедкраба.", Color( 255, 255, 255 ))
				ct:Broadcast()
			elseif ply:GetRole(SHERIF) then
				local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
				ct:Add(attacker:GetBystanderName(), attacker:GetBystanderColor(true))
				ct:Add(" "..textrer.." полицейского.", Color( 255, 255, 255 ))
				ct:Broadcast()
				uprsherif = true
			elseif ply:GetRole(DED) then
				local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
				ct:Add(attacker:GetBystanderName(), attacker:GetBystanderColor(true))
				ct:Add(" "..textrer.." санту.", Color( 255, 255, 255 ))
				ct:Broadcast()
				uprsherif = true
			end
						
			if !EVENTS:Get('RDM') then
				isrdm = false
				cansherif = true
			end
			
			if attacker:GetRole(SHERIF) and !cansherif then
				isrdm = false
				if uprsherif then
					isrdm = true
				end
				attacker:SetRole(0)
				attacker:SetModel(SherifTableModelsAcce[attacker:GetModel()] or "models/player/Group01/Male_05.mdl")
				if attacker:HasWeapon("weapon_mu_checker") then
					attacker:StripWeapon("weapon_mu_checker")
				end
				local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
				ct:Add(attacker:GetBystanderName(), attacker:GetBystanderColor(true))
				ct:Add(" лишен своей должности.", Color( 255, 255, 255 ))
				ct:Broadcast()
			end
			
			if attacker:GetRole(DINARA) and !cansherif and !attacker.DinaraBad then
				attacker.DinaraBad = true
				local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
				ct:Add(attacker:GetBystanderName(), attacker:GetBystanderColor(true))
				ct:Add(" перешла на темную сторону.", Color( 255, 255, 255 ))
				ct:Broadcast()
			end
			if isrdm then
				
				attacker:SetTKer(true)
				
				if type(rdms[attacker:SteamID()]) ~= 'table' then 
					rdms[attacker:SteamID()] = {
						['round'] = 0,
						['kill'] = 0,
						['nick'] = attacker:Nick(),
					}
				end 
				rdms[attacker:SteamID()]['kill'] = rdms[attacker:SteamID()]['kill'] + 1
				rdms[attacker:SteamID()]['round'] = 0
				net.Start("rdm_vgui")
				net.WriteTable(rdms)
				net.Broadcast()
				if rdms[attacker:SteamID()]['kill'] == 2 then
					RDMPSPlayer( attacker, 100, "за убийство "..ply:Nick())
				elseif rdms[attacker:SteamID()]['kill'] == 3 then
					RDMPSPlayer( attacker, 250, "за убийство "..ply:Nick())
					-- attacker:Ban(60, true, "RDM (x3)")
				end
			end
		end
	end
	end
end