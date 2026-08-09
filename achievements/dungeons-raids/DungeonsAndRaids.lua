local _, ns = ...
if ns.disabled then return end

local TYPE = CA_Criterias.TYPE
local A = ns.achievements
local classic, tbc = ns.categories.dungeonsClassic, ns.categories.dungeonsTBC

-- How to write these: .AchievementGuide/DungeonsAndRaids.md
-- Append new achievements at the bottom, ids are handed out in load order.

-- Anniversary already has a kill-the-last-boss achievement for every dungeon, so those
-- duplicate it. Ask for more than the kill, or gate on theirs:
--   meta = { ns.Anniversary('AN_RAGEFIRE_CHASM') }

-- Theirs is for everyone. Ours is for the faction that has no business being down there.
A.WHAT_ARE_YOU_DOING_HERE = ns.Achievement(classic, {
    name    = 'What are you doing here?',
    desc    = 'Kill Edwin VanCleef in The Deadmines as a Horde character.',
    points  = 20,
    icon    = 'achievement_boss_edwinvancleef',
    faction = 'Horde',
    criteria = {
        { TYPE.KILL_NPC, {639}, nil, 'Edwin VanCleef' },
    },
})

-- Guild Runner, Guild Dungeon Master and their TBC pair used to sit here, one achievement
-- covering every dungeon at once. Anniversary remembers progress by id, so the ids they
-- were given are stepped past rather than handed out again to the ones below.
classic.mvAchievementID = classic.mvAchievementID + 100
classic.mvCriteriaID = classic.mvCriteriaID + 1000
tbc.mvAchievementID = tbc.mvAchievementID + 100
tbc.mvCriteriaID = tbc.mvCriteriaID + 1000

local POINTS = 10

-- One achievement per dungeon, fed by core/GuildDungeons.lua, which only credits the final
-- boss while every member of the group is a guildmate.
local function guildRun(category, dungeon)
    return ns.Achievement(category, {
        name   = dungeon.title,
        desc   = ('Defeat %s in %s with a full group of %s guildmates.')
            :format(dungeon.boss, dungeon.name, ns.GUILD_NAME),
        points = POINTS,
        icon   = dungeon.icon,
        criteria = {
            { ns.CRITERIA_GUILD_RUN, {dungeon.key}, nil, dungeon.boss },
        },
    })
end

-- Every dungeon of an expansion, as one achievement asking for all the others.
local function everyDungeon(category, name, desc, points, icon, runs)
    return ns.Achievement(category, {
        name = name, desc = desc, points = points, icon = icon, meta = runs,
    })
end

local classicRuns = {}
for i, dungeon in ipairs(ns.Dungeons.classic) do
    classicRuns[i] = guildRun(classic, dungeon)
    A['GUILD_RUN_' .. dungeon.key] = classicRuns[i]
end

local tbcRuns = {}
for i, dungeon in ipairs(ns.Dungeons.tbc) do
    tbcRuns[i] = guildRun(tbc, dungeon)
    A['GUILD_RUN_' .. dungeon.key] = tbcRuns[i]
end

A.GUILD_DUNGEON_MASTER = everyDungeon(classic, 'Guild Dungeon Master',
    ('Complete every WoW Classic dungeon with a full group of %s guildmates.')
        :format(ns.GUILD_NAME),
    100, 'achievement_dungeon_classicdungeonmaster', classicRuns)

A.TBC_GUILD_DUNGEON_MASTER = everyDungeon(tbc, 'TBC Guild Dungeon Master',
    ('Complete every Burning Crusade dungeon with a full group of %s guildmates.')
        :format(ns.GUILD_NAME),
    100, 'achievement_dungeon_outland_dungeon_hero', tbcRuns)
