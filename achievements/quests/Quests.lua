local _, ns = ...
if ns.disabled then return end

local TYPE = CA_Criterias.TYPE
local A = ns.achievements
local azeroth, outland, dailies =
    ns.categories.questsAzeroth, ns.categories.questsOutland, ns.categories.questsDailies

-- How to write these: .AchievementGuide/Quests.md
-- Append new achievements at the bottom, ids are handed out in load order.

A.ODD_JOBS = ns.Achievement(azeroth, {
    name   = 'Odd Jobs',
    desc   = 'Complete 10 quests.',
    points = 10,
    icon   = '-Inv_Misc_Book_09',
    criteria = {
        { TYPE.COMPLETE_QUESTS, nil, 10, 'Quests completed' },
    },
})

-- Anniversary's quest counters start at 50, so keep ours under that or gate on theirs.
A.ERRAND_BOY = ns.Achievement(azeroth, {
    name     = 'Errand Boy',
    desc     = 'Complete 25 quests.',
    points   = 10,
    icon     = '-Inv_Scroll_03',
    previous = A.ODD_JOBS,
    criteria = {
        { TYPE.COMPLETE_QUESTS, nil, 25, 'Quests completed' },
    },
})

-- The quests everyone remembers, which is not the same as the quests everyone enjoyed.
A.CLUCK = ns.Achievement(azeroth, {
    name   = 'Cluck!',
    desc   = 'Feed the chicken in Westfall until it has something to say.',
    points = 15,
    icon   = '-ability_hunter_pet_turtle',
    criteria = {
        { TYPE.COMPLETE_QUEST, {3861}, nil, 'CLUCK!' },
    },
})

A.WANTED_HOGGER = ns.Achievement(azeroth, {
    name    = 'Wanted: Hogger',
    desc    = 'Bring in the most feared gnoll in Elwynn Forest.',
    points  = 15,
    icon    = '-Ability_Warrior_Rampage',
    faction = 'Alliance',
    criteria = {
        { TYPE.COMPLETE_QUEST, {176}, nil, 'Wanted: Hogger' },
    },
})

A.LAZY_PEON = ns.Achievement(azeroth, {
    name    = 'Lazy Peon',
    desc    = 'Wake up every sleeping peon in the Valley of Trials.',
    points  = 15,
    icon    = '-Ability_Warrior_DecisiveStrike',
    faction = 'Horde',
    criteria = {
        { TYPE.COMPLETE_QUEST, {5441}, nil, 'Lazy Peons' },
    },
})

A.STALVAN = ns.Achievement(azeroth, {
    name   = 'Stalvan',
    desc   = 'Read every page of the Duskwood letters and finish what they started.',
    points = 20,
    icon   = '-Inv_Misc_Book_07',
    criteria = {
        { TYPE.COMPLETE_QUEST, {98}, nil, 'The Legend of Stalvan' },
    },
})

A.WHERE_IS_AME = ns.Achievement(azeroth, {
    name   = 'Where Is A-Me?',
    desc   = 'Walk the gorilla all the way home through Un\'Goro Crater.',
    points = 20,
    icon   = '-Ability_Hunter_Pet_Gorilla',
    criteria = {
        { TYPE.COMPLETE_QUEST, {4245}, nil, 'Chasing A-Me 01' },
    },
})

-- The seven zones on the other side, in the order the portal sends you through them.
local OUTLAND_ZONES = {3483, 3521, 3519, 3518, 3522, 3523, 3520}

A.WRONG_SIDE_OF_THE_PORTAL = ns.Achievement(outland, {
    name   = 'Wrong Side of the Portal',
    desc   = 'Complete a quest in Hellfire Peninsula before level 58.',
    points = 20,
    icon   = 'hellfire_peninsula',
    criteria = {
        { ns.CRITERIA_QUEST_BELOW_LEVEL, {3483, 58}, nil, 'A quest done far too early' },
    },
})

local function outlandZones()
    local criteria = {}
    for i, areaID in ipairs(OUTLAND_ZONES) do
        criteria[i] = { ns.CRITERIA_QUEST_IN_ZONE, {areaID}, 1, AreaTableLocale[areaID] }
    end
    return criteria
end

A.OUTLAND_ODD_JOBS = ns.Achievement(outland, {
    name   = 'Outland Odd Jobs',
    desc   = 'Complete at least one quest in every Outland zone.',
    points = 25,
    icon   = 'achievement_zone_outland',
    criteria = outlandZones(),
})

-- Anniversary's daily counter starts at five, so the first one and the twenty-fifth are
-- both ours.
A.JUST_THIS_ONCE = ns.Achievement(dailies, {
    name   = 'Just This Once',
    desc   = 'Complete a daily quest.',
    points = 5,
    icon   = '-Inv_Misc_Note_01',
    criteria = {
        { TYPE.COMPLETE_DAILY_QUESTS, nil, 1, 'Daily quests completed' },
    },
})

A.DAILY_GRIND = ns.Achievement(dailies, {
    name     = 'Daily Grind',
    desc     = 'Complete 25 daily quests.',
    points   = 15,
    icon     = '-Inv_Misc_PocketWatch_01',
    previous = A.JUST_THIS_ONCE,
    criteria = {
        { TYPE.COMPLETE_DAILY_QUESTS, nil, 25, 'Daily quests completed' },
    },
})

local errands, habits = ns.categories.questsGuildErrands, ns.categories.questsBadHabits

-- Questing together, counted by core/Quests.lua at the moment the quest is handed in.
A.GUILD_ERRANDS = ns.Chain(errands, {
    name = function(n) return ('Run %d Guild Errands'):format(n) end,
    desc = function(n)
        return ('Hand in %d quests while grouped with a %s guildmate.'):format(n, ns.GUILD_NAME)
    end,
    criteria = ns.CRITERIA_QUEST_GUILD,
    label = 'Quests handed in together',
    icons = {'-Inv_Scroll_03', '-Inv_Misc_Book_09', '-Inv_Letter_03'},
})

A.QUEST_BUDDIES = ns.Achievement(errands, {
    name   = 'Quest Buddies',
    desc   = ('Hand in quests alongside 10 different %s guildmates.'):format(ns.GUILD_NAME),
    points = 25,
    icon   = '-Inv_Banner_03',
    criteria = {
        { ns.CRITERIA_QUEST_BUDDIES, nil, 10, 'Guildmates quested with' },
    },
})

-- The hundred tier, which is where a chain stops being a hobby.
local HUNDRED = 6

A.GUILD_GOFER = ns.Achievement(errands, {
    name   = 'Guild Gofer',
    desc   = 'Do the guild\'s legwork until somebody notices.',
    points = 40,
    icon   = 'achievement_quests_completed_04',
    meta = {
        A.ERRAND_BOY,
        A.GUILD_ERRANDS[HUNDRED],
        A.QUEST_BUDDIES,
    },
})

A.QUITTER = ns.Chain(habits, {
    name = function(n) return ('Abandon %d Quests'):format(n) end,
    desc = function(n) return ('Give up on %d quests.'):format(n) end,
    criteria = ns.CRITERIA_QUEST_ABANDON,
    label = 'Quests abandoned',
    icons = {'-Inv_Misc_Bandage_15', '-Spell_Shadow_Cripple', '-Ability_Rogue_FeignDeath'},
})

A.HOARDER = ns.Achievement(habits, {
    name   = 'Hoarder',
    desc   = 'Fill your quest log to the last slot.',
    points = 15,
    icon   = '-Inv_Misc_Bag_10_Green',
    criteria = {
        { ns.CRITERIA_QUEST_LOG_FULL, nil, nil, 'A quest log with no room left' },
    },
})

A.BENEATH_YOU = ns.Achievement(habits, {
    name   = 'Beneath You',
    desc   = 'Hand in 100 quests that were worth no experience at all.',
    points = 20,
    icon   = '-Spell_Shadow_Teleport',
    criteria = {
        { ns.CRITERIA_QUEST_NO_XP, nil, 100, 'Quests done for nothing' },
    },
})
