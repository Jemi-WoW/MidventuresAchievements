local _, ns = ...
if ns.disabled then return end

local db = CA_Database

-- Points, counters and recent lists all pick their tab through GetTabSpecial.
local baseGetTabSpecial = db.GetTabSpecial

function db:GetTabSpecial(isGuildView)
    if ns.active then return self:GetTab(ns.TAB_ID) end
    return baseGetTabSpecial(self, isGuildView)
end

-- Midi Points, whichever view is open.
function ns.GetPoints()
    local points = 0
    local completion = CA_CompletionManager:GetLocal()
    for _, category in pairs(ns.tab:GetCategories()) do
        for id, achievement in pairs(category:GetAchievements()) do
            if completion:IsAchievementCompleted(id) then
                points = points + achievement.points
            end
        end
    end
    return points
end
