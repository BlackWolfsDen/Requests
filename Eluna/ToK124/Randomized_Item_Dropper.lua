-- © random item giver script  -- ©
-- © this will allow an item to be clicked and reward the clicker some random item  -- ©
-- © the click item will be removed after the reward. -- ©
-- © Eluna script. -- ©
-- © Scripted by slp13at420 of EmuDevs.com -- ©
-- © private request.  -- ©
-- © For Tok124 of EmuDevs.com -- ©

local command = "#roll"; -- command used
local roll_item_ID = 8000001; -- id of the roll item
local ItemName = GetItemLink(roll_item_ID);
local cost = 1;
local remove_roll_item_delay = 100;

local Item_Drops = { -- {chance_Value {item_id_1, item_id_2, item_id_3, item_id_4, item_id_5....}},
		[1] = {60,{6400020, 6400021}}, -- green 60% deop rate.
		[2] = {30,{800000, 800001}}; -- blue 30% drop chance.
		[3] = {10,{6400016, 6400019}}; -- purple 10% drop chance.
	};

local time = tonumber(os.time());
math.randomseed(time*time);

local function RemoveItemRollItem(event, _, _, player)

	player:RemoveItem(roll_item_ID, cost)
end

local function ItemRoll(event, player, msg, Type, lang)

	if(msg == command)then

		if(player:HasItem(roll_item_ID, cost) == false)then
			player:SendBroadcastMessage("You need "..cost.." of "..ItemName..".");
		end

		if(player:HasItem(roll_item_ID, cost))then
		
			local roll = math.random(1, 100);
			local chance = nil;
			local comp = 0;
			
				for comp = 1, #Item_Drops do
			
					if(roll <= Item_Drops[comp][1])then
					
						chance = comp;
					end
				end

				if(chance == nil)then
				
					 ItemRoll(event, player, msg, Type, lang);
				end
			
				if(chance)then
				
					local item = math.random(1, #Item_Drops[chance][2]);
					
						if(player:AddItem(Item_Drops[chance][2][item], 1))then
			
							player:RegisterEvent(RemoveItemRollItem, remove_roll_item_delay, 1, player);
						end
				end
			end
	return false;
	end
end

RegisterPlayerEvent (18, ItemRoll)
