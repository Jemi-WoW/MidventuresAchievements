local _, ns = ...
if ns.disabled then return end

local A = ns.achievements
local food = ns.categories.generalFood

-- Fed by core/Consumables.lua, which watches the Food and Drink auras rather than the bag,
-- so only what actually went down counts.

A.SECOND_BREAKFAST = ns.Chain(food, {
    name = function(n) return ('Second Breakfast %d Times'):format(n) end,
    desc = function(n) return ('Sit down to eat %d times.'):format(n) end,
    criteria = ns.CRITERIA_EAT,
    label = 'Meals eaten',
    icons = {'-inv_misc_food_15', '-Inv_Misc_Food_49', '-inv_misc_food_84_roastclefthoof'},
})

A.HYDRATION_NATION = ns.Chain(food, {
    name = function(n) return ('Hydration Nation %d Times'):format(n) end,
    desc = function(n) return ('Sit down for a drink %d times.'):format(n) end,
    criteria = ns.CRITERIA_DRINK,
    label = 'Drinks drunk',
    icons = {'-Inv_Drink_04', '-inv_drink_13', '-Inv_Drink_17'},
})

A.ONE_MORE_ROUND = ns.Achievement(food, {
    name   = 'One More Round',
    desc   = 'Drink 25 alcoholic drinks.',
    points = 15,
    icon   = '-inv_misc_beer_02',
    criteria = {
        { ns.CRITERIA_ALCOHOL, nil, 25, 'Drinks with a kick' },
    },
})

A.BREWFEST_REGULAR = ns.Achievement(food, {
    name     = 'Brewfest Regular',
    desc     = 'Drink 100 alcoholic drinks.',
    points   = 25,
    icon     = '-inv_cask_01',
    previous = A.ONE_MORE_ROUND,
    criteria = {
        { ns.CRITERIA_ALCOHOL, nil, 100, 'Drinks with a kick' },
    },
})

A.CAKE_DAY = ns.Achievement(food, {
    name   = 'Cake Day',
    desc   = 'Eat a Delicious Chocolate Cake.',
    points = 10,
    icon   = '-inv_misc_celebrationcake_01',
    criteria = {
        { ns.CRITERIA_CONSUME_ITEM, {34767}, nil, 'Delicious Chocolate Cake' },
    },
})
