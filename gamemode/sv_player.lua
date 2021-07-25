util.AddNetworkString("flashlight_charge")
util.AddNetworkString("SetLoot")
util.AddNetworkString("mu_tker")
util.AddNetworkString("PickingNotif")
util.AddNetworkString("DeathSpec")

util.AddNetworkString("PredatorMaskHUD")
util.AddNetworkString("BuyMagnumQuer")
util.AddNetworkString("BuyMagnumWindow")

util.AddNetworkString("SpawnHasPlayer")
util.AddNetworkString("MovedAFKPlayer")

util.AddNetworkString("TinkingClear.endWichout")
util.AddNetworkString("TinkingClear.str")
util.AddNetworkString("TinkingClear.endW")
util.AddNetworkString("TinkingClear.end")
-- util.AddNetworkString("TinkingClear.endW")

local plyMeta = FindMetaTable("Player")
local entMeta = FindMetaTable("Entity")

function GM:PlayerInitialSpawn( ply )
	ply:SetLoot(0)
	ply.MurdererChance = 1
	ply.RoleChance = 1
	ply.mute_team = -1
	ply.LastActiveTime = CurTime()
	timer.Simple(0, function ()
		if IsValid(ply) then
			ply:KillSilent()
		end
	end)
	
	ply:SetTeam(1)
	if ply:IsBot() then
	ply:SetTeam(2)
	end
	self.LastConnect = CurTime() + 5
	self:RefreshRound(ply)
	local vec = Vector(0.5, 0.5, 0.5)
	ply:SetPlayerColor(vec)
	ply:SetNWString("SteamidOw", ply:SteamID())
	net.Start("SpawnHasPlayer")
	net.Send(ply)
end

function GM:PlayerDeathThink( ply )
	if ply:CanRespawn() then
		ply:Spawn()
	end
	if EVENTS:Get('ID') == EVENT_BOOM then
		if ply.NextSpawnTime && ply.NextSpawnTime+2 > CurTime() then return end
		ply:Spawn()
	end
end

hook.Add( "CanPlayerSuicide", "CanUserOwnerSuicide", function( ply )
	return GAMEMODE:GetRound( 1 )
end )

function GM:PlayerSpawn( ply )
	if ply:Team() == TEAM_SPECTATOR || ply:Team() == TEAM_UNASSIGNED || ply:Team() == 1 then
		ply:SetTeam(1)
		ply:KillSilent()
		//GAMEMODE:PlayerSpawnAsSpectator( ply )
		return false
	end
	ply:StopSpectate()
	ply:Give('weapon_mu_hands')
	ply:CalculateSpeed()

	ply:SetRenderMode( RENDERMODE_TRANSALPHA )
	self:PlayerSetModel(ply)
	if EVENTS:Get('ID') == EVENT_BOOM then
		ply:SetBystanderName("Джихадист")
		ply:Give('weapon_mu_secretbomb')
		ply:SelectWeapon("weapon_mu_secretbomb")
	end
end

-- Something to check how long it's been since the player last did something
hook.Add("FinishMove", "MurderIdleCheck", function( ply, mv )

	ply.LastActiveTime = ply.LastActiveTime or CurTime()
	ply.LastButtons = ply.LastButtons or mv:GetButtons()

	if (mv:GetButtons() ~= ply.LastButtons) then
		ply.LastActiveTime = CurTime()
	end
	ply.LastButtons = mv:GetButtons()

end)

function GM:CheckIdleTime( ply )
	ply.LastActiveTime = ply.LastActiveTime or CurTime()
	return CurTime() - ply.LastActiveTime
end

local playermodels = {
	"models/player/group01/male_01.mdl",
	"models/player/group01/male_02.mdl",
	"models/player/group01/male_03.mdl",
	"models/player/group01/male_04.mdl",
	"models/player/group01/male_05.mdl",
	"models/player/group01/male_06.mdl",
	"models/player/group01/male_07.mdl",
	"models/player/group01/male_08.mdl",
	"models/player/group01/male_09.mdl",
}
local playermodels_fem = {
	"models/player/group01/female_01.mdl",
	"models/player/group01/female_02.mdl",
	"models/player/group01/female_03.mdl",
	"models/player/group01/female_04.mdl",
	"models/player/group01/female_05.mdl",
	"models/player/group01/female_06.mdl",
}

function GM:PlayerSetModel( ply )

	local playermodelsel = playermodels
	local playermodelselsex = 'male'
	local pol = math.random(1,2)
	if pol == 2 then
		playermodelsel = playermodels_fem
		playermodelselsex = 'female'
	end
	
	local teblr = table.Random(playermodelsel)
	ply:SetModel( teblr )
	ply.ModelSex = playermodelselsex
	ply:SetupHands()
	
end

function GM:PlayerDeathSound()
	-- don't play sound
	return true
end

function plyMeta:PlayerSendNot(name, color)
	net.Start("PickingNotif")
		net.WriteString(name)
		net.WriteVector(color)
	net.Send(self)
end

function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )
	-- Don't scale it depending on hitgroup
end 

function GM:PlayerSilentDeath(ply) -- Ну как бы.... нужно. Походу. Бля.
	ply.NextSpawnTime = CurTime() + 5
	ply:BeginSpectate()
end

net.Receive("FrameMagnumWindow", function(len, ply)
	print(net.ReadEntity())
end)

net.Receive("PredatorMaskHUD", function(len, ply)
	local color = net.ReadVector()
	local number = net.ReadUInt(8)
	
	color = color:ToColor()
	
	ply:SetPData("predator_mask",number)
	ply:SetPData("predator_mask_r",color.r)
	ply:SetPData("predator_mask_g",color.g)
	ply:SetPData("predator_mask_b",color.b)
	ply:UpdatePredator()
end)

function plyMeta:UpdatePredator()
	self:SetNWInt("predator_mask", tonumber(self:GetPData("predator_mask")))
	self:SetNWInt("predator_mask_r", tonumber(self:GetPData("predator_mask_r")))
	self:SetNWInt("predator_mask_g", tonumber(self:GetPData("predator_mask_g")))
	self:SetNWInt("predator_mask_b", tonumber(self:GetPData("predator_mask_b")))
end

function functionLoadCustom(ply)		
	if ply:GetPData("predator_mask") == nil then
		ply:SetPData("predator_mask","0")
	end
	if ply:GetPData("predator_mask_r") == nil then
		ply:SetPData("predator_mask_r","0")
	end
	if ply:GetPData("predator_mask_g") == nil then
		ply:SetPData("predator_mask_g","0")
	end
	if ply:GetPData("predator_mask_b") == nil then
		ply:SetPData("predator_mask_b","0")
	end

	ply:UpdatePredator()
end

hook.Add("PlayerDisconnected", "dropweapon", function( ply )
	ply:DropWeapons()
end)

function GM:DoPlayerDeath(ply, attacker, dmginfo)
	ply:Freeze(false) // why?, *sigh*
	ply:Extinguish()
	ply:SetTKer(false)
	ply:DropWeapons()
	if !ply:GetRole(HEADCRAB_BLACK) and !ply:GetRole(HEADCRAB) and !ply:GetRole(CHICKEN) then
		ply:CreateRagdoll()
	end
end

hook.Add("PlayerSilentDeath","pk_pill_death_silent",function(ply)
	if IsValid(ply.pk_pill_ent) then
		ply.pk_pill_ent:PillDie()
	end
	//GAMEMODE:PlayerDeath(ply, game.GetWorld(), ply, true )
end)

function GM:PlayerDeath(ply, inflictor, attacker, issilent )
	self.LastDeath = CurTime() + 2.3
	if ply:GetRole(HEADCRAB) and ply:GetNWBool("hooked_troup") and ply:GetNWString("hooked_type") == "zombie_fast" and math.random(1,3) == 2 then
		timer.Simple(0, function()
		local oldpos = ply:GetPos()
		ply:Spawn()
		ply:SetNWInt("CountHited", 2)
		ply:SetNWBool("hooked_troup", false)
		local newPill = pk_pills.apply(ply,"zombie_torso_fast")
		ply:SetPos(oldpos+Vector(0,0,20))
		
		local button = ents.Create( "prop_ragdoll" )
		if ( IsValid( button ) ) then
			button:SetModel( 'models/gibs/fast_zombie_legs.mdl' )
			button:SetPos( oldpos )
			button:Spawn()
			button:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			button:Fire("FadeAndRemove",nil,10)
		end
		end)
		return false
	end
	if ply:GetRole(HEADCRAB) or ply:GetRole(HEADCRAB_BLACK) then
		timer.Simple(0.03,function() 
			if IsValid(ply) then
				ply:ChangeSpectate()
			end 
		end)
	end
	if (ply:GetRole(HEADCRAB) or ply:GetRole(HEADCRAB_BLACK))and ply:GetNWBool("hooked") then
		ply:SetNWBool("hooked", false)
		local h = ply:GetNWEntity("hooked_ply")
		if IsValid(h) then
			h:SetNWBool("h_hooked",false)
		end
		ply:SetNWEntity("hooked_ply",nil)
		ply:SetNWEntity("hooked_dbl", nil)
		
		local button = ents.Create( "prop_ragdoll" )
		if ( IsValid( button ) ) then
			if ply:GetNWString("hooked_type") == "zombie_fast" then
				button:SetModel("models/headcrab.mdl")
			else
				button:SetModel("models/headcrabblack.mdl")
			end
			button:SetPos( ply:GetPos() )
			button:Spawn()
			button:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			button:Fire("FadeAndRemove",nil,10)
		
		end
	//	pk_pills.apply(ply,'headcrab_fast')
	//	ply:SetPos(ply:GetPos()+Vector(0,0,30))
	//	ply:Kill()
	end
	
	
	if ply:GetRole(CHICKEN) then
		ply:SetRole(0)
	end
	if ply:GetRole(SHERIF) then
		if ply:GetNWBool("AmChecking") then
			ply:SetNWBool("AmChecking", false)
			ply:GetNWEntity("HeIsChecking"):SetNWBool("HeChecking", false)
			ply:GetNWEntity("HeIsChecking"):SetMoveType(MOVETYPE_WALK)
		end
	end
	
	if ply:GetRole(VOR) then
		if ply:GetNWBool("AmVor") then
			ply:SetNWBool("AmVor", false)
			ply:GetNWEntity("HeIsVoring"):SetNWBool("HeVoring", false)
			ply:GetNWEntity("HeIsVoring"):SetMoveType(MOVETYPE_WALK)
		end
	end
	if !issilent then
		ply.NextSpawnTime = CurTime() + 5
		net.Start("DeathSpec")
		net.Send(ply)
	end
	ply:BeginSpectate()
	ply:SpecModify( 0 )
	self:DeathRoles(ply, attacker)
	
	for k,slf in ipairs(player.GetAll()) do
		if slf:GetSpectate() && slf:GetObserverTarget() == ply then
			slf:SpecNext()
		end
	end
	-- timer.Simple(0.03, function()
		-- ply:SpecNext()
	-- end)
	//ply:Kill()
end

function GM:PlayerUse(ply, ent)
	return true
end

/*
hook.Add( "OnEntityCreated", "CheckEntity", function( ent )
	if ( ent:GetClass() == 'gmod_hands'	or ent:GetClass() == 'mu_loot') then return end
	print(ent, ent:GetCollisionGroup())
//	if ( not ( ent:IsValid() and TrackedEnts[ ent:GetClass() ] ) ) then return end

//	EntList[ ent:EntIndex() ] = ent
end )

hook.Add( "EntityRemoved", "CheckEntity", function( ent )
	if ( ent:GetClass() == 'gmod_hands'	or ent:GetClass() == 'mu_loot'	) then return end
	print(ent, 'remove')

//	EntList[ ent:EntIndex() ] = ent
end )
*/

function plyMeta:CanRespawn()
	if GAMEMODE:GetRound(0) then
		if self.NextSpawnTime && self.NextSpawnTime > CurTime() then return end
		if self:Team() == 1 or self:Team() == TEAM_SPECTATOR or self:Team() == TEAM_UNASSIGNED then return false end
		if #team.GetPlayers(1) > 1 then return false end
		if self:KeyPressed(IN_JUMP) then return true end
	end

	return false
end

function plyMeta:GetRole(role)
	if role ~= nil then
		return role == self.role
	end
	return self.role
end

function plyMeta:SetRole(role)
	if role ~= 0 then
		self.RoleChance = 1
	end
	self:SetNWInt("role", role)
	self.role = role
end

function entMeta:GetBystanderName(role)
	return self.BystanderName or "Невиновный"
end

function entMeta:SetBystanderName(name, isround)
	local round = false
	
	if isround != nil then
		round = isround
	end
	
	if round and self:GetNWBool('bystNW') then
		name = self:GetNWString('bystNWNick')
		self.ModelSex = self:GetNWString('bystNWSex')
	end
	
	self:SetNWString("BystanderName", name)
	self.BystanderName = name
end

function entMeta:GetBystanderColor(bool)

	if bool then
		return self.BystanderColor or Color(0,0,0)
	end
	return self:GetNWVector("BystanderColor") or Vector(0.25, 0.25, 0.25)
end

function entMeta:SetBystanderColor(color)
	self:SetNWVector("BystanderColor", Vector(color.r/255, color.g/255, color.b/255 ))
	self.BystanderColor = color
end

function plyMeta:BeginSpectate(ent)
	self:StripWeapons()
	self:StripAmmo()
	self.Spectating = true
	self.ObsMode = 0
	if IsValid(ent) then
	self:SpecEntity( ent, mode )
	else
	self:Spectate( OBS_MODE_IN_EYE )
	end
	self:SetupHands( nil )
end

function plyMeta:StopSpectate() -- when you want to end spectating immediately
	self.Spectating = false
	self:UnSpectate()
end 

function plyMeta:GetSpectate()
	return self.Spectating
end

function plyMeta:ChangeSpectate()
	if not self:GetSpectate() then return end
	if self:GetNWBool("h_hooked") then return end
	if not self.ObsMode2 then self.ObsMode2 = 1 end

	self.ObsMode2 = self.ObsMode2 + 1
	
	if self.ObsMode2 > 2 then
		self.ObsMode2 = 0
	end
	
	local pool = {}
	
	for k,self in ipairs(team.GetPlayers(2)) do
		if self:Alive() and not self:GetSpectate() then
			table.insert(pool, self)
		end
	end
	
	if #pool == 0 then
		self.ObsMode2 = 0
		self:Spectate( OBS_MODE_ROAMING )
		return
	end
		
	if self.ObsMode2 == 0 then 
		self:Spectate( OBS_MODE_ROAMING )
		--because it's nicer
		if self:GetObserverTarget() then
			self:SetPos( self:GetObserverTarget():EyePos() or self:GetObserverTarget():OBBCenter() + self:GetObserverTarget():GetPos() )
		end 
	end

	
	
	if self.ObsMode2 == 1 then self:Spectate( OBS_MODE_CHASE ) end
	if self.ObsMode2 == 2 then self:Spectate( OBS_MODE_IN_EYE ) end
	if self.ObsMode2 > 0 then
		
		--check if they don't already have a spectator target
		local target = self:GetObserverTarget()

		
		
		if not target then
			local tidx = math.random(#pool)
			self:SpectateEntity( pool[tidx] ) -- iff they don't then give em one
			self:SetupHands( pool[tidx] )
		end

	end

	self:SpecModify( 0 )
	self:SetupHands( self:GetObserverTarget() )
	
end

function plyMeta:SpecModify( n )

	if self:GetNWBool("h_hooked") then return end
	
	self.SpecEntIdx = self.SpecEntIdx or 1

	local pool = {}
		
	for k,self in ipairs(team.GetPlayers(2)) do
		if self:Alive() and not self:GetSpectate() then
			table.insert(pool, self)
		end
	end
		
	self.SpecEntIdx = self.SpecEntIdx + n

	if self.SpecEntIdx > #pool then
		self.SpecEntIdx = 1
	end
	if self.SpecEntIdx < 1 then
		self.SpecEntIdx = #pool
	end

	if #pool > 0 then
		if pool[self.SpecEntIdx] then
			self:SpectateEntity( pool[self.SpecEntIdx] )
			self:SetNWEntity("SpectateEntity", pool[self.SpecEntIdx])
			if self:GetObserverMode() == OBS_MODE_IN_EYE then
				self:SetupHands( pool[self.SpecEntIdx] )
			else
				self:SetupHands( nil )
			end

		end
	else
		self:SetNWEntity("SpectateEntity", nil)
	end
	if self:GetObserverMode() ~= OBS_MODE_IN_EYE then
		self:SetupHands( nil )
	end

end

function plyMeta:SpecEntity( ent, mode )
	self:Spectate( mode )
	self:SpectateEntity( ent )
	self:SetNWEntity("SpectateEntity", ent)
	
	if self:GetObserverMode() == mode then
		if ent:IsPlayer() then
			self:SetupHands( ent )
		end
	else
		self:SetupHands( nil )
	end
end

function plyMeta:SpecNext()
	self:SpecModify( 1 )
end
function plyMeta:SpecPrev()
	self:SpecModify( -1 )
end

hook.Add("KeyPress", "DeathrunSpectateChangeObserverMode", function(self, key)
	if self:GetSpectate() then
		if key == IN_JUMP then
			self:ChangeSpectate()
		end
		if key == IN_ATTACK then
			-- cycle players forward
			self:SpecNext()
		end
		if key == IN_ATTACK2 then
			-- cycle players bacwards
			//self:ChangeSpectate()
			self:SpecPrev()
		end
	end
end)
//hook.Remove("StartCommand", "movingOnTrack")

function GM:FlashlightThink()
	local decay = FrameTime() / 30
	for k, ply in pairs(player.GetAll()) do
		if ply:Alive() then
			if ply:FlashlightIsOn() then
				ply:SetFlashlightCharge(math.Clamp(ply:GetFlashlightCharge() - decay, 0, 1))
			else
				ply:SetFlashlightCharge(math.Clamp(ply:GetFlashlightCharge() + decay / 1.5, 0, 1))
			end
		end
	end
end

function GM:PlayerSwitchFlashlight(ply, turningOn)
	if turningOn then
		if ply.FlashlightPenalty && ply.FlashlightPenalty > CurTime() then
			return false
		end
	end
	return true
end

function plyMeta:GetFlashlightCharge()
	return self.FlashlightCharge or 1
end

function plyMeta:SetFlashlightCharge(charge)
	self.FlashlightCharge = charge
	if charge <= 0 then
		self.FlashlightPenalty = CurTime() + 1.5
		if self:FlashlightIsOn() then
			self:Flashlight(false)
		end
	end
	net.Start("flashlight_charge")
	net.WriteFloat(self.FlashlightCharge)
	net.Send(self)
end

function plyMeta:GetLoot()
	return self.LootCollected
end

function plyMeta:SetLoot(loot)
	self.LootCollected = loot
	net.Start("SetLoot")
	net.WriteUInt(self.LootCollected, 32)
	net.Send(self)
end

function plyMeta:CalculateSpeed()
	// set the defaults
	local walk,run,canrun = 255,255,false
	local jumppower = 290

	if self:GetRole(MURDER) then
		run = 350
	end

	if self:GetTKer() then
		walk = walk * 0.5
		run = run * 0.5
		jumppower = jumppower * 0.5
	end

	local wep = self:GetActiveWeapon()
	if IsValid(wep) then
		if wep.GetCarrying && wep:GetCarrying() then
			walk = walk * 0.3
			run = run * 0.3
			jumppower = jumppower * 0.3
		end
	end

	if EVENTS:Get('ID') == EVENT_TD and self:GetRole(MURDER) then
		walk,run = 160*(self.TailsRage+1),160*(self.TailsRage+1)
	end
	
	if EVENTS:Get('ID') == EVENT_CVP and self:GetRole(MURDER) then
		walk,run,jumppower = 500,500,360
	end
	if EVENTS:Get('ID') == EVENT_SLENDER and self:GetRole(MURDER) then
		walk,run,jumppower = 400,400,290
	end
	if self:GetRole(SUCCUB) then
		local sf = self:GetNWInt("MeEatSouls")
		walk,run = 255+(sf*20),255+(sf*20)
	end
	
	self:SetRunSpeed(run)
	self:SetWalkSpeed(walk)
	self:SetJumpPower(jumppower)
	self:SetCrouchedWalkSpeed(0.6)
end

function plyMeta:DropWeapons()
	for k,v in ipairs(self:GetWeapons()) do	
		if not v:IsValid() then continue end
		if string.find( v:GetClass(), "weapon_mu_magnum" )  then
			self:DropWeapon(v)
		end
		if v:GetClass() == "weapon_mu_stuner"  then
			self:DropWeapon(v)
		end	
		if v:GetClass() == "weapon_mu_def"  then
			self:DropWeapon(v)
		end	
		if v:GetClass() == "weapon_mu_adr"  then
			self:DropWeapon(v)
		end	
	end
end

function plyMeta:SetTKer(bool)
	
	self.LastTKTime = nil
	
	if bool then
		self.LastTKTime = CurTime()
		timer.Simple(0, function () 
			local haves = false
			local wep2
			for k, weapon in pairs(self:GetWeapons()) do
				//if weapon:GetClass() == "weapon_mu_magnum" then
				if string.find( weapon:GetClass(), "weapon_mu_magnum" )  then
					//ply:DropWeapon(weapon)
					haves = true
					wep2 = weapon
				end
			end
			
			if IsValid(self) && haves then
				local wep = wep2
				wep.LastTK = self
				wep.LastTKTime = CurTime()
				self:DropWeapon(wep)
			end
		end)
	end
	
	net.Start("mu_tker")
	net.WriteBool(bool)
	net.Send(self)
	
	self:CalculateSpeed()
end

function plyMeta:GetTKer()
	return self.LastTKTime and true or false
end

local PlayerCanPickupWeapon = function( ply, ent )
	if ent:GetClass() == 'weapon_mu_hands' then return true end
	
	if EVENTS:Get('ID') == EVENT_ULIKIPICKUP then return false end
	
	if ply:GetRole(MURDER) then
		if EVENTS:Get('ID') == EVENT_TD then
			return false
		end
		if EVENTS:Get('ID') == EVENT_SLENDER then 
			if ent:GetClass() == "weapon_slender" then
				return true
			end
			return false
		end
	end
	
	if ply:GetRole(SUCCUB) then return false end
	if ply:GetRole(SHUT) then return false end
	if ply:GetRole(HEADCRAB) then return false end
	if ply:GetRole(HEADCRAB_BLACK) then return false end
	if ply:GetRole(MOSHENNIK) then return false end
	if ply:GetRole(PRODAVEC) then return false end
	if ply:GetRole(CHICKEN) then return false end
	if ply:GetRole(PSYCHNAUTOR) then return false end
	if EVENTS:Get('Figth1vs1') then return true end
	local hasMagnum = false
	local entmagn =  string.find( ent:GetClass(), "weapon_mu_magnum" ) 
	for k, wep in pairs(ply:GetWeapons()) do
		if string.find( wep:GetClass(), "weapon_mu_magnum" )  then
			hasMagnum = true
		end
	end
	
	if hasMagnum and entmagn then
		return false
	end
	
	if entmagn then
		if ply:GetRole(MURDER) or ply:GetRole(MURDER_HELPER) then
			return false
		end

		// penalty for killing a bystander
		if ply:GetTKer() then
		
			if ply.TempGiveMagnum then
				ply.TempGiveMagnum = nil
				return true
			end
			return false
		end
	end

	if ply:GetRole(MURDER) && ent:GetClass() == "weapon_mu_stuner" then
		return false
	end
	
	if string.find( ent:GetClass(), "weapon_mu_knife_" )  then
		if ply:hasRole('founder') then
			return true
		end
		if ply:GetRole(VOR) then
			return true
		end
		if !ply:GetRole(MURDER) then
			return false
		end
		if ent:GetClass() != ply.knifeclass then
			return false
		end
	end
	
	return true 
end

function GM:PlayerCanPickupWeapon( ply, ent )
	return PlayerCanPickupWeapon(ply, ent)
end
function GM:AllowPlayerPickup( ply, ent )
	return PlayerCanPickupWeapon(ply, ent) 
end

function GM:WeaponEquip( weapon, owner )
	if string.find( weapon:GetClass(), "weapon_mu_magnum" ) or string.find( weapon:GetClass(), "weapon_mu_knife" ) or string.find( weapon:GetClass(), "weapon_mu_def" ) then
		owner:PlayerSendNot(weapon:GetPrintName() or "ERROR", Vector(0,0,0))
	end
end

function plyMeta:Disquise(ply)
	if !self.Disguised then
		self.DisguiseColor = self:GetBystanderColor(true)
		self.DisguiseName = self:GetBystanderName()
	end
	
	self.Disguised = true
	self.DisguisedStart = CurTime()
	self:SetBystanderName(ply:GetBystanderName())
	self:SetBystanderColor(ply:GetBystanderColor(true))
	//end
end

function plyMeta:GiveLoot(ply)
	GAMEMODE:PickupLoot(self, nil, -1, ply)
end

function plyMeta:UnDisquise()
	if self.Disguised then
		self:SetBystanderColor(self.DisguiseColor)
		self:SetBystanderName(self.DisguiseName)
	end
	self.Disguised = false
end

local function pressedUse(self, ply)
	local tr = ply:GetEyeTraceNoCursor()
	// press e on windows to break them
	if IsValid(tr.Entity) && (tr.Entity:GetClass() == "func_breakable" || tr.Entity:GetClass() == "func_breakable_surf") && tr.HitPos:Distance(tr.StartPos) < 50 then
		local typedmg = DMG_BULLET
		if tr.Entity:GetClass() == "func_breakable_surf" then
			typedmg = DMG_SLASH
		end
		//print(tr.Entity:GetClass())
		local dmg = DamageInfo()
		dmg:SetAttacker(game.GetWorld())
		dmg:SetInflictor(game.GetWorld())
		dmg:SetDamage(10)
		dmg:SetDamageType(typedmg)
		dmg:SetDamageForce(ply:GetAimVector() * 500)
		dmg:SetDamagePosition(tr.HitPos)
		tr.Entity:TakeDamageInfo(dmg)
		return
	end
	
	// disguise as ragdolls
	if IsValid(tr.Entity) && tr.Entity:GetClass() == "prop_ragdoll" && tr.HitPos:Distance(tr.StartPos) < 80 then
		if ply:GetRole(MURDER) && ply:GetLoot() >= 1 then
			if tr.Entity:GetBystanderName() != ply:GetBystanderName() || tr.Entity:GetBystanderColor() != ply:GetBystanderColor() then 
				ply:Disquise(tr.Entity)
				ply:SetLoot(ply:GetLoot() - 1)
				return
			end
		end
	end
	
	// Покупка магнума
	if (ply:GetRole(0) or ply:GetRole(MURDER) or ply:GetRole(MURDER_HELPER)) && ply:GetLoot() >= 1 then
		if IsValid(tr.Entity) && tr.Entity:IsPlayer() && tr.Entity:Alive() && (tr.Entity:GetRole(MOSHENNIK) or tr.Entity:GetRole(PRODAVEC)) && tr.HitPos:Distance(tr.StartPos) < 80 then
			ply.IWantBuyE = true
			net.Start('BuyMagnumWindow')
				net.WriteEntity(ply)
			net.Send(tr.Entity)
		end
	end
	
	// Ставка улик
	if ply:GetRole(MINER) && ply:GetLoot() >= 1 then
		ply.lootpicked = ply.lootpicked or {}
		if #ply.lootpicked != 0 then
			local tr = util.GetPlayerTrace( ply )
			tr.mask = bit.bor( CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX )
			tr.start     = ply:EyePos()
			tr.endpos    = ply:EyePos()+ply:GetAimVector()*100
			
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
	
	
	// disguise as ragdolls
	if ply:GetRole(SHUT) then
		if IsValid(tr.Entity) && tr.Entity.Alive && tr.Entity:Alive() && tr.HitPos:Distance(tr.StartPos) < 80 and tr.Entity:GetRole() != SHUT then
			ply.roleShuting = tr.Entity:GetRole()
			return
		end
		if ply.roleShuting != 0 and ply.allowShuting then
			ply:SettingRoleSpecial(ply.roleShuting)
			ply:SetLoot(0)
		end
	end
	
	// Dinara
	
	if ply:GetRole(DINARA) and ply:Alive() and ply:GetLoot() > 0 then
		if IsValid(tr.Entity) && tr.Entity:IsPlayer() && tr.Entity:Alive() && tr.HitPos:Distance(tr.StartPos) < 80 then
			ply:GiveLoot(tr.Entity)
			return
		end
	end
	
end

function GM:KeyPress(ply, key)
	if key == IN_USE then
		pressedUse(self, ply)
	end
end

net.Receive("BuyMagnumQuer", function(ln, own)
	local bool = net.ReadBool()
	local ply = net.ReadEntity()
	
	if IsValid(ply) and ply:IsPlayer() and ply:Alive() and (ply:GetRole(0) or ply:GetRole(MURDER) or ply:GetRole(MURDER_HELPER)) and ply:GetLoot() >= 1 and ply.IWantBuyE then
		ply.IWantBuyE = false
		local text,text2 = 'магнума','магнум'
	
		if ply:GetRole(MURDER) then
			text, text2 = 'брони', 'броню'
		end
		if ply:GetRole(MURDER_HELPER) then
			text, text2 = 'бомбы', 'бомбу'
		end
		
		if (bool) then
			if own:GetRole(MOSHENNIK) then
				if ply:GetRole(MURDER) then
					ply:SetNWBool('armormurder', true)
					ply:SetNWBool('fakearmor', true)
					own.yaprodaltype = 1
				elseif ply:GetRole(MURDER_HELPER) then
					ply:Give('weapon_mu_secretbomb')
				else
					ply:Give('weapon_mu_magnum_fake')
					own.yaprodaltype = 2
				end
			elseif own:GetRole(PRODAVEC) then
				if ply:GetRole(MURDER) then
					ply:SetNWBool('armormurder', true)
					own.yaprodaltype = 1
				elseif ply:GetRole(MURDER_HELPER) then
					ply:Give('weapon_mu_secretbomb')
				else 
					giveMagnum(ply)
					own.yaprodaltype = 2
				end
			end
			ply:SetLoot(ply:GetLoot()-1)
			
			local ms = ChatMsg()
			ms:Add("[", Color(255, 255, 255))
			ms:Add("SYSTEM", Color(11, 53, 114))
			ms:Add("] ", Color(255, 255, 255))
			ms:Add("Вам продали "..text2..".",Color(255,255,255))
			ms:Send(ply)
		else
			local ms = ChatMsg()
			ms:Add("[", Color(255, 255, 255))
			ms:Add("SYSTEM", Color(11, 53, 114))
			ms:Add("] ", Color(255, 255, 255))
			ms:Add("Вам отказали в продаже "..text..".",Color(255,255,255))
			ms:Send(ply)
		end
	end
end)

function GM:PlayerOnChangeTeam(ply, newTeam, oldTeam) 
	if oldTeam == 2 then
		ply:DropWeapons()	
	end
	
	if newteam == 1 then
		
	end
	ply.HasMoved = true
	ply:KillSilent()
end

concommand.Add("mu_jointeam", function (ply, com, args)
	if ply.LastChangeTeam && ply.LastChangeTeam + 5 > CurTime() then return end
	
	ply.LastChangeTeam = CurTime()
	ply.LastActiveTime = CurTime()
	
	local curTeam = ply:Team()
	local newTeam = tonumber(args[1] or "") or 0
	if newTeam >= 1 && newTeam <= 2 && newTeam != curTeam then
		ply:SetTeam(newTeam)
		GAMEMODE:PlayerOnChangeTeam(ply, newTeam, curTeam)
		if not ply:GetNWBool("Restrikted") then
			
			local femtext1
			local femtext2
			if ply:GetPData("woman") == "true" then
				femtext1 = "перешла"
			else 
				femtext1 = "перешел"
			end 
			if newTeam == 1 then
				femtext2 = "наблюдатели"
			else
				femtext2 = "игроки"
			end
		
			local ct = ChatText()
			ct:Add(ply:Nick(), team.GetColor(curTeam))
			ct:Add(" "..femtext1.." в "..femtext2)
			ct:Send()
		end
	end
end)

util.AddNetworkString("add_footstep")
util.AddNetworkString("clear_footsteps")

function GM:PlayerFootstep(ply, pos, foot, sound, volume, filter)
	if EVENTS:Get('ID') == EVENT_SLENDER and ply:GetRole(MURDER) then return true end
	net.Start("add_footstep")
	net.WriteEntity(ply)
	net.WriteVector(pos)
	net.WriteAngle(ply:GetAimVector():Angle())
	local tab = {}
	for k, ply in pairs(player.GetAll()) do
		if self:CanSeeFootsteps(ply) then
			table.insert(tab, ply)
		end
	end
	net.Send(tab)
end

function GM:CanSeeFootsteps(ply)
	if ply:GetRole(MURDER) && ply:Alive() then return true end
	//if ply:IsSuperAdmin() && ply:Alive() then return true end
	return false
end

function GM:ClearAllFootsteps()
	net.Start("clear_footsteps")
	net.Broadcast()
end

function GM:PlayerNoClip( ply )
	return ply:hasPerm('noclip') || ply:GetMoveType() == MOVETYPE_NOCLIP
end
function plyMeta:ResetBones()
	for i=0, self:GetBoneCount() - 1 do
		self:ManipulateBoneScale(i, Vector(1, 1, 1))
		self:ManipulateBoneAngles(i, Angle(0, 0, 0))
		self:ManipulateBonePosition(i, vector_origin)
	end
end

function plyMeta:SettingRoleSpecial(Unsigned)
	local ply = self
	local role = ply
	ply:SetRole(0)
	ply:StripWeapons()
	ply:Give('weapon_mu_hands')
	if Unsigned == MURDER then
		local usedef = false	
		if role:GetNWString("ps_weapon") == '' then
			usedef = true
		end
		
		local togive = usedef and role:GetNWString('def_knife') or (role:GetNWString("ps_weapon") == nil and "weapon_mu_knife_def" or role:GetNWString("ps_weapon"))
		
		role:SetRole(MURDER)
		role.knifeclass = togive
		role:Give(togive)
		role:RoundM()
		role.MurdererChance = 0
	elseif Unsigned == SCIENTIST then
		role:SetRole(SCIENTIST)
		role.ModelSex = "male"
		role:SetBystanderColor(Color(112, 0, 204))
		role:SetModel( "models/player/kleiner.mdl" )
	elseif Unsigned == MEDIC then
		if role.ModelSex == "male" then 
			role:SetModel( "models/player/Group03m/male_02.mdl" )
		else 
			role:SetModel( "models/player/Group03m/female_01.mdl" )
		end
		role:SetBystanderColor(Color(0,112, 0))
		role:SetRole(MEDIC)
		role:Give('weapon_mu_def')
	elseif Unsigned == MURDER_HELPER then
		role:SetRole(MURDER_HELPER)
		role:Give("weapon_mu_stuner")
	elseif Unsigned == SHERIF then
		role:SetRole(SHERIF)
		role:Give("weapon_mu_checker")
		
		if role:GetNWString("ps_weapon_rev") == '' then
			role:SetNWString("ps_weapon_rev",'weapon_mu_magnum_def')
		end
		
		role:Give( role:GetNWString("ps_weapon_rev"))
		role.ModelSex = "male"
		role:SetModel( table.Random(SherifTableModels) )
	
	elseif Unsigned == HEADCRAB then
		role:SetRole(HEADCRAB)
		role:SetBystanderName("Хедкраб")
		pk_pills.apply(role,'headcrab_fast')
		
	elseif Unsigned == HEADCRAB_BLACK then
		role:SetRole(HEADCRAB_BLACK)
		role:SetBystanderName("Хедкраб")
		pk_pills.apply(role,'headcrab_poison')
		
	elseif Unsigned == DRESSIROVSHIK then
		role:SetRole(DRESSIROVSHIK)
		role:Give('weapon_mu_hlist')
		role:SetModel( "models/player/Police.mdl" )
		role.ModelSex = "male"
		
	elseif Unsigned == DINARA then
		role:SetRole(DINARA)
		role:SetBystanderName("karamel`ka")
		role.ModelSex = "female"
		role:SetModel('models/captainbigbutt/vocaloid/miku_carbon.mdl')
		role:SetSkin(9)
	elseif Unsigned == DED then
		role:SetRole(DED)
		role:SetBystanderName("Санта")
		role:SetBystanderColor(Color(140,25,25))
		role:SetModel( "models/player/christmas/santa.mdl" )
	elseif Unsigned == VOR then
		role:SetRole(VOR)
		role:Give('weapon_mu_vor')
	elseif Unsigned == CHICKEN then
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
	elseif Unsigned == PSYCHNAUTOR then
		role:SetBystanderName("@psychonautar")
		role:SetBystanderColor(Color(69,77,65))
		role:SetRole(PSYCHNAUTOR)
		role.multip = 1
		role:SetModel("models/captainbigbutt/vocaloid/rin_phosphorescent.mdl")
	elseif Unsigned == ALKO then
		if math.random(1,4) == 2 then
			role:SetNWBool("cantsend", true)
		end
		role:SetRole(ALKO)
	elseif Unsigned == MOSHENNIK then
		role:SetRole(MOSHENNIK)
		role:SetModel("models/player/gman_high.mdl")
	elseif Unsigned == PRODAVEC then
		role:SetRole(PRODAVEC)
		role:SetModel("models/player/gman_high.mdl")
	elseif Unsigned == MINER then
		role:SetRole(MINER)
		role:SetLoot(0)
	end
end