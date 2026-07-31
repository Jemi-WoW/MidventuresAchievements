local _, ns = ...
if ns.disabled then return end

local db = CA_Database

-- Fourth tab in Anniversary's database.
-- Its factories are closures over `self`, so borrowing them registers our content globally.
local template = db:GetTab(db.TAB_ID_PLAYER)

local tab = {
    id = ns.TAB_ID,
    categories = {},
    CreateCategory = template.CreateCategory,
    GetCategory = template.GetCategory,
    GetCategories = template.GetCategories,
}

-- Fake category the UI uses for the Summary entry (id -1).
tab.summaryCategory = {
    id = -1,
    name = 'summary',
    parentID = -1,
    GetAchievement = function(self, id)
        return db:GetAchievement(id)
    end,
    GetAchievements = function(self)
        local result = {}
        for _, category in pairs(tab.categories) do
            for id, achievement in pairs(category:GetAchievements()) do
                result[id] = achievement
            end
        end
        return result
    end,
}

db.tabs[ns.TAB_ID] = tab

ns.tab = tab
