AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include("shared.lua")

function ENT:Initialize()

	self:SetModel( "models/props_junk/sawblade001a.mdl" )
	//self:PhysicsInit( SOLID_VPHYSICS )
	self:SetSolid( SOLID_NONE )
	self:SetUseType( SIMPLE_USE )
	self:DrawShadow( false )
end

function ENT:OnRemove()
	self:GetOwner().cWings = nil
end
/*
function ENT:SpawnFunction( ply, tr, ClassName )
	if !IsValid( ply.cWings ) then 
		local ent = ents.Create( ClassName )
		ent:SetPos( ply:GetPos() )
		ent:Spawn()
		ent:Activate()
		ent:SetOwner( ply )
		ent:SetParent( ply )
		ply.cWings = ent
		return ent
	end
	return nil
end
*/