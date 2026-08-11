local _, ns = ...
if ns.disabled then return end

local A = ns.achievements
local raids = ns.categories.dungeonsRaids

-- Guide: .AchievementGuide/DungeonsAndRaids.md. Append at the bottom, ids follow load order.

-- Anniversary has the kill; ours asks who you brought.
local function guildRaid(raid)
    return ns.Achievement(raids, {
        name   = raid.title,
        desc   = ('Defeat %s in %s with at least %d %s guildmates in the raid.')
            :format(raid.boss, raid.name, raid.need, ns.GUILD_NAME),
        points = raid.points,
        icon   = raid.icon,
        criteria = {
            { ns.CRITERIA_GUILD_RAID, {raid.key}, nil, raid.boss },
        },
    })
end

local classicRaids = {}
for i, raid in ipairs(ns.Raids.classic) do
    classicRaids[i] = guildRaid(raid)
    A['GUILD_RAID_' .. raid.key] = classicRaids[i]
end

local tbcRaids = {}
for i, raid in ipairs(ns.Raids.tbc) do
    tbcRaids[i] = guildRaid(raid)
    A['GUILD_RAID_' .. raid.key] = tbcRaids[i]
end

A.GUILD_RAID_MASTER = ns.Achievement(raids, {
    name   = 'Guild Raid Master',
    desc   = ('Clear every WoW Classic raid with %s.'):format(ns.GUILD_NAME),
    points = 100,
    icon   = 'achievement_boss_ragnaros',
    meta   = classicRaids,
})

A.TBC_GUILD_RAID_MASTER = ns.Achievement(raids, {
    name   = 'TBC Guild Raid Master',
    desc   = ('Clear every Burning Crusade raid with %s.'):format(ns.GUILD_NAME),
    points = 100,
    icon   = 'achievement_boss_illidan',
    meta   = tbcRaids,
})
