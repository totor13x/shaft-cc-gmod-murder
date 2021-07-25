AddCSLuaFile()

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"
SWEP.HoldType = "normal"

SWEP.UseHands = false
SWEP.ViewModel	= "models/weapons/c_arms.mdl"
SWEP.WorldModel	= ""

SWEP.PrintName = "Слендер"

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	self:SetHoldType(self.HoldType)
	if SERVER then
		timer.Simple(0, function()
			if IsValid(self) and IsValid(self.Owner) then
				self.Owner:DrawViewModel(true)
				self.Owner:SetupHands()
				self:SetHoldType(self.HoldType)		
			end
		end)
	end
end

function SWEP:DoPrimaryAttackEffect()
end

function SWEP:PreDrawPlayerHands( vm, Player, Weapon )
	return
end

function SWEP:PostDrawPlayerHands( hands, vm, pl )
	return
end

function SWEP:PreDrawViewModel( vm, Player, Weapon )
	return
end

function SWEP:PostDrawViewModel( vm, Player, Weapon )
	return

end
--{ Time to derive localized stuff from the base file! (Necessary, does not derive)
local team = team
local CurTime = CurTime
local ipairs = ipairs
local math = math
local Vector = Vector
local util = util
local ents = ents

local nextswitch1 = 0
local tracebox = {mask = MASK_SHOT}

local switchsound = Sound( "npc/fast_zombie/wake1.wav" )

local nextswitch = 0

SWEP.StuckDistance = 60
SWEP.AttackDistance = 650
SWEP.DamageDistance = 645

-- These functions did not derive for some reason, it's gamebreaking to not have it
function SWEP:Seen( newpos, newdot, checkvisibility )
	
	local clear = true
	local cur = self.Owner:GetPos()

	for k,v in ipairs(player.GetAll()) do
		if IsValid(v) and v:Alive() and v:GetRole(0) and (v:GetPos():Distance(cur) <= self.AttackDistance and v:GetAngles():Forward():Dot((v:GetPos()-cur):GetNormal()) < (newdot or -0.3) and TrueVisible(v:EyePos(),(newpos and newpos +vector_up*64)	or self.Owner:NearestPoint(v:EyePos()),v) or self:GetInvisMode() and v:GetPos():Distance(cur) < self.StuckDistance) then
			if (v == self.Owner) then continue end
			clear = false
			break
		end
	end
	
	return !clear
	
end

function SWEP:GetInvisMode()
	return self.Owner:GetNWBool('slender.invismode')
end

function SWEP:IsVisible()
	return self.Owner:GetNWBool('slender.isvisible')
end

function SWEP:MakeVisible( bl )
	self.Owner:SetNWBool('slender.isvisible', bl)
	if self.Owner then
		self.Owner:CollisionRulesChanged()
	end
end

function SWEP:Move(mv)
	if !self:GetInvisMode() then
		mv:SetMaxSpeed( 114 )
	end
	
	if self:Seen( nil, -0.5, true) and self:IsVisible() then
		mv:SetMaxSpeed( 0 )
		mv:SetVelocity( Vector(0,0,0) )
	end
	
	if self:IsVisible() then
		mv:SetUpSpeed( 1 )
	end
	
end

function SWEP:SetInvisMode( bl )
	self.Owner:SetNWBool('slender.invismode', bl)
	if self.Owner then
		self.Owner:CollisionRulesChanged()
	end
end

function SWEP:CheckTeleportPos()
	
	if self:Seen() then return end
	if !self:IsVisible() then return end
	
	local target = self:GetClosest()
	
	if IsValid(target) then
		tracebox.start = target:GetPos()+vector_up*2
		tracebox.endpos = target:GetPos() +vector_up*2 + target:GetAngles():Forward()*900
		tracebox.mins = Vector(-20,-20,0)
		tracebox.maxs = Vector(20,20,80)
		tracebox.filter = target
		
		local tr = util.TraceHull( tracebox )
		
		if !tr.Hit and !self:Seen( tracebox.endpos ) and TrueVisible(target:EyePos(),tracebox.endpos+vector_up*64,v) then
			return tracebox.endpos, tracebox.start
		end
		
	end
	
	return 
	
end

function SWEP:PrimaryAttack()
	if true then return end
	if CLIENT then return end
	if nextswitch1 >= CurTime() then return end
	if self:Seen() then return end
	if !self:IsVisible() then return end
	-- print(game.GetWorld():GetDTInt( 1 ))
	if game.GetWorld():GetDTInt( 1 ) < 4 then return end
	nextswitch = CurTime() + 0.1
	
	local to, targetpos = self:CheckTeleportPos()
	print(to)
	if to and targetpos then	
		self.Owner:SetPos(to)
		local dir = (targetpos-self.Owner:GetPos()):GetNormal()
		local ang = dir:Angle()
		self.Owner:SetEyeAngles(Angle(0,ang.y,ang.r))	
		nextswitch = CurTime() + 10
	end
end

function SWEP:GetClosest()
	local Closest = 999999999999999999
	local dist = 0
	local Ent = nil
		for k, v in ipairs(player.GetAll()) do
			dist = v:GetPos():Distance( self.Owner:GetPos() )
				if( dist < Closest) then
					if v:IsPlayer() and v:Alive() then
						Closest = dist
						Ent = v
						if math.random(20) == 1 then
							break
						end
					end
				end
		end
	return Ent
end

function SWEP:SecondaryAttack()
	if nextswitch >= CurTime() then return end
	if self:Seen() then return end
	nextswitch = CurTime() + 0.1
	

	if CLIENT then 
		self.Owner:EmitSound( switchsound, 35,120 )
	else
		self:SetInvisMode( !self:GetInvisMode() )
		if not self.Owner:OnGround() then
			self.Owner:SetLocalVelocity(vector_origin)
		end
	end
end

if CLIENT then

function SWEP:FreezeMovement()
	return self:Seen(nil, -0.5, true) and self:IsVisible()
end

function SWEP:DrawWorldModel()
	-- print(EyePos():Distance(self.Owner:GetPos()) >= 600, !self:IsVisible())
	if EyePos():Distance(self.Owner:GetPos()) >= 1600 then return end
	if !self:IsVisible() then return end
		
		local bone = self.Owner:GetAttachment(self.Owner:LookupAttachment("eyes"))//self.Owner:LookupBone("ValveBiped.Bip01_Head1")
		-- print(bone)
		if bone then
			local pos,ang = bone.Pos, bone.Ang//self.Owner:GetBonePosition(bone)
			if pos and ang then
				local dlight = DynamicLight( self.Owner:EntIndex() )
				if ( dlight ) then
					dlight.Pos = pos+self.Owner:GetAngles():Forward() * 13//+ang:Forward()*3
					dlight.r = 255
					dlight.g = 255
					dlight.b = 255
					dlight.Brightness = 5
					dlight.Size = 40
					dlight.Decay = 40 * 5
					dlight.DieTime = CurTime() + 1
					dlight.Style = 0
				end
			end
		end
end

end
--}


function SWEP:Think()

	local ct = CurTime()

	-- print(self.Owner:GetVelocity():Length() > 1 and self:GetInvisMode(), not self:Seen(), self.Owner)
	if self.Owner:GetVelocity():Length() > 1 and self:GetInvisMode() then
		-- print(not self:Seen())
		if not self:Seen() then
			self.Owner:SetRenderMode(RENDERMODE_NONE)
			if self:IsVisible() then
				self:MakeVisible( false )
			end
		end
		//self.Owner:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	else
			if not self:Seen() then
				self.Owner:SetRenderMode(RENDERMODE_NORMAL)
				//self.Owner:SetCollisionGroup(COLLISION_GROUP_PLAYER)
				
				if !self:IsVisible() then
					self:MakeVisible( true )
				end
			end
			
			if SERVER then
				self.NextAttack = self.NextAttack or ct + 0.5
				
				if self.NextAttack < ct then
					
					self:Attack()
					
					self.NextAttack = ct + 0.1
				end
			end
		//end
	end
	
	self:NextThink(ct)
	
	//if GetConVar("slender_enhanceddistortions"):GetInt() == 1 then
	self:EnhancedDistort()
	//end

end

function SWEP:Attack()

	local cur = self.Owner:GetPos()

	for k,v in ipairs(player.GetAll()) do
		if v == self.Owner then continue end
		if IsValid(v) and self:IsVisible() and v:Alive() and (v:GetPos():Distance(cur) <= self.AttackDistance and v:GetAngles():Forward():Dot((v:GetPos()-cur):GetNormal()) < -0.3 and TrueVisible(v:EyePos(),self.Owner:NearestPoint(v:EyePos()),v) or v:GetPos():Distance(cur) <= self.StuckDistance+3) then
			v:SetHealth(math.Clamp(v:Health()-math.Clamp(5*((self.DamageDistance-v:GetPos():Distance(cur))/self.DamageDistance),0,5),0,100))
			-- v:BreakBattery(math.Clamp(3*((self.DamageDistance-v:GetPos():Distance(cur))/self.DamageDistance),0,3))
			v.NextRegen = CurTime() + 3
			
			-- Enhanced Distortions
			-- if GetConVar("slender_enhanceddistortions"):GetInt() == 1 then
				if v:GetPos():Distance(cur) <= 400 then
					v:EnhancedDistortClose()
				else
					v:EnhancedDistortFar()
				end
			-- end
			
			if v:Health() <= 0 and (v.NextDeath or 0) <= CurTime() then
				v.NextDeath = CurTime() + 10
				v:Freeze(true)
				v:SendLua("ShowCloseup()")
				timer.Simple(3, function() 
					if IsValid(v) then
						-- if CurTime() - ROUNDTIME >= 10 then
						local Dmg = DamageInfo()
						Dmg:SetAttacker(self.Owner)
						Dmg:SetInflictor(v)
						Dmg:SetDamage(1)
						v:TakeDamageInfo( Dmg )
						-- end
					end
				end)
			end
		end
	end

end


if CLIENT then

function SWEP:DrawHUD()
	//if GAMEMODE:IsNight() then
		local light = self.Owner
		
		if light and IsValid(light) then
			light:SetOwner(LocalPlayer())
			light:SetPos(EyePos())
			light:SetAngles(EyeAngles())
		end
	//else
	/*	local dlight = DynamicLight( self:EntIndex() )
		if ( dlight ) then
			dlight.Pos = EyePos()+EyeAngles():Forward()*30
			dlight.r = 255
			dlight.g = 55
			dlight.b = 55
			dlight.Brightness = 3
			dlight.Size = 570
			dlight.Decay = 570 * 5
			dlight.DieTime = CurTime() + 1
			dlight.Style = 0
		end*/
	//end
	
	-- for k,v in pairs(team.GetPlayers(TEAM_HUMENS)) do
	-- for i,v in pairs(player.GetAll()) do
		-- local pos = v:GetShootPos():ToScreen()
		-- draw.SimpleText(v:GetPages().."/"..v:GetMaxPages(), "S_Regular_20",pos.x, pos.y, Color(215,215,215,250), TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		-- draw.SimpleText('Придурок', "S_Regular_20",pos.x, pos.y, Color(215,215,215,250), TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	-- end
	-- end
	
	-- for k,v in pairs(team.GetPlayers(TEAM_PROXY)) do
		-- local pos = v:GetShootPos():ToScreen()
		-- if v:Alive() and v:GetActiveWeapon():GetBlinded() then
			-- draw.SimpleText("!PROXY [BLINDED]!", "S_Regular_20",pos.x, pos.y, Color(215,215,215,250), TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		-- else
			-- draw.SimpleText("PROXY", "S_Regular_20",pos.x, pos.y, Color(215,215,215,250), TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		-- end
	-- end
	local dy = ScrH() - 90
	local visible = self:IsVisible()
	local seen = self:Seen() and visible
	
	surface.SetDrawColor( seen and Color(40,200,40,233) or Color(215,15,15,233) )
	surface.DrawRect( 50, dy-16, 200, 16 )
	local seen_info = ""
	if seen then
		seen_info = "Кто-то тебя видит!"
	else
		seen_info = "Никто не видит"
		if visible then
			seen_info = seen_info .. " (но ты видимый)"
		end
	end
	draw.SimpleText( seen_info , "Default", 50+4,  (dy-16) + 16/2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	
	
	surface.SetDrawColor( !self:GetInvisMode() and Color(40,200,40,233) or Color(215,15,15,233) )
	surface.DrawRect( ScrW()-200-50, dy-16, 200, 16 )
	draw.SimpleText(  (self:Seen() and "(Забл.) " or "").."ПКМ - Триггер невидимости - "..(!self:GetInvisMode() and "вкл." or "выкл."), "Default", ScrW()-200-50+4,  (dy-16) + 16/2, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	
	-- surface.SetDrawColor( self:CheckTeleportPos() and Color(15,215,15,100) or Color(215,15,15,100) )
	-- surface.DrawRect( ScrW()-200-50, dy-16, 200, 16 )
	-- draw.SimpleText(  (Entity(0):GetDTInt( 1 ) < 4 and "(Недост.) " or "").."ЛКМ - ТП к ближайшему игроку", "Default", ScrW()-200-50+4,  (dy-16) + 16/2, Color(255,255,255,150), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	
	-- draw.SimpleText(seen and "Someone sees you!" or "Noone sees you", "S_Regular_30",50, ScrH()-170, seen and Color(15,215,15,100) or Color(215,15,15,100), TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
	-- draw.SimpleText("X", "S_Regular_130",50, ScrH()-100, visible and Color(15,215,15,100) or Color(215,15,15,100), TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
	
	-- draw.SimpleText((self:Seen() and "(Blocked) " or "").."RMB - Toggle invisibility", "S_Regular_30",ScrW()-50, ScrH()-170, !self:GetInvisMode() and Color(15,215,15,100) or Color(215,15,15,100), TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
	-- if Entity(0):GetDTInt( 1 ) < 4 then return end
	-- draw.SimpleText((self:CheckTeleportPos() and "" or "(Blocked) ").."LMB - Teleport to nearby player", "S_Regular_30",ScrW()-50, ScrH()-90, self:CheckTeleportPos() and Color(15,215,15,100) or Color(215,15,15,100), TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
	
end

end

-- Enhanced Distortion (I know this is here twice, both in Meta and here)
function SWEP:EnhancedDistort( newpos, newdot, checkvisibility )
	-- print(self:IsVisible())
	if !self:IsVisible() then return end
	
	local cur = self.Owner:GetPos()

	for k,v in ipairs(player.GetAll()) do
		if v == self.Owner then continue end
		if IsValid(v) and v:Alive() and (v:GetPos():Distance(cur) <= self.AttackDistance and v:GetAngles():Forward():Dot((v:GetPos()-cur):GetNormal()) < (newdot or -0.3) and TrueVisible(v:EyePos(),(newpos and newpos +vector_up*64)	or self.Owner:NearestPoint(v:EyePos()),v) or self:GetInvisMode() and v:GetPos():Distance(cur) < self.StuckDistance) then
	
			-- print(v)
			--print("EY")
			if math.random(0,2) == 1 then
				v:ViewPunchReset()
			end
			if math.random(0,1) == 1 then
				if cur:Distance(v:GetPos()) < 500 then
					v:ViewPunch( Angle( math.random(-10, 10), math.random(-10,10), math.random(-10,10)) )
					if math.random(0,3) == 0 then
						v:SetFOV( math.random(5,20), 0.1)
						--print("FOV")
					else v:SetFOV(0, 0.1)
					end
					--print("close")
				else
					v:ViewPunch( Angle( math.random(-5, 5), math.random(-5,5), math.random(-5,5)) )
					if math.random(0,10) == 0 then
						v:SetFOV( math.random(20,50), 0.1)
						--print("FOV far")
					else v:SetFOV(0, 0.1)
					end
					--print("Short")
				end
			else
				if cur:Distance(v:GetPos()) < 500 then
					if math.random(0,5) == 0 then
						v:ViewPunch( Angle( math.random(-50, 50), math.random(-50,50), math.random(-50,50)) )
						--print("Heavy")
					end
				else
					if math.random(0,15) == 0 then
						v:ViewPunch( Angle( math.random(-15, 15), math.random(-15,15), math.random(-15,15)) )
						--print("Heavy far")
					end
				end
			end
		timer.Simple(0.1, function() v:SetFOV(0, 0.01) v:ViewPunchReset() end)
		end
	end
end

net.Receive("InformSlender", function()
	if net.ReadBit() == 0 then
		proxyBlinded = false
	else
		proxyBlinded = true
	end
end)
