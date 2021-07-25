matproxy.Add( 
{
	name	=	"PlayerColor", 
	init	=	function( self, mat, values )
		self.ResultTo = values.resultvar
	end,
	bind	=	function( self, mat, ent )
		if ( !IsValid( ent ) ) then return end
		if ( ent.GetBystanderColor ) then
			local col = ent:GetBystanderColor()
			if ( isvector( col ) ) then
				mat:SetVector( self.ResultTo, col )
			end
		else
			mat:SetVector( self.ResultTo, Vector( 62.0/255.0, 88.0/255.0, 106.0/255.0 ) )
		end

	end 
})


matproxy.Add{
	name = "PlayerCloak",
	init = function() end,
	bind = function( self, mat, ent )
		if not IsValid( ent ) or not ent.CloakFactor then return end
		-- print(ent, ent.CloakFactor)
		mat:SetFloat( "$cloakfactor", ent.CloakFactor )
	end
}