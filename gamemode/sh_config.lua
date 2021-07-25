
LootModels = {}
LootModels["breenbust"] = "models/props_c17/woodbarrel001.mdl"
LootModels["huladoll"] = "models/props_lab/huladoll.mdl"
LootModels["beer1"] = "models/props_junk/glassbottle01a.mdl"
LootModels["beer2"] = "models/props_junk/glassjug01.mdl"
LootModels["cactus"] = "models/props_lab/cactus.mdl"
LootModels["lamp"] = "models/props_lab/desklamp01.mdl"
LootModels["clipboard"] = "models/props_lab/clipboard.mdl"
LootModels["suitcase1"] = "models/props_c17/suitcase_passenger_physics.mdl"
LootModels["suitcase2"] = "models/props_c17/suitcase001a.mdl"
LootModels["battery"] = "models/items/car_battery01.mdl"
LootModels["toothbrush"] = "models/props/cs_militia/toothbrushset01.mdl"
LootModels["circlesaw"] = "models/props/cs_militia/circularsaw01.mdl"
LootModels["axe"] = "models/props/cs_militia/axe.mdl"
LootModels["skull"] = "models/Gibs/HGIBS.mdl"
LootModels["baby"] = "models/props_c17/doll01.mdl"
LootModels["antlionhead"] = "models/Gibs/Antlion_gib_Large_2.mdl"
LootModels["briefcase"] = "models/props_c17/BriefCase001a.mdl"
LootModels["breenclock"] = "models/props_combine/breenclock.mdl"
LootModels["sawblade"] = "models/props_junk/sawblade001a.mdl"
LootModels["wrench"] = "models/props_c17/tools_wrench01a.mdl"
LootModels["consolebox"] = "models/props_c17/consolebox01a.mdl"
LootModels["cashregister"] = "models/props_c17/cashregister01a.mdl"
LootModels["bananabunch"] = "models/props/cs_italy/bananna_bunch.mdl"
LootModels["banana"] = "models/props/cs_italy/bananna.mdl"
LootModels["orange"] = "models/props/cs_italy/orange.mdl"
LootModels["familyphoto"] = "models/props_lab/frame002a.mdl"
LootModels["watermelon"] = "models/props_junk/watermelon01.mdl"

if CLIENT then return end

function checkAvailableMap(ply)
 local tab = {
	['ttt_minecraft_b5'] = true,
	//['mu_springbreak'] = true,
 }
 
 if (tab[game.GetMap()]) then
 if EVENTS:Get('ID') != EVENT_CVP and  EVENTS:Get('ID') != EVENT_TD then
	local ent = ents.Create( "wings_color" )
	ent:SetPos( ply:GetPos() )
	ent:Spawn()
	ent:Activate()
	ent:SetOwner( ply )
	ent:SetParent( ply )
	ply.cWings = ent
 end
 end
end

tabletoBysNick = {}
tabletoBysNick["male"] = { 
	{"Олег"},
	{"Кирилл"},
	{"Слава"},
	{"Даниил"},
	{"Алексей"},
	{"Влад"},
	{"Валера"},
	{"Максим"},
	{"Сергей"},
	{"Денис"},
	{"Тарас"},
	{"Ваня"},
	{"Антон"}, 
	{"Илья"} ,
	{"Вова"},
	{"Глеб"},
	{"Карл"},
	{"Артур"},
	{"Иван"},
	{"Петр"},
	{"Гуля"},
	{"Гена"},
	{"Вася"},
	{"Юра"},
	{"Эндрю"},
	{"Афанасий"},
	{"Гарик"},
	{"Богдан"},
	{"Ярослав"},
	{"Коля"},
	{"Альберт"},
	{"Адам"},
	{"Арсений"},
	{"Борис"},
	{"Герман"},
	{"Егор"},
	{"Леонард"},
	{"Макс"},
	{"Артем"} ,
	{"Феликс"},
	{"Серафим"},
	{"Эдуард"},
	{"Ян"},
	{"Юлий"},
	{"Эрнест"},
	{"Матвей"},
	{"Руслан"},
	{"Федор"},
	{"Эльбрус"},
	{"Дэвид"},
}
tabletoBysNick["female"] = {
	{"Анна"},
	{"Аня"},
	{"Кристина"},
	{"Ася"},
	{"Алина"},
	{"Яна"},
	{"Вика"},
	{"Роза"},
	{"Таня"},
	{"Ольга"},
	{"Катя"} ,
	{"Саша"},
	{"Инна"},
	{"Маша"},
	{"Алла"},
	{"Галя"},
	{"Ева"},
	{"Рита"},
	{"Марина"},
	{"Лолита"},
	{"Валерия"},
	{"Лина"},
	{"Надя"},
	{"Стелла"},
	{"Марта"},
	{"Ксюша"},
	{"Люба"},
	{"Соня"},
	{"Полина"},
	{"Алеся"},
	{"Лера"},
	{"Даша"},
}