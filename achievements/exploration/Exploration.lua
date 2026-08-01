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

A.WOODS_OF_ELWYNN = zone(easternKingdoms, 'Woods of Elwynn', 'Explore Elwynn Forest.', 10,
    '-Inv_Mushroom_11',
    {87, 9, 1519, 57, 797, 60, 62, 91, 798, 88, 86, 18})

A.FRESH_OFF_THE_SLAB = zone(easternKingdoms, 'Fresh Off the Slab', 'Explore Tirisfal Glades.', 10,
    '-Spell_Shadow_DeathScream',
    {156, 154, 810, 157, 166, 811, 164, 159, 165, 162, 459, 167, 812, 160, 1497, 152})

A.RED_SANDS = zone(kalimdor, 'Red Sands', 'Explore Durotar.', 10,
    '-Spell_Fire_Lavaspawn',
    {367, 366, 368, 372, 362, 816, 369, 370, 817, 1637, 363})

A.AMONG_THE_BRANCHES = zone(kalimdor, 'Among the Branches', 'Explore Teldrassil.', 10,
    '-Ability_Racial_Shadowmeld',
    {736, 186, 261, 259, 478, 260, 264, 266, 1657, 702, 188})
