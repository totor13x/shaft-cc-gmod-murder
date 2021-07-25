
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')


function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetUseType(SIMPLE_USE)
	self.delay = CurTime() + 3
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(false)
	end
	self:SetNWBool("isActivated", false)
	util.PrecacheSound("weapons/mine_turtle/hello.wav")
end

function ENT:Use(ply)
if self.delay > CurTime() then return end
if ply:GetRole(CHICKEN) then return false end
if ply:GetRole(HEADCRAB) then return false end
if ply:GetRole(HEADCRAB_BLACK) then return false end
if ply:GetRole(PRODAVEC) then return false end
if ply:GetRole(MOSHENNIK) then return false end
if ply:GetRole(SUCCUB) then return false end
//if ply:GetRole(SHERIF) then return false end
if !EVENTS:Get('SpawnLoot') then return false end
if ply:GetRole(MURDER) and EVENTS:Get('ID') == EVENT_TD then return false end
//if ply:GetRole(DRESSIROVSHIK_ROLE) then return false end
if self:GetNWBool("isActivated") then return end
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(true)
	end
	sound.Play("weapons/mine_turtle/hello.wav", self:GetPos(), 100, math.random(95, 105), 1)
	self:SetNWBool("isActivated", true)
	phys:SetVelocity(Vector(0,0,120))
	timer.Simple(0.85, function()
		local ent = ents.Create( "env_explosion" )
		ent:SetPos( self:GetPos() )
		
		//ent:SetOwner( self.Owner )
		ent:SetKeyValue( "iMagnitude", "90" )
		ent:Spawn()
		ent:Fire( "Explode", 0, 0 )
		
		//GAMEMODE:PickupLoot(ply, self)
		self:Remove()
	end)
end

function ENT:Think()
end

