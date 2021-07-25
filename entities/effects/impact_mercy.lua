EFFECT.Life = 0.2
EFFECT.Sprite = Material("effects/cacadeus_sprite")
EFFECT.SpritePath = "effects/cacadeus_sprite"
EFFECT.RingPath = "effects/select_ring"
EFFECT.SparkPath = "effects/cacadeus_sprite"
EFFECT.Color = Color(254, 218, 37, 255)
EFFECT.SparkCountMin = 2
EFFECT.SparkCountMax = 4
EFFECT.SparkLife = 0.3
EFFECT.RadiusMin = 8
EFFECT.RadiusMax = 32
EFFECT.VelocityNormal = 100
EFFECT.VelocitySide = 50


local gravity_cv = GetConVar("sv_gravity")
local upvec = Vector(0,0,1)

function EFFECT:Init( data )
	self.Pos = data:GetOrigin()
	self.Norm = data:GetNormal()
	self.Right = self.Norm:Cross(upvec)
	self.Grav = Vector(0, 0, -gravity_cv:GetFloat())
	self.StartTime = CurTime()
	self.LifeTime = self.Life * math.Rand(0.75,1)
	self.KillTime = CurTime() + self.LifeTime
	local em = ParticleEmitter(self.Pos)
	local partcount = math.random(self.SparkCountMin, self.SparkCountMax)

	--Sparks
	for i = 1, partcount do
		local part = em:Add(self.SparkPath, self.Pos)
		local vel = self.Norm * 1
		local svel = self.Right * 1
		vel:Mul(self.VelocityNormal)
		svel:Mul( math.Rand(-self.VelocitySide,self.VelocitySide) )
		vel:Add( svel )
		vel:Add( svel )
		part:SetVelocity( vel )
		part:SetDieTime(math.Rand(0.75, 1) * self.SparkLife)
		part:SetStartAlpha(128)
		part:SetEndAlpha(0)
		part:SetStartSize(math.Rand(1, 2))
		part:SetEndSize(6)
		part:SetRoll(0)
		part:SetGravity(self.Grav)
		part:SetCollide(true)
		part:SetBounce(0.55)
		part:SetAirResistance(0.5)
		part:SetStartLength(0.2)
		part:SetEndLength(0.1)
		part:SetVelocityScale(true)
		part:SetCollide(true)
		part:SetColor(self.Color.r,self.Color.g,self.Color.b)
	end
	local part = em:Add( self.SpritePath, self.Pos)
	part:SetStartAlpha(255)
	part:SetStartSize(self.RadiusMin)
	part:SetEndSize(self.RadiusMax)
	part:SetDieTime(self.LifeTime)
	part:SetEndAlpha(0)
	part:SetRoll(math.Rand(0, 360))
	part:SetColor(self.Color.r,self.Color.g,self.Color.b)

	em:Finish()
end

function EFFECT:Think()
	if CurTime() > self.KillTime then
		return false
	end
	return true
end

local RingCached, SpriteCached

function EFFECT:Render()
	if not RingCached then
		RingCached = Material(self.RingPath)
	end
	if not SpriteCached then
		SpriteCached = Material(self.SpritePath)
	end
	local life = ( CurTime() - self.StartTime ) / self.LifeTime
	self.Radius = Lerp( life, self.RadiusMin, self.RadiusMax )
	render.SetMaterial( RingCached )
	render.DrawQuadEasy(self.Pos,self.Norm,self.Radius,self.Radius,ColorAlpha( self.Color, 255 - 255 * life ),0)
end