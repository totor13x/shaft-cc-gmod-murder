AddCSLuaFile()

SWEP.PrintName	= "Скилл"
SWEP.ViewModel	= "models/weapons/c_arms.mdl"
SWEP.WorldModel	= ""
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""
SWEP.DrawWeaponInfoBox = false
SWEP.Slot				= 2
SWEP.SlotPos			= 1
SWEP.HoldType = "normal"
SWEP.SequenceDraw = "fists_draw"
SWEP.SequenceIdle = "fists_idle_01"

function SWEP:Initialize()
self:SetWeaponHoldType( self.HoldType )
end

function SWEP:PrimaryAttack()
	if SERVER then
		local trace = self.Owner:GetEyeTrace()
		if self.Owner.SucIsUs then return end
		if trace.Entity and trace.Entity:IsValid() and trace.Entity:IsPlayer() and !trace.Entity:GetNWBool("SuccubFog") and trace.HitPos:Distance(trace.StartPos) < 150 then
			
			-- net.Start("TinkingClear.str")
			-- net.Send({trace.Entity, self.Owner})
			
			-- self.Owner:SetNWBool("MeSuccub", true)
			-- self.Owner:SetNWBool("MeSuccubTrig", true)
		
			trace.Entity:SetNWBool("SuccubFog", true)
			trace.Entity:SetNWEntity("whoEatSouls", self.Owner)
			
			-- trace.Entity:SetNWEntity("SuccubFogOwner", true)
			-- trace.Entity:SetNWBool("MeWajSuccub", true)
			
			self:SetNextPrimaryFire( CurTime() + 10 )
		end
	end	
end

function SWEP:SecondaryAttack()
	if SERVER then
		local trace = self.Owner:GetEyeTrace()
		if self.Owner.SucIsUs then return end
		if trace.Entity and trace.Entity:IsValid() and trace.Entity:IsPlayer() then
			net.Start("SendSharpedHUD")
				net.WriteInt(0, 4)
			net.Send({trace.Entity, self.Owner})
			net.Start("TinkingClear.str")
			net.Send({trace.Entity, self.Owner})
			self.Owner:SetNWBool("MeSuccub", false)
			self.Owner:SetNWBool("MeSuccubTrig", false)
		
			trace.Entity:SetNWBool("SuccubFog", false)
			trace.Entity:SetNWBool("MeWajSuccub", false)
		end
	end	
end


local function addangle(ang,ang2)
	ang:RotateAroundAxis(ang:Up(),ang2.y) -- yaw
	ang:RotateAroundAxis(ang:Forward(),ang2.r) -- roll
	ang:RotateAroundAxis(ang:Right(),ang2.p) -- pitch
end

function SWEP:CalcViewModelView(vm, opos, oang, pos, ang)
	
	// iron sights
	local pos2 = Vector(-35, 0, 0)
	addangle(ang, Angle(-90, 0, 0))
	pos2:Rotate(ang)
	return pos + pos2, ang
end

/*
SWEP.TinkingCountShar = 0
SWEP.TinkingCountSobel = 0
SWEP.TinkingCountSobel = 0
SWEP.TinkingCountSobelRedF = 0
SWEP.TinkingCountSobelRedS = 0
	
function SWEP:PrimaryAttack()
	self.Tinking = true
	
	
	self.TinkingCountShar = 0
	self.TinkingCountSobel = 0
	self.TinkingCountSobelRedF = 0
	self.TinkingCountSobelRedS = 0
	self.TinkingCountSobelcolour = 1
	self.TinkingCountSobelcontrast = 1
	
	hook.Add( "RenderScreenspaceEffects", "DrawMotionBloom", function()
	
		if self.Owner.GetActiveWeapon and self.Owner:GetActiveWeapon():GetClass() == 'weapon_mu_succub' then
			if self.Tinking then
				self.TinkingCountShar = Lerp(1.2*FrameTime() , self.TinkingCountShar , 100 )
				self.TinkingCountSobel = Lerp(5*FrameTime() , self.TinkingCountSobel , 2 )
				DrawSharpen(self.TinkingCountShar, 1.2 )
				DrawSobel( self.TinkingCountSobel )
				if self.TinkingCountSobel > 1.95 then

					self.TinkingCountSobelRedF = Lerp(0.5*FrameTime() , self.TinkingCountSobelRedF , 0.5 )
					self.TinkingCountSobelRedS = Lerp(0.5*FrameTime() , self.TinkingCountSobelRedS , 1 )
					self.TinkingCountSobelcolour = Lerp(0.5*FrameTime() , self.TinkingCountSobelcolour , 3 )
					self.TinkingCountSobelcontrast = Lerp(0.4*FrameTime() , self.TinkingCountSobelcontrast , 0 )

					local tab = {
						[ "$pp_colour_addr" ] = self.TinkingCountSobelRedF,
						[ "$pp_colour_addg" ] = 0,
						[ "$pp_colour_addb" ] = 0,
						[ "$pp_colour_brightness" ] = 0,
						[ "$pp_colour_contrast" ] = self.TinkingCountSobelcontrast,
						[ "$pp_colour_colour" ] = self.TinkingCountSobelcolour,
						[ "$pp_colour_mulr" ] = self.TinkingCountSobelRedS,
						[ "$pp_colour_mulg" ] = 0,
						[ "$pp_colour_mulb" ] = 0
					}
					DrawColorModify( tab )
				end
			end
		end
	end)

end

function SWEP:SecondaryAttack()
	
	self.Tinking = false
	self.TinkingCountShar = 0
	self.TinkingCountSobel = 0
	self.TinkingCountSobelRedF = 0
	self.TinkingCountSobelRedS = 0
	self.TinkingCountSobelcolour = 1
	self.TinkingCountSobelcontrast = 1
	hook.Remove( "RenderScreenspaceEffects", "DrawMotionBloom" )
end
*/