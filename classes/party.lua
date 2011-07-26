include("pawn.lua");
include("player.lua");



function PartyHeals()
		local partymember={}
		local partymemberName={}
		local partymemberObj={}

		table.insert(partymemberName,1, RoMScript("UnitName('player')"))  -- need to insert player name.
		table.insert(partymemberObj,1, player:findNearestNameOrId(partymemberName[1]))
		table.insert(partymember,1, CPawn(partymemberObj[1].Address))
for i = 1, 5 do
		if GetPartyMemberName(i) ~= nil then
		cprintf(cli.yellow,"Party member "..i.." has the name of ")
		cprintf(cli.red, GetPartyMemberName(i).."\n")
		else
		printf("No information for party member "..i.."\n")
		end
		
	if GetPartyMemberName(i) then
		table.insert(partymemberName,i + 1, GetPartyMemberName(i))
		table.insert(partymemberObj,i + 1, player:findNearestNameOrId(partymemberName[i]))
		table.insert(partymember,i + 1, CPawn(partymemberObj[i].Address))
	end
end



	while(true) do
	
		for i,v in ipairs(partymember) do
		if i == 1 then keyboardPress(key.VK_F1); end
		if i == 2 then keyboardPress(key.VK_F2); end
		if i == 3 then keyboardPress(key.VK_F3); end
		if i == 4 then keyboardPress(key.VK_F4); end
		if i == 5 then keyboardPress(key.VK_F5); end
		if i == 6 then keyboardPress(key.VK_F6); end

			partymember[i]:update()
			player:update()
			
			partymember[i]:updateBuffs()
			
			player:checkSkills(true);
			
			player:checkPotions()
								
			yrest(500)
				
 
		if (not player.Battling) then 
  
		getNameFollow()
		end	
	end
 	end
 end

function PartyDPS()
player:update();
if settings.profile.options.PARTY ~= true then settings.profile.options.PARTY = false end
 
	player:target(player:findEnemy(true, nil, nil, nil))
	local target = player:getTarget();
	local pawn = CPawn(target.Address);
	local icon = pawn:GetPartyIcon()
		
		if player:haveTarget() then

		if icon == 1 then 
			local target = player:getTarget();
				
   			player:fight();
		end
		end
		if (not player.Battling) then 
  -- might try to use moveinrange function.
		getNameFollow()
		end	
end			

function getNameFollow()
	while (true) do	
  		if ( settings.profile.options.PARTY_FOLLOW_NAME ) then
    	if GetPartyMemberName(1) == settings.profile.options.PARTY_FOLLOW_NAME  then RoMScript("FollowUnit('party1');"); break  end
		if GetPartyMemberName(2) == settings.profile.options.PARTY_FOLLOW_NAME  then RoMScript("FollowUnit('party2');"); break  end
		if GetPartyMemberName(3) == settings.profile.options.PARTY_FOLLOW_NAME  then RoMScript("FollowUnit('party3');"); break  end
		if GetPartyMemberName(4) == settings.profile.options.PARTY_FOLLOW_NAME  then RoMScript("FollowUnit('party4');"); break  end
		if GetPartyMemberName(5) == settings.profile.options.PARTY_FOLLOW_NAME  then RoMScript("FollowUnit('party5');"); break  end
		RoMScript("FollowUnit('party1');");
		else RoMScript("FollowUnit('party1');");		

		end
		break
	end
end