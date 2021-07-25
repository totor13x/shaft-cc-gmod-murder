if SERVER then AddCSLuaFile() end

ENT.Type = "anim"
ENT.PrintName = "Cacadeus Projectile"
ENT.Author = "TFA"
ENT.Contact = ""
ENT.Purpose = ""
ENT.Instructions = ""
ENT.DoNotDuplicate = true
ENT.DisableDuplicator = true

ENT.Damage = 20
ENT.Delay = 10
ENT.Radius = 3
ENT.Color = Color(254, 218, 37, 255)
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.Sprite = Material("effects/cacadeus_sprite")
ENT.Beam = Material("cable/smoke")

if SERVER then
	function ENT:Initialize()
		local mdl = self:GetModel()

		if mdl == "" or mdl == "models/error.mdl" then
			self:SetModel("models/weapons/w_eq_fraggrenade.mdl")
		end

		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:PhysicsInitSphere(self.Radius, "default_silent")
		local phys = self:GetPhysicsObject()

		if (phys:IsValid()) then
			phys:Wake()
			phys:EnableDrag(false)
			phys:EnableGravity(false)
			phys:SetMass(1)
		end

		self.DieTime = CurTime() + self.Delay
		self:DrawShadow(false)
	end

	function ENT:Think()
		if CurTime() > self.DieTime then return false end
		self:NextThink(CurTime())

		return true
	end

	function ENT:PhysicsCollide(colData, collider)
		timer.Simple(0, function()
			if IsValid(self) then
				self:Remove()
			end
		end)

	
		local ef = EffectData()
		ef:SetOrigin(colData.HitPos)
		ef:SetNormal(colData.HitNormal)
		util.Effect("impact_mercy",ef)
	end
end

if CLIENT then
	function ENT:Draw()
	end
	function ENT:DrawTranslucent()
		if not self.StartTime then
			self.StartTime = CurTime()
		end
		if self.StartTime + 0.05 > CurTime() then return end
		render.SetMaterial(self.Sprite)
		render.DrawQuadEasy(self:GetPos(), -EyeAngles():Forward(), self.Radius * 2, self.Radius * 2, self.Color, 0)
		render.SetMaterial(self.Beam)
		render.StartBeam(2)
		render.AddBeam(self:GetPos(),self.Radius,0,self.Color)
		render.AddBeam(self:GetPos() - self:GetVelocity() / 25,0,1,self.Color)
		render.EndBeam()
	end
end