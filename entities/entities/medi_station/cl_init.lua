include("shared.lua")

function ENT:Draw()
	self:DrawModel()
	local ang = Angle(0,0,0)
	pos = self:GetPos()
--	local circlepos = self:GetPos()
	--ang:RotateAroundAxis(Vector(1,0,0),-39)
--	pos = self:LocalToWorld(Vector(0,0,25))


	cam.Start3D2D(pos,ang,2)
		if self:GetNWBool("frozenmedi",false) == true then
			surface.DrawCircle(1,1,100,0,255,0,255)
		end
	cam.End3D2D()
end

