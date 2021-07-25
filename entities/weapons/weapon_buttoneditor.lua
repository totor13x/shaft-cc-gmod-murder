if SERVER then
	util.AddNetworkString("ButtonEditor")
	util.AddNetworkString("ButtonEditorRefresh")
	util.AddNetworkString("EffectsRinging")
else
	GAMEMODE.AllButtons = GAMEMODE.AllButtons or {}
	net.Receive("ButtonEditorRefresh", function()
		GAMEMODE.AllButtons = net.ReadTable()
	end)
	print('aa')
end

local luabsp = MapPatcher.Libs.luabsp
local quickhull = MapPatcher.Libs.quickhull
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


SWEP.PrintName	= "Редактор Кнопок"

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
	if SERVER then
		net.Start("ButtonEditorRefresh")
			local buttons = {}
			for i,v in pairs(ents.FindByClass("func_button")) do
				if ButtonsAllow[v:GetCreationID()] then
					buttons[v:GetPos()] = true
				else
					buttons[v:GetPos()] = false
				end
			end
			net.WriteTable(buttons)
		net.Send(self.Owner)
	end
end

function SWEP:PrimaryAttack()
/*
	if SERVER then
	net.Start("ButtonEditorRefresh")
		local buttons = {}
		for i,v in pairs(ents.FindByClass("func_button")) do
			buttons[v:GetPos()] = true
		end
		net.WriteTable(buttons)
	net.Send(self.Owner)
	end
*/
		
	if ( CLIENT && !IsFirstTimePredicted() ) then return end
	local tr = util.GetPlayerTrace( self.Owner )
	//tr.mask = bit.bor( CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX )
	local trace = util.TraceLine( tr )
	if ( !trace.Hit ) then return end
	local ent = trace.Entity
	if SERVER then
		if IsValid(ent) and ent:GetClass() == 'func_button' then
			print(!ButtonsAllow[ent:MapCreationID()], ent:MapCreationID())
			if !ButtonsAllow[ent:MapCreationID()] then
				AddButtonItem(ent:MapCreationID())
				net.Start("ButtonEditorRefresh")
					local buttons = {}
					for i,v in pairs(ents.FindByClass("func_button")) do
						if ButtonsAllow[v:MapCreationID()] then
							buttons[v:GetPos()] = true
						else
							buttons[v:GetPos()] = false
						end
					end
					net.WriteTable(buttons)
				net.Send(self.Owner)
			/*
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
			*/
			else
				RemoveButtonItem(self.Owner, ent:MapCreationID())
				net.Start("ButtonEditorRefresh")
					local buttons = {}
					for i,v in pairs(ents.FindByClass("func_button")) do
						if ButtonsAllow[v:MapCreationID()] then
							buttons[v:GetPos()] = true
						else
							buttons[v:GetPos()] = false
						end
					end
					net.WriteTable(buttons)
				net.Send(self.Owner)
			end
		end
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

end

--
-- Deploy - Allow lastinv
--
function SWEP:Deploy()

	return true

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

function SWEP:ShouldDropOnDie() return false end

if ( SERVER ) then return end -- Only clientside lua after this line

function draw.Circle( x, y, radius, seg )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

hook.Remove( "PostDrawOpaqueRenderables", "ButtonEditorTree")

function SWEP:DrawHUD()
	for i, v in pairs(GAMEMODE.AllButtons) do
		local screen = i:ToScreen()
		if v then
			surface.SetDrawColor( 0, 255, 0, 255 )
		else
			surface.SetDrawColor( 255, 0, 0, 255 )
		end
		draw.Circle( screen.x-8, screen.y-8 , 16, math.sin( CurTime() ) * 20 + 25 )
	end
end
function SWEP:PrintWeaponInfo( x, y, alpha ) end


local matScreen = Material( "models/weapons/v_toolgun/screen" )
local txBackground = surface.GetTextureID( "models/weapons/v_toolgun/screen_bg" )

-- GetRenderTarget returns the texture if it exists, or creates it if it doesn't
local RTTexture = GetRenderTarget( "GModToolgunScreen", 256, 256 )

surface.CreateFont( "GModToolScreen", {
	font	= "Helvetica",
	size	= 40,
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
			DrawScrollingText( "Редакирование кнопок", 104, TEX_SIZE )


	cam.End2D()
	render.SetRenderTarget( OldRT )
	render.SetViewPort( 0, 0, oldW, oldH )

end
