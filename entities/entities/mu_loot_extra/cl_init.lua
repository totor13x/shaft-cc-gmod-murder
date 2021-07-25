
include('shared.lua')

function ENT:Initialize()

end
function ENT:DrawMask( size )

    local pos = self:GetPos();
    local up = self:GetUp();
    local right = self:GetRight();

    local segments = 12;

    render.SetColorMaterial();

    mesh.Begin( MATERIAL_POLYGON, segments );

    for i = 0, segments - 1 do

        local rot = math.pi * 2 * ( i / segments );
        local sin = math.sin( rot ) * size;
        local cos = math.cos( rot ) * size;

        mesh.Position( pos + ( up * sin ) + ( right * cos ) );
        mesh.AdvanceVertex();

    end

    mesh.End();

end


function ENT:DrawInterior()
end
    

function ENT:DrawOverlay()
end


function ENT:Draw()

local pos = LocalPlayer():EyePos()+LocalPlayer():EyeAngles():Forward()*10
local ang = LocalPlayer():EyeAngles()
ang = Angle(ang.p+90,ang.y,0)
if self.Edition then
render.ClearStencil()
		render.SetStencilEnable(true)
			render.SetStencilWriteMask(255)
			render.SetStencilTestMask(255)
			render.SetStencilReferenceValue(10)
			render.SetStencilFailOperation(STENCILOPERATION_KEEP)
			render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
			render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
			render.SetBlend(0) --don't visually draw, just stencil
			self:SetModelScale(1.1,0) --slightly fuzzy, looks better this way
			self:DrawModel()
			self:SetModelScale(1,0)
			render.SetBlend(1)
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
			cam.Start3D2D(pos,ang,1)
					surface.SetDrawColor(math.Rand(210,255),0,0,255)
					surface.DrawRect(-ScrW(),-ScrH(),ScrW()*2,ScrH()*2)
			cam.End3D2D()
			//self:DrawModel()
		render.SetStencilEnable(false)
		return
end
if LocalPlayer():GetRole(VOR) and LocalPlayer():Alive() then

render.ClearStencil()
		render.SetStencilEnable(true)
			render.SetStencilWriteMask(255)
			render.SetStencilTestMask(255)
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
			render.SetStencilZFailOperation(STENCILOPERATION_REPLACE)
			render.SetStencilReferenceValue(1)
			render.SetBlend(0) --don't visually draw, just stencil

			self:SetModelScale(1,0) --slightly fuzzy, looks better this way
			self:DrawModel()
			self:SetModelScale(1,0)
			render.SetBlend(1)
			self:SetModelScale(1,0)
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
			cam.Start3D2D(pos,ang,1)
					surface.SetDrawColor(Color(16,97,84))
					surface.DrawRect(-ScrW(),-ScrH(),ScrW()*2,ScrH()*2)
			cam.End3D2D()
			self:DrawModel()

			render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
			
		render.SetStencilEnable(false)
		self:DrawModel()
		return
end
render.ClearStencil()
		render.SetStencilEnable(true)
			render.SetStencilWriteMask(255)
			render.SetStencilTestMask(255)
			render.SetStencilReferenceValue(10)
			render.SetStencilFailOperation(STENCILOPERATION_KEEP)
			render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
			render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
			render.SetBlend(0) --don't visually draw, just stencil
			self:SetModelScale(1.1,0) --slightly fuzzy, looks better this way
			self:DrawModel()
			self:SetModelScale(1,0)
			render.SetBlend(1)
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
			cam.Start3D2D(pos,ang,1)
					surface.SetDrawColor(0,math.Rand(210,255),0,255)
					surface.DrawRect(-ScrW(),-ScrH(),ScrW()*2,ScrH()*2)
			cam.End3D2D()
			self:DrawModel()
		render.SetStencilEnable(false)
end