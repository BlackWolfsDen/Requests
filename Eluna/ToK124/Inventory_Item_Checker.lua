-- ©inventory checker©
-- ©Lua sccript for Trinity Core with Eluna©
-- ©coded by slp13at420 of EmuDevs©
-- ©Projct Start date 5/22/2015 |::| Project Completion Date 5/22/15©

local command = "#check";
local rank = 3;
local ITEMDB = {};

local ITEMsql =  WorldDBQuery("SELECT `entry` FROM `item_template`;");

	if(ITEMsql)then
		repeat
			ITEMDB[ITEMsql:GetUInt32(0)] = {true
			};
		until not ITEMsql:NextRow();
	end


local function CheckPlayerInventory(event, pPlayer, msg)

local tPlayer = pPlayer:GetSelection();
local k = 0;
local MSG = {};


	for word in string.gmatch(msg, "[%w_]+") do
		k = k + 1;
		MSG[k] = word;
	end
		
	if(MSG[1])then
		
		local cmd = ("#"..MSG[1]);
		
		if(command == cmd)then
	
			if(pPlayer:GetGMRank() >= rank)then
	
				if(tPlayer)then
	
					if(tPlayer:GetObjectType() == "Player")then
	
						if(MSG[2])then
		
							local id = tonumber(MSG[2]);
		
								if(ITEMDB[id])then
								
									pPlayer:SendBroadcastMessage(tPlayer:GetName().." has "..pPlayer:GetItemCount(id).." "..GetItemLink(id));
								else
									pPlayer:SendBroadcastMessage("You need to enter a VALID item id entry.");
								end
						else
							pPlayer:SendBroadcastMessage("You need to enter an item id entry.");
						end
					else
						pPlayer:SendBroadcastMessage("You need to select a PLAYER.");
					end
				else
					pPlayer:SendBroadcastMessage("You need to select a player.");
				end
			return false;
			end
		end
	end
end
RegisterPlayerEvent(18, CheckPlayerInventory);

print("SPECIFIC ITEM INV CHECKER:Loaded")
