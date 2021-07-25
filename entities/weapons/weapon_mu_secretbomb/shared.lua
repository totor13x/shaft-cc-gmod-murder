if SERVER then
   AddCSLuaFile( "shared.lua" );
end
 
SWEP.HoldType                   = "slam"
 
if CLIENT then
   SWEP.PrintName                       = "Сделай грязь."
   SWEP.Slot                            = 4
   SWEP.SlotPos		= 1
 
   SWEP.EquipMenuData = {
      type  = "item_weapon",
      name  = "Секретная бомбочка!",
      desc  = "Не нажимай на левую кнопку мыши!"
   };
 
end

 
SWEP.Base = "weapon_base"
 
SWEP.ViewModel  = Model("models/weapons/v_c4.mdl")
SWEP.WorldModel = Model("models/weapons/w_c4.mdl")

SWEP.DrawCrosshair          = false
SWEP.ViewModelFlip          = false
SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = false
SWEP.Primary.Ammo           = "none"
SWEP.Primary.Delay          = 5.0
 
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo         = "none"
 
SWEP.NoSights               = true
 

 
function SWEP:Reload()
end  
 
function SWEP:Initialize()
    util.PrecacheSound("kaboom.wav")
end
 
 
function SWEP:Think()  
end
 
 

function SWEP:PrimaryAttack()
  self.Weapon:SetNextPrimaryFire(CurTime() + 2.3)    

  local effectdata = EffectData()
  effectdata:SetOrigin( self.Owner:GetPos() )
  effectdata:SetNormal( self.Owner:GetPos() )
  effectdata:SetMagnitude( 8 )
  effectdata:SetScale( 1 )
  effectdata:SetRadius( 75 )
  util.Effect( "Sparks", effectdata )
  self.BaseClass.ShootEffects( self )
       
  -- The rest is only done on the server
  if (SERVER) then
    timer.Simple(2, function() self:Asplode() end )
    self.Owner:EmitSound( "kaboom.wav" )
  end 
end
 

function SWEP:Asplode()
  local k, v
            
  local ent = ents.Create( "env_explosion" )
  ent:SetPos( self.Owner:GetPos() )
  ent:SetOwner( self.Owner )
  ent:SetKeyValue( "iMagnitude", "185" )
  ent:Spawn()
  ent:Fire( "Explode", 0, 0 )
  ent:EmitSound( "siege/big_explosion.wav", 500, 500 )
  self:Remove()
  
  local ct = ChatText()
  ct:Add(self.Owner:GetBystanderName(), self.Owner:GetBystanderColor(true))
  ct:Add(" подорвал себя.", Color( 255, 255, 255 ))
  ct:Broadcast()

  					
end
 
 

function SWEP:SecondaryAttack()
end