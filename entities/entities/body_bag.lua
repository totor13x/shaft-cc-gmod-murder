-- Decoy sending out a radar blip and redirecting DNA scans. Based on old beacon
-- code.

AddCSLuaFile()

ENT.Type = "anim"
ENT.Model = Model("models/jessev92/payday2/item_bag_body.mdl")

function ENT:Initialize()
   self:SetModel(self.Model)

   if SERVER then
      self:PhysicsInit(SOLID_VPHYSICS)
   end

   self:SetMoveType(MOVETYPE_VPHYSICS)
   self:SetSolid(SOLID_VPHYSICS)
   self:SetCollisionGroup(COLLISION_GROUP_NONE)

   -- can pick this up if we own it
   if SERVER then
      self:SetUseType(SIMPLE_USE)
   end
   
   
	local phys = self:GetPhysicsObject()

	if phys and phys:IsValid() then
		phys:Wake()
		phys:SetMass(20)
	end
end

