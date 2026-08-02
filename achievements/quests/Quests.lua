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
