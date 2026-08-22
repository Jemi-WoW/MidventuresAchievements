local _, ns = ...
if ns.disabled then return end

local TYPE = CA_Criterias.TYPE
local A = ns.achievements
local general = ns.categories.general
local levelling, combat, wealth =
    ns.categories.generalLevelling, ns.categories.generalCombat, ns.categories.generalWealth
local guild = ns.categories.generalGuild

-- Guide: .AchievementGuide/General.md. Append at the bottom, ids follow load order.

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

-- Guild chat, counted by core/GuildChat.lua; one criteria feeds every tier at once.
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
    chatDesc(67), 67, 10, '-inv_misc_rune_07', A.GUILD_CHAT_50)

A.GUILD_CHAT_100 = chatter('Write in Guild chat 100 times',
    chatDesc(100), 100, 15, '-Inv_Misc_Book_09', A.GUILD_CHAT_67)

A.GUILD_CHAT_200 = chatter('Write in Guild chat 200 times',
    chatDesc(200), 200, 20, '-inv_scroll_10', A.GUILD_CHAT_100)

A.GUILD_CHAT_1000 = chatter('Write in Guild chat 1000 Times',
    chatDesc(1000), 1000, 30, '-spell_shadow_deathscream', A.GUILD_CHAT_200)

-- Read off the combat log by core/CritStrike.lua, and only the player's own hits count.
A.A_REAL_CRITTER = ns.Achievement(combat, {
    name   = 'A real critter!',
    desc   = 'Land a critical strike of 300 damage or more.',
    points = 10,
    icon   = '-Ability_Rogue_Eviscerate',
    criteria = {
        { ns.CRITERIA_CRIT_ABOVE, {300}, nil, 'Critical strike of 300' },
    },
})

-- Armour, cloak, neck and weapon: rings and trinkets are dropped from the slot list.
local SKIPPED_SLOTS = {
    FIRST_RING = true,
    SECOND_RING = true,
    FIRST_TRINKET = true,
    SECOND_TRINKET = true,
}

-- GEAR_QUALITY fires for every quality up to the one worn, so these ask for it or better.
local function fullGear(name, desc, quality, points, icon, previous)
    local criteria = {}
    for idx, slot in ipairs(CA_Criterias.GEAR_SLOT) do
        if not SKIPPED_SLOTS[slot] then
            criteria[#criteria + 1] = { TYPE.GEAR_QUALITY, {idx, quality}, nil,
                ns.Localized('GEAR_SLOT_' .. slot) }
        end
    end
    return ns.Achievement(wealth, {
        name = name, desc = desc, points = points, icon = icon,
        previous = previous, criteria = criteria,
    })
end

A.I_AM_GREEN = fullGear('I am GREEN!',
    'Equip uncommon or better gear in every slot below.', 2, 20, '-inv_bijou_green')

A.BLUE_IS_THE_COLOR = fullGear('Blue is the color',
    'Equip rare or better gear in every slot below.', 3, 30, '-Spell_Frost_WizardMark',
    A.I_AM_GREEN)

-- The chat chain carries on in thousands, on the same criteria as the tiers above.
A.GUILD_CHAT_2000 = chatter('Write in Guild chat 2000 times',
    chatDesc(2000), 2000, 35, '-inv_misc_book_11', A.GUILD_CHAT_1000)

A.GUILD_CHAT_3000 = chatter('Write in Guild chat 3000 times',
    chatDesc(3000), 3000, 40, '-inv_scroll_10', A.GUILD_CHAT_2000)

A.GUILD_CHAT_4000 = chatter('Write in Guild chat 4000 times',
    chatDesc(4000), 4000, 45, '-Inv_Misc_Note_02', A.GUILD_CHAT_3000)

A.GUILD_CHAT_5000 = chatter('Write in Guild chat 5000 times',
    chatDesc(5000), 5000, 50, '-spell_Shadow_ConeOfSilence', A.GUILD_CHAT_4000)

-- What is worn where, read by core/Equipment.lua; theirs starts at uncommon.
A.SHOULDERS_OF_GIANTS = ns.Achievement(wealth, {
    name   = 'Shoulders Of Giants',
    desc   = 'Equip your first set of shoulders.',
    points = 5,
    icon   = '-Inv_Misc_ArmorKit_14',
    criteria = {
        { ns.CRITERIA_EQUIPMENT, {'SHOULDERS'}, nil, 'Shoulders equipped' },
    },
})

A.BLING = ns.Achievement(wealth, {
    name   = 'Bling',
    desc   = 'Equip your first ring.',
    points = 5,
    icon   = '-Inv_Jewelry_Ring_03',
    criteria = {
        { ns.CRITERIA_EQUIPMENT, {'RING_ANY'}, nil, 'Ring equipped' },
    },
})

A.BLING_BLING = ns.Achievement(wealth, {
    name     = 'Bling Bling!',
    desc     = 'Wear a ring in both ring slots.',
    points   = 10,
    icon     = '-inv_jewelry_ring_34',
    previous = A.BLING,
    criteria = {
        { ns.CRITERIA_EQUIPMENT, {'RING_BOTH'}, nil, 'Both rings equipped' },
    },
})

A.A_TRUE_DENTER = ns.Achievement(guild, {
    name   = 'A True Denter',
    desc   = ('Wear the %s guild tabard.'):format(ns.GUILD_NAME),
    points = 15,
    icon   = '-inv_shirt_guildtabard_01',
    criteria = {
        { ns.CRITERIA_EQUIPMENT, {'GUILD_TABARD'}, nil, 'Guild tabard worn' },
    },
})

-- Helpful spells landed on other players, counted by core/Buffs.lua.
local function helper(name, count, points, icon, previous)
    return ns.Achievement(general, {
        name = name, points = points, icon = icon, previous = previous,
        desc = ('Land %d helpful spells on other players.'):format(count),
        criteria = {
            { ns.CRITERIA_BUFF_PLAYERS, nil, count, 'Players buffed' },
        },
    })
end

A.HELPFUL_10 = helper('Buff 10 Players', 10, 5, '-Spell_Holy_Divinespirit')
A.HELPFUL_20 = helper('Buff 20 Players', 20, 10, '-Spell_Magic_GreaterBlessingOfKings', A.HELPFUL_10)
A.HELPFUL_50 = helper('Buff 50 Players', 50, 10, '-Spell_Holy_Prayerofspirit', A.HELPFUL_20)
A.HELPFUL_100 = helper('Buff 100 Players', 100, 15, '-spell_holy_symbolofhope', A.HELPFUL_50)
A.HELPFUL_200 = helper('Buff 200 Players', 200, 20, '-spell_holy_surgeoflight', A.HELPFUL_100)
A.HELPFUL_300 = helper('Buff 300 Players', 300, 20, '-Spell_Nature_Reincarnation', A.HELPFUL_200)
A.HELPFUL_400 = helper('Buff 400 Players', 400, 25, '-spell_holy_sealofsacrifice', A.HELPFUL_300)
A.HELPFUL_500 = helper('Buff 500 Players', 500, 25, '-Spell_Holy_Mindsooth', A.HELPFUL_400)
A.HELPFUL_1000 = helper('Buff 1000 Players', 1000, 30, '-inv_misc_cauldron_arcane', A.HELPFUL_500)
A.HELPFUL_2000 = helper('Buff 2000 Players', 2000, 35, '-inv_misc_cauldron_nature', A.HELPFUL_1000)
A.HELPFUL_3000 = helper('Buff 3000 Players', 3000, 40, '-spell_holy_revivechampion', A.HELPFUL_2000)
A.HELPFUL_4000 = helper('Buff 4000 Players', 4000, 45, '-spell_holy_summonchampion', A.HELPFUL_3000)
A.HELPFUL_5000 = helper('Buff 5000 Players', 5000, 50, 'spell_holy_aspiration', A.HELPFUL_4000)
