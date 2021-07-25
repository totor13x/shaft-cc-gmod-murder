AddCSLuaFile("shared.lua")
DEFINE_BASECLASS( "base_anim" )

ENT.PrintName 		= "Colorable Angel Wings"
ENT.Author 			= "ogniK & Sinful Mario"
ENT.Information 	= ""
ENT.Category 		= "Angel Wings"

ENT.Spawnable 		= true
ENT.AdminOnly 		= false
ENT.RenderGroup 	= RENDERGROUP_TRANSLUCENT

hook.Add( "SetupMove", "cwingsDoubleJump", function( ply, mv, cmd )

	ply.cCanDoubleJump = ply.cCanDoubleJump and true

	if IsValid( ply.cWings ) then
		if mv:KeyPressed( IN_JUMP ) and !ply:IsOnGround() and ply.cCanDoubleJump then
			local Vel = mv:GetVelocity()
			local zVel = 0
			if Vel.z <= -10 then zVel = math.abs( Vel.z ) end
			mv:SetVelocity( Vel + Vector( 0, 0, (ply:GetJumpPower() * 2) * (ply.cIsGliding and 1.03 or 1) + zVel ) )
			ply.cCanDoubleJump = false
			if CLIENT and IsValid( ply.cWings.BaseEntity ) then
				ply.cWings.BaseEntity:LotsaFeathers()
			end
		elseif ply:IsOnGround() then
			ply.cCanDoubleJump = true
		end
	end

end )

hook.Add( "Move", "cwingsGlide", function( ply, mv )

	ply.cIsGliding = ply.cIsGliding and false

	if IsValid( ply.cWings ) then
		if mv:KeyDown( IN_SPEED ) then
			local vel = mv:GetVelocity()
			local UpSpeed = vel:DotProduct( Vector( 0, 0, 1 ) )
			if UpSpeed <= -10 and !ply:IsOnGround() and ply:WaterLevel() == 0 then
				vel.z = vel.z * 0.97 -- Works like magic
				mv:SetVelocity( vel )
				ply.cIsGliding = true
			end
		else
			ply.cIsGliding = false
		end
	end

end )

hook.Add( "CalcMainActivity", "cwingsAnimations", function( ply, vel )

	ply.cIsFalling = ply.cIsFalling and false

	if IsValid( ply.cWings ) then
		local UpSpeed = vel:DotProduct( Vector( 0, 0, 1 ) )
		if ply.cIsGliding or ( ply:GetMoveType() == MOVETYPE_NOCLIP and !ply:InVehicle() ) then
			ply.CalcIdeal = ACT_MP_SWIM
			ply.CalcSeqOverride = -1
			ply.cIsFalling = false
			return ply.CalcIdeal, ply.CalcSeqOverride
		elseif !ply.cIsGliding and ply:GetMoveType() != MOVETYPE_NOCLIP and UpSpeed <= -500 and !ply:IsOnGround() and ply:WaterLevel() == 0 then
			ply.CalcIdeal = ACT_ZOMBIE_CLIMB_UP
			ply.CalcSeqOverride = -1
			ply.cIsFalling = true
			return ply.CalcIdeal, ply.CalcSeqOverride
		end
	end

	ply.cIsFalling = false
	
end )

hook.Add( "UpdateAnimation", "cwingsFallSpeed", function( ply, vel, maxseqgroundspeed )

	if IsValid( ply.cWings ) and ply.cIsFalling then
		ply:SetPlaybackRate( 3.0 ) 

		if CLIENT and IsValid( ply.cWings.BaseEntity ) then
			ply.cWings.BaseEntity:CreateSingleFeather()
		end

		return true
	end

end )