local _, ns = ...
if ns.disabled then return end

local A = ns.achievements
local travel = ns.categories.generalTravel

-- Fed by core/Travel.lua. Anniversary has the riding skills and nothing about using them.

A.FREQUENT_FLYER = ns.Chain(travel, {
    name = function(n) return ('Frequent Flyer %d Times'):format(n) end,
    desc = function(n) return ('Take %d flight paths.'):format(n) end,
    criteria = ns.CRITERIA_FLIGHTS,
    label = 'Flights taken',
    icons = {'-Ability_Mount_Gryphon_01', '-ability_druid_flightform', '-Ability_Eyeoftheowl'},
})

A.NO_PLACE_LIKE_HOME = ns.Chain(travel, {
    name = function(n) return ("There's No Place Like Home %d Times"):format(n) end,
    desc = function(n) return ('Use your Hearthstone %d times.'):format(n) end,
    criteria = ns.CRITERIA_HEARTHS,
    label = 'Hearthstones used',
    icons = {'-inv_misc_rune_07', '-Spell_Arcane_PortalShattrath', '-spell_arcane_teleportshattrath'},
})

A.SEASICK = ns.Achievement(travel, {
    name   = 'Seasick',
    desc   = 'Ride a boat or a zeppelin 25 times.',
    points = 15,
    icon   = 'inv_misc_map02',
    criteria = {
        { ns.CRITERIA_TRANSPORT, nil, 25, 'Crossings made' },
    },
})

A.SUMMONERS_SICKNESS = ns.Achievement(travel, {
    name   = "Summoner's Sickness",
    desc   = 'Accept 25 summons.',
    points = 15,
    icon   = '-Spell_Shadow_Summonimp',
    criteria = {
        { ns.CRITERIA_SUMMONED, nil, 25, 'Summons taken' },
    },
})

-- A million reads as a phone number without them.
local function commas(number)
    local text, replaced = tostring(number), 1
    while replaced > 0 do
        text, replaced = text:gsub('^(%d+)(%d%d%d)', '%1,%2')
    end
    return text
end

-- Counted by core/Movement.lua, which reads the client the way JemiStats does.
A.HAPPY_FEET = ns.Chain(travel, {
    name = function(n) return ('Jump %s Times'):format(commas(n)) end,
    desc = function(n) return ('Jump %s times.'):format(commas(n)) end,
    criteria = ns.CRITERIA_JUMPS,
    label = 'Jumps',
    icons = {'-Inv_Misc_Foot_Centaur'},
    tiers  = {1000, 2000, 3000, 5000, 10000, 15000, 25000, 50000, 75000, 100000, 250000},
    points = {5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 60},
    extraTiers  = {500000, 1000000, 2500000, 5000000},
    extraPoints = {70, 80, 90, 100},
})

-- Yards come in far faster than anything else, hence the ladder running to ten million.
A.LONG_WALK = ns.Chain(travel, {
    name = function(n) return ('Walk %s Yards'):format(commas(n)) end,
    desc = function(n) return ('Cover %s yards on your own two feet.'):format(commas(n)) end,
    criteria = ns.CRITERIA_YARDS,
    label = 'Yards walked',
    icons = {'-ability_hunter_pathfinding'},
    tiers  = {10000, 20000, 30000, 40000, 50000, 75000,
        100000, 150000, 200000, 300000, 400000},
    points = {5, 5, 10, 10, 15, 15, 20, 20, 25, 25, 30},
    extraTiers  = {500000, 750000, 1000000, 1500000},
    extraPoints = {30, 35, 40, 45},
    topTiers  = {2000000, 2500000, 3000000, 3500000, 4000000, 5000000,
        6000000, 7000000, 8000000, 9000000, 10000000},
    topPoints = {50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100},
})
