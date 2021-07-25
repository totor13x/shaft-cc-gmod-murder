SWEP.Base = "weapon_mu_knife_def"

SWEP.ViewModel 			= "models/mar/sickle.mdl"
SWEP.WorldModel 		= "models/mar/w_sickle.mdl"
SWEP.ENT 				= "mu_knife_sickle" 
SWEP.ViewModelFOV = 65
SWEP.DrawCrosshair  = true
SWEP.Primary.Damage = 60
SWEP.Primary.Delay = 0.4
SWEP.iSCustom = true

function SWEP:SetupDataTables()
	weapons.Get("weapon_mu_knife_def").SetupDataTables(self)
	self:NetworkVar( "Int", 0, "Charge" )
end
function SWEP:Think()
	weapons.Get("weapon_mu_knife_def").Think(self)
	//if 
end

-- Utility function for bring, goto, and send
local function playerSend( from, to, force )
	if not to:IsInWorld() and not force then return false end -- No way we can do this one

	local yawForward = to:EyeAngles().yaw
	local directions = { -- Directions to try
		math.NormalizeAngle( yawForward ), -- Behind first
		math.NormalizeAngle( yawForward + 90 ), -- Right
		math.NormalizeAngle( yawForward - 90 ), -- Left
		yawForward,
	}

	local t = {}
	t.start = to:GetPos() + Vector( 0, 0, 32 ) -- Move them up a bit so they can travel across the ground
	t.filter = { to, from }

	local i = 1
	t.endpos = to:GetPos() + Angle( 0, directions[ i ], 0 ):Forward() * 47 -- (33 is player width, this is sqrt( 33^2 * 2 ))
	local tr = util.TraceEntity( t, from )
	while tr.Hit do -- While it's hitting something, check other angles
		i = i + 1
		if i > #directions then	 -- No place found
			if force then
				from.ulx_prevpos = from:GetPos()
				from.ulx_prevang = from:EyeAngles()
				return to:GetPos() + Angle( 0, directions[ 1 ], 0 ):Forward() * 47
			else
				return false
			end
		end

		t.endpos = to:GetPos() + Angle( 0, directions[ i ], 0 ):Forward() * 47

		tr = util.TraceEntity( t, from )
	end

	from.ulx_prevpos = from:GetPos()
	from.ulx_prevang = from:EyeAngles()
	return tr.HitPos
end


function SWEP:SecondaryAttack()
	//if !self:IsIdle() then return end
	if( CurTime() < self:GetCharge() ) then	return; end
	if SERVER then
	local trace = {}
	trace.filter = self.Owner
	trace.start = self.Owner:GetShootPos()
	trace.mask = MASK_SHOT_HULL
	trace.endpos = trace.start + self.Owner:GetAimVector() * 2500
	trace.mins = Vector(0,0,0)
	trace.maxs = Vector(0,0,0)
	local tr = util.TraceHull(trace)
	tr.TraceAimVector = self.Owner:GetAimVector()
	 
	local ent = tr.Entity	
	if IsValid(ent) and ent:IsPlayer() and ent:Alive() then	
	
	local newpos = playerSend( self.Owner, ent, ent:GetMoveType() == MOVETYPE_NOCLIP )
	if not newpos then
		ULib.tsayError( self.Owner, "Невозможно телепортироваться!", true )
		return
	end

	if ent:InVehicle() then
		ent:ExitVehicle()
	end

	local newang = (ent:GetPos() - newpos):Angle()

	self.Owner:SetPos( newpos )
	self.Owner:SetEyeAngles( newang )
	self.Owner:SetLocalVelocity( Vector( 0, 0, 0 ) ) -- Stop!
	
	self:SetCharge( CurTime() + 20);
	end
	end
	
end

function SWEP:DrawHUD()
	
	local charge = (self:GetCharge() - CurTime())/30*100
	if charge > 0 then
		local aa = math.EaseInOut( charge, 0.1, 0.1 ) 
			surface.SetDrawColor( Color(255,255,255,150)  )
			surface.DrawRect( (ScrW()/2)-100, (ScrH()/2)+230, 200, 16 )
			local tcol = self.Owner:GetPlayerColor()
			local scc = string.Explode(".",charge)
			//draw.SimpleText('Cooldown: '..scc[1]..'%', "Default", (ScrW()/2)-100+5,  (ScrH()/2)+150-8, tcol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			surface.SetDrawColor( Color(tcol.x*255,tcol.y*255,tcol.z*255,255)  )
			surface.DrawRect( (ScrW()/2)-(charge), (ScrH()/2)+230, charge*2, 16 )
			draw.SimpleTextOutlined( 'Cooldown: '..scc[1]..'%', Default, (ScrW()/2)-100+5, (ScrH()/2)+230+8, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, tcol )
			
	end
end  
