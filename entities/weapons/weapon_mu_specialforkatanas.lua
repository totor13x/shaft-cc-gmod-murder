AddCSLuaFile()

SWEP.PrintName	= "Ebony Blade"			
SWEP.Author		= "calafex for coding, Deika for model"
SWEP.Purpose    = "to suck life essence"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Base         = "weapon_base"
SWEP.Category     = "The Elder Scrolls V: Skyrim"
SWEP.ViewModelFOV = 70
SWEP.Primary.ClipSize 		= -1
SWEP.Primary.DefaultClip 	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo 			= "none"
SWEP.Primary.Delay			= 0.08	

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo 		= "none"	

SWEP.Weight			    = 5
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= false
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.ViewModel = "models/weapons/c_ebonyblade.mdl"
SWEP.WorldModel = "models/weapons/w_ebonyblade.mdl"

SWEP.UseHands = true

SWEP.SuckedDamage = 120
SWEP.MaxSuckedDamage = 200

local validDoors = {"func_door", "func_door_rotating", "prop_door_rotating"}

function SWEP:SetupDataTables()
	weapons.Get("weapon_mu_knife_def").SetupDataTables(self)
	self:NetworkVar( "Int", 0, "Charge" )
	self:NetworkVar( "Int", 1, "Cooldown" )
end

local function find_in_cone(cone_origin, cone_direction, cone_radius, cone_angle)
	local entities = ents.FindInSphere(cone_origin, cone_radius)
	local result = {}
	cone_direction:Normalize()
	local cos = math.cos(cone_angle)
	for _, entity in pairs(entities) do local pos = entity:GetPos() local dir =
	pos - cone_origin dir:Normalize() local dot = cone_direction:Dot(dir)
	if (dot > cos) then table.insert(result, entity) end end
	return result
end

function SWEP:Think()

end

function SWEP:Initialize()
	self:SetWeaponHoldType("melee2")
	self:SetHoldType("melee2")
end

function SWEP:PrimaryAttack()
	local Range     = 120
    local Forward 	= self.Owner:GetAimVector()
	local AttackSrc = self.Owner:EyePos()
	local AttackEnd = AttackSrc + Forward * Range
	
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Weapon:SetPlaybackRate(1.5)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	
	self:SetNextPrimaryFire(CurTime() + 1.2)
	
	self.Owner:ViewPunch(Angle(0, 2, -2))
	    
    self.Owner:LagCompensation(true)
    
    local tracedata = {}

	tracedata.start     = AttackSrc
	tracedata.endpos    = AttackEnd
	tracedata.filter    = self.Owner
    tracedata.mask      = MASK_SOLID
    tracedata.mins      = Vector( -16 , -16 , -18 )
    tracedata.maxs      = Vector( 16, 16 , 18 )
	
    -- We should calculate trajectory twice. If TraceHull hits entity, then we use second trace, otherwise - first.
    -- It's needed to prevent head-shooting since in CS:GO you cannot headshot with knife
    local tr1 = util.TraceLine( tracedata )
    local tr2 = util.TraceHull( tracedata )
    local tr = IsValid(tr2.Entity) and tr2 or tr1
    
    self.Owner:LagCompensation(false) -- Don't forget to disable it!
	
    local DidHit            = tr.Hit and not tr.HitSky
	
	if DidHit then
		if IsValid(tr.Entity) then
			local dmg = DamageInfo()
			dmg:SetDamage(self.SuckedDamage)
			dmg:SetDamageType(DMG_SLASH)
			dmg:SetAttacker(self.Owner)
			dmg:SetInflictor(self.Weapon)
			dmg:SetDamageForce(self.Owner:GetAimVector() * 10)
			
			if SERVER then 
				tr.Entity:TakeDamageInfo(dmg)

				if tr.Entity:IsPlayer() then
					self.Owner:SetHealth(self.Owner:Health() + self.SuckedDamage * 0.2)

					if not tr.Entity:Alive() then self.SuckedDamage = math.min(self.MaxSuckedDamage, self.SuckedDamage + math.random(15, 20)) end
				end
			end
		end

		local trs = self.Owner:GetEyeTrace()
	
		if tr.Entity:IsPlayer() or tr.Entity:IsNPC() and IsValid(tr.Entity) then
			for i = 1, 5 do
				EffectData():SetOrigin(tr.HitPos)
				EffectData():SetAngles(tr.HitNormal:Angle())
				util.Effect("BloodImpact", EffectData())
						
				self.Weapon:EmitSound("weapons/skyrimswords/wpn_impact_blade_flesh_0"..math.random(3)..".wav")
			end
		else
			self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
			
			self.Weapon:EmitSound("weapons/skyrimswords/fx_melee_sword_other_0"..math.random(3)..".wav")
				
			if self.Owner:GetShootPos():Distance(trs.HitPos) < 97 then
				util.Decal("ManhackCut", trs.HitPos + trs.HitNormal, trs.HitPos - trs.HitNormal)
					
				EffectData():SetOrigin(tr.HitPos)
				EffectData():SetAngles(tr.HitNormal:Angle()) --doesnt work
				--util.Effect("ManhackSparks", EffectData())
			end
		end
	else	
		self.Weapon:EmitSound("weapons/skyrimswords/fx_swing_blade_medium_0"..math.random(4)..".wav")
	end
end

function SWEP:Reload()
end

function SWEP:Deploy()
	self.Weapon:EmitSound("weapons/skyrimswords/wpn_blade1hand_draw_0"..math.random(3)..".wav")
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	self:SetNextPrimaryFire(CurTime() + 1.5)
end

function SWEP:SecondaryAttack()	
end



function SWEP:functionsettime(coold)
	self:SetCooldown(coold)
	self:SetCharge( CurTime() + coold);

	local aim = self.Owner:GetAimVector( )
	local force  = aim*(self:GetCooldown()*500)+Vector(0,0,500)
	local plyHeadPos = self.Owner:GetPos()+Vector(0,0,0)

	local Dmg = DamageInfo()
	Dmg:SetAttacker(self.Owner)
	Dmg:SetInflictor(self.Owner)
	Dmg:SetDamage(10000)
	
	for k,v in pairs (find_in_cone(plyHeadPos,aim,400,math.pi/4)) do
		if v ~= self.Owner then
			if (v:IsValid() and !table.HasValue(validDoors, v:GetClass()) ) then
				if v:IsPlayer() and v:Alive() and self:GetCooldown() > 15 then
					v:SetVelocity(force*5)
					timer.Simple(0, function() v:TakeDamageInfo( Dmg ) end)
				elseif v:GetMoveType( ) == MOVETYPE_VPHYSICS then
					v:GetPhysicsObject():SetVelocity(force)
				else
					v:SetVelocity(force)
				end
			end
		end
	end

	//self.Owner:SendLua('dragonShout:ScreenFlash(1,145,255,255,75)')
end

function SWEP:DrawHUD()
	local charge = (self:GetCharge() - CurTime())/self:GetCooldown()*100
	if charge > 0 then
		local aa = math.EaseInOut( charge, 0.1, 0.1 ) 
			surface.SetDrawColor( Color(255,255,255,150)  )
			surface.DrawRect( (ScrW()/2)-100, (ScrH()/2)+230, 200, 16 )
			local tcol = self.Owner:GetPlayerColor()
			local scc = string.Explode(".",charge)
			//draw.SimpleText('Cooldown: '..scc[1]..'%', "Default", (ScrW()/2)-100+5,  (ScrH()/2)+150-8, tcol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			surface.SetDrawColor( Color(tcol.x*255,tcol.y*255,tcol.z*255,255)  )
			surface.DrawRect( (ScrW()/2)-(charge), (ScrH()/2)+230, charge*2, 16 )
			draw.SimpleTextOutlined( 'Cooldown: '..scc[1]..'%', Default, (ScrW()/2)-100+5, (ScrH()/2)+230+8, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, tcol )
			
	end
end  
