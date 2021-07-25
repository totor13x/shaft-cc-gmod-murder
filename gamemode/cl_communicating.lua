net.Receive("chattext_msg", function (len)
	local msgs = {}
	while true do
		local i = net.ReadUInt(8)
		if i == 0 then break end
		local str = net.ReadString()
		local col = net.ReadVector()
		table.insert(msgs, Color(col.x, col.y, col.z))
		table.insert(msgs, str)
	end
	chat.AddText(unpack(msgs))
end)

net.Receive("chattext_msgnetstring", function (len)
	local msgs = {}
	local stringed = {}
	local muted = false
	local entity = net.ReadEntity()
	if IsValid(entity) and entity.SetMute then muted = true end
	if muted then return end
	while true do
		local i = net.ReadUInt(8)
		if i == 0 then break end
		local str = net.ReadString()
		local col = net.ReadVector()
		table.insert(msgs, Color(col.x, col.y, col.z))
		table.insert(msgs, str)
		table.insert(stringed, str)
	end
	chat.AddText(unpack(msgs))
	if IsValid(ChatWindow) and IsValid(panel2dropeedlist) then
		//PrintTable(aa)
		local Dbutus = vgui.Create( "DPanel", ChatWindow)
		Dbutus:SetSize(panel2dropeedlist:GetWide(),30 + 2)
		Dbutus:SetText("")
		Dbutus:Dock( BOTTOM )
		Dbutus.ply = ""
		Dbutus.tesm = entity:Team()
		Dbutus.strText = table.concat( stringed, " " )
		Dbutus.Paint = function( s, w, h )
			draw.SimpleText(s.ply, "S_Light_15", 10, 8, team.GetColor(s.tesm), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(s.strText, "S_Light_15", 10, 20, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end	
		ChatWindow:AddItem(Dbutus)	
	end
end)

AnnouncerName = "HELP" -- incase the file refreshes
AnnouncerColor = Color(231,76,60)

local msgs = {}

msgs = {
-- 'Чтобы узнать что делает та или иная роль откройте таб -> описание ролей',
-- 'Для перехода в наблюдатели/игроки используйте таб -> в игроки/наблюдатели',
-- 'Донат доступен по клавише F6',
-- 'Не поверите, но у нас есть сайт. Домен - https://shaft.сс/',
}

function AddAnnouncement( ann )
	table.insert( msgs, ann or "Blank Announcement" )
end

local idx = 1

local function DoAnnouncements()

	chat.AddText( Color(233,242,249), "[", AnnouncerColor, AnnouncerName,  Color(233,242,249), "] "..(msgs[idx]))
	idx = idx + 1
	if idx > #msgs then idx = 1 end
end

timer.Create("DeathrunAnnouncementTimer", 120, 0, function()
	DoAnnouncements()
end)