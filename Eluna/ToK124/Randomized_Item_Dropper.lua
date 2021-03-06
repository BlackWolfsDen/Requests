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
local tries = 3; -- catch 22 in case player can only have 1 item they allready have then reroll x tries for a new item.
local try = 1;

local Item_Drops = { -- {chance_Value {item_id_1, item_id_2, item_id_3, item_id_4, item_id_5....}},
		[1] = {6400020, 6400021}, -- green 60% deop rate.
		[2] = {800000, 800001}; -- blue 30% drop chance.
		[3] = {6400016, 6400019}; -- purple 10% drop chance.
	};

local time = tonumber(os.time());
math.randomseed(time*time);

local function ItemRoll(event, player, msg, Type, lang)

	if(msg == command)then
	
		local count = player:GetItemCount(roll_item_ID);
		
			if(player:HasItem(roll_item_ID, cost) == false)then	player:SendBroadcastMessage("You need "..cost.." of "..ItemName..". You have "..count..".");

			else

				local roll = math.random(1, #Item_Drops);
				local item = math.random(1, #Item_Drops[roll]);

					if(player:AddItem(Item_Drops[roll][item], 1))then player:RemoveItem(roll_item_ID, cost);

					else 
						if(try >= tries)then player:SendBroadcastMessage("There was an error trying to gift you an item. please try again later.");

						else 
							try = try + 1;
							ItemRoll(event, player, msg, Type, lang);
						end
					end
			end
	return false;
	end
end

RegisterPlayerEvent (18, ItemRoll)
