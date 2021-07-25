
ENT.Type = "point"
ENT.Base = "base_point"

ENT.Message = ""
ENT.Color = COLOR_WHITE

local RECEIVE_ACTIVATOR = 0
local RECEIVE_ALL = 1
local RECEIVE_DETECTIVE = 2
local RECEIVE_TRAITOR = 3
local RECEIVE_INNOCENT = 4

ENT.Receiver = RECEIVE_ACTIVATOR

function ENT:KeyValue(key, value)
   if key == "message" then
      self.Message = tostring(value) or "ERROR: bad value"
   elseif key == "color" then
      local mr, mg, mb = string.match(value, "(%d*) (%d*) (%d*)")

      local c = Color(0,0,0)
      c.r = tonumber(mr) or 255
      c.g = tonumber(mg) or 255
      c.b = tonumber(mb) or 255

      self.Color = c
   elseif key == "receive" then
      self.Receiver = tonumber(value)
      if not (self.Receiver and self.Receiver >= 0 and self.Receiver <= 4) then
         ErrorNoHalt("ERROR: ttt_game_text has invalid receiver value\n")
         self.Receiver = RECEIVE_ACTIVATOR
      end
   end
end

function ENT:AcceptInput(name, activator)
	if name == "Display" then
		local recv = activator
		
		if self.Message == '' then return false end //Clean
		if self.Message == 'Made by Finniespin. Visit http://conjointgaming.com/' then return false end //Sorry, u created a spam trigger.
		print(self.Message)
		local r = self.Receiver
		if r == RECEIVE_ALL then
			recv = nil
		elseif r == RECEIVE_DETECTIVE then
			//recv = GetDetectiveFilter()
			recv = {}
			//for i,ply in pairs(team.GetPlayers(2)) do
			//	if ply:GetRole(MURDER) or ply:GetRole(MURDER_HELPER) then continue end
			//	table.insert(recv, ply)
			//end
			return true
		elseif r == RECEIVE_TRAITOR then
			//recv = GetTraitorFilter()
			recv = {}
			for i,ply in pairs(team.GetPlayers(2)) do
				if !ply:GetRole(MURDER) and !ply:GetRole(MURDER_HELPER) then continue end
				table.insert(recv, ply)
			end
		elseif r == RECEIVE_INNOCENT then
			recv = {}
			for i,ply in pairs(team.GetPlayers(2)) do
				if ply:GetRole(MURDER) or ply:GetRole(MURDER_HELPER) then continue end
				table.insert(recv, ply)
			end
			//recv = GetInnocentFilter()
		elseif r == RECEIVE_ACTIVATOR then
			if not (IsValid(activator) and activator:IsPlayer()) then
				ErrorNoHalt("ttt_game_text tried to show message to invalid !activator\n")
				return true
			end
		end
	  
		local ms = ChatMsg()
		ms:Add("[", Color(255, 255, 255))
		ms:Add("SYSTEM", Color(11, 53, 114))
		ms:Add("] ", Color(255, 255, 255))
		ms:Add(self.Message,self.Color)
		ms:Send(recv)
	  
		//CustomMsg(recv, self.Message, self.Color)

		return true
   end
end

