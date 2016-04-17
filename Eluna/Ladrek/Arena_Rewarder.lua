-- arena points awarder slp13at420 of EmuDevs.com

local npcid = 100; -- id of the creature
local arena = 3; -- how many to award

local function AwardArena(event, creature, player)

	if(player:IsInGroup()) then
	
		for _, v in ipairs(player:GetGroup():GetMembers()) do
		
			if v:IsInWorld() then

				v:ModifyArenaPoints(arena)
			end
		end
	else
		player:ModifyArenaPoints(arena)
	end
end

RegisterCreatureEvent(npcid, 4, AwardArena)
