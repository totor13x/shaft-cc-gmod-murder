SWEP.PrintName = "Vodka"
 SWEP.Author = "Dexter"
 SWEP.Contact = "Addon page"
 SWEP.Purpose = "To drink crap."
 SWEP.Instructions = "Left click to drink, Right click to toss that garbage."
 SWEP.Category = "Dexter's Drinkables"
 SWEP.Primary.Ammo = "None"
 SWEP.Primary.ClipSize = -1
 SWEP.Primary.DefaultClip = -1
 SWEP.Primary.Automatic = false
 SWEP.Secondary.Ammo = "None"
 SWEP.Secondary.Automatic = false
 SWEP.Secondary.ClipSize = -1
 SWEP.Secondary.DefaultClip = -1
 SWEP.UseHands = true
 //SWEP.Base = "weapon_base"
 SWEP.DrawCrosshair = false
 SWEP.Spawnable = true
 SWEP.ViewModelFOV = 56 
 SWEP.ViewModelFlip = false 
 SWEP.HoldType = "slam" 
 SWEP.ViewModel = "models/weapons/c_grenade.mdl" 
 SWEP.WorldModel = "models/weapons/w_grenade.mdl"
 SWEP.Slot = 2
 SWEP.SlotPos = 1
 SWEP.SwayScale = 0
 SWEP.BobScale = 0
 SWEP.Benefit = 0
 SWEP.DrinkModel = "models/props_junk/garbage_glassbottle003a.mdl"

 function SWEP:SetupDataTables()
 self:NetworkVar("Float",0,"Drink")
 self:NetworkVar("Float",1,"ThrowDelay")
 self:NetworkVar("Bool",0,"StartThrowing") 
 end 
 
 function SWEP:Deploy() 
	 local vm = self.Owner:GetViewModel()
	 vm:SendViewModelMatchingSequence(vm:LookupSequence("draw"))
	self:SetNextSecondaryFire(CurTime()+1)
	self:SetThrowDelay(0)
	self:SetStartThrowing(false)
 end
 
 function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
 end  
 
 function SWEP:Think()
	if self.Owner:KeyDown(IN_ATTACK) then
		self:SetDrink(Lerp(0.1,self:GetDrink(),1)) 
	elseif self:GetStartThrowing() == true then
		self:SetDrink(Lerp(0.1,self:GetDrink(),0)) 
	else
		self:SetDrink(Lerp(0.1,self:GetDrink(),0)) 
	end 
 
 if self:GetStartThrowing() == false then 
 if self:GetDrink() > 0.95 then 
 if (CurTime()%0.6 < 0.05) then
	self.Owner:ViewPunch(Angle(-0.2,math.Rand(-0.1,0.1),0))
	self:EmitSound("ambient/water/water_spray3.wav",90,math.random(77,83))
	if SERVER then
	local ply = self.Owner
	
		ply:SetNWInt('drinked',ply:GetNWInt('drinked')+1)
		if ply:GetNWInt('drinked') > 100 then
			ply:SetNWInt('drinked',100)
		end
		
		umsg.Start( "StartBlueer", player.GetAll() )
		umsg.End()
	end
 end
 end 
 end 
 if self:GetStartThrowing() == true and CurTime() >= self:GetThrowDelay() then
 if SERVER then
 local drinkowner = self.Owner 
 self:Remove() 
 if #drinkowner:GetWeapons() > 0 then 
 drinkowner:SelectWeapon(drinkowner:GetWeapons()[1]:GetClass())
 end
 end
 end 
 end 

if ( CLIENT ) then

	usermessage.Hook( "StartBlueer", function()
		hook.Add( "RenderScreenspaceEffects", "DrawMotionBlur", function()
			local ply = LocalPlayer()
			if !ply:Alive() and IsValid(ply:GetNWEntity("SpectateEntity")) and ply:GetNWEntity("SpectateEntity"):IsPlayer() then ply = ply:GetNWEntity("SpectateEntity") end
			DrawMotionBlur( 0.1, ply:GetNWInt('drinked')/100, 0.05)
		end )
		
	end )
	
end


 function SWEP:PreDrawViewModel(vm)
 render.SetBlend(0)
 end 
 function SWEP:PostDrawViewModel(vm)
 render.SetBlend(1)
 if ( !self.Arms ) then 
 self.Arms = ClientsideModel("models/weapons/c_arms_citizen.mdl",RENDERGROUP_BOTH) 
 self.Arms:SetNoDraw( true )
 end 
 self.Arms:SetModel(self.Owner:GetHands():GetModel())
 self.Arms:SetPos(vm:GetPos())
 self.Arms:SetAngles(vm:GetAngles())
 self.Arms:SetParent(vm) 
 self.Arms:AddEffects(EF_BONEMERGE)
 self.Arms:DrawModel() 
 if (!self.FakeDrink) then 
 self.FakeDrink = ClientsideModel(self.DrinkModel,RENDERGROUP_BOTH) 
 self.FakeDrink:SetNoDraw(true)
 end
 local pos = vm:GetBoneMatrix(vm:LookupBone("ValveBiped.Grenade_Body")):GetTranslation()
 local ang = vm:GetBoneMatrix(vm:LookupBone("ValveBiped.Grenade_Body")):GetAngles()
 ang:RotateAroundAxis(ang:Right(),180)
 pos = pos + ang:Up()*3 
 self.FakeDrink:SetPos(pos) 
 self.FakeDrink:SetAngles(ang) 
 self.FakeDrink:SetModelScale(0.9) 
 self.FakeDrink:DrawModel()
 end 
 
 function SWEP:PrimaryAttack() 
 end  
 
 function SWEP:SecondaryAttack()
 if self:GetDrink() < 0.1 then 
 if SERVER then
 if self:GetOwner():GetNWBool("cantsend") then
	local tr = self.Owner:GetEyeTraceNoCursor()
	if tr.HitPos:Distance(tr.StartPos) < 150 then
	local trace = {}
	trace.filter = self.Owner
	trace.start = self.Owner:GetShootPos()
	trace.mask = MASK_SHOT_HULL
	trace.endpos = trace.start + self.Owner:GetAimVector() * 200
	trace.mins = Vector(0,0,0)
	trace.maxs = Vector(0,0,0)
	local tr = util.TraceHull(trace)
	tr.TraceAimVector = self.Owner:GetAimVector()


	local ent = tr.Entity
	if IsValid(ent) and ent:IsPlayer()  and ent:Alive()  then	
		if( SERVER )  then 
			if IsValid(self.Owner) and self.Owner:Alive() then
				ent:SetNWBool("saysey", true)
				ent:ConCommand('mu_taunt me "'..ent:SteamID()..'"')
				ent:SetNWInt('drinked',100)
				self:Remove()
			end
		end
	end
	end
 else
 //self.Owner:SetNWInt('drinked',0)
 local vm = self.Owner:GetViewModel()
 vm:SendViewModelMatchingSequence(vm:LookupSequence("throw"))
 self:SetStartThrowing(true)
 self:SetThrowDelay(CurTime()+0.3)
 local tr = util.TraceLine({ start = self.Owner:EyePos(), endpos = self.Owner:EyePos() + self.Owner:GetAimVector()*32, filter = self.Owner }) 
 if IsFirstTimePredicted() then
 self.Owner:ViewPunch(Angle(1,1,1))
 self:EmitSound("WeaponFrag.Throw") 
 local throwndrink = ents.Create("prop_physics") 
 throwndrink:SetModel(self.DrinkModel) 
 if tr.Hit then 
 throwndrink:SetPos(self.Owner:EyePos() + self.Owner:GetAimVector()*(tr.HitPos:Distance(tr.StartPos))/2) 
 else
 throwndrink:SetPos(self.Owner:EyePos() + self.Owner:GetAimVector()*32) 
 end
 throwndrink:SetAngles(self.Owner:EyeAngles())
 throwndrink:Spawn()
 local phys = throwndrink:GetPhysicsObject()
 if phys and IsValid(phys) then
 phys:SetVelocity(self.Owner:GetAimVector()*650) 
 phys:AddAngleVelocity(VectorRand()*450) 
 end 
 end 
 end 
 self:SetNextSecondaryFire(CurTime()+1) 
 end
 end 
 end 
 
 function SWEP:Reload() 
 end 
 
 function SWEP:DrawWorldModel() 
 if (!self.FakeDrinkW) then 
 self.FakeDrinkW = ClientsideModel(self.DrinkModel,RENDERGROUP_BOTH) 
 self.FakeDrinkW:SetNoDraw(true)
 end 
 local owner = self.Owner 
 if owner:IsValid() then 
 local pos = owner:GetBoneMatrix(owner:LookupBone("ValveBiped.Bip01_R_Hand")):GetTranslation() 
 local ang = owner:GetBoneMatrix(owner:LookupBone("ValveBiped.Bip01_R_Hand")):GetAngles() 
 ang:RotateAroundAxis(ang:Right(),180) 
 pos = pos + ang:Forward()*-3 
 pos = pos + ang:Right()*2
 pos = pos + ang:Up()*3 
 ang:RotateAroundAxis(ang:Forward(),-20) 
 self.FakeDrinkW:SetPos(pos) 
 self.FakeDrinkW:SetAngles(ang) 
 self.FakeDrinkW:SetModelScale(0.8)
 else
 self.FakeDrinkW:SetModelScale(1)
 self.FakeDrinkW:SetPos(self:GetPos()+self:GetUp()*4)
 self.FakeDrinkW:SetAngles(self:GetAngles())
 end 
 self.FakeDrinkW:DrawModel() 
 end 
 
 function SWEP:GetViewModelPosition(pos,ang)
 pos = pos + ang:Forward()*self:GetDrink()*1 
 pos = pos + ang:Up()*-self:GetDrink()*21
 pos = pos + ang:Right()*self:GetDrink()*15.6 
 ang:RotateAroundAxis(ang:Right(),self:GetDrink()*60) 
 ang:RotateAroundAxis(ang:Up(),self:GetDrink()*45)
 return pos, ang 
 end