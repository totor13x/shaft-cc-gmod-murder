SWEP.Base = "weapon_mu_knife_def"

SWEP.ViewModel = "models/weapons/c_ebonyblade.mdl"
SWEP.WorldModel = "models/weapons/w_ebonyblade.mdl"
SWEP.ENT 				= "mu_knife_sickle" 
SWEP.ViewModelFOV = 65
SWEP.DrawCrosshair  = true
SWEP.Primary.Damage = 120
SWEP.Primary.Delay = 1.2
SWEP.HoldType = "melee2"
SWEP.UseHands = true

function SWEP:SetupDataTables()
	weapons.Get("weapon_mu_knife_def").SetupDataTables(self)
	self:NetworkVar( "Int", 0, "Charge" )
	self:NetworkVar( "Int", 1, "Cooldown" )
end

local function find_in_cone(cone_origin, cone_direction, cone_radius, cone_angle)
	local entities = ents.FindInSphere(cone_origin, cone_radius)
	local result = {}
	cone_direction:Normalize()
	local cos = math.cos(cone_angle)
	for _, entity in pairs(entities) do local pos = entity:GetPos() local dir =
	pos - cone_origin dir:Normalize() local dot = cone_direction:Dot(dir)
	if (dot > cos) then table.insert(result, entity) end end
	return result
end

function SWEP:Ragdoll(npc,time)

	local hp = npc:Health()
	local mdl = npc:GetModel()
	local skin = npc:GetSkin()
	local class = npc:GetClass()
	local wep = npc:GetActiveWeapon()
	if wep:IsValid() then wep = wep:GetClass() else wep = nil end
	local bones = {}
	for i=1,npc:GetBoneCount() do
		bones[i] = npc:GetBoneMatrix(i)
	end

	local rag = ents.Create("prop_ragdoll")
	rag:SetModel(mdl)
	rag:SetPos(npc:GetPos())
	rag:SetAngles(npc:GetAngles())
	npc:Remove()

	local tbl = {hp=hp,mdl=mdl,skin=skin,class=class,rag=rag,wep=wep}

	rag:Spawn()
	rag:SetSkin(skin)
	rag.DamageTaken = 0

	for k,v in pairs (bones) do
		rag:SetBoneMatrix(k,v)
	end

	timer.Simple(time,function() self:UnRagdoll(tbl) end)

	return rag

end

hook.Add("EntityTakeDamage", "TakenDamageInRagdolled", function( target, dmginfo )

if target.DamageTaken != nil then
	target.DamageTaken = target.DamageTaken + dmginfo:GetDamage()
end

end)

function SWEP:UnRagdoll(tbl)

	if tbl.rag ~= nil then
		if not tbl.rag:IsValid() then
			return
		end
	else
		return
	end
	if tbl.rag.DamageTaken >= tbl.hp then return end
	local npc = ents.Create(tbl.class)
	npc:SetModel(tbl.mdl)
	npc:SetPos(tbl.rag:GetPos())
	if tbl.wep ~= nil then npc:SetKeyValue("additionalequipment", tbl.wep) end
	tbl.rag:Remove()
	npc:Spawn()
	npc:SetHealth(tbl.hp)
	npc:SetSkin(tbl.skin)

end
function SWEP:Think()

	weapons.Get("weapon_mu_knife_def").Think(self)

	if ( RealTime() < self:GetCharge() ) then return; end
	if self.Owner:KeyReleased(IN_ATTACK2) and SERVER then
		self:Selved()
	end
	if self.Owner:KeyDown(IN_ATTACK2) and SERVER then
		if self.timeSel == nil then
			self.timeSel = RealTime()
		end
		if RealTime()-self.timeSel > 1 then
			self:Selved()
		end
	end

end
function SWEP:Selved()
	if self.timeSel ~= nil then
		local s1 = SoundDuration(Sound("dragon_shouts/Level 1/FUS.wav"))
		local s2 = SoundDuration(Sound("dragon_shouts/Level 2/FUS_RO.wav"))
		local s3 = SoundDuration(Sound("dragon_shouts/Level 3/FUS_RO_DAH.wav"))
		
		local timed = RealTime()-self.timeSel
		local curtime = RealTime()
		local coold = 0
		
		if timed >= 0 and timed <= 0.65 then 
			self.Owner:EmitSound("dragon_shouts/Level 1/FUS.wav",100,100)
			self.Owner:EmitSound("dragon_shouts/FX/FUS_RO_DAH_fx_lvl1.wav",100,100)
			coold = 1.5
		elseif timed > 0.65 and timed <= 1 then
			self.Owner:EmitSound("dragon_shouts/Level 2/FUS_RO.wav",100,100)
			self.Owner:EmitSound("dragon_shouts/FX/FUS_RO_DAH_fx_lvl2.wav",100,100)
			coold = 1.5
		else
			self.Owner:EmitSound("dragon_shouts/Level 3/FUS_RO_DAH.wav",100,100)
			self.Owner:EmitSound("dragon_shouts/FX/FUS_RO_DAH_fx_lvl3.wav",100,100)
			coold = 1.5
		end
		
		self:functionsettime(coold)
		
		self.timeSel = nil
	end
end
function SWEP:SecondaryAttack()
	if !self:IsIdle() then return end
end

function SWEP:functionsettime(coold)
	self:SetCooldown(coold)
	self:SetCharge( RealTime() + coold);

	local aim = self.Owner:GetAimVector( )
	local force  = aim*(self:GetCooldown()*500)+Vector(0,0,500)
	local plyHeadPos = self.Owner:GetPos()+Vector(0,0,0)

	for k,v in pairs (find_in_cone(plyHeadPos,aim,400,math.pi/4)) do
		if v ~= self.Owner then
			if v:IsNPC() and v:GetMoveType() == 3 and self:GetCooldown() > 0 then
				local rag = self:Ragdoll(v,5)
				rag:GetPhysicsObject():SetVelocity(force*5)
			elseif v:GetMoveType( ) == MOVETYPE_VPHYSICS then
				v:GetPhysicsObject():SetVelocity(force)
			else
				v:SetVelocity(force)
			end
		end
	end

	self.Owner:SendLua('dragonShout:ScreenFlash(1,145,255,255,75)')
end

function SWEP:Deploy()
	self.Weapon:EmitSound("weapons/skyrimswords/wpn_blade1hand_draw_0"..math.random(3)..".wav")
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	self:SetNextPrimaryFire(CurTime() + 1.5)
	self:SetNetHoldType(self.HoldType)
end

function SWEP:DrawHUD()

	local charge = (self:GetCharge() - RealTime())/self:GetCooldown()*100
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
