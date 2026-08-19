local _, ns = ...
if ns.disabled then return end

-- Anniversary only matches the name, so a word from a description finds nothing.
local db = CA_Database

local results, ranks = {}, {}

local function completed(id)
    return CA_CompletionManager:GetLocal():IsAchievementCompleted(id)
end

-- The same rung rule the category lists use, so search shows what browsing would.
local function visible(achievement)
    if not achievement:IsAvailable() then return false end

    if completed(achievement.id) then
        local nextID = achievement:GetNextID()
        return not nextID or not completed(nextID)
    end

    if achievement.points == 0 then return false end
    local previousID = achievement:GetPreviousID()
    return not previousID or completed(previousID)
end

local function holds(text, within)
    return within ~= nil and within:lower():find(text, 1, true) ~= nil
end

-- Lower is a closer match, and ranks the list.
local function rank(achievement, text)
    if holds(text, achievement.name) then return 1 end
    if holds(text, achievement.description) then return 2 end
    if holds(text, achievement:GetRewardText()) then return 3 end

    for _, criteria in pairs(achievement:GetCriterias()) do
        if holds(text, criteria.name) then return 3 end
    end
end

function SetAchievementSearchString(text)
    results, ranks = {}, {}

    text = (text or ''):lower()
    if text == '' then return true end

    for _, category in pairs(db:GetSelectedTab():GetCategories()) do
        for _, achievement in pairs(category:GetAchievements()) do
            local place = visible(achievement) and rank(achievement, text)
            if place then
                results[#results + 1] = achievement
                ranks[achievement] = place
            end
        end
    end

    table.sort(results, function(a, b)
        if ranks[a] ~= ranks[b] then return ranks[a] < ranks[b] end
        local doneA, doneB = completed(a.id), completed(b.id)
        if doneA ~= doneB then return doneA end
        return a.id < b.id
    end)

    return true
end

function GetNumFilteredAchievements()
    return #results
end

function GetFilteredAchievementID(index)
    local achievement = results[index]
    return achievement and achievement.id
end
