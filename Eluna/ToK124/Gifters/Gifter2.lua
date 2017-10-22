-- © random item giver script  -- ©
-- © this will allow an item to be clicked and reward the clicker some random item  -- ©
-- © the click item will be removed after the reward. -- ©
-- © Eluna script. -- ©
-- © Scripted by slp13at420 of EmuDevs.com -- ©
-- © private request.  -- ©
-- © For Tok124 of EmuDevs.com -- ©

local command = "#roll"; -- command used
local roll_item_ID = 63020; -- id of the roll item.
local ItemName = GetItemLink(roll_item_ID); -- ingame item link.
local cost = 1; -- cost of item per roll.
local try = 1;
local tries = 3; -- catch 22 in case player can only have 1 item they allready have then reroll x tries for a new item.
local test = false;

local Item_Drops = { -- {chance_Value {item_id_1, item_id_2, item_id_3, item_id_4, item_id_5....}},
		[1] = {{20}, 6400020, 6400021}, -- green 20% deop rate.
		[2] = {{40}, 800000, 800001}; -- blue 40% drop chance.
		[3] = {{90}, 6400016, 6400019}; -- purple 90% drop chance.
	};

local time = tonumber(os.time());
math.randomseed(time*time);

local function ItemRoll(event, player, msg, Type, lang)

	if(msg == command)then
	
		local count = player:GetItemCount(roll_item_ID);
		
			if(player:HasItem(roll_item_ID, cost) == false)then	player:SendBroadcastMessage("You need "..cost.." of "..ItemName..". You have "..count..".");

			else

				local roll = math.random(1, 100);
				local pct;
				
				if(test)then print("-----------") end;
				if(test)then print("Gifter test") end;
				if(test)then print("-----------") end;
				if(test)then print("roll:"..roll) end;				
				
					for pct = 1, #Item_Drops do
						
						if(test)then print("percent:"..pct )end;
						
						if(roll <= Item_Drops[pct][1][1])then
						
							local item = math.random(2, #Item_Drops[pct]);
								
								if(test)then print("item:"..item) end;

								if(player:AddItem(Item_Drops[pct][item], 1))then 
									player:RemoveItem(roll_item_ID, cost);
									return false;
			
								else 
									if(try >= tries)then 
										player:SendBroadcastMessage("There was an error trying to gift you an item. please try again later.");
										return false;
										
									else 
										try = try + 1;
										ItemRoll(event, player, msg, Type, lang);
									end
								end
						end
					end
					
			end
	return false;
	end
end

RegisterPlayerEvent (18, ItemRoll)
