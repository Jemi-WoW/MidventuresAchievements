local _, ns = ...
if ns.disabled then return end

local TYPE = CA_Criterias.TYPE
local A = ns.achievements
local battlegrounds, arenas = ns.categories.pvpBattlegrounds, ns.categories.pvpArenas

-- How to write these: .AchievementGuide/PvP.md
-- Append new achievements at the bottom, ids are handed out in load order.

local WARSONG_GULCH = 1460

-- Anniversary already has win counts of 1, 5, 10, 25 and 50 for every battleground, so
-- those duplicate it. Use the score and stat types instead, or gate on theirs.

local duels = ns.categories.pvpDuels

-- Anniversary counts duels won but never asks who lost, so core/GuildDuels.lua does.
A.MAKGORA = ns.Achievement(duels, {
    name   = "Mak'gora",
    desc   = ('Defeat a %s guildmate in a duel.'):format(ns.GUILD_NAME),
    points = 10,
    icon   = '-Ability_Warrior_Challange',
    criteria = {
        { ns.CRITERIA_GUILD_DUEL, nil, 1, 'Guildmates defeated' },
    },
})

A.MAKGORA_VETERAN = ns.Achievement(duels, {
    name     = "Mak'gora Veteran",
    desc     = ('Win 10 duels against %s guildmates.'):format(ns.GUILD_NAME),
    points   = 20,
    icon     = '-Ability_Warrior_DecisiveStrike',
    previous = A.MAKGORA,
    criteria = {
        { ns.CRITERIA_GUILD_DUEL, nil, 10, 'Guildmates defeated' },
    },
})
