local _, ns = ...
if ns.disabled then return end

local TYPE = CA_Criterias.TYPE
local A = ns.achievements
local general = ns.categories.general
local levelling, combat, wealth =
    ns.categories.generalLevelling, ns.categories.generalCombat, ns.categories.generalWealth

-- How to write these: .AchievementGuide/General.md
-- Append new achievements at the bottom, ids are handed out in load order.

-- Sits in the parent category rather than a subcategory, because it is the welcome.
A.MIDVENTURER = ns.Achievement(general, {
    name   = 'Midventurer',
    desc   = ('Join the %s guild.'):format(ns.GUILD_NAME),
    points = 25,
    icon   = '-Inv_Banner_03',
    reward = 'Reward: a place in the Midventures community.',
    criteria = {
        { ns.CRITERIA_GUILD, nil, nil, ('Member of %s'):format(ns.GUILD_NAME) },
    },
})

A.FIRST_STEPS = ns.Achievement(levelling, {
    name   = 'First Steps',
    desc   = 'Reach level 5.',
    points = 10,
    icon   = '-Inv_Misc_Note_01',
    criteria = {
        { TYPE.REACH_LEVEL, {5} },
    },
})

A.SETTLING_IN = ns.Achievement(levelling, {
    name   = 'Settling In',
    desc   = 'Reach level 20.',
    points = 15,
    icon   = '-Ability_Mount_RidingHorse',
    meta   = { ns.Anniversary('AN_LVL', 10) },
    criteria = {
        { TYPE.REACH_LEVEL, {20} },
    },
})

A.BLOODED = ns.Achievement(combat, {
    name   = 'Blooded',
    desc   = 'Kill 10 monsters.',
    points = 10,
    icon   = '-Inv_Misc_Bone_DwarfSkull_01',
    criteria = {
        { TYPE.KILL_ANY_NPC, nil, 10, 'Monsters killed' },
    },
})

A.SCRAPPER = ns.Achievement(combat, {
    name   = 'Scrapper',
    desc   = 'Win a duel.',
    points = 10,
    icon   = '-Ability_Warrior_DecisiveStrike',
    criteria = {
        { TYPE.DUELS },
    },
})

A.ROOM_TO_SPARE = ns.Achievement(wealth, {
    name   = 'Room to Spare',
    desc   = 'Purchase your first bank slot.',
    points = 15,
    icon   = '-inv_box_01',
    criteria = {
        { TYPE.BANK_SLOTS, nil, 1, 'Bank slots purchased' },
    },
})

A.TRAVELLING_CLOTHES = ns.Achievement(wealth, {
    name   = 'Travelling Clothes',
    desc   = 'Equip uncommon gear on your head, chest and legs.',
    points = 15,
    icon   = '-Inv_Enchant_EssenceNetherSmall',
    criteria = {
        { TYPE.GEAR_QUALITY, {1, 2}, nil, 'Head' },
        { TYPE.GEAR_QUALITY, {4, 2}, nil, 'Chest' },
        { TYPE.GEAR_QUALITY, {6, 2}, nil, 'Legs' },
    },
})
