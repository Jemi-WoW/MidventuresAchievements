local _, ns = ...
if ns.disabled then return end

local TYPE = CA_Criterias.TYPE
local A = ns.achievements
local battlegrounds, arenas = ns.categories.pvpBattlegrounds, ns.categories.pvpArenas

-- How to write these: .AchievementGuide/PvP.md
-- Append new achievements at the bottom, ids are handed out in load order.

local WARSONG_GULCH = 1460

A.INTO_THE_GULCH = ns.Achievement(battlegrounds, {
    name   = 'Into the Gulch',
    desc   = 'Win a Warsong Gulch match.',
    points = 15,
    icon   = '-Inv_Shield_05',
    criteria = {
        { TYPE.BATTLEFIELD_WINS, {WARSONG_GULCH} },
    },
})

A.FLAG_RUNNER = ns.Achievement(battlegrounds, {
    name     = 'Flag Runner',
    desc     = 'Win 5 Warsong Gulch matches.',
    points   = 20,
    icon     = '-Inv_Sword_47',
    previous = A.INTO_THE_GULCH,
    criteria = {
        { TYPE.BATTLEFIELD_WINS, {WARSONG_GULCH}, 5, 'Warsong Gulch wins' },
    },
})
