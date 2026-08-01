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

-- The community guild, and our own criteria type for being in it.
ns.GUILD_NAME = 'Dentventures'
ns.CRITERIA_GUILD = 5001

ns.active = false           -- true while the Midventures view is on screen
ns.leaderboard = false      -- true while the leaderboard view is on screen
ns.achievements = {}        -- short name -> achievement, for metas and the summary

-- All our ids sit above the offset.
function ns.Owns(achievementID)
    return achievementID ~= nil and achievementID >= ns.ID_OFFSET
end

MidventuresAchievements = ns
