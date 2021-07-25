print("Loaded cl_menus.lua...")

XHairThickness = CreateClientConVar("deathrun_crosshair_thickness", 2, true, false)
XHairGap = CreateClientConVar("deathrun_crosshair_gap", 8, true, false)
XHairSize = CreateClientConVar("deathrun_crosshair_size", 8, true, false)
XHairRed = CreateClientConVar("deathrun_crosshair_red", 255, true, false)
XHairGreen = CreateClientConVar("deathrun_crosshair_green", 255, true, false)
XHairBlue = CreateClientConVar("deathrun_crosshair_blue", 255, true, false)
XHairAlpha = CreateClientConVar("deathrun_crosshair_alpha", 255, true, false)

local crosshair_convars = {
	{"header", "Crosshair Dimensions"},
	{"number", "deathrun_crosshair_thickness",0,16, "Stroke Thickness"},
	{"number", "deathrun_crosshair_gap",0,32, "Inner Gap"},
	{"number", "deathrun_crosshair_size",0,32, "Stroke Length"},

	{"header", "Crosshair Color"},
	{"number", "deathrun_crosshair_red",0,255, "Red"},
	{"number", "deathrun_crosshair_green",0,255, "Green"},
	{"number", "deathrun_crosshair_blue",0,255, "Blue"},
	{"number", "deathrun_crosshair_alpha",0,255, "Transparency"},
}

function OpenCrosshairCreator()
	local frame = vgui.Create("DFrame")
	frame:SetSize(640,480)
	frame:Center()
	frame:MakePopup()
	frame:SetTitle("")
	frame.Paint = function(s,x,y)
    DLib.blur.DrawPanel(x, y, s:LocalToScreen(0, 0))
		draw.RoundedBox( 0, 0, 0, x, y, Color( 35, 35, 35,200) )		
		draw.RoundedBox( 0, 0, 0, x, 25, Color( 5, 5, 5,255) )
		
		draw.SimpleText("Создание прицела", "Defaultfont", 10, 2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)		
	end
	local panel = vgui.Create("DPanel", frame)
	panel:SetSize( frame:GetWide()-5, frame:GetTall()-35 )
	panel:SetPos(5,30)
	function panel:Paint() end

	local drawx = vgui.Create("DPanel", panel)
	drawx:SetSize( panel:GetWide()/2 - 5, panel:GetTall() )
	drawx:SetPos(0,0)

	function drawx:Paint(w,h)

		surface.SetDrawColor( 35, 35, 35,200)
		surface.DrawRect(0,0,w,h)

		local XHairThickness = GetConVar("deathrun_crosshair_thickness")
		local XHairGap = GetConVar("deathrun_crosshair_gap")
		local XHairSize = GetConVar("deathrun_crosshair_size")
		local XHairRed = GetConVar("deathrun_crosshair_red")
		local XHairGreen = GetConVar("deathrun_crosshair_green")
		local XHairBlue = GetConVar("deathrun_crosshair_blue")
		local XHairAlpha = GetConVar("deathrun_crosshair_alpha")

		local thick = XHairThickness:GetInt()
		local gap = XHairGap:GetInt()
		local size = XHairSize:GetInt()

		surface.SetDrawColor(XHairRed:GetInt(), XHairGreen:GetInt(), XHairBlue:GetInt(), XHairAlpha:GetInt())
		surface.DrawRect(w/2 - (thick/2), h/2 - (size + gap/2), thick, size )
		surface.DrawRect(w/2 - (thick/2), h/2 + (gap/2), thick, size )
		surface.DrawRect(w/2 + (gap/2), h/2 - (thick/2), size, thick )
		surface.DrawRect(w/2 - (size + gap/2), h/2 - (thick/2), size, thick )
	end

	local controls = vgui.Create("DPanel", panel)
	controls:SetSize( panel:GetWide()/2 - 5, panel:GetTall() )
	controls:SetPos( panel:GetWide() - controls:GetWide() -5, 0 )

	function controls:Paint(w,h)
		surface.SetDrawColor( Color(200,200,200,255) )
		surface.DrawRect(0,0,w,h)
	end

	local scr = vgui.Create("DScrollPanel", controls)
	scr:SetSize( controls:GetWide()-16, controls:GetTall()-16 )
	scr:SetPos(8,8)

	local vbar = scr:GetVBar()
	vbar:SetWide(4)

	function vbar:Paint(w,h)
		surface.SetDrawColor(0,0,0,100) 
		surface.DrawRect(0,0,w,h)
	end
	function vbar.btnUp:Paint() end
	function vbar.btnDown:Paint() end
	function vbar.btnGrip:Paint(w, h)
		surface.SetDrawColor(0,0,0,200)
		surface.DrawRect(0,0,w,h)
	end

	local dlist = vgui.Create("DIconLayout", scr)
	dlist:SetSize( scr:GetSize() )
	dlist:SetPos(0,0)
	dlist:SetSpaceX(0)
	dlist:SetSpaceY(4)

	local lbl = vgui.Create("DLabel")
	lbl:SetFont("lidi_hud_32")
	lbl:SetTextColor(Color(0,0,0,255))
	lbl:SetText("Crosshair Options")
	lbl:SizeToContents()
	lbl:SetWide( dlist:GetWide() )
	dlist:Add(lbl)

	for k,v in pairs( crosshair_convars ) do
		local ty = v[1] -- convar type

		if ty == "header" then
			local pnl = vgui.Create("DPanel") -- spacer
			pnl:SetWide( dlist:GetWide() )
			pnl:SetTall( 24 )
			function pnl:Paint() end
			dlist:Add( pnl )

			local lbl = vgui.Create("DLabel")
			lbl:SetFont("lidi_hud_25")
			lbl:SetTextColor(Color(0,0,0,255))
			lbl:SetText(v[2])
			lbl:SizeToContents()
			lbl:SetWide( dlist:GetWide() )
			dlist:Add(lbl)
		elseif ty == "number" then
			local lbl = vgui.Create("DLabel") -- label
			lbl:SetFont("deathrun_derma_Tiny")
			lbl:SetTextColor( Color(0,0,0,255) )
			lbl:SetText(v[5])
			lbl:SizeToContents()
			lbl:SetWide( dlist:GetWide() )
			dlist:Add(lbl)

			-- slider
			local sl = vgui.Create("Slider")
			sl:SetMin( v[3] )
			sl:SetMax( v[4] )
			sl:SetWide(dlist:GetWide())
			sl:SetValue( GetConVar( v[2] ):GetFloat() )

			sl.convarname = v[2]

			function sl:OnValueChanged()
				RunConsoleCommand(self.convarname, self:GetValue())
			end

			dlist:Add(sl)	
		end
	end

end

concommand.Add("deathrun_open_crosshair_creator", function()
	OpenCrosshairCreator()
end)
