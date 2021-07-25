
ENT.Type = "point"
ENT.Base = "base_point"

local ROLE_ANY = 666

ENT.Role = ROLE_ANY

function ENT:KeyValue(key, value)
   if key == "OnPass" or key == "OnFail" then
      -- this is our output, so handle it as such
      self:StoreOutput(key, value)
   elseif key == "Role" then
      self.Role = tonumber(value)

      if not self.Role then
         ErrorNoHalt("ttt_logic_role: bad value for Role key, not a number\n")
         self.Role = ROLE_ANY
      end
   end
end

/*
ROLE_INNOCENT  = 0
ROLE_TRAITOR   = 1
ROLE_DETECTIVE = 2
ROLE_NONE = ROLE_INNOCENT
*/

function ENT:AcceptInput(name, activator)
   if name == "TestActivator" then
      if IsValid(activator) and activator:IsPlayer() then
		if self.Role == 3 then
			self.Role = 666
		end
         local activator_role = activator:GetRole()
		 if activator_role == 7 then
			activator_role = 1
		 else
		 	activator_role = 0
		 end
         if self.Role == ROLE_ANY or self.Role == activator_role then
           // activator:ChatPrint(self.Role.." passed logic_role test of ".. self:GetName().." "..activator_role)
            self:TriggerOutput("OnPass", activator)
         else
          //  activator:ChatPrint(self.Role.." failed logic_role test of ".. self:GetName().." "..activator_role)
            self:TriggerOutput("OnFail", activator)
         end
      end

      return true
   end
end

