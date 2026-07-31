local _, ns = ...

-- Disable cleanly if Anniversary Achievements is missing or too old.
if not (CA_Database and CA_Loader and CA_Criterias and CA_CompletionManager
        and AnniversaryAchievements_GetAchievementFrame) then
    ns.disabled = true
    DEFAULT_CHAT_FRAME:AddMessage('|cffff4040Midventures Achievements:|r requires Anniversary Achievements - disabled.')
    return
end

ns.TAB_ID = 4               -- next free CA_Database tab after player/guild/stats
ns.ID_OFFSET = 500000       -- reserved id range for our categories, achievements and criteria
ns.TAB_LABEL = 'Midventures'
ns.POINTS_LABEL = 'Midi Points'

ns.active = false           -- true while the Midventures view is on screen
ns.achievements = {}        -- short name -> achievement, for metas and the summary

-- All our ids sit above the offset.
function ns.Owns(achievementID)
    return achievementID ~= nil and achievementID >= ns.ID_OFFSET
end

MidventuresAchievements = ns
