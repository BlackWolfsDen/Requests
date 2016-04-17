-- �Grumbo'z PvP gold Looter�
-- �Creator slp13at420 of EmuDevs.com�
-- �Project started 1/23/2015�
-- �Project finished 1/23/2015�
-- For Trinity Core2 3.3.5a
-- �Do NOT re-release privately/publicly under ANY credits other than the true credits.�
-- reward is 0.05 = 5% of victims gold.

local function Pvp_Gold_Reward(event, killer, killed)

local coin = killed:GetCoinage();

	if(coin > 100)then
	
		local percentage = 0.05;
		local win = (coin * percentage);
		local loose = (coin - win);
		local K
		
		killer:ModifyMoney(win);
		killed:ModifyMoney(loose);
		
		killer:SendBroadcastMessage("You have looted "..win.." copper from your victim.")
		killed:SendBroadcastMessage("You have lost "..win.." copper.")
	end
end

RegisterPlayerEvent(6, Pvp_Gold_Reward)

print(" - Grumbo'z PvP Gold Looter loaded. - ")
