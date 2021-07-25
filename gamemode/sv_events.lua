util.AddNetworkString("RoundADS")
util.AddNetworkString("GetInfoADS")

EVENTS = EVENTS or {}
function EVENTS:Reload()

	EVENTS.data = {
		['ID'] = 0,
		['RDM'] = true,
		['SpawnRoles'] = true,
		['CustomEnd'] = false,
		['CustomDeath'] = false,
		['CustomThink'] = false,
		['Figth1vs1'] = false,
		['SpawnLoot'] = true,
	}
	
end

net.Receive("GetInfoADS", function (len, ply)
	EVENTS:Refresh(ply)
end)

function EVENTS:Refresh(ply)
	if type(self.data) ~= 'table' then
		self:Reload()
	end
	
	net.Start("RoundADS")
	net.WriteTable(EVENTS.data)
	if ply == nil then
		net.Broadcast()
	else
		net.Send(ply)
	end
end

function EVENTS:Edit(key, value)
	EVENTS.data[key] = value
end

function EVENTS:Get(key)
	if type(self.data) ~= 'table' then
		self:Reload()
	end
	return EVENTS.data[key]
end

function EVENTS:GetID(key)
	return key != nil and (EVENTS.data and EVENTS.data["ID"] or 0) == key or (EVENTS.data and EVENTS.data["ID"] or 0)
end
