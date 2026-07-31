local _, ns = ...
if ns.disabled then return end

local TYPE = CA_Criterias.TYPE
local general, A = ns.categories.general, ns.achievements

-- How to write these: .AchievementGuide/General.md
-- Append new achievements at the bottom, ids are handed out in load order.

A.TEST_A = ns.Achievement(general, {
    name   = 'TEST_A',
    desc   = 'Kill 3 monsters.',
    points = 20,
    icon   = '-INV_Misc_Bone_HumanSkull_01',
    criteria = {
        { TYPE.KILL_ANY_NPC, nil, 3, 'Monsters killed' },
    },
})