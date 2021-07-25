AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_events.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "cl_player.lua" )
AddCSLuaFile( "sh_events.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "sh_config.lua" )
AddCSLuaFile( "cl_fixplayercolor.lua" )
AddCSLuaFile( "cl_loot.lua" )
AddCSLuaFile( "cl_communicating.lua" )
AddCSLuaFile( "cl_qmenu.lua" )
AddCSLuaFile( "3d2dvgui.lua" )
AddCSLuaFile( "cl_crosshair.lua" )

AddCSLuaFile( "cl_hudlidi.lua" )
AddCSLuaFile( "cl_scoreboard_param.lua" )

AddCSLuaFile( "cl__outline.lua" )

include( "shared.lua" )
include( "sh_config.lua" )
include( "sh_events.lua" )
include( "sv_rounds.lua" )
include( "sv_player.lua" )
include( "sv_roll.lua" )
include( "sv_loot.lua" )
include( "sv_ragdoll.lua" )
include( "sv_communicating.lua" )
include( "sv_death.lua" )
include( "sv_rounds.lua" )
include( "sv_events.lua" )
include( "sv_qmenu.lua" )
include( "sv_functions.lua" )
include( "sv_murders.lua" )
include( "sv_spawns.lua" )

AddCSLuaFile( "mv/cl_mv.lua" )
AddCSLuaFile( "mv/sh_mv.lua" )
include( "mv/sv_mv.lua" )

RunConsoleCommand("sv_friction", 5)
RunConsoleCommand("sv_sticktoground", 0)
RunConsoleCommand("sv_airaccelerate", 3)
RunConsoleCommand("sv_gravity", 860)
RunConsoleCommand("sv_hibernate_think", 1)

function GM:Think()
	self:RoundThink()
	self:FlashlightThink()
	self:LootThink()
end

function GM:Initialize() 
	self.DeathRagdolls = {}
	self:LoadLootData()
	self:LoadSpawnsData() 
	self.LastDeath = CurTime()
end


CreateConVar("deathrun_drown_time","20", defaultFlags, "")
timer.Create("DeathrunDrowningStuff", 0.5,0,function()
	for k,ply in ipairs( player.GetAll() ) do
		ply.LastOxygenTime = ply.LastOxygenTime or CurTime()
		if ply:WaterLevel() == 2 then
			if ply:IsOnFire() then
				ply:Extinguish()
			end
		end
		if ply:WaterLevel() == 3 then --they are submerged completely
			local timeUnder = CurTime() - ply.LastOxygenTime
			if timeUnder > GetConVarNumber("deathrun_drown_time") then
				local di = DamageInfo()
				di:SetDamage( 5 )
				di:SetDamageType( DMG_DROWN )
				ply:TakeDamageInfo( di )
				ply:ViewPunch( Angle( 0,0,math.random(-1,1) ) )
			end
		else
			ply.LastOxygenTime = CurTime()
		end

		if not ply:Alive() or ply:GetSpectate() then
			ply.LastOxygenTime = CurTime()
		end
	end
end)

function GM:EntityTakeDamage( ent, dmginfo )
	local target = ent
		
	local attacker = dmginfo:GetAttacker()
	local fixknife = dmginfo:GetInflictor()
	// disable all prop damage
	
	if IsValid(dmginfo:GetAttacker()) && (dmginfo:GetAttacker():GetClass() == "prop_physics" || dmginfo:GetAttacker():GetClass() == "prop_physics_multiplayer" || dmginfo:GetAttacker():GetClass() == "func_physbox") then
		dmginfo:SetDamage(0)
	end

	if IsValid(dmginfo:GetInflictor()) && (dmginfo:GetInflictor():GetClass() == "prop_physics" || dmginfo:GetInflictor():GetClass() == "prop_physics_multiplayer" || dmginfo:GetAttacker():GetClass() == "func_physbox") then
		dmginfo:SetDamage(0)
	end
	
	
	if IsValid(fixknife) then
		local scripg = string.Explode("_",fixknife:GetClass())
		if scripg[1] == "mu" and scripg[2] == "knife" then dmginfo:SetDamage(0) end
	end
	local dmg = dmginfo:GetDamage()
	if dmg > 0 then
		if dmginfo:GetDamageType() == DMG_DROWN then -- drowning noisess
			local drownsounds = {
				"player/pl_drown1.wav",
				"player/pl_drown2.wav",
				"player/pl_drown3.wav",
			}
			target:EmitSound( table.Random( drownsounds ) )
		end
	end
	if target:IsPlayer() and attacker:IsPlayer() then
	
		local od = dmginfo:GetDamage()
		
		if !self:GetRound(1) then dmginfo:SetDamage(0) return end
		if target:GetRole(MOSHENNIK) then dmginfo:SetDamage(0) return end
		if target:GetRole(PRODAVEC) then dmginfo:SetDamage(0) return end
		if target:GetRole(CHICKEN) then dmginfo:SetDamage(0) return end
		if EVENTS:Get('ID') == EVENT_TD and target:GetRole(MURDER) and target ~= attacker  then 
			dmginfo:SetDamage(25)
			target.TailsRage = target.TailsRage+1
			target:SetSkin( target.TailsRage )
			target:CalculateSpeed()
			net.Start("SendSharpedHUD")
				net.WriteInt(target.TailsRage, 4)
			net.Send(team.GetPlayers(2))
			
		end
		if EVENTS:Get('ID') == EVENT_CVP and attacker:GetRole(MURDER) and target:GetRole(MURDER) then  dmginfo:SetDamage(0) return end
		if EVENTS:Get('ID') == EVENT_CVP and !attacker:GetRole(MURDER) and !target:GetRole(MURDER) then  dmginfo:SetDamage(0) return end
		if EVENTS:Get('ID') == EVENT_CVP and attacker:GetRole(MURDER) and !target:GetRole(MURDER) then if target:Health() - od <= 0 then attacker:EmitSound("scpredator.wav") end end
		if target:GetRole(MURDER) and attacker:GetRole(MURDER_HELPER) then
			dmginfo:SetDamage(0)
		end
		if attacker:GetRole(MURDER) and target:GetRole(MURDER_HELPER) then
			dmginfo:SetDamage(34)
			attacker:SendLua([[
				notification.AddLegacy( "Вы ударили Вашего помощника!", NOTIFY_ERROR, 2 )
				surface.PlaySound( "buttons/button10.wav" )
			]])
		end
		if attacker:GetRole(MURDER) and target:GetRole(MURDER) and target ~= attacker  then
			dmginfo:SetDamage(0)
		end
		
		if target:GetRole(PSYCHNAUTOR) and target ~= attacker and !attacker:GetRole(PSYCHNAUTOR) then
			target:SetBloodColor(DONT_BLEED)
			local od = dmginfo:GetDamage()
			local he = attacker:Health()
			dmginfo:SetDamage(0)
			local Dmg = DamageInfo()
			local DmgToAtt = od/target.multip
			Dmg:SetAttacker(target)
			Dmg:SetInflictor(target)
			Dmg:SetDamage(DmgToAtt)
			local backdmg = 0
			if target:Health() - DmgToAtt > 0 or target.multip > 3 then
				backdmg = (target:Health() - DmgToAtt)//*target.multip
				if target.multip > 3 then
					backdmg = backdmg * target.multip
				end
				if backdmg < 0 then
					backdmg = backdmg * -1
				end
			end
			
			target.multip = target.multip +1
			attacker:TakeDamageInfo( Dmg )
			
			target:SetHealth(target:Health()-backdmg)
			
		  local effectdata = EffectData()
		  local pos = target:GetPos()
		  effectdata:SetOrigin( Vector(pos.x+5, pos.y, pos.z + 45))
		  effectdata:SetNormal( Vector(pos.x*180, pos.y, pos.z) )
		  effectdata:SetMagnitude( 7 )
		  effectdata:SetScale( 1 )
		  effectdata:SetRadius( 50 )
		  util.Effect( "Sparks", effectdata )
		  
		end
		if target:GetNWBool('armormurder') and target != attacker then
			target:SetBloodColor(DONT_BLEED)
			dmginfo:SetDamage(0)
			target:SetNWBool('armormurder',false)
			
			  local effectdata = EffectData()
			  local pos = target:GetPos()
			  effectdata:SetOrigin( Vector(pos.x+5, pos.y, pos.z + 45))
			  effectdata:SetNormal( Vector(pos.x*180, pos.y, pos.z) )
			  effectdata:SetMagnitude( 7 )
			  effectdata:SetScale( 1 )
			  effectdata:SetRadius( 50 )
			  util.Effect( "Sparks", effectdata )
			if target:GetNWBool('fakearmor') then
						 
				target:SetNWBool('fakearmor', false)
				local bone = target:LookupBone("ValveBiped.Bip01_Spine")

				//if (!bone) then return end
				
				pos, ang = target:GetPos(), Angle(0,0,0)
				if (bone) then
					local m = target:GetBoneMatrix(bone)
					if (m) then
						pos, ang = m:GetTranslation(), m:GetAngles()
					end
				end
				local ent = ents.Create( "env_explosion" )
				ent:SetPos( pos )

				//ent:SetOwner( self.Owner )
				ent:SetKeyValue( "iMagnitude", "120" )
				ent:Spawn()
				ent:Fire( "Explode", 0, 0 )
			end
		end
	end

end

util.AddNetworkString("ads_panel")
util.AddNetworkString("zaprostoads")


net.Receive("zaprostoads",function(len, ply)
//local json = AdsPars()
local asd = ents.FindByName('ad_panel')
if #asd > 0 then
net.Start("ads_panel")
	net.WriteAngle(asd[1]:GetAngles())
	net.WriteVector(asd[1]:GetPos())
net.Send(ply)
end

end)
