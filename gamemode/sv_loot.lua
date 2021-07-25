
if !LootItems then
	LootItems = {}
end

local FruitModels = {
	"models/props/cs_italy/bananna_bunch.mdl",
	"models/props/cs_italy/orange.mdl",
	"models/props/cs_italy/bananna.mdl",
	"models/props_junk/watermelon01.mdl"
}
function GM:LoadLootData() 
	local mapName = game.GetMap()
	local jason = file.Read("murder/" .. mapName .. "/loot.txt", "DATA")
	if jason then
		local tbl = util.JSONToTable(jason)
		LootItems = tbl
	end
end

function giveMagnum(ply)
	-- if they already have the gun, drop the first and give them a new one
	for k,v in ipairs(ply:GetWeapons()) do	
		if not v:IsValid() then continue end
		if string.find( v:GetClass(), "weapon_mu_magnum" )  then
			ply:DropWeapon(ply:GetWeapon(v:GetClass()))
		end
	end
	
	if ply:GetTKer() then
		-- if they are penalised, drop the gun on the floor
		ply.TempGiveMagnum = true -- temporarily allow them to pickup the gun
		
		if ply:GetNWString("ps_weapon_rev") == '' then
			ply:SetNWString("ps_weapon_rev",'weapon_mu_magnum_def')
		end
		local ps_we = ply:GetNWString("ps_weapon_rev")
		ply:Give( ps_we )
		ply:DropWeapon(ply:GetWeapon(ps_we))
		
	else
		
		if ply:GetNWString("ps_weapon_rev") == '' then
			ply:SetNWString("ps_weapon_rev",'weapon_mu_magnum_def')
		end
		
		ply:Give( ply:GetNWString("ps_weapon_rev"))
		ply:SelectWeapon(ply:GetNWString("ps_weapon_rev"))
		
	end
end

function GM:PickupLoot(ply, ent, count, target)
	if count == nil then
		count = 1
	end
	
	ply:SetLoot(ply:GetLoot()+count)
		
	if IsValid(target) and target:IsPlayer() then
		ply = target
	
		ply:SetLoot(ply:GetLoot()+(count*-1))
	end
	
	lootDrop(ply, ent)
	
	if ply != target then
		ply:EmitSound("ambient/levels/canals/windchime2.wav", 100, math.random(40,160))
		ent:Remove()
	else
		target:EmitSound("items/gift_pickup.wav", 70, 100)
	end
end

function GM:PickupExtraDo(ply)
	print('extra', ply)
	
	if ply:HasWeapon('weapon_mu_knife_blink') then
		return false
	end
	
end

function GM:SaveLootData()

	// ensure the folders are there
	if !file.Exists("murder/","DATA") then
		file.CreateDir("murder")
	end

	local mapName = game.GetMap()
	if !file.Exists("murder/" .. mapName .. "/","DATA") then
		file.CreateDir("murder/" .. mapName)
	end

	// JSON!
	local jason = util.TableToJSON(LootItems)
	file.Write("murder/" .. mapName .. "/loot.txt", jason)
end

function GM:AddLootItem(ent)
	local data = {}
	data.model = ent:GetModel()
	data.material = ent:GetMaterial()
	data.pos = ent:GetPos()
	data.angle = ent:GetAngles()
	table.insert(LootItems, data)
end

function GM:SpawnLoot()
	for k, ent in pairs(ents.FindByClass("mu_loot")) do
		ent:Remove()
	end

	for k, data in pairs(LootItems) do
		self:SpawnLootItem(data, data.Extra and true or false)
	end
end

function GM:LootThink()
	if self:GetRound(1) and EVENTS:Get('SpawnLoot') then

		if !self.LastSpawnLoot || self.LastSpawnLoot < CurTime() then
			self.LastSpawnLoot = CurTime() + 7
			if EVENTS:Get('ID') == EVENT_TD then
				self.LastSpawnLoot = CurTime() + 3
			end
			if EVENTS:Get('ID') == EVENT_SLENDER then
				self.LastSpawnLoot = CurTime() + 60
			end
			local data = table.Random(LootItems)
			if data then
				self:SpawnLootItem(data, data.Extra and true or false)
			end
		end
	end
end
concommand.Add('mu_loot_respawn', function(ply)
	if !IsValid(ply) || ply:IsSuperAdmin() then
		for i,v in pairs(LootItems) do
			GAMEMODE:SpawnLootItem(v, v.Extra and true or false)
		end
		if ply:IsValid() then
			ply:ChatPrint(#LootItems..' spawned!')
		else
			print(#LootItems..' spawned!')
		end
		
	end
end)

function GM:SpawnLootItem(data, bool)
	for k, ent in pairs(ents.FindByClass("mu_loot*")) do
		if ent.LootData == data then
			ent:Remove()
		end
	end
	
	local def = "mu_loot"
	if bool then
		def = 'mu_loot_extra'
	end
	
	local ent = ents.Create(def)
	ent:SetModel(data.model)
	ent:SetPos(data.pos)
	ent:SetAngles(data.angle)
	ent:Spawn()

	ent.LootData = data

	return ent
end

local function getLootPrintString(data, plyPos) 
	local str = math.Round(data.pos.x) .. "," .. math.Round(data.pos.y) .. "," .. math.Round(data.pos.z) .. " " .. math.Round(data.pos:Distance(plyPos) / 12) .. "ft"
	str = str .. " " .. data.model
	return str
end

function mu_loot_add(ang, pos, name, bool)

	local mdl = ""

	if name == "rand" || name == "random" then
		mdl = table.Random(LootModels)
	elseif name == "fruit" then
		mdl = table.Random(FruitModels)
	elseif !name:find("%.mdl$") then
		if !LootModels[name] then
			ply:ChatPrint("Invalid model alias " .. name)
			return
		end
		mdl = LootModels[name]
	elseif name:find("%.mdl$") then
		mdl = name
	end


	local data = {}
	data.model = mdl
	data.pos = pos
	data.angle = ang
	data.angle.p = 0
	
	if bool then
		data.Extra = true
	end
	table.insert(LootItems, data)

	
	GAMEMODE:SaveLootData()

	local ent = GAMEMODE:SpawnLootItem(data, data.Extra and true or false)
	local mins, maxs = ent:OBBMins(), ent:OBBMaxs()
	local pos = ent:GetPos()
	pos.z = pos.z - mins.z
	ent:SetPos(pos)

	data.pos = pos
	GAMEMODE:SaveLootData()
end

function mu_loot_remove(key)
	if !LootItems[key] then
		ply:ChatPrint("Invalid key, position inexists")
		return
	end

	local data = LootItems[key]
	table.remove(LootItems, key)
	
	GAMEMODE:SaveLootData()
end

function mu_loot_changemodel(pos, model)
	local id = 0
	local idded = ''
	for k, pos2 in pairs(LootItems) do
		if pos:IsEqualTol( pos2.pos,0.1 ) then idded = pos2.pos id = k end
	end
	if id ~= 0 then
	local data = LootItems[id]
	data.model = model
	
	for k, ent in pairs(ents.FindByClass("mu_loot*")) do
		if ent.LootData.pos == idded then
			ent:SetModel(model)
		end
	end
	
	
	GAMEMODE:SaveLootData()
	end
end