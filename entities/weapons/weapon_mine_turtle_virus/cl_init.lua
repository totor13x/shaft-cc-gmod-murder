include('shared.lua')

SWEP.PrintName = "Mine Turtle"
SWEP.Slot = 4

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false


function SWEP:OnRemove()
	if (IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive()) then
		RunConsoleCommand("lastinv")
	end
end
