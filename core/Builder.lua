local _, ns = ...
if ns.disabled then return end

local criterias = CA_Criterias

-- ns.Achievement / ns.Category. Fields: .AchievementGuide/README.md.
local ACHIEVEMENTS_PER_CATEGORY = 1000
local CRITERIA_PER_CATEGORY = 10000

local blocks = 0

-- Categories, achievements and criteria have separate id registries.
function ns.Category(name, parent)
    local category = ns.tab:CreateCategory(name, parent and parent.id, false, ns.ID_OFFSET + blocks)
    category.mvAchievementID = ns.ID_OFFSET + blocks * ACHIEVEMENTS_PER_CATEGORY
    category.mvCriteriaID = ns.ID_OFFSET + blocks * CRITERIA_PER_CATEGORY
    blocks = blocks + 1
    return category
end

local function addCriteria(category, achievement, type, data, quantity, name)
    local criteria = criterias:Create(name, type, data, quantity, category.mvCriteriaID)
    if not criteria then
        error(('Midventures: bad criteria on "%s" (type %s)'):format(achievement.name, tostring(type)))
    end
    category.mvCriteriaID = category.mvCriteriaID + 1
    achievement:AddCriteria(criteria)
end

-- Builds one achievement from a def table.
function ns.Achievement(category, def)
    local achievement = category:CreateAchievement(
        def.name, def.desc, def.points, def.icon, false, category.mvAchievementID)
    category.mvAchievementID = category.mvAchievementID + 1

    for _, c in ipairs(def.criteria or {}) do
        addCriteria(category, achievement, c[1], c[2], c[3], c[4])
    end
    for _, sub in ipairs(def.meta or {}) do
        addCriteria(category, achievement, criterias.TYPE.COMPLETE_ACHIEVEMENT, {sub.id}, nil, sub.name)
    end

    if def.previous then def.previous:SetNext(achievement) end
    if def.reward then achievement:SetRewardText(def.reward) end
    if def.anyCompletable then achievement:SetAnyCompletable() end

    -- Both deactivate the criteria above, so they run after them.
    if def.faction == 'Horde' then
        achievement:SetHordeOnly()
    elseif def.faction == 'Alliance' then
        achievement:SetAllianceOnly()
    elseif def.faction then
        error(('Midventures: "%s" has faction "%s", expected Horde or Alliance')
            :format(def.name, tostring(def.faction)))
    end
    if def.unavailable then achievement:SetUnavailable() end

    return achievement
end
