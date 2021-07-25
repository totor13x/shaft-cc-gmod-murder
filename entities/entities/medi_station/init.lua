AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("cl_init.lua")
include("shared.lua")

function ENT:Initialize()

	self:SetModel("models/healthvial.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	self:SetCustomCollisionCheck(true)
	
	self:GetOwner():SetCustomCollisionCheck(true)
	vel = self:GetOwner():GetAimVector()
	vel = vel * 1000
	self:GetPhysicsObject():SetVelocity(vel)
	self.ThinkHP = CurTime()
end


function ENT:Think()

	if self:GetNWBool("frozenmedi",false) == false then 
		local ent = self
		// Trace check to see if it's collided with world
		local trace = {start = self:GetPos(), endpos = self:GetPos() - Vector(0,0,5), filter = ent}
		
		local tr = util.TraceEntity(trace, game.GetWorld())
		if (tr.Hit) then
			if (tr.Entity:IsPlayer()) then
				return
			else
			
				self:GetPhysicsObject():EnableMotion(false)
				self:SetNWBool("frozenmedi",true)
				self:EmitSound("items/medshot4.wav",70,100)
				//adding sound to stop it later down the line
				sound.Add( {
				name = "med_beep",
				channel = CHAN_STATIC,
				volume = 1.0,
				level = 80,
				pitch = 95,
				sound = "items/medcharge4.wav"
				} )
				timer.Simple(0.9, function() self:EmitSound("med_beep") end)
				timer.Simple(20, function() if self:IsValid() then self:StopSound("med_beep") self:Remove() end end)
			end
		end
	end
	
	if self.ThinkHP+0.2 < CurTime() then
		if self:GetNWBool("frozenmedi",false) == true then

			for k,i in pairs(ents.FindInSphere(self:GetPos(),200)) do
				if i:IsPlayer() then
					if i:Health() < 100 then
						i:SetHealth(i:Health() + 1)

					end
				end
			end
		end
		self.ThinkHP = CurTime()
	end
end


function ENT:PhysicsCollide(data, phys)
	if (data.HitEntity) == self:GetOwner() then
		return false
	end
end

//We need to freeze on collision with an ent.
function ENT:StartTouch()
	self:GetPhysicsObject():EnableMotion(false)
	self:SetNWBool("frozenmedi",true)
end

function StopPickup(ply, ent)
	if ent:GetClass() == "medi_station" then
		return false
	end
end


function MedCollide(ent1, ent2)
	if ent1:IsPlayer() then
		if ent2 == self then
			return false
		end
	end
	return true
end

hook.Add("PhysgunPickup","AntiPickup", StopPickup)

hook.Add("ShouldCollide",MedCollide)