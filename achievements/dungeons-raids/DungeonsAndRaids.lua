local _, ns = ...
if ns.disabled then return end

local TYPE = CA_Criterias.TYPE
local A = ns.achievements
local classic, tbc = ns.categories.dungeonsClassic, ns.categories.dungeonsTBC

-- Guide: .AchievementGuide/DungeonsAndRaids.md. Append at the bottom, ids follow load order.

-- Anniversary has the last-boss kill already, so ask for more or gate on theirs.

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

-- The ids the retired guild-run achievements used are stepped past, never reused.
classic.mvAchievementID = classic.mvAchievementID + 100
classic.mvCriteriaID = classic.mvCriteriaID + 1000
tbc.mvAchievementID = tbc.mvAchievementID + 100
tbc.mvCriteriaID = tbc.mvCriteriaID + 1000

local POINTS = 10

-- One per dungeon, credited by core/GuildDungeons.lua when the whole group is ours.
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

-- How the runs went rather than where; parent category, since either expansion counts.
local anyDungeon = ns.categories.dungeons

A.DUNGEON_CRAWLER = ns.Chain(anyDungeon, {
    name = function(n) return ('Complete %d Guild Dungeon Runs'):format(n) end,
    desc = function(n)
        return ('Finish %d dungeons with a full group of %s guildmates.')
            :format(n, ns.GUILD_NAME)
    end,
    criteria = ns.CRITERIA_GUILD_RUNS,
    label = 'Guild runs finished',
    icons = {'-Inv_Misc_Key_03', 'achievement_dungeon_classicdungeonmaster',
        'inv_misc_map02'},
})

A.FLAWLESS = ns.Achievement(anyDungeon, {
    name   = 'Flawless',
    desc   = 'Finish a guild dungeon run without a single one of you dying.',
    points = 25,
    icon   = '-Spell_Holy_SealOfProtection',
    criteria = {
        { ns.CRITERIA_RUN_FLAWLESS, nil, nil, 'A run nobody died on' },
    },
})

A.FULL_HOUSE = ns.Achievement(anyDungeon, {
    name   = 'Full House',
    desc   = 'Finish a guild dungeon run with five different classes in the group.',
    points = 25,
    icon   = '-spell_holy_prayerofhealing',
    criteria = {
        { ns.CRITERIA_RUN_CLASSES, nil, nil, 'Five guildmates, five classes' },
    },
})
