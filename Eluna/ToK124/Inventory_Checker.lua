-- inventory lister 
-- Lua sccript for Trinity Core with Eluna
-- coded by slp13at420 of EmuDevs
-- request by tok123 of EmuDevs

local command = "#inv";
local Player_Inventory = {};
local Itemid = nil;
local rank = 3;
local test = 2;
local Steps = {
		[1] = {255,0,18}, -- when 3 entries -- its stays in location data1 and scans from data2 to data3
		[2] = {255,23,38}, -- when 4 entries -- is scans from data1 to data2 with sub-scanning from data3 to data4
		[3] = {19,22,0,35}, -- when 4 entries -- is scans from data1 to data2 with sub-scanning from data3 to data4
		};
		
local function GetPlayerInventory(event, pPlayer, msg)

local tPlayer = pPlayer:GetSelection();
local Item = nil;

	if(msg == command)then
				
		if(pPlayer:GetGMRank() >= rank)then
			
			if(tPlayer)then
			
				if(tPlayer:GetObjectType() == "Player")then
					
					local tGuid = tPlayer:GetGUIDLow();
					local Iscan = nil;
					Player_Inventory[tGuid] = {};
					pPlayer:SendBroadcastMessage(tPlayer:GetName().."'s inventory:");
						for step = 1,#Steps do

							if not(Steps[step][4])then 
							
								stone = Steps[step][1];
								
									for ITMscan = Steps[step][2],Steps[step][3] do
	
										Item = tPlayer:GetItemByPos(stone, ITMscan); -- GetEquippedItemBySlot(Iscan);
									
											if(Item)then
											
												ItemID = Item:GetEntry();

													if not(Player_Inventory[tGuid][ItemID])then
														Player_Inventory[tGuid][ItemID] = tPlayer:GetItemCount(ItemID);
														pPlayer:SendBroadcastMessage(GetItemLink(ItemID).." x "..Player_Inventory[tGuid][ItemID]);
													end
													
											end
									end
							end
							
							if(Steps[step][4])then 
								
								for stone = Steps[step][1],Steps[step][2] do

									for ITMscan = Steps[step][3],Steps[step][4] do
								
										Item = tPlayer:GetItemByPos(stone, ITMscan); -- GetEquippedItemBySlot(Iscan);
									
											if(Item)then
											
												ItemID = Item:GetEntry();

													if not(Player_Inventory[tGuid][ItemID] == true)then
														Player_Inventory[tGuid][ItemID] = tPlayer:GetItemCount(ItemID);
														pPlayer:SendBroadcastMessage(GetItemLink(ItemID).." x "..Player_Inventory[tGuid][ItemID]);
													end													
											end
									end
								end
							end
							
						end
					Player_Inventory[tGuid] = nil;
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

RegisterPlayerEvent(18, GetPlayerInventory);
