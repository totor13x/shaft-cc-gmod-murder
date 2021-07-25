
if !SpawnsPoint then
	SpawnsPoint = {}
end

function GM:LoadSpawnsData() 
	local mapName = game.GetMap()
	local jason = file.Read("murder/" .. mapName .. "/spawn.txt", "DATA")
	if jason then
		local tbl = util.JSONToTable(jason)
		SpawnsPoint = tbl
	end
end

function GM:SaveSpawnsData()

	// ensure the folders are there
	if !file.Exists("murder/","DATA") then
		file.CreateDir("murder")
	end

	local mapName = game.GetMap()
	if !file.Exists("murder/" .. mapName .. "/","DATA") then
		file.CreateDir("murder/" .. mapName)
	end

	// JSON!
	local jason = util.TableToJSON(SpawnsPoint)
	file.Write("murder/" .. mapName .. "/spawn.txt", jason)
end

function GM:AddSpawnItem(pos)
	table.insert(SpawnsPoint, pos)
end

function AddSpawnItem(pos)

	GAMEMODE:AddSpawnItem(pos)
	GAMEMODE:SaveSpawnsData()
	
end

function RemoveSpawnItem(key)
	if !SpawnsPoint[key] then
		ply:ChatPrint("Invalid key, position inexists")
		return
	end

	local data = SpawnsPoint[key]
	table.remove(SpawnsPoint, key)
	
	GAMEMODE:SaveSpawnsData()
end