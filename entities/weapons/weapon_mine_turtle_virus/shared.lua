--- Default GMod values ---
SWEP.Base = "weapon_base"
SWEP.Category = "Fun"
SWEP.Purpose = "Place it somewhere and it will greet you with a nice HELLO!"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

SWEP.Primary.Ammo = "slam"
SWEP.Primary.Delay = 1.5
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = 5
SWEP.Primary.DefaultClip = 2
SWEP.Primary.Sound = Sound("weapons/mine_turtle/hello_mine_turtle.wav")
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 1.5
SWEP.Secondary.Automatic = false
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Sound = Sound("weapons/mine_turtle/hello_mine_turtle.wav")
SWEP.FiresUnderwater = false

--- Model settings ---
SWEP.HoldType = "slam"

SWEP.UseHands = true
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 70
SWEP.ViewModel = Model("models/weapons/zaratusa/mine_turtle/v_mine_turtle.mdl")
SWEP.WorldModel	= Model("models/weapons/zaratusa/mine_turtle/w_mine_turtle.mdl")

function SWEP:Precache()
	util.PrecacheSound("weapons/mine_turtle/hello_mine_turtle.wav")
end

function SWEP:PrimaryAttack()
	if (self:CanPrimaryAttack() and self:GetNextPrimaryFire() <= CurTime()) then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

		self:MineDrop()
	end
end

function SWEP:MineDrop()
	local owner = self.Owner
	if (SERVER and IsValid(owner)) then
		local mine = ents.Create("zaratusas_mine_turtle_virus")
		if (IsValid(mine)) then
			self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
			local src = owner:GetShootPos()
			local ang = owner:GetAimVector()
			local vel = owner:GetVelocity()

			local throw = vel + ang * 200

			mine:SetPos(src + ang * 10)
			mine:SetPlacer(owner)
			mine:Spawn()

			local phys = mine:GetPhysicsObject()
			if (IsValid(phys)) then
				phys:Wake()
				phys:SetVelocity(throw)
			end

			self:TakePrimaryAmmo(1)
			self:Deploy()
		end
	end
end

function SWEP:SecondaryAttack()
	if (self:CanPrimaryAttack() and self:GetNextSecondaryFire() <= CurTime()) then
		self:SetNextPrimaryFire(CurTime() + self.Secondary.Delay)
		self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)

		self:MineStick()
	end
end

local validDoors = {"func_door", "func_door_rotating", "prop_door_rotating"}

function SWEP:MineStick()
	local owner = self.Owner
	if (SERVER and IsValid(owner)) then
		local ignore = {owner, self.Weapon}
		local spos = owner:GetShootPos()
		local epos = spos + owner:GetAimVector() * 42

		local tr = util.TraceLine({start=spos, endpos=epos, filter=ignore, mask=MASK_PLAYERSOLID})
		
		local ent = tr.Entity
		if (tr.HitWorld) or (ent:IsValid() and table.HasValue(validDoors, ent:GetClass()) ) then
			local mine = ents.Create("zaratusas_mine_turtle_virus")
			if (IsValid(mine)) then
				local tr_ent = util.TraceEntity({start=spos, endpos=epos, filter=ignore, mask=MASK_PLAYERSOLID}, mine)
				if (tr_ent.HitWorld or (ent:IsValid() and table.HasValue(validDoors, ent:GetClass()))) then
					self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
					local ang = tr_ent.HitNormal:Angle()
					ang.p = ang.p + 90
					
					
					
					//print(tr.Entity)
				
					mine:SetPos(tr_ent.HitPos + (tr_ent.HitNormal * 3))
					mine:SetAngles(ang)
					mine:SetPlacer(owner)
					mine:SetDoor(ent or nil)
					mine:Spawn()

					local phys = mine:GetPhysicsObject()
					if IsValid(phys) then
						phys:Wake()
						phys:EnableMotion(false)
					end

					if ent:IsValid() then 
						mine:SetMoveType(MOVETYPE_NONE)
						mine:SetParent(ent, 1)
					end
					
					self:TakePrimaryAmmo(1)
					self:Deploy()
				
				end
			end
		end
	end
end

function SWEP:Deploy()
	if (self.Weapon:Clip1() == 0) then
		self:Remove()
	else
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	end
end

-- Reload does nothing
function SWEP:Reload()
end
