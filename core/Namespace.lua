local _, ns = ...

-- Disable cleanly if Anniversary Achievements is missing or too old.
if not (CA_Database and CA_Loader and CA_Criterias and CA_CompletionManager
        and AnniversaryAchievements_GetAchievementFrame) then
    ns.disabled = true
    DEFAULT_CHAT_FRAME:AddMessage('|cffff4040Midventures Achievements:|r requires Anniversary Achievements - disabled.')
    return
end

ns.TAB_ID = 4               -- next free CA_Database tab after player/guild/stats
ns.ID_OFFSET = 510000       -- reserved id range for our categories, achievements and criteria
ns.TAB_LABEL = 'Midventures'
ns.POINTS_LABEL = 'Midi Points'
ns.ANNIVERSARY_LABEL = 'Achievement Points'

-- Leaderboard sidebar rows are fake categories, kept below ID_OFFSET so ns.Owns ignores them.
ns.LEADERBOARD_ID_BASE = 400000
ns.LEADERBOARD_LABEL = 'Leaderboard'
ns.SECTION_ANNIVERSARY = 'A'
ns.SECTION_MIDVENTURES = 'M'
ns.COMM_PREFIX = 'MVACH'

-- Our own criteria types, each registered and fired by the core file named beside it.
ns.GUILD_NAME = 'Dentventures'
ns.CRITERIA_GUILD = 5001          -- Guild.lua, member of GUILD_NAME
ns.CRITERIA_GUILD_DUEL = 5002     -- GuildDuels.lua, duel won against a guildmate
ns.CRITERIA_GUILD_CHAT = 5003     -- GuildChat.lua, message sent in guild chat
ns.CRITERIA_GUILD_RUN = 5004      -- GuildDungeons.lua, dungeon completed with a guild party
-- 5005 was GuildDungeons.lua's clear-every-boss criteria, retired with its achievements.
ns.CRITERIA_POSITION = 5006       -- Position.lua, standing on a spot
ns.CRITERIA_ZONE_BELOW_LEVEL = 5007 -- ZoneLevel.lua, in an area under a level
ns.CRITERIA_TIER_SET = 5008       -- TierSet.lua, wearing a full dungeon set in an area
ns.CRITERIA_CRIT_ABOVE = 5009     -- CritStrike.lua, a critical strike of at least so much
ns.CRITERIA_EQUIPMENT = 5010      -- Equipment.lua, what is worn in a slot
ns.CRITERIA_BUFF_PLAYERS = 5011   -- Buffs.lua, a helpful spell landed on another player
ns.CRITERIA_EMOTE_AT = 5012       -- Emotes.lua, an emote aimed at something
ns.CRITERIA_DANCE_PARTY = 5013    -- Emotes.lua, guildmates dancing together
ns.CRITERIA_GUILD_NAMED = 5014    -- GuildChat.lua, a guildmate named in guild chat
ns.CRITERIA_GUILD_CHAT_ZONE = 5015 -- GuildChat.lua, messages sent from one area
ns.CRITERIA_GUILD_ONLINE = 5016   -- GuildPresence.lua, guildmates online at once
ns.CRITERIA_GUILD_GROUPED = 5017  -- GuildPresence.lua, different guildmates grouped with
ns.CRITERIA_DEATHS = 5018         -- Deaths.lua, times died
ns.CRITERIA_DEATH_CAUSE = 5019    -- Deaths.lua, what killed you
ns.CRITERIA_CORPSE_RUNS = 5020    -- Deaths.lua, walked back to the body
ns.CRITERIA_WIPE = 5021           -- Deaths.lua, the whole group down together
ns.CRITERIA_LEEROY = 5022         -- Deaths.lua, died moments after pulling in a dungeon
ns.CRITERIA_DEATHLESS_LEVEL = 5023 -- Deaths.lua, reached a level without dying
ns.CRITERIA_DEATH_WITH_HEALER = 5024 -- Deaths.lua, died with a guild healer in the group
ns.CRITERIA_BIG_FALL = 5025       -- Deaths.lua, survived a fall of at least so much
ns.CRITERIA_RESURRECTS = 5026     -- CombatExtras.lua, guildmates brought back
ns.CRITERIA_INTERRUPTS = 5027     -- CombatExtras.lua, casts interrupted
ns.CRITERIA_DISPELS = 5028        -- CombatExtras.lua, effects dispelled
ns.CRITERIA_OVERKILL = 5029       -- CombatExtras.lua, a killing blow with room to spare
ns.CRITERIA_SURVIVE_LOW = 5030    -- CombatExtras.lua, walked out of a dungeon fight at 5%
ns.CRITERIA_FASHION_KILL = 5031   -- CombatExtras.lua, a kill made wearing nothing useful
ns.CRITERIA_PACIFIST = 5032       -- CombatExtras.lua, a level reached on few kills
ns.CRITERIA_EAT = 5033            -- Consumables.lua, meals eaten
ns.CRITERIA_DRINK = 5034          -- Consumables.lua, drinks drunk
ns.CRITERIA_ALCOHOL = 5035        -- Consumables.lua, of those, the alcoholic ones
ns.CRITERIA_CONSUME_ITEM = 5036   -- Consumables.lua, {itemID} eaten or drunk
ns.CRITERIA_FLIGHTS = 5037        -- Travel.lua, flight paths taken
ns.CRITERIA_HEARTHS = 5038        -- Travel.lua, hearthstones used
ns.CRITERIA_TRANSPORT = 5039      -- Travel.lua, boat and zeppelin rides
ns.CRITERIA_SUMMONED = 5040       -- Travel.lua, summons accepted
ns.CRITERIA_VENDOR_SALES = 5041   -- Money.lua, items sold to a vendor
ns.CRITERIA_AUCTIONS = 5042       -- Money.lua, auctions posted
ns.CRITERIA_BAGS_FULL = 5043      -- Money.lua, not one free slot
ns.CRITERIA_MONEY = 5044          -- Money.lua, {copper} carried at once
ns.CRITERIA_BROKE = 5045          -- Money.lua, rich once, skint now
ns.CRITERIA_LOW_DURABILITY = 5046 -- Equipment.lua, {items} worn through
ns.CRITERIA_NAKED_RUN = 5047      -- Equipment.lua, two cities with nothing on
ns.CRITERIA_ZONE_VISIT = 5048     -- Zones.lua, {areaID} set foot in
ns.CRITERIA_UNARMED_HITS = 5049   -- CombatExtras.lua, melee landed with empty hands
ns.CRITERIA_QUEST_GUILD = 5050    -- Quests.lua, a quest handed in beside a guildmate
ns.CRITERIA_QUEST_BUDDIES = 5051  -- Quests.lua, different guildmates quested with
ns.CRITERIA_QUEST_ABANDON = 5052  -- Quests.lua, quests given up on
ns.CRITERIA_QUEST_LOG_FULL = 5053 -- Quests.lua, a quest log with no room left
ns.CRITERIA_QUEST_NO_XP = 5054    -- Quests.lua, quests handed in for no experience
ns.CRITERIA_QUEST_IN_ZONE = 5055  -- Quests.lua, a quest handed in in {areaID}
ns.CRITERIA_QUEST_BELOW_LEVEL = 5056 -- Quests.lua, a quest in {areaID} under {level}
ns.CRITERIA_GUILD_RAID = 5057     -- GuildRaids.lua, a raid boss down with enough of us there
ns.CRITERIA_BG_WIN_GUILD = 5058   -- Battlegrounds.lua, a win with {guildmates} of ours in
ns.CRITERIA_BG_LOSSES = 5059      -- Battlegrounds.lua, battlegrounds lost
ns.CRITERIA_BG_DEATHS = 5060      -- Battlegrounds.lua, deaths in a battleground
ns.CRITERIA_BG_CARRIED = 5061     -- Battlegrounds.lua, a win with an empty scoreboard
ns.CRITERIA_ARENA_GUILD = 5062    -- Battlegrounds.lua, an arena won by an all-guild team
ns.CRITERIA_ARENA_LOSSES = 5063   -- Battlegrounds.lua, arena matches lost
ns.CRITERIA_DUEL_PARTNERS = 5064  -- GuildDuels.lua, different guildmates duelled
ns.CRITERIA_DUEL_MASTER = 5065    -- GuildDuels.lua, the guild master beaten
ns.CRITERIA_DUEL_LOSSES = 5066    -- GuildDuels.lua, duels lost to guildmates
ns.CRITERIA_GATHER = 5067         -- Gathering.lua, {kind} gathered from the world
ns.CRITERIA_CRAFTED = 5068        -- Crafting.lua, items made
ns.CRITERIA_DISENCHANTS = 5069    -- Crafting.lua, items taken apart
ns.CRITERIA_GUILD_TRADES = 5070   -- Crafting.lua, trades finished with a guildmate
ns.CRITERIA_ENCHANT_GUILD = 5071  -- Crafting.lua, a guildmate's gear enchanted
ns.CRITERIA_BANDAGE_GUILD = 5072  -- FirstAid.lua, guildmates patched up
ns.CRITERIA_BANDAGE_LOW = 5073    -- FirstAid.lua, bandaged yourself at death's door
ns.CRITERIA_JUNK_FISH = 5074      -- Fishing.lua, rubbish pulled out of the water
ns.CRITERIA_REP_HATED = 5075      -- Reputation.lua, Hated with {factionID}, 0 for any
ns.CRITERIA_GUILD_RUNS = 5076     -- GuildDungeons.lua, guild dungeon runs finished
ns.CRITERIA_RUN_FLAWLESS = 5077   -- GuildDungeons.lua, a run where nobody went down
ns.CRITERIA_RUN_CLASSES = 5078    -- GuildDungeons.lua, a run of five different classes
ns.CRITERIA_GOLD_HELD = 5079      -- Money.lua, copper carried right now
ns.CRITERIA_EMOTE_AT_SPOT = 5080  -- Emotes.lua, {emote token, spot key} performed on the spot
ns.CRITERIA_QUEST_NIGHT = 5081    -- Quests.lua, quests handed in in the small hours

ns.active = false           -- true while the Midventures view is on screen
ns.leaderboard = false      -- true while the leaderboard view is on screen
ns.achievements = {}        -- short name -> achievement, for metas and the summary
ns.commands = {}            -- /midv word -> handler, filled by the file that owns it

function ns.Print(message)
    DEFAULT_CHAT_FRAME:AddMessage('|cff00ff00MidventuresAchievements:|r ' .. message)
end

-- All our ids sit above the offset.
function ns.Owns(achievementID)
    return achievementID ~= nil and achievementID >= ns.ID_OFFSET
end

MidventuresAchievements = ns
