local _, ns = ...
if ns.disabled then return end

local TYPE = CA_Criterias.TYPE
local exploration, A = ns.categories.exploration, ns.achievements

-- How to write these: .AchievementGuide/Exploration.md
-- Append new achievements at the bottom, ids are handed out in load order.

-- Expands a subzone id list into one criteria each, named from AreaTableLocale.
-- Args: name, desc, points, icon, areaIDs.
local function zone(name, desc, points, icon, areaIDs)
    local criteria = {}
    for i, areaID in ipairs(areaIDs) do
        criteria[i] = { TYPE.EXPLORE_AREA, {areaID}, nil, AreaTableLocale[areaID] }
    end
    return ns.Achievement(exploration, {
        name = name, desc = desc, points = points, icon = icon, criteria = criteria,
    })
end
