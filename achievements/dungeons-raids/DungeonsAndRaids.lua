local _, ns = ...
if ns.disabled then return end

local TYPE = CA_Criterias.TYPE
local A = ns.achievements
local classic, tbc, raids =
    ns.categories.dungeonsClassic, ns.categories.dungeonsTBC, ns.categories.dungeonsRaids

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

-- One criteria per dungeon, both fed by core/GuildDungeons.lua, which only credits a boss
-- while the party is five guildmates. Running counts the last boss, clearing counts them all.
local function guildRun(category, criteriaType, name, desc, points, icon, list, previous)
    local criteria = {}
    for i, dungeon in ipairs(list) do
        criteria[i] = { criteriaType, {dungeon.key}, nil, dungeon.name }
    end
    return ns.Achievement(category, {
        name = name, desc = desc, points = points, icon = icon,
        previous = previous, criteria = criteria,
    })
end

A.GUILD_RUNNER = guildRun(classic, ns.CRITERIA_GUILD_RUN, 'Guild Runner',
    ('Complete every WoW Classic dungeon in a party of five %s guildmates.')
        :format(ns.GUILD_NAME),
    50, 'achievement_dungeon_classicraider', ns.Dungeons.classic)

A.GUILD_DUNGEON_MASTER = guildRun(classic, ns.CRITERIA_GUILD_CLEAR, 'Guild Dungeon Master',
    ('Clear every boss of every WoW Classic dungeon in a party of five %s guildmates.')
        :format(ns.GUILD_NAME),
    75, 'achievement_dungeon_classicdungeonmaster', ns.Dungeons.classic)

A.TBC_GUILD_RUNNER = guildRun(tbc, ns.CRITERIA_GUILD_RUN, 'TBC Guild Runner',
    ('Complete every Burning Crusade dungeon in a party of five %s guildmates.')
        :format(ns.GUILD_NAME),
    50, 'achievement_dungeon_outland_dungeon_hero', ns.Dungeons.tbc)

A.TBC_GUILD_DUNGEON_MASTER = guildRun(tbc, ns.CRITERIA_GUILD_CLEAR, 'TBC Guild Dungeon Master',
    ('Clear every boss of every Burning Crusade dungeon in a party of five %s guildmates.')
        :format(ns.GUILD_NAME),
    75, 'achievement_boss_illidan', ns.Dungeons.tbc)
