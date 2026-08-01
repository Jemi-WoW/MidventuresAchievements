local _, ns = ...
if ns.disabled then return end

local TYPE = CA_Criterias.TYPE
local A = ns.achievements
local classic, tbc, raids =
    ns.categories.dungeonsClassic, ns.categories.dungeonsTBC, ns.categories.dungeonsRaids

-- How to write these: .AchievementGuide/DungeonsAndRaids.md
-- Append new achievements at the bottom, ids are handed out in load order.

A.INTO_THE_FIRE = ns.Achievement(classic, {
    name   = 'Into the Fire',
    desc   = 'Defeat Taragaman the Hungerer in Ragefire Chasm.',
    points = 15,
    icon   = '-Spell_Shadow_Summonimp',
    criteria = {
        { TYPE.KILL_NPC, {11520} },
    },
})

A.MINE_ALL_MINE = ns.Achievement(classic, {
    name   = 'Mine, All Mine',
    desc   = 'Defeat Edwin VanCleef in the Deadmines.',
    points = 15,
    icon   = '-Inv_Sword_39',
    criteria = {
        { TYPE.KILL_NPC, {639} },
    },
})
