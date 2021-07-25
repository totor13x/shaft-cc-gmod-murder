EVENT_AK47 = 1
EVENT_KATANAS = 2
EVENT_CROSSBOW = 3
EVENT_CROSSBOWHARD = 4
EVENT_ULIKIPICKUP = 5
EVENT_KATANASHARD = 6
EVENT_CVP = 7
EVENT_TD = 8
EVENT_BOOM = 9
EVENT_SLENDER = 10

EVENTSINFO = {}
EVENTSINFO[EVENT_AK47] = {
name = 'AK-47', players = 8
}
EVENTSINFO[EVENT_KATANAS] = {
name = 'KATANAS', players = 10
}
EVENTSINFO[EVENT_CROSSBOW] = {
name = 'CROSSBOW', players = 9
}
EVENTSINFO[EVENT_CROSSBOWHARD] = {
name = 'CROSSBOW-HARD', players = 9
}
EVENTSINFO[EVENT_KATANASHARD] = {
name = 'KATANAS-HARD', players = 9
}
EVENTSINFO[EVENT_ULIKIPICKUP] = {
name = 'LOOT PICKER', players = 9
}
EVENTSINFO[EVENT_CVP] = {
name = 'CVP', players = 10
}
EVENTSINFO[EVENT_TD] = {
name = 'Tails-Doll', players = 10, roles = 
	{
		[MURDER] = 'Tails-Doll',
		[0] = 'Жертва',
	}
}
EVENTSINFO[EVENT_BOOM] = {
name = 'BOOM', players = 10,
		[0] = 'BOOM',
}
EVENTSINFO[EVENT_SLENDER] = {
name = 'Slender', players = 10, roles = 
	{
		[MURDER] = 'Слендер',
		[0] = 'Потерявшийся',
	}
}

function EventPars(ID)
	if EVENTSINFO[ID] then
		return true, ID, EVENTSINFO[ID]
	end
	return false
end

function EventParsRoles(ID)
	if EVENTSINFO[ID] and EVENTSINFO[EVENT_TD].roles then
		return true, EVENTSINFO[ID].roles
	end
	return false
end

/* Функции для ивентов */
function TrueVisible(posa, posb, owner)
	local filt = owner or player.GetAll()
	return not util.TraceLine({start = posa, endpos = posb,mask = MASK_SHOT, filter = filt}).Hit
end

hook.Add("UpdateAnimation","Slenderman_UpdateAnimations",function(pl, velocity, maxseqgroundspeed)
	
	if EVENTS:Get('ID') == EVENT_SLENDER and pl:GetRole(MURDER) then
		if velocity:Length2D() < 1 then
			pl:SetCycle(0)
		else
			pl:SetPlaybackRate(0.7)
		end
		return true
	end

end)
local meta = FindMetaTable("Player")
function meta:EnhancedDistortClose()
	
	if math.random(0,2) == 1 then
		self:ViewPunchReset()
	end
		if math.random(0,2) > 0 then
			self:ViewPunch( Angle( math.random(-2, 2), math.random(-2,2), math.random(-2,2)) )
			if math.random(0,5) == 0 then
				self:SetFOV( math.random(5,20), 0.1)
			else self:SetFOV(0, 0.1)
			end
			--print("close")
		else
			if math.random(0,5) == 0 then
				self:ViewPunch( Angle( math.random(-30, 30), math.random(-30,30), math.random(-30,30)) )
				--print("HeavyClose")
			end
		end
end

function meta:EnhancedDistortFar()

	if math.random(0,2) == 1 then
		self:ViewPunchReset()
	end
		if math.random(0,2) > 1 then
			self:ViewPunch( Angle( math.random(-0.5, 0.5), math.random(-0.5,0.5), math.random(-0.5,0.5)) )
			if math.random(0,15) == 0 then
				self:SetFOV( math.random(20,50), 0.1)
			else self:SetFOV(0, 0.1)
			end
			--print("Far")
		else
			if math.random(0,15) == 0 then
				self:ViewPunch( Angle( math.random(-10, 10), math.random(-10,10), math.random(-10,10)) )
				--print("Heavy far")
			end
		end
end
function GM:ShouldCollide( ent1, ent2 )
	-- print(EVENTS:Get('ID') == EVENT_SLENDER)
	if EVENTS:Get('ID') == EVENT_SLENDER then
		if ent1:IsPlayer() and ent2:IsPlayer() then
			if ent1:GetRole(MURDER) and !ent1:GetNWBool('slender.isvisible') and ent2:GetRole(0) or ent2:GetRole(MURDER) and !ent2:GetNWBool('slender.isvisible') and ent1:GetRole(0) then
				return false
			end
		end
		if ent1:IsPlayer() and ent1:GetRole(MURDER) and (ent2:GetClass() == "prop_physics" or ent2:GetClass() == "prop_door_rotating") or
			ent2:IsPlayer() and ent2:GetRole(MURDER) and (ent1:GetClass() == "prop_physics" or ent1:GetClass() == "prop_door_rotating") then
			return false
		end
		return true
	end
end

function GM:Move( pl, mv )		
	if EVENTS:Get('ID') == EVENT_SLENDER then
		local wep = IsValid(pl:GetActiveWeapon()) and pl:GetActiveWeapon()
		if wep and wep.Move then
			wep:Move(mv)
		end
	end
end