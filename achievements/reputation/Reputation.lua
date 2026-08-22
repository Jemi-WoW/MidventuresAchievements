local _, ns = ...
if ns.disabled then return end

local TYPE = CA_Criterias.TYPE
local A = ns.achievements
local azeroth, outland = ns.categories.reputationAzeroth, ns.categories.reputationOutland

-- Guide: .AchievementGuide/Reputation.md. Append at the bottom, ids follow load order.

local HONORED = 6

A.MAKING_FRIENDS = ns.Achievement(azeroth, {
    name   = 'Making Friends',
    desc   = 'Reach Honored with any faction.',
    points = 10,
    icon   = '-Spell_Holy_Mindsooth',
    criteria = {
        { TYPE.REACH_ANY_REPUTATION, {HONORED}, 1, 'Factions at Honored' },
    },
})

A.WELL_REGARDED = ns.Achievement(azeroth, {
    name     = 'Well Regarded',
    desc     = 'Reach Honored with 3 factions.',
    points   = 15,
    icon     = '-Spell_Holy_Prayerofspirit',
    previous = A.MAKING_FRIENDS,
    criteria = {
        { TYPE.REACH_ANY_REPUTATION, {HONORED}, 3, 'Factions at Honored' },
    },
})

-- Anniversary only ever counts Exalted, so every standing below it is ours to use.
local FRIENDLY, REVERED = 5, 7

A.FRIENDLY_FACE = ns.Achievement(azeroth, {
    name   = 'Friendly Face',
    desc   = 'Reach Friendly with 10 factions.',
    points = 10,
    icon   = '-Spell_Holy_Prayerofhealing',
    criteria = {
        { TYPE.REACH_ANY_REPUTATION, {FRIENDLY}, 10, 'Factions at Friendly' },
    },
})

A.REVERED_DENTER = ns.Achievement(azeroth, {
    name     = 'Revered Denter',
    desc     = 'Reach Revered with 5 factions.',
    points   = 20,
    icon     = '-Spell_Holy_ChampionsBond',
    previous = A.WELL_REGARDED,
    criteria = {
        { TYPE.REACH_ANY_REPUTATION, {REVERED}, 5, 'Factions at Revered' },
    },
})

-- The cities you were born owing nothing to; Ambassador wants them all at Exalted.
local HOME_FACTIONS = UnitFactionGroup('player') == 'Horde'
    and { {76, 'Orgrimmar'}, {530, 'Darkspear Trolls'}, {68, 'Undercity'},
          {81, 'Thunder Bluff'}, {911, 'Silvermoon City'} }
    or { {72, 'Stormwind'}, {69, 'Darnassus'}, {54, 'Gnomeregan Exiles'},
         {47, 'Ironforge'}, {930, 'Exodar'} }

local function homeCriteria()
    local criteria = {}
    for i, faction in ipairs(HOME_FACTIONS) do
        criteria[i] = { TYPE.REACH_REPUTATION, {faction[1], HONORED}, nil, faction[2] }
    end
    return criteria
end

A.HOMETOWN_HERO = ns.Achievement(azeroth, {
    name   = 'Hometown Hero',
    desc   = 'Reach Honored with every home city of your own faction.',
    points = 20,
    icon   = '-inv_banner_03',
    criteria = homeCriteria(),
})

A.BLOODSAIL_ADMIRAL = ns.Achievement(azeroth, {
    name   = 'Bloodsail Admiral',
    desc   = 'Reach Honored with the Bloodsail Buccaneers, whatever it costs you.',
    points = 25,
    icon   = '-Inv_Helmet_66',
    criteria = {
        { TYPE.REACH_REPUTATION, {87, HONORED}, nil, 'Bloodsail Buccaneers' },
    },
})

A.HATED = ns.Achievement(azeroth, {
    name   = 'Hated',
    desc   = 'Get somebody, anybody, to Hated.',
    points = 15,
    icon   = '-spell_shadow_demonictactics',
    criteria = {
        { ns.CRITERIA_REP_HATED, {ns.REP_ANY_FACTION}, nil, 'A faction that is done with you' },
    },
})

-- The three goblin towns you burn through on the way to the pirate hat.
local STEAMWHEEDLE = {
    [21] = 'Booty Bay', [369] = 'Gadgetzan', [577] = 'Everlook',
}

local function steamwheedleCriteria()
    local criteria = {}
    for factionID, name in pairs(STEAMWHEEDLE) do
        criteria[#criteria + 1] = { ns.CRITERIA_REP_HATED, {factionID}, nil, name }
    end
    return criteria
end

A.PERSONA_NON_GRATA = ns.Achievement(azeroth, {
    name     = 'Persona Non Grata',
    desc     = 'Reach Hated with all three Steamwheedle towns.',
    points   = 30,
    icon     = '-ability_racial_shadowmeld',
    previous = A.HATED,
    criteria = steamwheedleCriteria(),
})

-- Anniversary asks for Exalted with the Aldor or the Scryers, so Honored is still open.
A.PICKING_SIDES = ns.Achievement(outland, {
    name   = 'Picking Sides',
    desc   = 'Reach Honored with the Aldor or the Scryers.',
    points = 15,
    icon   = '-Spell_Holy_MindVision',
    anyCompletable = true,
    criteria = {
        { TYPE.REACH_REPUTATION, {932, HONORED}, nil, 'The Aldor' },
        { TYPE.REACH_REPUTATION, {934, HONORED}, nil, 'The Scryers' },
    },
})

-- Five named factions, since an achievement completes only when every criteria does.
local GARRISON = UnitFactionGroup('player') == 'Horde'
    and {947, 'Thrallmar'} or {946, 'Honor Hold'}

A.SHATARI_SIGHTSEER = ns.Achievement(outland, {
    name   = 'Sha\'tari Sightseer',
    desc   = 'Reach Honored with five of Outland\'s factions.',
    points = 20,
    icon   = 'outland',
    criteria = {
        { TYPE.REACH_REPUTATION, {GARRISON[1], HONORED}, nil, GARRISON[2] },
        { TYPE.REACH_REPUTATION, {942, HONORED}, nil, 'Cenarion Expedition' },
        { TYPE.REACH_REPUTATION, {935, HONORED}, nil, 'The Sha\'tar' },
        { TYPE.REACH_REPUTATION, {933, HONORED}, nil, 'The Consortium' },
        { TYPE.REACH_REPUTATION, {989, HONORED}, nil, 'Keepers of Time' },
    },
})

A.DIPLOMATIC_IMMUNITY = ns.Achievement(outland, {
    name   = 'Diplomatic Immunity',
    desc   = 'Be liked and loathed in roughly equal measure.',
    points = 40,
    icon   = '-Inv_Misc_Note_02',
    meta = {
        A.MAKING_FRIENDS,
        A.WELL_REGARDED,
        A.REVERED_DENTER,
        A.HATED,
    },
})
