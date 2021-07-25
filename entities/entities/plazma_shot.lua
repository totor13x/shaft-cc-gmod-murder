if SERVER then AddCSLuaFile() end

ENT.Type = "anim"
ENT.PrintName = ""
ENT.Author = ""
ENT.Contact = ""
ENT.Purpose = ""
ENT.Instructions = ""
ENT.DoNotDuplicate = true
ENT.DisableDuplicator = true

ENT.Damage = 20
ENT.Delay = 10
ENT.Radius = 10
ENT.Color = Color(254, 218, 37, 255)
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Wir = "trails/tube.vmt"
ENT.Sprite = Material(ENT.Wir)

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
		//util.SpriteTrail( self, -1, Color(255,255,255), false, 0, 10, .1, 1, self.Wir )
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

		local ow = self:GetOwner()

		if IsValid(ow) then
			local d = DamageInfo()
			d:SetAttacker(ow)
                        local inf = ow
                        if ow.GetActiveWeapon and IsValid( ow:GetActiveWeapon() ) then inf = ow:GetActiveWeapon() end
			d:SetInflictor( inf )
			d:SetDamage(1000)
			colData.Normal = colData.OurOldVelocity
			colData.Normal:Normalize()
			d:SetDamageForce( colData.Normal * self.Damage * 1000)
			d:SetDamageType(DMG_BLAST)
			d:SetDamagePosition( colData.HitPos )
			if colData.HitEntity and colData.HitEntity:IsValid() then
				colData.HitEntity:DispatchTraceAttack(d,util.QuickTrace(colData.HitPos,-colData.HitNormal * 32,self),colData.Normal)
			end
		/*
			if colData.HitEntity and colData.HitEntity:IsValid() and colData.HitEntity:IsPlayer() then
				local ply = colData.HitEntity
						
				if ply:Health() < 100 then
					ply:SetHealth(ply:Health()+2)
				end
			end
			
			local d = DamageInfo()
			d:SetAttacker(ow)
                        local inf = ow
                        if ow.GetActiveWeapon and IsValid( ow:GetActiveWeapon() ) then inf = ow:GetActiveWeapon() end
			d:SetInflictor( inf )
			d:SetDamage(self.Damage)
			colData.Normal = colData.OurOldVelocity
			colData.Normal:Normalize()
			d:SetDamageForce( colData.Normal * self.Damage * 100)
			d:SetDamageType(DMG_BULLET)
			d:SetDamagePosition( colData.HitPos )
			if colData.HitEntity and colData.HitEntity:IsValid() then
				colData.HitEntity:DispatchTraceAttack(d,util.QuickTrace(colData.HitPos,-colData.HitNormal * 32,self),colData.Normal)
			end
		*/
		end
		
		local ef = EffectData()
		ef:SetOrigin(colData.HitPos)
		ef:SetNormal(colData.HitNormal)
		util.Effect("impact_plazma",ef)
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
		render.DrawSphere( self:GetPos(), self.Radius, 30, 30, Color( 0, 175, 175, 100 ) )
	end
end