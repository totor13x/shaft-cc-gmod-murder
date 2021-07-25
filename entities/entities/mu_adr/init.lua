AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/pg_props/pg_stargate/pg_shot.mdl") 
	//self:PhysicsInitSphere(40, "canister")
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetUseType(SIMPLE_USE)
	self:PhysicsInit( SOLID_VPHYSICS )
	--self:PhysicsInitSphere(50)
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	local phys = self:GetPhysicsObject()

	if phys and phys:IsValid() then
		phys:Wake()
	end
end

function ENT:SpawnFunction( ply, tr )
    if ( !tr.Hit ) then return end
	
    local ent = ents.Create("mu_adr")
    ent:SetPos( tr.HitPos + tr.HitNormal * 16 ) 
    ent:Spawn()
    ent:Activate()
 
    return ent
end

function ENT:OnTakeDamage(dmginfo)
	self:GetPhysicsObject():AddVelocity(dmginfo:GetDamageForce() * 0.1)
end

function ENT:Use(activator, caller)

return true
end

function ENT:OnRemove()
return false
end 