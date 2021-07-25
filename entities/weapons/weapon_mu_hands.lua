if SERVER then
	AddCSLuaFile()
else
	function SWEP:DrawWeaponSelection( x, y, w, h, alpha )
		-- draw.DrawText("Hands","Default",x + w * 0.44,y + h * 0.20,Color(0,50,200,alpha),1)
	end
end

SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.UseHands = false
SWEP.ViewModel	= "models/weapons/c_arms.mdl"
SWEP.WorldModel	= ""
SWEP.ViewModelFlip = false

SWEP.HoldType = "normal"

SWEP.PrintName = "Руки"

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

local pickupWhiteList = {
	prop_ragdoll = true,
	prop_physics = true,
	prop_physics_multiplayer = true,
	body_bag = true,
}

if SERVER then
	function SWEP:CanPickup(ent)
		if ent:IsWeapon() || ent:IsPlayer() || ent:IsNPC() then return false end
		
		local class = ent:GetClass()
		if self.Owner:GetNWInt("murdertype") == 2 and self.Owner:GetRole(MURDER) and class == 'prop_ragdoll' then
		
		local x = ent:GetPos()
		local ent2 = ents.Create("body_bag")
			ent2:SetPos( x ) 
			ent2:Spawn()
			ent2:Activate()
			ent:Remove()
			return false 
		end 
		print(ent:GetModel()) 
		if pickupWhiteList[class] then
			
			if ent:GetModel() == 'models/player_ahri_tails.mdl' then if self.Owner:SteamID() == 'STEAM_0:1:58105' then return true end return false end
			return true 
		end
		return false
	end
end

function SWEP:SecondaryAttack()
	if SERVER then
		self:SetCarrying()
		local tr = self.Owner:GetEyeTraceNoCursor()
		if IsValid(tr.Entity) && self:CanPickup(tr.Entity) then
			self:SetCarrying(tr.Entity, tr.PhysicsBone)
			self:ApplyForce()
		end
	end
end

function SWEP:ApplyForce()
	local target = self.Owner:GetAimVector() * 30 + self.Owner:GetShootPos()
	local phys = self.CarryEnt:GetPhysicsObjectNum(self.CarryBone)
	
	if IsValid(phys) then
		local vec = target - phys:GetPos()
		local len = vec:Length()
		if len > 40 then
			self:SetCarrying()
			return
		end

		vec:Normalize()
		
		local tvec = vec * len * 15
		local avec = tvec - phys:GetVelocity()
		avec = avec:GetNormal() * math.min(45, avec:Length())
		avec = avec / phys:GetMass() * 16
		
		phys:AddVelocity(avec)
	end
end

function SWEP:GetCarrying()
	return self.CarryEnt
end

function SWEP:SetCarrying(ent, bone)
	if IsValid(ent) then
		self.CarryEnt = ent
		self.CarryBone = bone
	else
		self.CarryEnt = nil
		self.CarryBone = nil
	end
	
	self.Owner:CalculateSpeed()
end

local lastThink = 0
timer.Create("SuccubEat", 0.1, 0, function() 
	if SERVER then
		-- if self:GetOwner():GetRole(SUCCUB) then
		for i,v in pairs(team.GetPlayers(2)) do
			if v:GetRole(SUCCUB) then continue end
			if !v:Alive() then continue end
			if !v:GetNWBool("SuccubFog") then continue end
			
			local owner = v:GetNWEntity("whoEatSouls")
			
			if !IsValid(owner) then continue end
			if !owner:Alive() then continue end
			
			if v:GetPos():DistToSqr(owner:GetPos()) < 300*300 then
				if !v:GetNWBool("IsEated") then
					v:SetNWBool("IsEated", true)
				end
						
				local d = DamageInfo()
				d:SetDamage( 2 )
				d:SetAttacker( owner )
				d:SetDamageType( DMG_DISSOLVE ) 

				v:TakeDamageInfo( d )
			else
				if v:GetNWBool("IsEated") then
					v:SetNWBool("IsEated", false)
				end
			end
		end
	end
end )
function SWEP:Think()
	if IsValid(self.Owner) && self.Owner:KeyDown(IN_ATTACK2) then
		if IsValid(self.CarryEnt) then
			self:ApplyForce()
		end
	elseif self.CarryEnt then
		self:SetCarrying()
	end
	
	
	if EVENTS:Get('ID') == EVENT_TD and SERVER then
		if self:GetOwner():GetRole(MURDER) then	
			for i,v in pairs(player.GetAll()) do
				if v == self:GetOwner() or !v:Alive() then continue end
				if v:GetPos():Distance(self:GetOwner():GetPos()) < 100 then
					v:Kill()
				end
 			end
		end
	end
end

function SWEP:PrimaryAttack()
/*
	if SERVER then
		if IsValid(self.Owner) then

			for k,v in ipairs(self.Owner:GetWeapons()) do	
				if not v:IsValid() then continue end

				if string.find( v:GetClass(), "weapon_mu_knife" )  then
					self.Owner:SelectWeapon(v:GetClass())
				end
				if string.find( v:GetClass(), "weapon_mu_magnum" )  then
					self.Owner:SelectWeapon(v:GetClass())
				end
			end
		end
	end
*/
	if SERVER then
		if self:GetOwner():GetRole(SUCCUB) then
			local trace = self.Owner:GetEyeTrace()
			
			-- 
			
			if trace.Entity 
				and trace.Entity:IsValid() 
				and trace.Entity:IsPlayer() 
				-- and !trace.Entity:GetNWBool("SuccubFog") 
				and trace.HitPos:Distance(trace.StartPos) < 2000 then
				
				if !trace.Entity:GetNWBool("SuccubFog") then
					if self.Owner.SucIsUs then return end
					
					self:GetOwner().SucIsUs = true
					trace.Entity:SetNWBool("SuccubFog", true)
					trace.Entity:SetNWBool("IsEated", true)
					trace.Entity:SetNWEntity("whoEatSouls", self.Owner)
				else
					self:GetOwner().SucIsUs = false
					trace.Entity:SetNWBool("SuccubFog", false)
					trace.Entity:SetNWBool("IsEated", false)
					trace.Entity:SetNWEntity("whoEatSouls", true)
				end
				
				self:SetNextPrimaryFire( CurTime() + 0.3 )
			end
		end
	end
end
