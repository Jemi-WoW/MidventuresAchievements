local _, ns = ...
if ns.disabled then return end

local TYPE = CA_Criterias.TYPE
local A = ns.achievements
local easternKingdoms = ns.categories.explorationEasternKingdoms
local kalimdor, outland = ns.categories.explorationKalimdor, ns.categories.explorationOutland

-- How to write these: .AchievementGuide/Exploration.md
-- Append new achievements at the bottom, ids are handed out in load order.

-- Expands a subzone id list into one criteria each, named from AreaTableLocale.
-- Args: category, name, desc, points, icon, areaIDs.
local function zone(category, name, desc, points, icon, areaIDs)
    local criteria = {}
    for i, areaID in ipairs(areaIDs) do
        criteria[i] = { TYPE.EXPLORE_AREA, {areaID}, nil, AreaTableLocale[areaID] }
    end
    return ns.Achievement(category, {
        name = name, desc = desc, points = points, icon = icon, criteria = criteria,
    })
end

-- Anniversary already has an Explore achievement for every single zone, with the same
-- subzone lists, so a plain one duplicates it. Combine zones or gate on theirs instead:
--   meta = { ns.Anniversary('AN_EXPLORE', AreaTableLocale[12]) }
