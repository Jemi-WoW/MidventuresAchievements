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

local trespassing, landmarks =
    ns.categories.explorationTrespassing, ns.categories.explorationLandmarks

-- Walking into the other side's front room. The guards disagree, which is the point, so
-- each of these only exists for the faction with no business being there.
local function capital(name, desc, areaID, faction)
    return ns.Achievement(trespassing, {
        name = name, desc = desc, points = 25, icon = 'inv_misc_map02', faction = faction,
        criteria = {
            { ns.CRITERIA_ZONE_VISIT, {areaID}, nil, AreaTableLocale[areaID] },
        },
    })
end

A.CATHEDRAL_CRASHER = capital('Cathedral Crasher',
    'Set foot in Stormwind City and live to tell it.', 1519, 'Horde')
A.UNDER_THE_MOUNTAIN = capital('Under the Mountain',
    'Set foot in Ironforge and live to tell it.', 1537, 'Horde')
A.TREE_HUGGER = capital('Tree Hugger',
    'Set foot in Darnassus and live to tell it.', 1657, 'Horde')
A.EXODAR_EXCURSION = capital('Exodar Excursion',
    'Set foot in The Exodar and live to tell it.', 3557, 'Horde')

A.HOLD_THE_HOLD = capital('Hold the Hold',
    'Set foot in Orgrimmar and live to tell it.', 1637, 'Alliance')
A.HIGH_PLAINS_DRIFTER = capital('High Plains Drifter',
    'Set foot in Thunder Bluff and live to tell it.', 1638, 'Alliance')
A.DOWN_AMONG_THE_DEAD = capital('Down Among the Dead',
    'Set foot in Undercity and live to tell it.', 1497, 'Alliance')
A.SUNSTRIDER_SIGHTSEEING = capital('Sunstrider Sightseeing',
    'Set foot in Silvermoon City and live to tell it.', 3487, 'Alliance')

-- All eight cities are built so the ids never move, but only one set is ever reachable, so
-- the meta asks for whichever four are the enemy's.
local ENEMY_CAPITALS = UnitFactionGroup('player') == 'Horde'
    and { A.CATHEDRAL_CRASHER, A.UNDER_THE_MOUNTAIN, A.TREE_HUGGER, A.EXODAR_EXCURSION }
    or { A.HOLD_THE_HOLD, A.HIGH_PLAINS_DRIFTER, A.DOWN_AMONG_THE_DEAD,
         A.SUNSTRIDER_SIGHTSEEING }

A.UNINVITED_GUEST = ns.Achievement(trespassing, {
    name   = 'Uninvited Guest',
    desc   = 'Walk into all four of the enemy\'s cities.',
    points = 50,
    icon   = 'achievement_zone_easternkingdoms',
    meta   = ENEMY_CAPITALS,
})

-- Zones you have no business in yet. Booty Bay Tourist above is the first of these.
local function tooEarly(name, desc, points, icon, areaID, level)
    return ns.Achievement(trespassing, {
        name = name, desc = desc, points = points, icon = icon,
        criteria = {
            { ns.CRITERIA_ZONE_BELOW_LEVEL, {areaID, level},
                nil, ('%s before level %d'):format(AreaTableLocale[areaID], level) },
        },
    })
end

A.CHILLED_OUT = tooEarly('Chilled Out',
    'Reach Winterspring before level 40.', 15, 'winterspring', 618, 40)
A.PLAGUE_BEARER = tooEarly('Plague Bearer',
    'Reach the Eastern Plaguelands before level 45.', 15, 'eastern_plaguelands', 139, 45)
A.SANDSTORM_TOURIST = tooEarly('Sandstorm Tourist',
    'Reach Silithus before level 50.', 15, 'silithus', 1377, 50)
A.NOT_READY_FOR_THIS = tooEarly('Not Ready For This',
    'Reach Shattrath City before level 58.', 25, 'terokkar_forest', 3703, 58)

A.YOU_SHOULDNT_BE_HERE = ns.Achievement(trespassing, {
    name   = 'You Shouldn\'t Be Here',
    desc   = 'Turn up everywhere long before anyone expected you.',
    points = 40,
    icon   = 'inv_misc_map_01',
    meta = {
        A.BOOTY_BAY_TOURIST,
        A.CHILLED_OUT,
        A.PLAGUE_BEARER,
        A.SANDSTORM_TOURIST,
        A.NOT_READY_FOR_THIS,
    },
})

-- Places worth standing in for their own sake. Anniversary asks for whole zones uncovered,
-- never for one spot, so these are ours.
local function landmark(name, desc, points, icon, areaID)
    return ns.Achievement(landmarks, {
        name = name, desc = desc, points = points, icon = icon,
        criteria = {
            { ns.CRITERIA_ZONE_VISIT, {areaID}, nil, AreaTableLocale[areaID] },
        },
    })
end

A.SCARAB_WALL = landmark('Scarab Wall',
    'Stand at the Gates of Ahn\'Qiraj and read the wall.', 15, 'silithus', 3478)
A.INTO_THE_MOUNTAIN = landmark('Into the Mountain',
    'Walk into Blackrock Mountain, chain bridge and all.', 15, 'burning_steppes', 25)
A.VOLCANO_DIVER = landmark('Volcano Diver',
    'Climb Fire Plume Ridge in Un\'Goro Crater.', 15, 'ungoro_crater', 537)
A.DARK_PORTAL_SELFIE = landmark('Dark Portal Selfie',
    'Stand under the Dark Portal on the Azeroth side.', 10, 'blasted_lands', 72)
A.TIMELESS = landmark('Timeless',
    'Follow the road to the bottom of the Caverns of Time.', 10, 'tanaris', 1941)

A.SIGHTSEER = ns.Achievement(landmarks, {
    name   = 'Sightseer',
    desc   = 'Visit every landmark worth the walk.',
    points = 30,
    icon   = 'achievement_zone_kalimdor',
    meta = {
        A.SCARAB_WALL,
        A.INTO_THE_MOUNTAIN,
        A.VOLCANO_DIVER,
        A.DARK_PORTAL_SELFIE,
        A.TIMELESS,
    },
})
