local _, ns = ...
if ns.disabled then return end

local TYPE = CA_Criterias.TYPE
local dungeons, A = ns.categories.dungeons, ns.achievements
local classic, tbc = ns.categories.dungeonsClassic, ns.categories.dungeonsTBC

-- How to write these: .AchievementGuide/DungeonsAndRaids.md
-- Append new achievements at the bottom, ids are handed out in load order.

A.TEST_B = ns.Achievement(tbc, {
    name   = 'TEST_B',
    desc   = 'Kill 5 monsters.',
    points = 20,
    icon   = '-INV_Misc_Bone_HumanSkull_01',
    criteria = {
        { TYPE.KILL_ANY_NPC, nil, 5, 'Monsters killed' },
    },
})