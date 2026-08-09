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
    icon   = '-inv_misc_map02',
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
