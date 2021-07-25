if SERVER then
	util.AddNetworkString("SpawnEditingSpawn")
	util.AddNetworkString("SpawnEditingRefresh")
	net.Receive("SpawnEditingRefresh", function(ln, ply)
		net.Start('SpawnEditingSpawn')
			net.WriteTable(SpawnsPoint)
		net.Send(ply)
	end)
else
	net.Receive("SpawnEditingSpawn", function()
		local table = net.ReadTable()
		//print(table)
		LocalPlayer().SpawnList = table
	end)
	function InverseLerp( pos, p1, p2 )

		local range = 0
		range = p2-p1

		if range == 0 then return 1 end

		return ((pos - p1)/range)

	end
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


SWEP.PrintName	= "СпавнРедактор"

SWEP.Slot		= 5
SWEP.SlotPos	= 1
SWEP.DrawCrosshair	= true

SWEP.DrawAmmo		= false
SWEP.Spawnable		= true
/*
function SWEP:SetupDataTables()

	self:NetworkVar( "String", 0, "Spawns" )
	if SERVER then
		self:SetSpawns(util.TableToJSON(SpawnsPoint))
	end
end
*/

if ( SERVER ) then

	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false

end

function SWEP:Initialize()
	if CLIENT then
	net.Start('SpawnEditingRefresh')
	net.SendToServer()
	end
	self:SetHoldType( "pistol" )

end
//do 
function SWEP:Think()
if CLIENT then
	for i,v in pairs(LocalPlayer().SpawnList or {}) do
		local dist = self.Owner:GetPos():Distance(v) 
		local color = Color(0,255,0)
		if dist < 150 then
			color = Color(255,0,0)
		end
		
		local bottomLight = DynamicLight(i);

		if (bottomLight) then
			bottomLight.pos = v;
			bottomLight.brightness = 0.5;
			bottomLight.Size = 350;
			bottomLight.Decay = 1000
			bottomLight.r = color.r;
			bottomLight.g = color.g;
			bottomLight.b = color.b;
			bottomLight.DieTime = CurTime() + 0.2;
			bottomLight.style = 0;
		end;
	end;
	self:NextThink(CurTime());

	return true;
end;
end
//end

function SWEP:Reload()
	if ( !IsFirstTimePredicted() ) then return end
	if CLIENT then
		net.Start('SpawnEditingRefresh')
		net.SendToServer()
	end
end
/*
local mat2 = CreateMaterial("blinkBottom", "UnlitGeneric", {
	["$basetexture"] = "particle/particle_glow_05",
	["$basetexturetransform"] = "center .5 .5 scale 1 1 rotate 0 translate 0 0",
	["$additive"] = 1,
	["$translucent"] = 1,
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1,
	["$ignorez"] = 1
});
*/
/*
function SWEP:Draw3D()
	if CLIENT then
		
		for i,v in pairs(util.JSONToTable(self:GetSpawns())) do
			//local bottomVis = util.PixelVisible(v, 3, self.bottomVis);

			//if (bottomVis and bottomVis >= 0.1) then
			//end
		end
	end
end
*/
function SWEP:ziiip(pos)
	for i,v in pairs(SpawnsPoint) do
		if v:Distance(pos) < 150 then
			return self.Owner:ChatPrint('Близко к другому спавну')
		end
	end
	AddSpawnItem(pos)
	self.Owner:ChatPrint('Точка добавлена')
end

function SWEP:SAziiip(pos)
	for i,v in pairs(SpawnsPoint) do
		if v:Distance(pos) < 100 then
			self.Owner:ChatPrint('Точка удалена')
			RemoveSpawnItem(i)
			return
		end
	end
	self.Owner:ChatPrint('Подойдите к точке чтобы она была на расстоянии 100 юнит.')
	//AddSpawnItem(pos)
end

function SWEP:PrimaryAttack()

	
	if ( !IsFirstTimePredicted() ) then return end
	self:SetNextPrimaryFire(CurTime() + 0.3)
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	if SERVER then self:ziiip(self.Owner:GetPos()) end
	if CLIENT then
	timer.Simple(0, function()
		net.Start('SpawnEditingRefresh')
		net.SendToServer()
	end)
	end
end

--
-- SecondaryAttack - Nothing. See Tick for zooming.
--
function SWEP:SecondaryAttack()
	if ( !IsFirstTimePredicted() ) then return end
	self:SetNextPrimaryFire(CurTime() + 0.3)
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	if SERVER then self:SAziiip(self.Owner:GetPos()) end
	
	if CLIENT then
	timer.Simple(0, function()
		net.Start('SpawnEditingRefresh')
		net.SendToServer()
	end)
	end
end

--
-- Deploy - Allow lastinv
--
function SWEP:Deploy()

	return true

end


function SWEP:ShouldDropOnDie() return false end

if ( SERVER ) then return end -- Only clientside lua after this line

function SWEP:DrawHUD()
	local tablr = LocalPlayer().SpawnList or {}
	draw.SimpleText( #tablr..'/'..game.MaxPlayers(), "CloseCaption_Normal", ScrW()-5, 5, Color(255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT)
	if #tablr >= game.MaxPlayers() then
	draw.SimpleText( 'Работают кастомные спавны!', "CloseCaption_Normal", ScrW()-5, 25, Color(120,255,120), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT)
	end
	for i,v in pairs(tablr) do
		local data = v:ToScreen()
		local a = 0
		local color = Color(0,255,0)
		local dist = self.Owner:GetPos():Distance( v )
		if dist > 750 then
			a = 0
		elseif dist < 200 then
			a = 255
		else
			a = InverseLerp( dist, 750, 200 )*255
		end
		if dist < 150 then
			color = Color(255,0,0)
		end
		
		color.a = a
		
		draw.SimpleText( math.Round(dist, 2), "default", data.x, data.y, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	//return true
end
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
			DrawScrollingText( "СПАВНКРЕЙАТОР", 104, TEX_SIZE )


	cam.End2D()
	render.SetRenderTarget( OldRT )
	render.SetViewPort( 0, 0, oldW, oldH )

end
