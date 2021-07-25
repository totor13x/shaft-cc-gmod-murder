
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')


function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetUseType(SIMPLE_USE)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(false)
	end
end

function ENT:Use(ply)
if ply:GetRole(CHICKEN) then return false end
if ply:GetRole(HEADCRAB) then return false end
if ply:GetRole(HEADCRAB_BLACK) then return false end
if ply:GetRole(PRODAVEC) then return false end
if ply:GetRole(MOSHENNIK) then return false end
if ply:GetRole(SUCCUB) then return false end
//if ply:GetRole(SHERIF) then return false end
if !EVENTS:Get('SpawnLoot') then return false end
if EVENTS:Get('ID') == EVENT_TD and ply:GetRole(MURDER) then return false end
if EVENTS:Get('ID') == EVENT_SLENDER and ply:GetRole(MURDER) then return false end
//if ply:GetRole(DRESSIROVSHIK_ROLE) then return false end

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(true)
	end
	GAMEMODE:PickupLoot(ply, self)
end

function ENT:Think()
end

