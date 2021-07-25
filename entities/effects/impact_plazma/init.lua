local matBulge2 = Material("effects/dsgun/refract_ring")

function EFFECT:Init(data)
	
	self.Position = data:GetOrigin()
	self.Normal = data:GetNormal()
	self.Ent = data:GetEntity()
	self.KillTime = CurTime() + 0.65
	self:SetRenderBoundsWS(self.Position + Vector()*100,self.Position - Vector()*100)
	
	timer.Simple( 0.1, function() 
	
	if self.Normal == nil then return end
	
	local ang = self.Normal:Angle():Right():Angle() -- D :
	
	
	local dlight = DynamicLight(math.random(2048,4096)) --This works for some reason.  Don't ask.
	dlight.Pos = self.Position
	dlight.Size = 50
	dlight.DieTime = CurTime() + 0.2
	dlight.r = 255
	dlight.g = 255
	dlight.b = 255
	dlight.Brightness = 1//1
	dlight.Decay = 1000

	
	end )
	
end


function EFFECT:Think()
	
	
	if CurTime() > self.KillTime then return false end
	return true
		
end


function EFFECT:Render()
	
	local invintrplt = (self.KillTime - CurTime())/0.15
	local intrplt = 1 - invintrplt

	local size = 100
	
	self:SetRenderBoundsWS(self.Position + Vector()*size,self.Position - Vector()*size)

	local invintrplt = (self.KillTime - CurTime())/0.65
	local intrplt = 1 - invintrplt

	local size = 100 + 15*intrplt*10
	
	self:SetRenderBoundsWS(self.Position + Vector()*size,self.Position - Vector()*size)
	
	matBulge2:SetFloat("$refractamount", math.sin(0.5*invintrplt*math.pi)*0.16)
	render.SetMaterial(matBulge2)
	render.UpdateRefractTexture()
	render.DrawSprite(self.Position,size,size,Color( 255, 255, 255,150*invintrplt))
	
end
