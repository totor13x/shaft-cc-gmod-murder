
-----------------------------------------------------

if( SERVER ) then
	AddCSLuaFile( "shared.lua" );
end

SWEP.PrintName		= "Воровать"
SWEP.ViewModel	= "models/weapons/c_arms.mdl"
SWEP.WorldModel	= ""
SWEP.ViewModelFOV       = 62
SWEP.ViewModelFlip      = false
SWEP.AnimPrefix  = "stunstick"
SWEP.Spawnable      = false
SWEP.AdminSpawnable          = true
SWEP.NextStrike = 0;
SWEP.FakeAttack = 0;
SWEP.UseHands = true
SWEP.Primary.ClipSize      = -1    
SWEP.Primary.DefaultClip        = 0  
SWEP.Primary.Automatic    = false  
SWEP.Primary.Ammo                     = ""
SWEP.Secondary.ClipSize  = -1    
SWEP.Secondary.DefaultClip      = 0   
SWEP.Secondary.Automatic        = false  
SWEP.Secondary.Ammo               = ""

SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""
SWEP.DrawWeaponInfoBox = false
SWEP.Slot				= 2
SWEP.SlotPos			= 1

SWEP.HoldType = "normal"
SWEP.SequenceDraw = "fists_draw"
SWEP.SequenceIdle = "fists_idle_01"

function SWEP:SetupDataTables()
	self:NetworkVar( "String", 0, "tablea" )
	self:NetworkVar( "Int", 0, "Charge" )
	self:NetworkVar( "Bool", 0, "IsPlaying" )
	self:NetworkVar( "Bool", 0, "Used" )
end

function SWEP:Initialize()
	self.PrintName = "Воровать"
	self.tableWep = {}
	self:Settablea("")
	self:SetWeaponHoldType( self.HoldType );
	self.Owner:SetNWBool("AmVor", false)
	self.Owner:SetNWEntity("HeIsVoring", nil)
	self.Obvod = CurTime()
end

local function addangle(ang,ang2)
	ang:RotateAroundAxis(ang:Up(),ang2.y) -- yaw
	ang:RotateAroundAxis(ang:Forward(),ang2.r) -- roll
	ang:RotateAroundAxis(ang:Right(),ang2.p) -- pitch
end

function SWEP:CalcViewModelView(vm, opos, oang, pos, ang)
	
	// iron sights
	local pos2 = Vector(-35, 0, 0)
	addangle(ang, Angle(-90, 0, 0))
	pos2:Rotate(ang)
	return pos + pos2, ang
end

function SWEP:checkPlayer( ply )
	if SERVER then
		if IsValid(ply) then
			ply:SetMoveType(MOVETYPE_WALK)
			self:SetUsed(true)
			
			local nametable = {
				["weapon_mu_knife"] = true,
				["weapon_mu_magnum"] = true,
				["weapon_mu_adr"] = true,
				["weapon_mu_def"] = true,
				["weapon_mu_vodka"] = true,
				["weapon_mu_secretbomb"] = true,
			}
			local asdfake = false
			for k,v in ipairs(self.Owner:GetWeapons()) do
				if v:GetClass() == 'weapon_mu_magnum_fake' then
					self.Owner:StripWeapon('weapon_mu_magnum_fake')
					asdfake = true
					break
				end
			end
			
			for k,v in ipairs(ply:GetWeapons()) do
				local name = v:GetClass()
				//table.insert(self.tableWep,name)
				local scripg = string.Explode("_",name)
				if scripg[3] == nil then continue end
				if name == 'weapon_mu_magnum_fake' then continue end
				if nametable[scripg[1].."_"..scripg[2].."_"..scripg[3]] then
					ply:StripWeapon(name)
					ply:SelectWeapon('weapon_mu_hands')
					
					self.Owner:Give(name)
					self.Owner:SelectWeapon(name)
					
				end
			end
			
			//timer.Simple(0, function()
				
				if asdfake then
					ply:Give('weapon_mu_magnum_fake')
				end
			//end)
			
			if self:IsValid() then
				self:Remove()
			end
			
			
		end

	end
end
 
function SWEP:SecondaryAttack()
end

function SWEP:Deploy()
	if IsValid(self.Owner) then
		//self:PreModel()
	end
end

function SWEP:Think()
	local trace = self.Owner:GetEyeTrace();
	local tr = self.Owner:GetEyeTraceNoCursor()
	local checksh = CreateSound(trace.Entity, Sound("physics/body/body_medium_scrape_smooth_loop1.wav"))
	if SERVER and self.Owner:GetNWBool("AmVor") then
		if self.Owner:GetNWEntity("HeIsVoring") == trace.Entity && self.Owner:KeyDown(IN_ATTACK) and tr.HitPos:Distance(tr.StartPos) < 150 then
			if self.Owner:KeyReleased(IN_ATTACK) and SERVER then
				self.Owner:SetNWBool("AmVor", false)
				self.Owner:GetNWEntity("HeIsVoring"):SetNWBool("HeVoring", false)
				self.Owner:GetNWEntity("HeIsVoring"):SetMoveType(MOVETYPE_WALK)
				//self.Owner:EmitSound("Weapon_Crossbow.BoltElectrify");
				checksh:Stop()
				self:Remove()
				self:SetIsPlaying(false)
			end
			if (self.Owner:KeyDown(IN_ATTACK) and self.Owner:GetNWEntity("HeIsVoring")) then
				self.Obvod = CurTime() + 0.7
			end
				if not self:GetIsPlaying() then
					checksh:Play()
					//self.Owner:EmitSound(Sound("physics/body/body_medium_scrape_smooth_loop1.wav"));
					self:SetIsPlaying(true)
				end
		else

			if self.Obvod >= CurTime() then
				return
			end

			self.Owner:SetNWBool("AmVor", false)
			self.Owner:GetNWEntity("HeIsVoring"):SetNWBool("HeVoring", false)
			self.Owner:GetNWEntity("HeIsVoring"):SetMoveType(MOVETYPE_WALK)
			//self.Owner:EmitSound("Weapon_Crossbow.BoltElectrify");
			checksh:Stop()
			self:Remove()
			self:SetIsPlaying(false)
		end
		if self:GetCharge() <= CurTime() then
			self.P = self.Owner
			if SERVER then
			self:checkPlayer( self.Owner:GetNWEntity("HeIsVoring") )
			end
			self.Owner:SetNWBool("AmVor", false)
			self.Owner:GetNWEntity("HeIsVoring"):SetNWBool("HeVoring", false)
			self.Owner:GetNWEntity("HeIsVoring"):SetMoveType(MOVETYPE_WALK)
			//self.Owner:EmitSound("Weapon_Crossbow.BoltElectrify");
			
			checksh:Stop()
			
			if self:IsValid() then
				self:Remove()
			end
		end
	end
	
end

function SWEP:DrawHUD()
/*
if type(util.JSONToTable(self:Gettablea())) == "table" then
local tableWep = util.JSONToTable(self:Gettablea())
if #tableWep > 0 then
local abc = {
			"weapon_mu_hands",
			"weapon_boombox",
			}
			for i,v in ipairs(abc) do
				table.RemoveByValue(tableWep,v)
			end 	
			local nametable = {
				["weapon_mu_knife"] = 'Нож',
				["weapon_mu_magnum"] = 'Магнум',
				["weapon_mu_def"] = 'Дефибриллятор',
				["weapon_mu_adr"] = 'Адреналин',
				["weapon_mu_secretbomb"] = 'Бомба',
				["weapon_mu_c4"] = 'C4',
				["weapon_mu_vodka"] = 'Водка',
				["weapon_mu_stuner"] = 'Шокер',
				["weapon_mu_hlist"] = 'Шокер дрессировщика',
				["weapon_mu_checker"] = 'Обыск',
				["weapon_ak47_csgo"] = 'CV-47',
			}
			local count = 0
					local tcol = self.Owner:GetPlayerColor()
						//print(scripg[1].."_"..scripg[2].."_"..scripg[3])
						//drawTextShadow(nametable[scripg[1].."_"..scripg[2].."_"..scripg[3]], "MersHead1", ScrW()/2, ScrH()/2-count, Color(255,255,255), 1, TEXT_ALIGN_CENTER)
						surface.DrawRect( ScrW()-200-50, ((ScrH()/2)-(#tableWep*32)/2)+count-32-16, 200, 16 )
						surface.SetDrawColor( Color(tcol.x*255,tcol.y*255,tcol.z*255,255)  )
						draw.SimpleText(  "Рез. обыска "..self.Owner:GetNWEntity("HeIsChecking"):GetBystanderName(), "Default", ScrW()-200-46,  ((ScrH()/2)-(#tableWep*32)/2)+count-24-16, Color(tcol.x*255,tcol.y*255,tcol.z*255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
						//draw.SimpleText( 'Cooldown: %', Default, ScrW()-200-50, ((ScrH()/2)-(#tableWep*32)/2)+count-23, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

						surface.SetDrawColor( Color(tcol.x*255,tcol.y*255,tcol.z*255,255)  )
						if #tableWep > 0 then
						for i,v in ipairs(tableWep) do
						local scripg = string.Explode("_",v)
						surface.DrawRect( ScrW()-200-50, ((ScrH()/2)-(#tableWep*32)/2)+count-32, 200, 20 )
						draw.SimpleText( nametable[scripg[1].."_"..scripg[2].."_"..scripg[3]], "deathrun_hud_Medium_clock", ScrW()-100-50, ((ScrH()/2)-(#tableWep*32)/2)+count-24, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1 )
						count = count+20
						end
						else
						surface.DrawRect( ScrW()-200-50, ((ScrH()/2)-(#tableWep*32)/2)+count-32, 200, 20 )
						draw.SimpleText( 'Пусто', "deathrun_hud_Medium_clock", ScrW()-100-50, ((ScrH()/2)-(#tableWep*32)/2)+count-24, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1 )
						end
end
		end
		*/
	//draw.SimpleText( self.Owner:GetNWBool("AmChecking"), Default, (ScrW()/2), (ScrH()/2)+250+8, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, tcol )
	local charge = (self:GetCharge() - CurTime())/2*100
	if charge > 0 then
		local aa = math.EaseInOut( charge, 0.1, 0.1 ) 
			surface.SetDrawColor( Color(255,255,255,150)  )
			surface.DrawRect( (ScrW()/2)-100, (ScrH()/2)+150, 200, 16 )
			local tcol = self.Owner:GetPlayerColor()
			local scc = string.Explode(".",charge)
			//draw.SimpleText('Cooldown: '..scc[1]..'%', "Default", (ScrW()/2)-100+5,  (ScrH()/2)+150-8, tcol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			surface.SetDrawColor( Color(tcol.x*255,tcol.y*255,tcol.z*255,255)  )
			surface.DrawRect( (ScrW()/2)-(charge), (ScrH()/2)+150, charge*2, 16 )
			draw.SimpleTextOutlined( 'Воровство: '..scc[1]..'%', Default, (ScrW()/2)-100+5, (ScrH()/2)+150+8, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, tcol )
			
	end
end  


function SWEP:PrimaryAttack()
	if self:GetUsed() then return false end
	local tr = self.Owner:GetEyeTraceNoCursor()
	if tr.HitPos:Distance(tr.StartPos) < 150 then
	local trace = {}
	trace.filter = self.Owner
	trace.start = self.Owner:GetShootPos()
	trace.mask = MASK_SHOT_HULL
	trace.endpos = trace.start + self.Owner:GetAimVector() * 600
	trace.mins = Vector(0,0,0)
	trace.maxs = Vector(0,0,0)
	local tr = util.TraceHull(trace)
	tr.TraceAimVector = self.Owner:GetAimVector()


	local ent = tr.Entity
	if IsValid(ent) and ent:IsPlayer()  then	
		if( SERVER )  then 
			if IsValid(self.Owner) and self.Owner:Alive() and not self.Owner:GetNWBool("AmVor") then
				self.Owner:SetNWBool("AmVor", true)
				self.Owner:SetNWEntity("HeIsVoring", ent)
				self.Owner:GetNWEntity("HeIsVoring"):SetNWBool("HeVoring", true)
				ent:SetMoveType(MOVETYPE_FLYGRAVITY)
				self:SetCharge(CurTime()+2)
				//self:checkPlayer(ent)
			end
			//self.Owner:SetAnimation( PLAYER_ATTACK1 );
			//self.Owner:EmitSound("Weapon_StunStick.Activate");
			//self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK );
		end
	end
	end
end
