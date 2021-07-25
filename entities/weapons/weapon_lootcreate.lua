if SERVER then
	util.AddNetworkString("LootEditing")
	util.AddNetworkString("LootEditingChangeModel")
	
	net.Receive("LootEditingChangeModel", function(len, ply)
	//if ply:GGG then
		if !ply:IsSuperAdmin() then return end
		mu_loot_changemodel(net.ReadVector(), net.ReadString())
	end)
	
else
	net.Receive("LootEditing", function()
		local ent = net.ReadEntity()
		local bool = net.ReadBool()
		for i,v in pairs(ents.FindByClass("mu_loot")) do
			v.Edition = false
		end
		if IsValid(ent) then
			ent.Edition = bool
			ent.LootData = net.ReadTable()
		end
	end)
end

AddCSLuaFile()

SWEP.ViewModel		= "models/weapons/c_toolgun.mdl"
SWEP.WorldModel		= "models/weapons/w_toolgun.mdl"

SWEP.UseHands		= true
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"


SWEP.PrintName	= "ЛутРедактор"

SWEP.Slot		= 5
SWEP.SlotPos	= 1
SWEP.DrawCrosshair	= true

SWEP.DrawAmmo		= false
SWEP.Spawnable		= true


if ( SERVER ) then

	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false

end

function SWEP:Initialize()
	self:SetHoldType( "pistol" )
end

function SWEP:Think()
if CLIENT then
	if IsValid(FrameEditModelsLoot) then
	local lootm = {}
	for i,v in pairs(ents.FindByClass("mu_loot")) do
		if v.Edition then
			table.insert(lootm, v)
		end
	end
	if #lootm == 0 then
		FrameEditModelsLoot:Remove()
	end
	end
	end

end

if CLIENT then
	if FrameEditModelsLoot then
	FrameEditModelsLoot:Remove()
	end

end

function SWEP:Reload()
	if !CLIENT then return end
	if ( !IsFirstTimePredicted() ) then return end
	if ( IsValid(FrameEditModelsLoot) ) then return end
	local lootm = {}
	for i,v in pairs(ents.FindByClass("mu_loot")) do
		if v.Edition then
			table.insert(lootm, v)
		end
	end
	if #lootm == 1 then
		function AddSlot(id, frame, bool)
			Slot = vgui.Create("DModelPanel", FrameEditModelsLoot)  
			Slot:SetSize(108,96)
			Slot.ID = id 
			
			Slot:SetModel(LootModels[id])
			
			local PrevMins, PrevMaxs = Slot.Entity:GetRenderBounds()
			Slot:SetCamPos(PrevMins:Distance(PrevMaxs) * Vector(0.5, 0.5, 0.5))
			Slot:SetLookAt((PrevMaxs + PrevMins) / 2)
			Slot.DoClick = function(s)
				local modelold = s.Entity:GetModel()
				lootm[1].LootData.model = modelold
				net.Start( "LootEditingChangeModel" )
					net.WriteVector(lootm[1].LootData.pos)
					net.WriteString(modelold)
				net.SendToServer()
				
			end
			Slot.Paint = function( self, w, h )
				draw.RoundedBox( 0, 0, 0, w-2, h-2,Color( 35, 35, 35,200) )
				if lootm[1].LootData ~= nil and self.Entity:GetModel() == string.lower(lootm[1].LootData.model) then draw.RoundedBox( 0, 0, 0, w-2, h,  Color(210,0,0,255)) end
				if ( !IsValid( self.Entity ) ) then return end

				local x, y = self:LocalToScreen( 0, 0 )

				self:LayoutEntity( self.Entity )

				local ang = self.aLookAngle
				if ( !ang ) then
					ang = (self.vLookatPos-self.vCamPos):Angle()
				end

				cam.Start3D( self.vCamPos, ang, self.fFOV, x, y, w, h, 5, self.FarZ )

				render.SuppressEngineLighting( true )
				render.SetLightingOrigin( self.Entity:GetPos() )
				render.ResetModelLighting( self.colAmbientLight.r/255, self.colAmbientLight.g/255, self.colAmbientLight.b/255 )
				render.SetColorModulation( self.colColor.r/255, self.colColor.g/255, self.colColor.b/255 )
				render.SetBlend( self.colColor.a/255 )

				for i=0, 6 do
					local col = self.DirectionalLight[ i ]
					if ( col ) then
						render.SetModelLighting( i, col.r/255, col.g/255, col.b/255 )
					end
				end

				self:DrawModel()

				render.SuppressEngineLighting( false )
				cam.End3D()

			//end
				
				
				render.MaterialOverride()
			end
			frame:AddItem(Slot)
			table.insert(frame.list, Slot)
			
			return Slot
		end
		FrameEditModelsLoot = vgui.Create("DFrame")
		//FrameEditModelsLoot:SetPos(10+500,30+25)
		FrameEditModelsLoot:SetSize(350,400)
		FrameEditModelsLoot:MakePopup()
		FrameEditModelsLoot:Center()
		FrameEditModelsLoot:SetTitle("")
		FrameEditModelsLoot:SetDeleteOnClose(true)
		FrameEditModelsLoot.Paint = function( s, w, h )
			draw.RoundedBox( 0, 0, 0, w, h,Color( 35, 35, 35,200) ) 
			draw.RoundedBox( 0, 0, 0, w, 25, Color( 5, 5, 5,255) )
			draw.SimpleText("Редактор улик", "Defaultfont", 10, 2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
		end
		
		local PanelSlots = vgui.Create("DPanelSelect", FrameEditModelsLoot)
		PanelSlots:SetPos(5, 30)
		PanelSlots:SetSize(345,400-5-30)
		PanelSlots.list = {}
		for i,v in pairs(LootModels) do
			AddSlot(i, PanelSlots)
		end

	end
end

function SWEP:ziiip(trace)
	local effectdata = EffectData()
	effectdata:SetOrigin( trace.HitPos )
	effectdata:SetNormal( trace.HitNormal )
	effectdata:SetEntity( trace.Entity )
	effectdata:SetAttachment( trace.PhysicsBone )
	util.Effect( "selection_indicator", effectdata )

	local effectdata = EffectData()
	effectdata:SetOrigin( trace.HitPos )
	effectdata:SetStart( self.Owner:GetShootPos() )
	effectdata:SetAttachment( 1 )
	effectdata:SetEntity( self )
	util.Effect( "ToolTracer", effectdata )
end

function SWEP:PrimaryAttack()

	if ( CLIENT && !IsFirstTimePredicted() ) then return end
	local tr = util.GetPlayerTrace( self.Owner )
	tr.mask = bit.bor( CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX )
	local trace = util.TraceLine( tr )
	if ( !trace.Hit ) then return end
	local ent = trace.Entity
	if SERVER and IsValid(ent) and ent:GetClass() == 'mu_loot' then
		net.Start( "LootEditing" )
			net.WriteEntity(ent)
			net.WriteBool(true)
			net.WriteTable(ent.LootData)
		net.Send(self.Owner)
		ent.NoChang = true
		timer.Simple(60, function()
			if IsValid(ent) then
			ent.NoChang = false
			end
		end)
	end
	self:SetNextPrimaryFire(CurTime() + 0.3)
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self:ziiip(trace)
end

--
-- SecondaryAttack - Nothing. See Tick for zooming.
--
function SWEP:SecondaryAttack()

	if ( CLIENT && !IsFirstTimePredicted() ) then return end
	local tr = util.GetPlayerTrace( self.Owner )
	tr.mask = bit.bor( CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX )
	local trace = util.TraceLine( tr )
	if ( !trace.Hit ) then return end
	if (trace.HitWorld) then
		local ply = self.Owner
		if SERVER then mu_loot_add(ply:GetAngles() * 1, ply:GetEyeTrace().HitPos, 'random') end
	end

	local ent = trace.Entity
	if SERVER and IsValid(ent) and (ent:GetClass() == 'mu_loot' or ent:GetClass() == 'mu_loot_extra') then
		for k, pos in pairs(LootItems) do
			if ent.NoChang and ent.LootData.pos == pos.pos then
				local ang = ent.LootData.angle
				local pos2 = ent.LootData.pos
				local name = ent:GetModel()
								
				mu_loot_remove(k)
				
				timer.Simple(0, function() mu_loot_add(ang, pos2, name, true) end)
				ent:Remove()
				return
			end
			if ent.LootData.pos == pos.pos then
				//RunConsoleCommand("mu_loot_remove", k)
				mu_loot_remove(k)
				ent:Remove()
			end
		end
	end
	self:SetNextSecondaryFire(CurTime() + 0.3)
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self:ziiip(trace)
end

--
-- Deploy - Allow lastinv
--
function SWEP:Deploy()

	return true

end

function SWEP:ShouldDropOnDie() return false end

if ( SERVER ) then return end -- Only clientside lua after this line

function SWEP:DrawHUD() end
function SWEP:PrintWeaponInfo( x, y, alpha ) end


local matScreen = Material( "models/weapons/v_toolgun/screen" )
local txBackground = surface.GetTextureID( "models/weapons/v_toolgun/screen_bg" )

-- GetRenderTarget returns the texture if it exists, or creates it if it doesn't
local RTTexture = GetRenderTarget( "GModToolgunScreen", 256, 256 )

surface.CreateFont( "GModToolScreen", {
	font	= "Helvetica",
	size	= 60,
	weight	= 900
} )

local function DrawScrollingText( text, y, texwide )

	local w, h = surface.GetTextSize( text )
	w = w + 64

	y = y - h / 2 -- Center text to y position

	local x = RealTime() * 250 % w * -1

	while ( x < texwide ) do

		surface.SetTextColor( 0, 0, 0, 255 )
		surface.SetTextPos( x + 3, y + 3 )
		surface.DrawText( text )

		surface.SetTextColor( 255, 255, 255, 255 )
		surface.SetTextPos( x, y )
		surface.DrawText( text )

		x = x + w

	end

end

--[[---------------------------------------------------------
	We use this opportunity to draw to the toolmode
		screen's rendertarget texture.
-----------------------------------------------------------]]
function SWEP:RenderScreen()

	local TEX_SIZE = 256
	local mode = GetConVarString( "gmod_toolmode" )
	local oldW = ScrW()
	local oldH = ScrH()

	-- Set the material of the screen to our render target
	matScreen:SetTexture( "$basetexture", RTTexture )

	local OldRT = render.GetRenderTarget()

	-- Set up our view for drawing to the texture
	render.SetRenderTarget( RTTexture )
	render.SetViewPort( 0, 0, TEX_SIZE, TEX_SIZE )
	cam.Start2D()

		-- Background
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetTexture( txBackground )
		surface.DrawTexturedRect( 0, 0, TEX_SIZE, TEX_SIZE )

		-- Give our toolmode the opportunity to override the drawing


			surface.SetFont( "GModToolScreen" )
			DrawScrollingText( "ЭТО ОРУЖИЕ СДЕЛАНО ДЛЯ ТОГО ЧТОБЫ ПРОЩЕ БЫЛО СОЗДАВАТЬ УЛИКИ И РЕДАКТИРОВАТЬ ИХ", 104, TEX_SIZE )


	cam.End2D()
	render.SetRenderTarget( OldRT )
	render.SetViewPort( 0, 0, oldW, oldH )

end
