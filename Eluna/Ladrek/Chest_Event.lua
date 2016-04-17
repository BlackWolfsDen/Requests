-- ?Grumbo'z Hidden Treasures - Custom request?
-- ?Created/Designed by slp13at420 of EmuDevs.com ?
-- ?Project started 1/15/2015?
-- ?Project finished 1/16/2015?
-- For Trinity Core2 3.3.5a
-- ?Custom Private Release for Ladrek of EmuDevs.com. Please dont remove any credits.?
-- ?Do NOT re-release privately/publicly under ANY credits other than the true credits.?

print(" *******************?************* ")
print("*  ?  Grumbo'z Hidden Treasures   *")
print("*              ?                 * ")

local Min_GM = 9; -- minimum required rank able to control system. (must be gm rank x+ AND have gm tag on.)
local start = "#start chest event"; -- /say command to start system. by default system is off.
local stop = "#stop chest event"; -- /say command to disable system.
local Game = 0; -- operational in-game setable switch. 0/1 off/on. Default is of for manual operation of single rounds.
local auto = 1; -- cyclic or  single round. 0/1 ::  0 = single round then it must be started again manually. 1 = continually fires with pauses between.(can only be stopped manually)
local cooldown = 15.30; -- duration between spawns
local duration = 35; -- in minutes. duration a chest will be spawned for.
local Count = 8; -- 8; -- how many chests to spawn.
local ChestID = {101028,101029,101030,101031,101032,101033,101034,101035,101036,101037,101038,101039,101040,101041,101042,101043,101044,101045,101037,101037,101037,101037,101037,101037,101037,101037,101037,101037,101037,101037}; -- {600000,600001,600002,600003,600004,}; -- add id's of the chests here.
local HnS = {Gear = 0};
local Locations = {};
local CHESTS = {};
local Flag = {};
local Loc = {};

local function Tables()

CHESTS = {101028,101029,101030,101031,101032,101033,101034,101035,101036,101037,101038,101039,101040,101041,101042,101043,101044,101045,101037,101037,101037,101037,101037,101037,101037,101037,101037,101037,101037,101037}; -- {600000,600001,600002,600003,600004,}; -- add id's of the chests here.

Locations = { -- this is where you can add an unlimited amount of gps locations for spawning.
	{"location one",  530,-843.151794,8258.223633,31.743633,0.792679},
	{"location two", 530,-510.595245,8337.355469,66.992081,2.713763},
	{"location three",530,-1701.154785,7465.026367,213.525558 ,3.503090},
	{"location four",  530,-1093.974487,6507.346191,199.167725,1.335388},
	{"location five", 530,-2201.700439,5893.112305,188.647659,3.573775},
	{"location Six",  530,-2683.816895,5828.674316,217.902115,0.895562},
	{"location seven", 530,-2525.189941,6414.955078,204.102844,1.209721},
	{"location 8",  530,-3129.305908,6901.650879,10.118382,3.004357},
	{"location 9", 530,-3077.517822,7322.890137,27.044775,0.296301},
	{"location 10",  530,-2494.963135,8642.841797,192.879807,0.669360},
--	{"location 11", 530, -3628.452881, 2415.214355, 76.867737, 4.947165},
--	{"location 12", 530, -3570.218994, 2450.963623, 74.80993, 2.221849},
};
end

local function GetChest()

	repeat
		local chest = math.random(1, #CHESTS)

		if(CHESTS[chest])then

			return chest;
		end
	until(CHESTS[chest]);
end

local function GetLoc()

	repeat
		local loc = math.random(1, #Locations)

		if(Locations[loc])then

			return loc;
		end
	until(Locations[loc]);
end

local function DespawnDeadGO(event, duration, cycles, go)

go:RemoveEvents()

	if(not go:IsSpawned())then
		
		if(go:Respawn())then
		
			go:Respawn()
			go:RemoveFromWorld()
		else
			go:RegisterEvent(DespawnDeadGO, 1000, 1)
		end
	end

end

local function DespawnChests(event, duraton, cycles, go)

go:RemoveEvents()

	if(not go:IsSpawned())then
		go:Respawn()
	end
	
	if(HnS.Gear ~= 1)then

		if(go:RemoveFromWorld())then
	
			go:RemoveFromWorld()
		else

			go:RegisterEvent(DespawnDeadGO, 1000, 1)		
		end
	end
go:RegisterEvent(DespawnChests, 1000, 1)
end

local function SpawnChest(chest_id, loc_id)

local name, map, x, y, z, o = table.unpack(Locations[loc_id])-- unpacks the table for chest location datum

go = PerformIngameSpawn(2, ChestID[chest_id], map, 0, x, y, z, o);
go:RegisterEvent(DespawnChests, 1000, 1)

CHESTS[chest_id] = nil;
Locations[loc_id] = nil;

end

--     ||||||||||||
-- __*?************?*__
-- __*** Grumbo'z ***__
-- __*** Process  ***__
-- __*** Tree     ***__
--   *?************?*  
--     ||||||||||||
local function Proccess(event)

local chest = 0;
local loc = 0;

Tables()

HnS.Gear = (HnS.Gear + 1)

	if(event)then RemoveEventById(Process_Timer); end

	if(Game == 1)then
	
		if(HnS.Gear == 3)then HnS.Gear = 1; end -- start all over
	
		if(HnS.Gear == 1)then -- start round
		
			for a=1,Count do

				chest = GetChest();
				loc = GetLoc();

				SpawnChest(chest, loc)
			end
			SendWorldMessage("Wow-Delusion Treasures event has started.");

			Process_Timer = CreateLuaEvent(Proccess, duration*60000, 1)
		end
		
		if(HnS.Gear == 2)then -- end round
			
			SendWorldMessage("WoW-Delusion Treasures event has ended.");
			
			if(auto == 1)then
			
				Process_Timer = CreateLuaEvent(Proccess, (cooldown*60000), 1)
			end
		end
	end
end

local function Control(event, player, msg, type, lang, channel)

	if(player:IsGM())then
		
		if(player:GetGMRank() >= Min_GM)then
	
			if(msg == start)then
				HnS.Gear = 0;
				Game = 1
				Proccess()
				return false;
			end
			
			if(msg == stop)then
				HnS.Gear = 1;
				Proccess()
				Game = 0;
				SendWorldMessage("WoW-Delusion Treasures event has ended.");
				return false;
			end
		end
	end
end

RegisterPlayerEvent(18, Control)

	if(Game == 0)then
		print("*               Idle      ?       *")
		print(" *********?***********************\n")
	end

	if(Game == 1)then
		print("*    ?         Loaded             *")
		print(" ****************?****************\n")
		Proccess()
	end
