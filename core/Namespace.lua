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

-- The community guild, and our own criteria types for the things Anniversary cannot see.
-- Each is registered by the core file named beside it, which also fires it.
ns.GUILD_NAME = 'Dentventures'
ns.CRITERIA_GUILD = 5001          -- Guild.lua, member of GUILD_NAME
ns.CRITERIA_GUILD_DUEL = 5002     -- GuildDuels.lua, duel won against a guildmate
ns.CRITERIA_GUILD_CHAT = 5003     -- GuildChat.lua, message sent in guild chat
ns.CRITERIA_GUILD_RUN = 5004      -- GuildDungeons.lua, dungeon completed with a guild party
ns.CRITERIA_GUILD_CLEAR = 5005    -- GuildDungeons.lua, dungeon cleared with a guild party
ns.CRITERIA_POSITION = 5006       -- Position.lua, standing on a spot
ns.CRITERIA_ZONE_BELOW_LEVEL = 5007 -- ZoneLevel.lua, in an area under a level
ns.CRITERIA_TIER_SET = 5008       -- TierSet.lua, wearing a full dungeon set in an area
ns.CRITERIA_CRIT_ABOVE = 5009     -- CritStrike.lua, a critical strike of at least so much

ns.active = false           -- true while the Midventures view is on screen
ns.leaderboard = false      -- true while the leaderboard view is on screen
ns.achievements = {}        -- short name -> achievement, for metas and the summary

-- All our ids sit above the offset.
function ns.Owns(achievementID)
    return achievementID ~= nil and achievementID >= ns.ID_OFFSET
end

MidventuresAchievements = ns
