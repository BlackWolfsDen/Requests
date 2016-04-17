-- ©Grumbo'z Portable WSG System - Custom requested System©
-- ©Created/Designed by slp13at420 of EmuDevs.com ©
-- ©Project started 1/2/2015©
-- ©Project finished 1/2/2015©
-- uses WorldStates by FoeReaper of EmuDevs.com
-- found here http://emudevs.com/showthread.php/2691-Eluna-Extension-WorldState-methods! <-- REQUIRED
-- For Trinity Core2 3.3.5a
-- ©Custom Private Release for Ladrek of EmuDevs.com. Please dont remove any credits.©
-- ©Do NOT re-release privately/publicly under ANY credits other than the true credits.©

print("\n *********************************")
print("*****        Grumbo'z         *****")
print("*****        Portable         *****")
print("***         WSG System          ***")
print("* Capture The Flag System Loading *")

-- CTF is the operational switch. system 1=on/0=off
-- required_players is minimum required players per team for system to start a round. default 4 players.
-- CTF_round_timer is the duration of a round
-- CTF_spawn_timer is the pause between rounds
-- team_flag_loc is the table for the 2 team flag spawn locations.
-- flag_id is the starting flag Gobject id.

local CTF = 1; -- system operation switch. 0=system off/1=system on.
local required_players = 1; -- how many players PER team for the system to operate.
local MaxScore = 3; -- how many captures to win a round.
local rest = 1; -- time in minutes between round and stage. float values work (0.5 = 500 milliseconds = 1/2 second).
local cooldown = 0.3; -- time in minutes being staged before flags spawn. float values work (0.5 = 500 milliseconds = 1/2 second).
local round = 15; -- time duration in minutes for a round. float values work (0.5 = 500 milliseconds = 1/2 second).
local recheck = 10; -- time in seconds between checks for player count. in minutes. float values work (0.5 = 500 milliseconds = 1/2 second).
local Advertise = 5; -- timer in minutes. how often to announce about this float values work.
-- DON'T Edit ANYTHING Below here UNLESS you REALLY know what your doing --

local sound_id1 = 1; -- grab enemy flag
local sound_id2 = 2; -- capture enemy flag
local sound_id3 = 3; -- return team flag
local sound_id4 = 4; -- enter zone

local flag_id = 600000; -- starting id for dynamic id'd flags

local Blocked_Buffs ={1784, 1785, 1786, 1787, 58984, 5215,}; -- spell buffs that cause the player to drop the flag.

local GO = {};

local team_flag_loc = {
			[0] = {-11904.839844, -4588.023926, 0.795418, 5.511887}, -- ally {x, y, z, o}
			[1] = {-11330.767578, -4719.598145, 5.942307, 3.535823}, -- Horde {x, y, z, o}
};

local World_CTF = { 
	player = {
		[0] = nil, -- ally flag holding player guid
		[1] = nil, -- horde flag holding player guid
	},
	FLAG = {
		[0] = nil, -- ally go pointer
		[1] = nil, -- horde go pointer
	},
	team_name = { -- for broadcasts
		[0] = "Alliance",
		[1] = "Horde",
	},
	Aura = { -- flag holder auras from wsg.
		[0] = 23333,
		[1] = 23335,
	},
	count = { -- player count
		[0] = 0, -- ally
		[1] = 0, -- horde
	},
	Drop = { -- stores true/false team flag dropped spawned.
		[0] = nil,
		[1] = nil,
	},
	Gear = 0,
	Group = {},
	Pen = {},
	Stop = 0,
};

local Zone = { -- from Foereapers Zone Battles
	Name = "South Seas",
	Map =  1,
	Zone =  440, -- Zone name, MapId, ZoneId, AreaId
	Area = 2317, -- Area id 
	Rewards = {1000, 20, {43307, 3}, 25}, -- Copper, Honor, {ItemId, ItemCount}, arena points
	Score = {
		[0] = 0, -- Declare Alliance Score
		[1] = 0, -- Declare Horde Score
	},
};

local function GetTeamName(team_id)

	return World_CTF.team_name[team_id];

end

local function GetApossingTeam(team_id)

	if(team_id == 0)then
		return 1;
	else
		return 0;
	end	
end

local function SendMessage(key, name)

if not(name)then name = ""; end

local msg = { -- messages for zone only announcements
		[0] = "|cff0066CC The Alliance have captured the flag.|r", -- blue for ally
		[1] = "|cff900000 The Horde have captured the flag.|r", -- dark red for horde
		[2] = "|cff0066CC The Alliance have won this round.|r",
		[3] = "|cff900000 The Horde have won this round.|r",
		[4] = "|cff009900 The Flags are returned.|r",
		[5] = "|cff606060 Next round in "..cooldown.." minutes.|r", -- grey
		[6] = "|cff606060 The Battle of "..Zone.Name.." Has started.|r",
		[7] = "|cff606060 The Battle of "..Zone.Name.." is delayed due to lack of players.|r",
		[8] = "|cff009900 Requires |cff000000"..required_players.."|r|cff009900 players per team.|r",
		[9] = "|cff0066CC Alliance:|r|cff000000"..World_CTF.count[0].."|r",
		[10] = "|cff900000 Horde:|r|cff000000"..World_CTF.count[1].."|r",
		[11] = "|cff0066CC The Alliance have rescued there flag.|r",
		[12] = "|cff900000 The Horde have rescued there flag.|r",
		[13] = "|cff0066CC an Alliance player has left the zone.|r",
		[14] = "|cff900000 a Horde player has left the zone.|r",
		[15] = "|cffFF0000 Insufficient players in the zone.|r",
		[16] = "|cff606060 Grumbo'z Portable Capture The Flag System shutting down.|r",
		[17] = "|cff0066CC an Alliance player has joined the zone.|r",
		[18] = "|cff900000 a Horde player has joined the zone.|r",
		[19] = "|cff900000 "..name.."|cff0066CC Has picked up the Alliance flag.",
		[20] = "|cff0066CC "..name.."|cff900000 Has picked up the Horde flag.",
		[21] = "|cff900000 "..name.."|cff0066CC Has dropped the Alliance flag.",
		[22] = "|cff0066CC "..name.."|cff900000 Has dropped the Horde flag.",
};
		
	for _, v in pairs(GetPlayersInMap(Zone.Map))do

		if (v:GetZoneId() == Zone.Zone)then
			v:SendBroadcastMessage(msg[key])
		end
	end
end

local function WorldAnnounce() -- world announcement for advertising
	SendWorldMessage("Join your friends and battle for "..Zone.Name..".")
end

WorldAnnounce()
CreateLuaEvent(WorldAnnounce, Advertise*60000, 0) -- starts a cyclic world broadcast . in minutes

-- *******************
-- * Player Controls *
-- *******************

local function PlayerCount() -- counts all the players in the zone

World_CTF.count[0] = 0;
World_CTF.count[1] = 0;

	for _, v in pairs(GetPlayersInMap(Zone.Map))do

		if((v:GetZoneId() == Zone.Zone)and(v:GetAreaId() == Zone.Area))then
			World_CTF.count[v:GetTeam()] = World_CTF.count[v:GetTeam()] + 1;
		end
	end
	if((World_CTF.count[0] >= required_players)and(World_CTF.count[1] >= required_players))then
		return true;
	else
		return false;
	end
end

local function PenPlayers()
	for _, v in pairs(GetPlayersInMap(Zone.Map))do

		if((v:GetZoneId() == Zone.Zone)and(v:GetAreaId() == Zone.Area))then
			local team_id = v:GetTeam();
			local guid_id = v:GetGUIDLow();
			local x, y, z, o =  table.unpack(team_flag_loc[team_id])
			World_CTF.Group[guid_id] = true;
			v:Teleport(Zone.Map, x+1, y, z, o)
		end
	end
end

-- *****************
-- * Score Control *
-- *****************

local function ClearScore(team_id)

Zone.Score[0] = 0;
Zone.Score[1] = 0;

	for _, v in pairs(GetPlayersInMap(Zone.Map))do

		if((v:GetZoneId() == Zone.Zone)and(v:GetAreaId() == Zone.Area))then
			v:InitializeWorldState(1, 1377, 0, 1) -- Initialize world state, score 0/0
			v:UpdateWorldState(2317, MaxScore) -- Sets correct MaxScore
			v:UpdateWorldState(2313, 0) -- Reset Alliance score when battle resets
			v:UpdateWorldState(2314, 0) -- Reset Horde score when battle resets
		end
	end
end

ClearScore()

local function IncreaseScore(team_id, value)

Zone.Score[team_id] = Zone.Score[team_id] + value;

	for _, v in pairs(GetPlayersInMap(Zone.Map))do

		if((v:GetZoneId() == Zone.Zone)and(v:GetAreaId() == Zone.Area))then
		
			v:UpdateWorldState(2313+team_id, Zone.Score[team_id]) -- Reset Alliance score when battle resets
		end
	end
end

local function GiveRewards(team)
	local MoneyReward = Zone.Rewards[1];
	local HonorReward = Zone.Rewards[2];
	local ItemReward, ItemRewardCount = Zone.Rewards[3][1], Zone.Rewards[3][2];
	local ArenaReward = Zone.Rewards[4];

	for _, v in pairs(GetPlayersInMap(Zone.Rewards[2]))do

		if((v:GetZoneId() == Zone.Zone)and(v:GetAreaId() == Zone.Area))then
		
			if(v:GetTeam() == team)then
			
				if (MoneyReward > 0) then -- Handle Money Reward
					v:ModifyMoney(MoneyReward)
				end
				
				if (HonorReward > 0) then -- Handle Honor Reward
					v:ModifyHonorPoints(HonorReward)
				end
				
				if (ItemReward > 0) and (ItemRewardCount > 0) then -- Handle Item/Token Reward
					v:AddItem(ItemReward, ItemRewardCount)
				end
				
				if(ArenaReward > 0)then -- Handle Arena points Reward
					v:ModifyArenaPoints(ArenaReward)
				end
			end
		end
	end
end

local function RemovePlayerAura(player) 
 	player:RemoveAura(World_CTF.Aura[player:GetTeam()]) 
 end 
 
local function RemoveAllAuras(event, duration, cycle)

	for _, v in pairs(GetPlayersInMap(Zone.Map))do

		if((v:GetZoneId() == Zone.Zone)and(v:GetAreaId() == Zone.Area))then

			if(v:InBattleground() == false)then
				RemovePlayerAura(v)
			end
		end
	end
end

local function PlayerAddAura(player)

	local aura = World_CTF.Aura[player:GetTeam()]
	player:AddAura(aura, player)
end

local function SetFlagHolder(guid, team)

	if(team)then
		World_CTF.player[team] = guid
	end
end

-- ************
-- * SPAWNING *
-- ************

local function RemoveGhostFlag(go)
	go:RemoveFromWorld()
end
	
local function Spawn_Dropped_Flag(player)

local teamP = player:GetTeam();
local teamA = GetApossingTeam(teamP);
local map = Zone.Map;
local x, y, z, o = table.unpack({player:GetX(), player:GetY(), player:GetZ(), player:GetO()})

	World_CTF.Drop[teamA] = true; -- mark team flag as dropped spawned
	gob = PerformIngameSpawn(2, flag_id+teamA, map, 0, x, y, z, o) -- store the go's pointer while spawning it.

	local Gguid = gob:GetGUIDLow();
	
	World_CTF.FLAG[teamA] = Gguid;
	World_CTF.Drop[teamA] = true;
	GO[teamA] = gob;
end

local function Despawn_Team_Flag(event, duration, cycles, go)

go:RemoveEvents()

	if(World_CTF.Gear == 0)then
		go:RemoveFromWorld()
	end
	
	if(World_CTF.Gear ~= 0)then
		go:RegisterEvent(Despawn_Team_Flag, 1000, 1)
	end
end

local function RemoveTeamFlag(go)
	go:RemoveFromWorld()
end
	
local function Spawn_Team_Flag(team_id)

GO[team_id] = nil;

	if(team_id)then

		local x, y, z, o = table.unpack(team_flag_loc[team_id])-- unpacks the table for team flag
	
		go = PerformIngameSpawn(2, flag_id+team_id, Zone.Map, 0, x, y, z, o) -- store the go's pointer while spawning it.
		local Gguid = go:GetGUIDLow()
		World_CTF.FLAG[team_id] = Gguid;
		go:RegisterEvent(Despawn_Team_Flag, 1000, 1)
		GO[team_id] = go;
	end
end

-- ************
-- * Checkers *
-- ************

local function AuraCheck(event, duration, cycle, player)

local team_id = player:GetTeam();
local Pguid = player:GetGUIDLow();
local Pname = player:GetName();
local not_team_id = GetApossingTeam(team_id);
local aura = World_CTF.Aura[team_id];


	if((player:GetMapId() == Zone.Map)and(player:GetZoneId() == Zone.Zone)and(player:GetAreaId() == Zone.Area))then -- if in map/zone

		if(World_CTF.player[team_id] == Pguid)then -- if team flag carrier is player

			if(player:HasAura(aura))then -- if player don't have aura then do next
	
				for a=1,#Blocked_Buffs do
			
					if player:HasAura(Blocked_Buffs[a])then
				
						RemovePlayerAura(player)
						World_CTF.player[team_id] = nil;
						Spawn_Dropped_Flag(player)
						player:RemoveEvents() -- removes any timed events
						SendMessage(21+not_team_id, Pname)
					end
				end
			end
				
			if not(player:HasAura(aura))then -- if player don't have aura then do next
			
				if(World_CTF.player[team_id] == Pguid)then	
				
					player:RemoveEvents() -- removes any timed events
					World_CTF.player[team_id] = nil;
					Spawn_Dropped_Flag(player)
					SendMessage(21+not_team_id, Pname)
					player:RemoveEvents() -- removes any timed events
				end
			end
		end
	end
end

-- *****************
-- * Round Control *
-- *****************

local function Spawn_Flags()
		Spawn_Team_Flag(0)
		Spawn_Team_Flag(1)
		SendMessage(4)
end

local function NEW_Spawn_Flags()

	if(PlayerCount() == true)then
		Spawn_Team_Flag(0)
		Spawn_Team_Flag(1)
		SendMessage(6)
	else
		SendMessage(7)
		SendMessage(8)
		SendMessage(9)
		SendMessage(10)
		CreateLuaEvent(NEW_Spawn_Flags, recheck*60000, 1)
	end
end

-- **************
-- **************
-- ** Proccess **
-- **************
-- **************

local function Proccess()

local Pcount = PlayerCount()

	if(Pcount == true)then

			if(World_CTF.Gear == 2)then 
				World_CTF.Gear = 0; 
			end
			
			if(World_CTF.Gear == 0)then
				PenPlayers()
				SendMessage(8)
				SendMessage(9)
				SendMessage(10)
				SendMessage(5)
				CreateLuaEvent(Proccess, cooldown*60000, 1)
			end
		
			if(World_CTF.Gear == 1)then
				
				PenPlayers()
				NEW_Spawn_Flags()
				CreateLuaEvent(Proccess, round*60000, 1)
			end
	
		World_CTF.Gear = World_CTF.Gear +1;
	
	end
	
	if(Pcount == false)then

		SendMessage(7)
		SendMessage(8)
		SendMessage(9)
		SendMessage(10)
		CreateLuaEvent(Proccess, recheck*1000, 1)
	end
end

-- *****************
-- * Flag Triggers *
-- *****************

local function Tag_Team_Flag(event, player, go)

local Pmap = player:GetMapId();
local Pzone = player:GetZoneId();
local Parea = player:GetAreaId();

	if((player:GetMapId() == Zone.Map)and(player:GetZoneId() == Zone.Zone)and(player:GetAreaId() == Zone.Area))then

	local Pguid = player:GetGUIDLow()
	local team_id = player:GetTeam()
	local team_name = GetTeamName(team_id)
	local Pname = player:GetName();
	local not_flag_team = GetApossingTeam(team_id)
	local Gguid = go:GetGUIDLow()
	local aura  = World_CTF.Aura[team_id]
	

		if(Gguid ~= World_CTF.FLAG[0])then -- checks if go pointer NOT same as stored pointers
			if(Gguid ~= World_CTF.FLAG[1])then -- checks if go pointer NOT same as stored pointers
				RemoveGhostFlag(go) -- if go pointer NOT same as stored then despawn the ghost flag
			end
		end
		
		if(Gguid == World_CTF.FLAG[not_flag_team])then -- is appossing team flag

			World_CTF.player[team_id] = Pguid;
			player:RemoveEvents()
			go:Despawn()
			RemoveTeamFlag(go, not_flag_team)
			PlayerAddAura(player)
			SendMessage(19+not_flag_team , Pname)
			player:RegisterEvent(AuraCheck, 1000, 0)
			player:PlaySoundToPlayer(sound_id1)
		end
		
		if(Gguid == World_CTF.FLAG[team_id])then -- if flag guid is players team flag guid

			if(World_CTF.Drop[team_id] == true)then -- if flag is a captureable dropped flag
				World_CTF.Drop[team_id] = nil;
				go:Despawn()
				RemoveTeamFlag(go, team_id)
				SendMessage(11+team_id)
				Spawn_Team_Flag(team_id)
			end
						
			if(player:HasAura(aura))then --if player has aura

				if(World_CTF.player[team_id] == Pguid)then -- if player is true flag carrier
	
					
					player:RemoveEvents()
					RemovePlayerAura(player)
					IncreaseScore(team_id, 1)
					
								
						if(Zone.Score[team_id] < MaxScore)then -- if under Max Score
							SendMessage(team_id)
							Spawn_Team_Flag(not_flag_team)
						end

						if(Zone.Score[team_id] >= MaxScore)then -- reach max score
							RemoveTeamFlag(go)
							RemoveAllAuras()
							GiveRewards(team_id)
							CreateLuaEvent(ClearScore, rest*60000, 1)
							SendMessage(2+team_id)
							SendMessage(5)
							World_CTF.Gear = 0;
							CreateLuaEvent(Proccess, rest*60000, 1)
						end

					World_CTF.player[team_id] = nil;
					player:PlaySoundToPlayer(sound_id2)
				end
			end
		end
	end
end

RegisterGameObjectGossipEvent(flag_id, 1, Tag_Team_Flag)
RegisterGameObjectGossipEvent(flag_id+1, 1, Tag_Team_Flag)

-- **************
-- * Catch 22's *
-- **************

local function clear_aura(event, player)

local team_id = player:GetTeam()

	if((player:GetMapId() == Zone.Map)and(player:GetZoneId() == Zone.Zone)and(player:GetAreaId() == Zone.Area))then
	
		if(event == 36)then
			local x, y, z, o =  table.unpack(team_flag_loc[team_id])
			player:Teleport(Zone.Map, x+1, y, z, o)
		end
		
		RemovePlayerAura(player)
	end
end

RegisterPlayerEvent(3, clear_aura) -- login
RegisterPlayerEvent(36, clear_aura) -- revive

local function Return_Flag(event, a, b)

if(event == (6 or 8))then player = b else player = a; end

	if((player:GetMapId() == Zone.Map)and(player:GetZoneId() == Zone.Zone)and(player:GetAreaId() == Zone.Area))then

local team_id = player:GetTeam();
local guid_id = player:GetGUIDLow();
local Pname = player:GetName();
local not_team_id = GetApossingTeam(team_id)
local Pcount = GetPlayerCount();

		if(event == (6 or 8))then 

				if(World_CTF.player[team_id] == guid_id)then

					Spawn_Dropped_Flag(player)
					World_CTF.player[team_id] = nil;
					SendMessage(21+not_team_id, Pname)
				end
		end
		
		if(event == 4)then

			player:RemoveEvents()

			if(guid_id == World_CTF.player[team_id])then
				World_CTF.player[team_id] = nil;
				Spawn_Team_Flag(player)
				SendMessage(21+not_team_id, Pname)
			end

			if(Pcount)then
				SendMessage(13+team_id , Pname)
			end
			
			if not(Pcount)then -- if not enough players now
	
				RemoveAllAuras()
				World_CTF.Gear = 0;
				SendMessage(13 + team_id)
				SendMessage(15)
				SendMessage(16)
				ClearScore(0)
				ClearScore(1)
	
					for a=1,#GO do
						if(GO[a])then
							GO[a]:Despawn()
							GO[a] = nil;
						end
					Proccess()
					end
			end
		end
		
		World_CTF.player[team_id] = nil;
	end
end

RegisterPlayerEvent(4, Return_Flag) -- logout
RegisterPlayerEvent(6, Return_Flag) -- die by plr
RegisterPlayerEvent(8, Return_Flag) -- die by npc

local function EnterArea(event, player, newZone, newArea)

local Pmap = player:GetMapId();
local Pzone = player:GetZoneId();
local Parea = player:GetAreaId();
local team_id = player:GetTeam();
local guid_id = player:GetGUIDLow();
local Pname = player:GetName();

local not_team_id = GetApossingTeam(team_id)

	if((Pmap == Zone.Map)and(Pzone == Zone.Zone)and(Parea == Zone.Area))then
		player:InitializeWorldState(1, 1377, 0, 1) -- Initialize world state, score 0/0
		player:UpdateWorldState(2317, MaxScore) -- Sets correct MaxScore
		player:UpdateWorldState(2313, Zone.Score[0]) -- Set correct Alliance score
		player:UpdateWorldState(2314, Zone.Score[1]) -- Set correct Horde score

			if(World_CTF.player[team_id] == guid_id)then
				PlayerAddAura(player)
			end
			
			if not(World_CTF.Group[guid_id])then 
				SendMessage(17 + team_id)
				local x, y, z, o =  table.unpack(team_flag_loc[team_id])
				World_CTF.Group[guid_id] = true;
				player:Teleport(Zone.Map, x+1, y, z, o)
				player:PlaySoundToPlayer(sound_id4)
			end
	return false;
	end

	if not((Pmap == Zone.Map)or(Pzone == Zone.Zone)or(Parea == Zone.Area))then
		
		if(World_CTF.Group[guid_id])then 
		
			local Pcount = PlayerCount()
			World_CTF.Group[guid_id] = false;
	
				if(World_CTF.player[team_id])then
				
					if(World_CTF.player[team_id] == guid_id)then
						World_CTF.player[team_id] = nil;
						Spawn_Team_Flag(not_team_id)
						SendMessage(21+not_team_id, Pname)
					end
				end
				
	
				if(Pcount == true)then
					SendMessage(13 + team_id)
				end
				
				if(Pcount == false)then
				
					if(World_CTF.Gear > 0)then
					
						RemoveAllAuras()
						World_CTF.Gear = 0;
						SendMessage(13 + team_id)
						SendMessage(15)
						SendMessage(16)
						ClearScore(0)
						ClearScore(1)
		
							for a=1,#GO do
								if(GO[a])then
									GO[a]:Despawn()
									GO[a] = nil;
								end
							Proccess()
							end
					end
				end
			end
	end
end

RegisterPlayerEvent(27, EnterArea)

	if(CTF == 0)then
		print("**          System idle.         **")
		print(" *********************************\n")
	end
	
	if(CTF == 1)then 
	 	print("**          System Ready.        **") 
		print(" *********************************\n")
		Proccess()
	 end
