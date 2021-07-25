-- Файл создан специально для кастомизации классов убийцы.

mBenji = 1
mVirus = 2
mDovakin = 3
mSith = 4
mInviz = 5
mBlink = 6
mKama = 7

mFunctions = {
	[mBenji] = function(ply)
		ply.knifeclass = 'weapon_mu_knife_sickle'
		ply:Give('weapon_mu_knife_sickle')
	end,
	[mVirus] = function(ply) 
		ply.knifeclass = 'weapon_mu_knife_virus'
		ply:Give('weapon_mine_turtle_virus')
		ply:Give('weapon_mu_knife_virus')
	end,
	[mDovakin] = function(ply)
		ply.knifeclass = 'weapon_mu_knife_edgystick'
		ply:Give(ply.knifeclass)
	end,
	[mSith] = function(ply) 
		ply.knifeclass = 'weapon_mu_knife_lightsaber'
		ply:Give('weapon_mu_knife_lightsaber')
	end,
	[mInviz] = function(ply, knife)
		ply.knifeclass = knife
		ply:SetNWString("murd_t", "inv")
		ply:Give( ply.knifeclass )
	end,

	[mBlink] = function(ply, knife)
		ply.knifeclass = knife
		ply:SetNWString("murd_t", "tp")
		ply:Give( ply.knifeclass )
	end,

	[mKama] = function(ply, knife)
		ply.knifeclass = knife
		ply:SetNWString("murd_t", "kama")
		ply:Give( ply.knifeclass )
	end,
	/*
	[mKama] = function(ply)
		ply.knifeclass = 'weapon_mu_knife_kamapulya'
		ply:Give('weapon_mu_knife_kamapulya')
	end,
	*/

}

local plyMeta = FindMetaTable("Player")

function plyMeta:RoundM(knife)
	local id = self:GetNWInt('murdertype')
	if mFunctions[id] then 
		self:StripWeapons()
		
		timer.Simple(0, function()
			mFunctions[id](self, knife)
			self:Give('weapon_mu_hands')
		end)
	end
end

function plyMeta:SetTypeM(ID)
	self:SetNWInt("murdertype", ID)
	self:SetPData("murdertype_pd", ID)
end

function plyMeta:GetTypeM(ID)
	if ID ~= nil then
		return self:GetNWInt("murdertype") == ID
	end
	return self:GetNWInt("murdertype")
end

function functionLoadCustom(ply)
	if ply:GetPData("murdertype_pd") == nil then
		ply:SetPData("murdertype_pd",0)
	end
	
	ply:SetNWInt("murdertype", tonumber(ply:GetPData("murdertype_pd")))
end
