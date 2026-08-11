local _, ns = ...
if ns.disabled then return end

local A = ns.achievements
local guild = ns.categories.generalGuild

-- Being in the guild rather than merely joining it. Trackers: core/GuildChat.lua,
-- core/Emotes.lua and core/GuildPresence.lua.

A.SAY_MY_NAME = ns.Chain(guild, {
    name = function(n) return ('Say My Name %d Times'):format(n) end,
    desc = function(n) return ('Name a guildmate in guild chat %d times.'):format(n) end,
    criteria = ns.CRITERIA_GUILD_NAMED,
    label = 'Guildmates named',
    icons = {'-Inv_Letter_03', '-Spell_Holy_Mindsooth', '-Inv_Misc_Note_01'},
})

A.HUG_IT_OUT = ns.Chain(guild, {
    name = function(n) return ('Hug It Out %d Times'):format(n) end,
    desc = function(n) return ('Hug a guildmate %d times.'):format(n) end,
    criteria = ns.CRITERIA_EMOTE_AT,
    data = {'HUG', ns.GUILDMATE},
    label = 'Guildmates hugged',
    icons = {'-Spell_Holy_Prayerofspirit', '-inv_valentineschocolate02', '-inv_rosebouquet01'},
})

A.SLAPPER = ns.Chain(guild, {
    name = function(n) return ('Slap Happy %d Times'):format(n) end,
    desc = function(n) return ('Slap a guildmate %d times.'):format(n) end,
    criteria = ns.CRITERIA_EMOTE_AT,
    data = {'SLAP', ns.GUILDMATE},
    label = 'Guildmates slapped',
    icons = {'-Ability_Warrior_DecisiveStrike', '-Ability_Gouge', '-ability_warrior_warcry'},
})

-- core/Emotes.lua adds /fart where the client has none, so this is earnable either way.
A.SILENT_BUT_DEADLY = ns.Chain(guild, {
    name = function(n) return ('Silent but Deadly %d Times'):format(n) end,
    desc = function(n) return ('Fart on the Guild Master %d times.'):format(n) end,
    criteria = ns.CRITERIA_EMOTE_AT,
    data = {'FART', ns.GUILD_MASTER},
    label = 'Guild Masters offended',
    icons = {'-Spell_Nature_Acid_01', '-inv_mushroom_11', '-spell_shadow_abominationexplosion'},
})

A.REZZED_AGAIN = ns.Chain(guild, {
    name = function(n) return ('Rezzed Again %d Times'):format(n) end,
    desc = function(n) return ('Bring %d guildmates back from the dead.'):format(n) end,
    criteria = ns.CRITERIA_RESURRECTS,
    label = 'Guildmates raised',
    icons = {'-Spell_Nature_Reincarnation', '-spell_holy_revivechampion', '-spell_holy_summonchampion'},
})

A.ROLL_CALL = ns.Achievement(guild, {
    name   = 'Roll Call',
    desc   = ('Be online with 10 other %s guildmates at once.'):format(ns.GUILD_NAME),
    points = 20,
    icon   = '-Inv_Misc_Book_09',
    criteria = {
        { ns.CRITERIA_GUILD_ONLINE, {11}, nil, 'Guildmates online at once' },
    },
})

A.DANCE_PARTY = ns.Achievement(guild, {
    name   = 'Dance Party',
    desc   = 'Dance with four guildmates in your group at the same time.',
    points = 25,
    icon   = '-inv_misc_celebrationcake_01',
    criteria = {
        { ns.CRITERIA_DANCE_PARTY, {5}, nil, 'Guildmates dancing together' },
    },
})

A.GUILD_TOUR_GUIDE = ns.Achievement(guild, {
    name   = 'Guild Tour Guide',
    desc   = 'Group up with 25 different guildmates.',
    points = 30,
    icon   = '-Inv_Banner_03',
    criteria = {
        { ns.CRITERIA_GUILD_GROUPED, nil, 25, 'Guildmates grouped with' },
    },
})

-- Two more for the Guild Master to put up with, so the whole set can be rolled up.
A.GROUP_HUG = ns.Achievement(guild, {
    name   = 'Group Hug',
    desc   = 'Hug the Guild Master.',
    points = 15,
    icon   = '-inv_rosebouquet01',
    criteria = {
        { ns.CRITERIA_EMOTE_AT, {'HUG', ns.GUILD_MASTER}, nil, 'Guild Master hugged' },
    },
})

A.INSUBORDINATION = ns.Achievement(guild, {
    name   = 'Insubordination',
    desc   = 'Slap the Guild Master. Consider your rank.',
    points = 15,
    icon   = '-Ability_Warrior_DecisiveStrike',
    criteria = {
        { ns.CRITERIA_EMOTE_AT, {'SLAP', ns.GUILD_MASTER}, nil, 'Guild Master slapped' },
    },
})

A.THANKS_FOR_NOTHING = ns.Achievement(guild, {
    name   = 'Thanks For Nothing',
    desc   = 'Die with a guildmate who could have healed you standing right there.',
    points = 10,
    icon   = '-spell_holy_sealofsacrifice',
    criteria = {
        { ns.CRITERIA_DEATH_WITH_HEALER, nil, nil, 'Died beside a guild healer' },
    },
})
