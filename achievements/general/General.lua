local _, ns = ...
if ns.disabled then return end

local TYPE = CA_Criterias.TYPE
local A = ns.achievements
local general = ns.categories.general
local levelling, combat, wealth =
    ns.categories.generalLevelling, ns.categories.generalCombat, ns.categories.generalWealth
local guild = ns.categories.generalGuild

-- How to write these: .AchievementGuide/General.md
-- Append new achievements at the bottom, ids are handed out in load order.

-- Sits in the parent category rather than a subcategory, because it is the welcome.
A.MIDVENTURER = ns.Achievement(general, {
    name   = 'Midventurer',
    desc   = ('Join the %s guild.'):format(ns.GUILD_NAME),
    points = 25,
    icon   = '-Inv_Banner_03',
    reward = 'Reward: a place in the Midventures community.',
    criteria = {
        { ns.CRITERIA_GUILD, nil, nil, ('Member of %s'):format(ns.GUILD_NAME) },
    },
})

A.FIRST_STEPS = ns.Achievement(levelling, {
    name   = 'First Steps',
    desc   = 'Reach level 5.',
    points = 10,
    icon   = '-Inv_Misc_Note_01',
    criteria = {
        { TYPE.REACH_LEVEL, {5} },
    },
})

A.BLOODED = ns.Achievement(combat, {
    name   = 'Blooded',
    desc   = 'Kill 10 monsters.',
    points = 10,
    icon   = '-Inv_Misc_Bone_DwarfSkull_01',
    criteria = {
        { TYPE.KILL_ANY_NPC, nil, 10, 'Monsters killed' },
    },
})

A.ROOM_TO_SPARE = ns.Achievement(wealth, {
    name   = 'Room to Spare',
    desc   = 'Purchase your first bank slot.',
    points = 15,
    icon   = '-inv_box_01',
    criteria = {
        { TYPE.BANK_SLOTS, nil, 1, 'Bank slots purchased' },
    },
})

A.TRAVELLING_CLOTHES = ns.Achievement(wealth, {
    name   = 'Travelling Clothes',
    desc   = 'Equip uncommon gear on your head, chest and legs.',
    points = 15,
    icon   = '-Inv_Enchant_EssenceNetherSmall',
    criteria = {
        { TYPE.GEAR_QUALITY, {1, 2}, nil, 'Head' },
        { TYPE.GEAR_QUALITY, {4, 2}, nil, 'Chest' },
        { TYPE.GEAR_QUALITY, {6, 2}, nil, 'Legs' },
    },
})

-- Guild chat, counted by core/GuildChat.lua. One criteria type feeds the whole chain, so
-- every tier fills at once and `previous` is what shows them one at a time.
local function chatter(name, desc, count, points, icon, previous)
    return ns.Achievement(guild, {
        name = name, desc = desc, points = points, icon = icon, previous = previous,
        criteria = {
            { ns.CRITERIA_GUILD_CHAT, nil, count, 'Messages sent' },
        },
    })
end

local function chatDesc(count)
    return ('Write %d messages in %s guild chat.'):format(count, ns.GUILD_NAME)
end

A.GUILD_CHAT_10 = chatter('Write in Guild chat 10 times',
    chatDesc(10), 10, 5, '-Inv_Letter_03')

A.GUILD_CHAT_50 = chatter('Write in Guild chat 50 times',
    chatDesc(50), 50, 10, '-Inv_Misc_Note_01', A.GUILD_CHAT_10)

A.GUILD_CHAT_67 = chatter('Write in Guild chat 67 times',
    chatDesc(67), 67, 10, '-Inv_Misc_Rune_01', A.GUILD_CHAT_50)

A.GUILD_CHAT_100 = chatter('Write in Guild chat 100 times',
    chatDesc(100), 100, 15, '-Inv_Misc_Book_09', A.GUILD_CHAT_67)

A.GUILD_CHAT_200 = chatter('Write in Guild chat 200 times',
    chatDesc(200), 200, 20, '-Inv_Scroll_05', A.GUILD_CHAT_100)

A.GUILD_CHAT_1000 = chatter('Write in Guild chat 1000 Times',
    chatDesc(1000), 1000, 30, '-Spell_Holy_Silence', A.GUILD_CHAT_200)
