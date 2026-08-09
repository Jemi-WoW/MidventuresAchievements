local _, ns = ...
if ns.disabled then return end

local TYPE = CA_Criterias.TYPE
local A = ns.achievements
local odd = ns.categories.generalOddities

-- Combat oddities and silly business. Fed by core/CombatExtras.lua, core/Emotes.lua,
-- core/Zones.lua, core/Equipment.lua and core/GuildChat.lua.

A.A_REALER_CRITTER = ns.Achievement(odd, {
    name     = 'A realer critter!',
    desc     = 'Land a critical strike of 500 damage or more.',
    points   = 15,
    icon     = '-Ability_Rogue_Eviscerate',
    previous = A.A_REAL_CRITTER,
    criteria = {
        { ns.CRITERIA_CRIT_ABOVE, {500}, nil, 'Critical strike of 500' },
    },
})

A.AN_EVEN_REALER_CRITTER = ns.Achievement(odd, {
    name     = 'An even realer critter!',
    desc     = 'Land a critical strike of 1000 damage or more.',
    points   = 25,
    icon     = '-Ability_Thunderbolt',
    previous = A.A_REALER_CRITTER,
    criteria = {
        { ns.CRITERIA_CRIT_ABOVE, {1000}, nil, 'Critical strike of 1000' },
    },
})

A.THE_REALEST_CRITTER = ns.Achievement(odd, {
    name     = 'The realest critter!',
    desc     = 'Land a critical strike of 2000 damage or more.',
    points   = 40,
    icon     = '-Inv_Hammer_Unique_Sulfuras',
    previous = A.AN_EVEN_REALER_CRITTER,
    criteria = {
        { ns.CRITERIA_CRIT_ABOVE, {2000}, nil, 'Critical strike of 2000' },
    },
})

A.OVERKILL = ns.Achievement(odd, {
    name   = 'Overkill',
    desc   = 'Land a killing blow with 500 damage to spare.',
    points = 20,
    icon   = '-Ability_Warrior_DecisiveStrike',
    criteria = {
        { ns.CRITERIA_OVERKILL, {500}, nil, 'Damage wasted on a corpse' },
    },
})

A.PACIFIST_RUN = ns.Achievement(odd, {
    name   = 'Pacifist Run',
    desc   = 'Reach level 10 having killed fewer than 50 things yourself.',
    points = 25,
    icon   = '-Spell_Holy_Mindsooth',
    criteria = {
        { ns.CRITERIA_PACIFIST, {10, 50}, nil, 'Level 10, hands clean' },
    },
})

A.NOT_TODAY = ns.Achievement(odd, {
    name   = 'Not Today',
    desc   = 'Drop below 5% health in a dungeon and still be standing half a minute later.',
    points = 20,
    icon   = '-ability_warrior_secondwind',
    criteria = {
        { ns.CRITERIA_SURVIVE_LOW, nil, nil, 'Survived on nothing' },
    },
})

A.INTERRUPTED = ns.Chain(odd, {
    name = function(n) return ('Interrupted %d Times'):format(n) end,
    desc = function(n) return ('Interrupt %d casts.'):format(n) end,
    criteria = ns.CRITERIA_INTERRUPTS,
    label = 'Casts interrupted',
    icons = {'-Ability_Cheapshot', '-Spell_Shadow_ConeOfSilence', '-Spell_Holy_Silence'},
})

A.DISPEL_THIS = ns.Chain(odd, {
    name = function(n) return ('Dispel This %d Times'):format(n) end,
    desc = function(n) return ('Dispel %d effects.'):format(n) end,
    criteria = ns.CRITERIA_DISPELS,
    label = 'Effects dispelled',
    icons = {'-Spell_Arcane_MassDispel', '-Inv_Enchant_DustIllusion', '-spell_holy_surgeoflight'},
})

A.KNUCKLE_SANDWICH = ns.Chain(odd, {
    name = function(n) return ('Knuckle Sandwich %d Times'):format(n) end,
    desc = function(n) return ('Land %d melee hits with an empty main hand.'):format(n) end,
    criteria = ns.CRITERIA_UNARMED_HITS,
    label = 'Punches landed',
    icons = {'-Ability_Warrior_Innerrage', '-ability_warrior_rallyingcry', '-Ability_Gouge'},
})

A.FASHION_OVER_FUNCTION = ns.Achievement(odd, {
    name   = 'Fashion Over Function',
    desc   = 'Land a killing blow wearing nothing but a shirt and a tabard.',
    points = 25,
    icon   = '-inv_shirt_08',
    criteria = {
        { ns.CRITERIA_FASHION_KILL, nil, nil, 'Killed in your best outfit' },
    },
})

A.CHICKEN_DINNER = ns.Achievement(odd, {
    name   = 'Chicken Dinner',
    desc   = 'Use /chicken on a Chicken.',
    points = 10,
    icon   = '-ability_hunter_pet_turtle',
    criteria = {
        { ns.CRITERIA_EMOTE_AT, {'CHICKEN', 'Chicken'}, nil, 'Chicken addressed' },
    },
})

-- The one boss the whole guild has a grudge against.
A.SLAP_DRAKKISATH = ns.Achievement(odd, {
    name   = 'Slap Drakkisath',
    desc   = 'Use /slap on General Drakkisath in Upper Blackrock Spire.',
    points = 20,
    icon   = 'achievement_boss_generaldrakkisath',
    criteria = {
        { ns.CRITERIA_EMOTE_AT, {'SLAP', 'General Drakkisath'}, nil, 'Drakkisath slapped' },
    },
})

A.BARRENS_CHAT_SURVIVOR = ns.Achievement(odd, {
    name   = 'Barrens Chat Survivor',
    desc   = 'Write 1000 guild chat messages while standing in The Barrens.',
    points = 40,
    icon   = 'barrens',
    criteria = {
        { ns.CRITERIA_GUILD_CHAT_ZONE, {17}, 1000, 'Messages sent in The Barrens' },
    },
})

A.MANKRIKS_WIFE = ns.Achievement(odd, {
    name   = "Mankrik's Wife",
    desc   = 'Finally find her, and complete "Lost in Battle".',
    points = 15,
    icon   = '-Inv_Misc_Bone_DwarfSkull_01',
    criteria = {
        { TYPE.COMPLETE_QUEST, {4921}, nil, 'Lost in Battle' },
    },
})

A.DEEP_SEA_DIVER = ns.Achievement(odd, {
    name   = 'Deep Sea Diver',
    desc   = 'Swim out into the Great Sea, where the map gives up on you.',
    points = 20,
    icon   = 'inv_misc_fish_50',
    criteria = {
        { ns.CRITERIA_ZONE_VISIT, {207}, nil, 'The Great Sea' },
    },
})

-- More for core/Emotes.lua, which matches on who the emote was aimed at.
A.PUCKER_UP = ns.Achievement(odd, {
    name   = 'Pucker Up',
    desc   = 'Kiss the Guild Master.',
    points = 15,
    icon   = '-inv_valentineschocolate02',
    criteria = {
        { ns.CRITERIA_EMOTE_AT, {'KISS', ns.GUILD_MASTER}, nil, 'Guild Master kissed' },
    },
})

A.MOO = ns.Achievement(odd, {
    name   = 'Moo',
    desc   = 'Use /moo on a Cow. She has heard it before.',
    points = 10,
    icon   = '-Inv_Misc_Food_49',
    criteria = {
        { ns.CRITERIA_EMOTE_AT, {'MOO', 'Cow'}, nil, 'Cow addressed' },
    },
})

-- Cats come as Cat, Siamese Cat, Mountain Cat and so on, so this asks for the word rather
-- than one name. The frontier pattern keeps Bobcat and Wildcat out of it.
A.HERE_KITTY = ns.Achievement(odd, {
    name   = 'Here Kitty',
    desc   = 'Use /beg on a cat. It will not help.',
    points = 10,
    icon   = '-ability_hunter_catlikereflexes',
    criteria = {
        { ns.CRITERIA_EMOTE_AT, {'BEG', '*%f[%a]cat%f[%A]'}, nil, 'Cat begged at' },
    },
})

A.HOW_RUDE = ns.Achievement(odd, {
    name   = 'How Rude',
    desc   = 'Use /rude on the Guild Master, and live with that.',
    points = 15,
    icon   = '-Ability_Gouge',
    criteria = {
        { ns.CRITERIA_EMOTE_AT, {'RUDE', ns.GUILD_MASTER}, nil, 'Guild Master offended' },
    },
})

A.NAKED_GNOME_RUN = ns.Achievement(odd, {
    name   = 'Naked Gnome Run',
    desc   = 'Get from Stormwind to Ironforge without a stitch on.',
    points = 30,
    icon   = '-inv_chest_cloth_04',
    criteria = {
        { ns.CRITERIA_NAKED_RUN, nil, nil, 'Ironforge reached, still naked' },
    },
})
