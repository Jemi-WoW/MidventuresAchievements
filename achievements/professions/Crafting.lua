local _, ns = ...
if ns.disabled then return end

local A = ns.achievements
local crafting = ns.categories.professionsCrafting

-- Fed by core/Crafting.lua. Anniversary counts a handful of specific items made, never the
-- total, and never who you made them for.

A.MADE_IT_MYSELF = ns.Chain(crafting, {
    name = function(n) return ('Craft %d Items'):format(n) end,
    desc = function(n) return ('Make %d items with your own two hands.'):format(n) end,
    criteria = ns.CRITERIA_CRAFTED,
    label = 'Items made',
    icons = {'-Inv_Hammer_20', '-Inv_Misc_ArmorKit_04', '-Trade_BlackSmithing'},
})

A.DUST_TO_DUST = ns.Achievement(crafting, {
    name   = 'Dust to Dust',
    desc   = 'Disenchant 100 items back into their parts.',
    points = 15,
    icon   = '-Inv_Enchant_DustIllusion',
    criteria = {
        { ns.CRITERIA_DISENCHANTS, nil, 100, 'Items disenchanted' },
    },
})

A.GUILD_SUPPLIER = ns.Achievement(crafting, {
    name   = 'Guild Supplier',
    desc   = ('Complete 50 trades with %s guildmates.'):format(ns.GUILD_NAME),
    points = 25,
    icon   = '-Inv_Misc_Bag_10',
    criteria = {
        { ns.CRITERIA_GUILD_TRADES, nil, 50, 'Trades with guildmates' },
    },
})

A.ENCHANTERS_FRIEND = ns.Achievement(crafting, {
    name   = "Enchanter's Friend",
    desc   = ('Put an enchant on a %s guildmate\'s gear.'):format(ns.GUILD_NAME),
    points = 20,
    icon   = '-Spell_Holy_GreaterHeal',
    criteria = {
        { ns.CRITERIA_ENCHANT_GUILD, nil, nil, 'A guildmate sent away better off' },
    },
})
