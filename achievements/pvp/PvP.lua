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

A.MAKGORA_LEGEND = ns.Achievement(duels, {
    name     = "Mak'gora Legend",
    desc     = ('Win 50 duels against %s guildmates.'):format(ns.GUILD_NAME),
    points   = 40,
    icon     = '-Inv_Sword_39',
    previous = A.MAKGORA_VETERAN,
    criteria = {
        { ns.CRITERIA_GUILD_DUEL, nil, 50, 'Guildmates defeated' },
    },
})

-- Anniversary counts battleground wins, objectives and scores for everyone. What it never
-- asks is who you turned up with, which is what core/Battlegrounds.lua watches.
local PREMADE, WALL = 5, 10

A.PREMADE = ns.Achievement(battlegrounds, {
    name   = 'Premade',
    desc   = ('Win a battleground with at least %d %s guildmates in the raid.')
        :format(PREMADE, ns.GUILD_NAME),
    points = 25,
    icon   = '-Inv_Banner_02',
    criteria = {
        { ns.CRITERIA_BG_WIN_GUILD, {PREMADE}, nil, 'A win with the guild along' },
    },
})

A.GUILD_WALL = ns.Achievement(battlegrounds, {
    name     = 'Guild Wall',
    desc     = ('Win a battleground with at least %d %s guildmates in the raid.')
        :format(WALL, ns.GUILD_NAME),
    points   = 40,
    icon     = '-Inv_Shield_06',
    previous = A.PREMADE,
    criteria = {
        { ns.CRITERIA_BG_WIN_GUILD, {WALL}, nil, 'A win with half the guild along' },
    },
})

A.WE_TRIED = ns.Achievement(battlegrounds, {
    name   = 'We Tried',
    desc   = 'Lose 25 battlegrounds. Somebody has to.',
    points = 15,
    icon   = '-Ability_Rogue_FeignDeath',
    criteria = {
        { ns.CRITERIA_BG_LOSSES, nil, 25, 'Battlegrounds lost' },
    },
})

A.CANNON_FODDER = ns.Achievement(battlegrounds, {
    name   = 'Cannon Fodder',
    desc   = 'Die 100 times in battlegrounds.',
    points = 15,
    icon   = '-Ability_Creature_Cursed_05',
    criteria = {
        { ns.CRITERIA_BG_DEATHS, nil, 100, 'Deaths in battlegrounds' },
    },
})

A.CARRIED = ns.Achievement(battlegrounds, {
    name   = 'Carried',
    desc   = 'Win a battleground without a single killing blow or honourable kill.',
    points = 20,
    icon   = '-Spell_Nature_Sleep',
    criteria = {
        { ns.CRITERIA_BG_CARRIED, nil, nil, 'A win you had no part in' },
    },
})

A.GUILD_TEAM = ns.Achievement(arenas, {
    name   = 'Guild Team',
    desc   = ('Win an arena match with nobody but %s on your side.'):format(ns.GUILD_NAME),
    points = 25,
    icon   = '-Ability_Warrior_Challange',
    criteria = {
        { ns.CRITERIA_ARENA_GUILD, nil, 1, 'Arena wins with an all-guild team' },
    },
})

A.GUILD_TEAM_VETERAN = ns.Achievement(arenas, {
    name     = 'Guild Team Veteran',
    desc     = ('Win 50 arena matches with nobody but %s on your side.')
        :format(ns.GUILD_NAME),
    points   = 40,
    icon     = '-Inv_Jewelry_Amulet_07',
    previous = A.GUILD_TEAM,
    criteria = {
        { ns.CRITERIA_ARENA_GUILD, nil, 50, 'Arena wins with an all-guild team' },
    },
})

A.BLINDFOLDED = ns.Achievement(arenas, {
    name   = 'Blindfolded',
    desc   = 'Lose 50 arena matches. The rating will recover eventually.',
    points = 15,
    icon   = '-Spell_Shadow_Cripple',
    criteria = {
        { ns.CRITERIA_ARENA_LOSSES, nil, 50, 'Arena matches lost' },
    },
})

-- The rest of what a duel says about you, from core/GuildDuels.lua.
A.DUEL_CLUB = ns.Achievement(duels, {
    name   = 'Duel Club',
    desc   = ('Duel 10 different %s guildmates.'):format(ns.GUILD_NAME),
    points = 20,
    icon   = '-Inv_Sword_04',
    criteria = {
        { ns.CRITERIA_DUEL_PARTNERS, nil, 10, 'Guildmates duelled' },
    },
})

A.BEST_OF_THE_BEST = ns.Achievement(duels, {
    name   = 'Best of the Best',
    desc   = 'Beat the Guild Master in a duel.',
    points = 25,
    icon   = '-Inv_Crown_01',
    criteria = {
        { ns.CRITERIA_DUEL_MASTER, nil, nil, 'The Guild Master, beaten' },
    },
})

A.HUMBLED = ns.Achievement(duels, {
    name   = 'Humbled',
    desc   = ('Lose 50 duels to %s guildmates.'):format(ns.GUILD_NAME),
    points = 15,
    icon   = '-Ability_Warrior_Disarm',
    criteria = {
        { ns.CRITERIA_DUEL_LOSSES, nil, 50, 'Duels lost' },
    },
})

A.GUILD_GLADIATOR = ns.Achievement(duels, {
    name   = 'Guild Gladiator',
    desc   = 'Take on the whole guild, one at a time, and come out on top.',
    points = 50,
    icon   = 'achievement_featsofstrength_gladiator_01',
    meta = {
        A.MAKGORA_LEGEND,
        A.DUEL_CLUB,
        A.BEST_OF_THE_BEST,
    },
})
