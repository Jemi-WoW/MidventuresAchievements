local _, ns = ...
if ns.disabled then return end

local TYPE = CA_Criterias.TYPE
local A = ns.achievements
local easternKingdoms = ns.categories.explorationEasternKingdoms
local kalimdor, outland = ns.categories.explorationKalimdor, ns.categories.explorationOutland

-- Guide: .AchievementGuide/Exploration.md. Append at the bottom, ids follow load order.

-- Expands a subzone id list into one criteria each, named from AreaTableLocale.
local function zone(category, name, desc, points, icon, areaIDs)
    local criteria = {}
    for i, areaID in ipairs(areaIDs) do
        criteria[i] = { TYPE.EXPLORE_AREA, {areaID}, nil, AreaTableLocale[areaID] }
    end
    return ns.Achievement(category, {
        name = name, desc = desc, points = points, icon = icon, criteria = criteria,
    })
end

-- Anniversary explores every zone already, so combine zones or gate on theirs.

local exploration = ns.categories.exploration

-- The eight valleys every character wakes up in.
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

-- Booty Bay at 35 is well past the level the zone around it is built for.
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

-- Coordinates read off the summit; correct these first if it never lands.
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

-- Tier 0.5 was the best in the game until the portal opened. That is the joke.
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

-- Each only exists for the faction with no business being there.
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

-- All eight are built so ids never move; the meta takes whichever four are the enemy's.
local ENEMY_CAPITALS = UnitFactionGroup('player') == 'Horde'
    and { A.CATHEDRAL_CRASHER, A.UNDER_THE_MOUNTAIN, A.TREE_HUGGER, A.EXODAR_EXCURSION }
    or { A.HOLD_THE_HOLD, A.HIGH_PLAINS_DRIFTER, A.DOWN_AMONG_THE_DEAD,
         A.SUNSTRIDER_SIGHTSEEING }

A.UNINVITED_GUEST = ns.Achievement(trespassing, {
    name   = 'Uninvited Guest',
    desc   = 'Walk into all four of the enemy\'s cities.',
    points = 50,
    icon   = 'eastern_kingdoms',
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
    'Reach Shattrath City before level 58.', 25, 'terrokar', 3703, 58)

A.YOU_SHOULDNT_BE_HERE = ns.Achievement(trespassing, {
    name   = 'You Shouldn\'t Be Here',
    desc   = 'Turn up everywhere long before anyone expected you.',
    points = 40,
    icon   = 'inv_misc_map02',
    meta = {
        A.BOOTY_BAY_TOURIST,
        A.CHILLED_OUT,
        A.PLAGUE_BEARER,
        A.SANDSTORM_TOURIST,
        A.NOT_READY_FOR_THIS,
    },
})

-- Places worth standing in for their own sake, which Anniversary never asks for.
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
    'Climb Fire Plume Ridge in Un\'Goro Crater.', 15, 'ungoro', 537)
A.DARK_PORTAL_SELFIE = landmark('Dark Portal Selfie',
    'Stand under the Dark Portal on the Azeroth side.', 10, 'blasted_lands', 72)
A.TIMELESS = landmark('Timeless',
    'Follow the road to the bottom of the Caverns of Time.', 10, 'tanaris', 1941)

A.SIGHTSEER = ns.Achievement(landmarks, {
    name   = 'Sightseer',
    desc   = 'Visit every landmark worth the walk.',
    points = 30,
    icon   = 'kalimdor',
    meta = {
        A.SCARAB_WALL,
        A.INTO_THE_MOUNTAIN,
        A.VOLCANO_DIVER,
        A.DARK_PORTAL_SELFIE,
        A.TIMELESS,
    },
})

-- Corners of the map nothing sends you to, so getting there is the whole point.
local farCorners = ns.categories.explorationFarCorners

local function corner(name, desc, points, icon, areaID)
    return ns.Achievement(farCorners, {
        name = name, desc = desc, points = points, icon = icon,
        criteria = {
            { ns.CRITERIA_ZONE_VISIT, {areaID}, nil, AreaTableLocale[areaID] },
        },
    })
end

A.TWIN_COLOSSALS = corner('Twin Peaks',
    'Find the path up the Twin Colossals in Feralas.', 15, 'feralas', 1119)
A.MASTERS_GLAIVE = corner('The Master\'s Glaive',
    'Stand among the fallen swords on the coast of Darkshore.', 10, 'darkshore', 449)
A.ELDARATH = corner('Elven Ruins',
    'Wade into the Ruins of Eldarath in Azshara.', 10, 'azshara', 1221)
A.DARKWHISPER = corner('Darkwhisper Gorge',
    'Walk into the demons\' gorge in southern Winterspring.', 20, 'winterspring', 2256)
A.TIMBERMAW = corner('Through the Hold',
    'Walk the tunnel through Timbermaw Hold.', 15, 'felwood', 1216)
A.KODO_GRAVEYARD = corner('Where Kodos Go',
    'Find the Kodo Graveyard in Desolace.', 10, 'desolace', 596)
A.ULDUM_GATE = corner('Sealed Away',
    'Find the sealed gate of Uldum in southern Tanaris.', 15, 'tanaris', 989)

A.DALARAN_DOME = corner('Under the Dome',
    'Walk up to the shield over Dalaran in the Alterac Mountains.', 15, 'alterac_mountains', 279)
A.SERADANE = corner('Green Dragon Country',
    'Find Seradane, the green dragon portal in the Hinterlands.', 15, 'hinterlands', 356)
A.JINTHA_ALOR = corner('Top of the Ziggurat',
    'Climb to the altar at the top of Jintha\'Alor in the Hinterlands.', 20,
    'hinterlands', 354)
A.TWILIGHT_GROVE = corner('The Twilight Grove',
    'Find the sunken grove hidden in Duskwood.', 10, 'duskwood', 856)
A.KARAZHAN_GATES = corner('The Tower in the Pass',
    'Stand at the gates of Karazhan in Deadwind Pass.', 15, 'deadwind_pass', 2562)
A.GRIM_BATOL = corner('The Shut Gate',
    'Follow the pass to the gate of Grim Batol in the Wetlands.', 15, 'wetlands', 1037)

A.BASHIR_LANDING = corner('Nothing Below',
    'Land on Bash\'ir Landing, the floating platform in Blade\'s Edge Mountains.', 20,
    'blades_edge_mtns', 3864)
A.NETHERWING_LEDGE = corner('The Dragons\' Ledge',
    'Reach Netherwing Ledge in Shadowmoon Valley.', 20, 'shadowmoon', 3759)
A.OSHUGUN = corner('The Mountain That Fell',
    'Stand at the foot of Oshu\'gun in Nagrand.', 15, 'nagrand', 3630)
A.SKETTIS = corner('Above the Trees',
    'Find Skettis in Terokkar Forest.', 15, 'terrokar', 3679)
A.BLACK_TEMPLE_GATES = corner('At the Gates',
    'Walk up to the Black Temple in Shadowmoon Valley.', 20, 'shadowmoon', 3840)
A.THRONE_OF_KILJAEDEN = corner('Throne of Kil\'jaeden',
    'Climb the Throne of Kil\'jaeden in Hellfire Peninsula.', 15, 'hellfire_peninsula', 3547)
A.STORMSPIRE = corner('The Stormspire',
    'Reach the Stormspire in Netherstorm.', 15, 'netherstorm', 3738)

A.FAR_CORNERS_AZEROTH = ns.Achievement(farCorners, {
    name   = 'Far Corners of Azeroth',
    desc   = 'Reach every corner of the old world nothing ever sends you to.',
    points = 50,
    icon   = 'inv_misc_map02',
    meta = {
        A.TWIN_COLOSSALS,
        A.MASTERS_GLAIVE,
        A.ELDARATH,
        A.DARKWHISPER,
        A.TIMBERMAW,
        A.KODO_GRAVEYARD,
        A.ULDUM_GATE,
        A.DALARAN_DOME,
        A.SERADANE,
        A.JINTHA_ALOR,
        A.TWILIGHT_GROVE,
        A.KARAZHAN_GATES,
        A.GRIM_BATOL,
    },
})

A.FAR_CORNERS_OUTLAND = ns.Achievement(farCorners, {
    name   = 'Far Corners of Outland',
    desc   = 'Reach every corner of the other side nothing ever sends you to.',
    points = 40,
    icon   = 'outland',
    meta = {
        A.BASHIR_LANDING,
        A.NETHERWING_LEDGE,
        A.OSHUGUN,
        A.SKETTIS,
        A.BLACK_TEMPLE_GATES,
        A.THRONE_OF_KILJAEDEN,
        A.STORMSPIRE,
    },
})
