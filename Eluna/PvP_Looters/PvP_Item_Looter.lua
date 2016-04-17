-- �Grumbo'z PvP Item Looter�
-- �Creator slp13at420 of EmuDevs.com�
-- �Project started 1/23/2015�
-- �Project finished 1/23/2015�
-- For Trinity Core2 3.3.5a
-- �Do NOT re-release privately/publicly under ANY credits other than the true credits.�
-- �randomly loots 1 equiped item to killer.�

function Pvp_Gear_Reward(event, killer, killed)

	repeat

		local Iscan = math.random(0, 18) -- choose random equip slot 0 to 18
		local Itemid = killed:GetEquippedItemBySlot(Iscan) -- attempt to grab guid of equipped item.
		
	until(Itemid);

   	if(killer:AddItem(Itemid:GetEntry(), 1) == true)then

	   	killer:SendBroadcastMessage("|cff00cc00Congratulations you looted "..GetItemLink(Itemid).." from "..killed:GetName()..".|r")
		killed:RemoveItem(Itemid:GetEntry(), 1)
		killed:SendBroadcastMessage("|cffcc0000"..killer:GetName().." looted your "..GetItemLink(Itemid)..".|r")
	else
	   	killer:SendBroadcastMessage("|cff00cc00tsk.. tsk.. If you had room in your inventory you could have looted "..GetItemLink(Itemid).." from "..killed:GetName().."....|r")
	end
end

RegisterPlayerEvent(6, Pvp_Gear_Reward)

print(" - Grumbo'z PvP Item Looter loaded. - ")
