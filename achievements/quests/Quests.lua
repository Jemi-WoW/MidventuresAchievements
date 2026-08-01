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

A.ERRAND_RUNNER = ns.Achievement(azeroth, {
    name     = 'Errand Runner',
    desc     = 'Complete 50 quests.',
    points   = 15,
    icon     = '-Inv_Misc_Book_07',
    previous = A.ODD_JOBS,
    criteria = {
        { TYPE.COMPLETE_QUESTS, nil, 50, 'Quests completed' },
    },
})
