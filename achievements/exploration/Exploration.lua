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

local exploration = ns.categories.exploration

-- The eight valleys every character wakes up in. Anniversary only ever asks for whole
-- zones, so the starting subzones are ours to use.
local STARTING_ZONES = {
    9,    -- Northshire Valley
    132,  -- Coldridge Valley
    188,  -- Shadowglen
    154,  -- Deathknell
    3526, -- Ammen Vale
    363,  -- Valley of Trials
    220,  -- Red Cloud Mesa
    3431, -- Sunstrider Isle
}

A.ONE_SMALL_STEP = zone(exploration, 'One Small Step',
    'Set foot in every starting zone in the game.', 20, 'inv_misc_map02', STARTING_ZONES)

-- Booty Bay is the far end of a long boat ride, and 35 is well past the level the zone
-- around it is built for, so getting there early is the whole point.
A.BOOTY_BAY_TOURIST = ns.Achievement(easternKingdoms, {
    name   = 'Booty Bay Tourist',
    desc   = 'Visit Booty Bay before level 35.',
    points = 10,
    icon   = 'stranglethorn_valley',
    criteria = {
        -- Area 35 is Booty Bay itself, the 35 after it is the level to still be under.
        { ns.CRITERIA_ZONE_BELOW_LEVEL, {35, 35}, nil, 'Booty Bay before level 35' },
    },
})

-- Coordinates read off the summit itself, so they are the thing to correct if the criteria
-- never lands. Ironforge's own map is accepted too, in case the peak reads as the city.
A.MOUNTAIN_GOAT = ns.Achievement(easternKingdoms, {
    name   = 'Mountain Goat',
    desc   = 'Reach the summit of Ironforge Mountain.',
    points = 15,
    icon   = 'dun_morogh',
    criteria = {
        { ns.CRITERIA_POSITION, {ns.Spot('IRONFORGE_SUMMIT', {
            zones = {1, 1537}, x = 64.0, y = 26.35, radius = 2,
        })}, nil, 'Summit of Ironforge Mountain' },
    },
})

-- Tier 0.5 was the best gear in the game right up until the portal opened, at which point
-- quest greens beat it. Wearing the full set through it is the joke.
A.YOU_WERE_PREPARED = ns.Achievement(outland, {
    name   = 'YOU WERE PREPARED',
    desc   = 'Step through the Dark Portal in Tier 0.5 head, shoulders, chest, legs '
          .. 'and gloves.',
    points = 25,
    icon   = 'hellfire_peninsula',
    criteria = {
        { ns.CRITERIA_TIER_SET, {3483}, nil, 'In Hellfire Peninsula in Tier 0.5' },
    },
})
