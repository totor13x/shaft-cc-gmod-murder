include("shared.lua")
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.cAngelWings = nil
ENT.Sequences = {
	Idle = -1,
	Takeoff = -1,
	Fly = -1,
}

ENT.PlayerStates = {
	DEAD = 0,
	ALIVE = 1,
}
ENT.LastPaint = 0
ENT.lastPlayerState = 0
ENT.renderTick = RealTime()
ENT.Emitter = nil
ENT.Tick = 0.2
ENT.plyColor = Color(1, 1, 1)

function ENT:OnRemove()
	if IsValid( self.cAngelWings ) then
		self.cAngelWings:Remove()
		self:GetOwner().cWings = nil
	end
end

function ENT:SetTick( Tick )
	self.Tick = Tick
end

function ENT:Draw() end

function ENT:SetAnim( ply )

	local seq = self.cAngelWings:GetSequence()
	local rate = 1
	local vel = ply:GetVelocity()

	if ply:GetMoveType() == MOVETYPE_NOCLIP then
		seq = self.Sequences.Fly
		rate = vel:Length() / 600
		rate = math.Clamp( rate, 0.3, 1.2 )
		self:SetTick( 1.4 - rate )
	elseif (vel:Length() > 15 and !ply:IsOnGround()) then
		seq = self.Sequences.Fly
		rate = vel:Length() / 200
		rate = math.Clamp( rate, 0.3, 3 )
		self:SetTick( 3.2 - rate )
	else
		seq = self.Sequences.Idle
	end

	if ( self.cAngelWings:GetSequence() != seq ) then
		self.cAngelWings:ResetSequence( seq )
		self.cAngelWings:SetCycle( 0 )
	end

	rate = math.Clamp(rate, 0.1, 4)
	if !ply:Alive() then rate = 0 end
	self.cAngelWings:FrameAdvance( FrameTime() )
	self.cAngelWings:SetPlaybackRate( rate )
end

function ENT:OnReloaded()
	self.Sequences.Idle = self.cAngelWings:LookupSequence( "idle" )
	self.Sequences.Fly = self.cAngelWings:LookupSequence( "flying" )
end

function ENT:Startup()
	local ply = self:GetOwner()
	if IsValid( ply ) then
		self.cAngelWings = ClientsideModel( "models/sinful/angel_wings.mdl" , RENDERGROUP_BOTH)
		self.cAngelWings:SetPos( ply:GetPos() )
		self.cAngelWings:SetAngles( ply:GetAngles() )
		self.cAngelWings:SetNoDraw( true )
		self.cAngelWings.BaseEntity = self
		ply.cWings = self.cAngelWings



		self.lastMoveType = ply:GetMoveType()

		self.Sequences.Idle = self.cAngelWings:LookupSequence( "idle" )
		self.Sequences.Fly = self.cAngelWings:LookupSequence( "flying" )

		self.cAngelWings:ClearPoseParameters()
		self.cAngelWings:ResetSequenceInfo()

		self.cAngelWings:ResetSequence( self.Sequences.Idle )
		self.cAngelWings:SetCycle( 0.0 )


		self:SetRenderBounds( ply:OBBMins() * 2, ply:OBBMaxs() * 2 )
	end
end

/*function ENT:Initialize()

end*/

function ENT:DrawTranslucent()
	local ply = self:GetOwner()
	self.plyColor = ply:GetBystanderColor()
	if IsValid( self.cAngelWings ) and IsValid( ply ) and ply:Alive() then
		//self.cAngelWings:SetModelScale( math.abs( math.sin(RealTime()) * 3 ), 0 )
		local spine1Bone = ply:LookupBone( "ValveBiped.Bip01_Spine2" ) -- Gotta get the right pos
		local spine2Bone = ply:LookupBone( "ValveBiped.Bip01_Spine4" ) -- Gotta get the right pos

		// Just in case we're missing bones
		if spine1Bone and !spine2Bone then
			spine2Bone = spine1Bone
		elseif !spine1Bone and spine2Bone then
			spine1Bone = spine2Bone
		elseif !spine1Bone and !spine2Bone then
			return
		end

		local BonePos1, BoneAng1 = ply:GetBonePosition( spine1Bone )
		local BonePos2, BoneAng2 = ply:GetBonePosition( spine2Bone )

		// Center between bones
		local BonePos = Vector( Lerp( .5, BonePos1.x, BonePos2.x ), Lerp( .5, BonePos1.y, BonePos2.y ), Lerp( .5, BonePos1.z, BonePos2.z ) )
		local BoneAng = LerpAngle( .5, BoneAng1, BoneAng2 )
		BoneAng:RotateAroundAxis( BoneAng:Up(), 90 )
		BoneAng:RotateAroundAxis( BoneAng:Forward(), 90 )
		self.cAngelWings:SetAngles( BoneAng )
		self.cAngelWings:SetPos( BonePos + BoneAng:Forward() * -8 )
		if ply:ShouldDrawLocalPlayer() or ply != LocalPlayer() then -- Hide in first person
			local r, g, b = render.GetColorModulation()
			render.SetColorModulation( math.Clamp(self.plyColor.r, 0.2, 0.7), math.Clamp(self.plyColor.g, 0.2, 0.7), math.Clamp(self.plyColor.b, 0.2, 0.7) )
				if LocalPlayer():GetObserverMode() != OBS_MODE_IN_EYE then
				self.cAngelWings:DrawModel()
				end
			render.SetColorModulation( math.Clamp(r, 0, 1), math.Clamp(g, 0, 1), math.Clamp(b, 0, 1) )
		end
	elseif !IsValid( ply ) then
		self.cAngelWings:Remove()
	end
end

function ENT:LotsaFeathers()
	for i = 0, 30 do
		local particle = self.Emitter:Add( "sprites/Feathers/feather_" .. math.Rand( 1, 5 ), self.cAngelWings:GetPos() + Vector(math.random(-1, 1),math.random(-1, 1),0) * (self.cAngelWings:GetModelRadius() * 0.3) )
		particle:SetVelocity( VectorRand() * 128 )
		particle:SetDieTime( 2 )
		particle:SetStartAlpha( math.Rand( 75, 200 ) )
		particle:SetGravity( Vector( VectorRand() * 512 ) )
		particle:SetStartSize( 8 )
		particle:SetEndSize( 0 )
		particle:SetRoll( math.Rand( -0.2, 0.2 ) )
		particle:SetColor( self.plyColor.r * 255, self.plyColor.g * 255, self.plyColor.b * 255 )
		particle:SetCollide( true )
	end
end

function ENT:CreateSingleFeather()
	local particle = self.Emitter:Add( "sprites/Feathers/feather_" .. math.Rand( 1, 5 ), self.cAngelWings:GetPos() + Vector(math.random(-1, 1),math.random(-1, 1),0) * (self.cAngelWings:GetModelRadius() * 0.3) )
	particle:SetVelocity( VectorRand() * 128 )
	particle:SetDieTime( 2 )
	particle:SetStartAlpha( math.Rand( 75, 200 ) )
	particle:SetGravity( Vector( VectorRand() * 512 ) )
	particle:SetStartSize( 8 )
	particle:SetEndSize( 0 )
	particle:SetRoll( math.Rand( -0.2, 0.2 ) )
	particle:SetColor( self.plyColor.r * 255, self.plyColor.g * 255, self.plyColor.b * 255 )
	particle:SetCollide( true )
end

function ENT:Think()
	if !IsValid( self.cAngelWings ) then self:Startup() end
	if !self.Emitter then
		self.Emitter = ParticleEmitter( self:GetPos(), false )
	end
	local ply = self:GetOwner()
	if IsValid( ply ) and IsValid( self.cAngelWings ) then
		self:SetAnim( ply )
		local currentState = ply:Alive() and 1 or 0
		if( self.lastPlayerState != currentState ) then
			if self.lastPlayerState == self.PlayerStates.ALIVE then
				for i = 1, 30 do
					local particle = self.Emitter:Add( "sprites/Sparkles/Sparkle" .. math.Rand( 1, 4 ), self:GetPos() )
					particle:SetVelocity( VectorRand() * 128 )
					particle:SetDieTime( 3 )
					particle:SetStartAlpha( math.Rand( 75, 200 ) )
					particle:SetStartSize( 16 )
					particle:SetEndSize( 0 )
					particle:SetRoll( math.Rand( -0.2, 0.2 ) )
					particle:SetColor( self.plyColor.r * 255, self.plyColor.g * 255, self.plyColor.b * 255 )
				end
			end
		end
		self.lastPlayerState = currentState

		if self.renderTick > RealTime() then return end
		self.renderTick = RealTime() + self.Tick

		local vel = ply:GetVelocity()
		if ply:GetMoveType() == MOVETYPE_NOCLIP or (vel:Length() > 15 and !ply:IsOnGround()) and ply:WaterLevel() < 2 then
			for i = 1, 3 do
				local particle = self.Emitter:Add( "sprites/Feathers/feather_" .. math.Rand( 1, 5 ), self.cAngelWings:GetPos() + Vector(math.random(-1, 1),math.random(-1, 1),0) * (self.cAngelWings:GetModelRadius() * 0.3) )
				particle:SetVelocity( VectorRand() * math.random(8, 128) )
				particle:SetDieTime( 3 )
				particle:SetStartAlpha( math.Rand( 75, 200 ) )
				particle:SetGravity( Vector( VectorRand().x * 64, VectorRand().y * 64, -math.random( 200, 800 ) ) )
				particle:SetStartSize( 8 )
				particle:SetEndSize( 0 )
				particle:SetRoll( math.Rand( -0.2, 0.2 ) )
				particle:SetColor( self.plyColor.r * 255, self.plyColor.g * 255, self.plyColor.b * 255 )
				particle:SetCollide( true )
			end
		end
	end
end