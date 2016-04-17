-- Simply makes A single zone do something when a player enters the zone.
-- just add your code to ofc Do something block.

local Neutral = {
			Map = 1,
			Zone = 100,
};


local function ChangeZone(event, player)

	if(player:GetMapId() == Neutral.Map)and(player:GetZoneId() == Neutral.Zone)then
			-- Do Stuff blocking
	end
end

RegisterPlayerEvent(27, ChangeZone)
