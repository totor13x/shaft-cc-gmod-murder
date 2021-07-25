local plyMeta = FindMetaTable("Player")
if !plyMeta.CreateRagdollOld then
	plyMeta.CreateRagdollOld = plyMeta.CreateRagdoll
end

function plyMeta:CreateRagdoll(attacker, dmginfo)
	if EVENTS:Get('ID') == EVENT_BOOM then return end
	local tab = {}
	-- local id = PS.CacheModels[self:GetModel()]
	-- if id and self.PS_Items[id] and self.PS_Items[id]['Modifiers'] and self.PS_Items[id]['Modifiers']['bodygroup'] then
	-- 	tab = table.Copy(self.PS_Items[id]['Modifiers']['bodygroup'])
	-- end
	local ent = ents.Create( "prop_ragdoll" )
	ent:SetNWEntity("RagdollOwner", self)
	ent:SetModel(self:GetModel())
	ent:Spawn()
	if tab ~= {} then
		for i,v in pairs(tab) do
			ent:SetBodygroup(i,v)
		end
	end
	ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	
	self:SetNWEntity("DeathRagdoll", ent )
	
	ent:SetNWInt("OwnerTimeDeath", ROUND:GetTimer())
	ent:SetNWString("SteamidOw", self:SteamID())
	ent:SetBystanderName(self:GetBystanderName())
	
	local vel = self:GetVelocity()
	for bone = 0, ent:GetPhysicsObjectCount() - 1 do
		local phys = ent:GetPhysicsObjectNum( bone )
		if IsValid(phys) then
			local pos, ang = self:GetBonePosition( ent:TranslatePhysBoneToBone( bone ) )
			phys:SetPos(pos)
			phys:SetAngles(ang)
			phys:AddVelocity(vel)
		end
	end
	
	if ent.SetBystanderColor then
		ent:SetBystanderColor(self:GetBystanderColor(true))
	end
end


function playerCorpseRemove(ply,entity)

	if IsValid(ply) and ply:GetNWBool("dissole") and ply:GetNWString("dissolestring") != ""  then
		//ply:CreateRagdoll()
		
		local corpse = ply:GetNWEntity("DeathRagdoll")
		local typediss = ply:GetNWString("dissolestring")
		timer.Simple(10,function()
		if IsValid(corpse) then
			
			if typediss == 'standart_diss' then
			
				corpse.oldname=corpse:GetName()
				corpse:SetName("fizzled"..corpse:EntIndex().."");
				local dissolver = ents.Create( "env_entity_dissolver" );
				if IsValid(dissolver) then
					dissolver:SetPos( corpse:GetPos() );
					dissolver:SetOwner( corpse );
					dissolver:Spawn();
					dissolver:Activate();
					dissolver:SetKeyValue( "target", "fizzled"..corpse:EntIndex().."" );
					dissolver:SetKeyValue( "magnitude", 100 );
					dissolver:SetKeyValue( "dissolvetype", 0 );
					dissolver:Fire( "Dissolve" );
					timer.Simple( 1, function()
						if IsValid(corpse) then 
							corpse:SetName(corpseoldname)
						end
					end)
				end
			elseif typediss == 'standart_silnie_diss' then
				corpse.oldname=corpse:GetName()
				corpse:SetName("fizzled"..corpse:EntIndex().."");
				local dissolver = ents.Create( "env_entity_dissolver" );
				if IsValid(dissolver) then
					dissolver:SetPos( corpse:GetPos() );
					dissolver:SetOwner( corpse );
					dissolver:Spawn();
					dissolver:Activate();
					dissolver:SetKeyValue( "target", "fizzled"..corpse:EntIndex().."" );
					dissolver:SetKeyValue( "magnitude", 100 );
					dissolver:SetKeyValue( "dissolvetype", 1 );
					dissolver:Fire( "Dissolve" );
					timer.Simple( 1, function()
						if IsValid(corpse) then 
							corpse:SetName(corpseoldname)
						end
					end)
				end
			end
		end
		end)
	end
end			

hook.Add( "PlayerDeath", "playerCorpseRemove", playerCorpseRemove )