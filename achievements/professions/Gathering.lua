local _, ns = ...
if ns.disabled then return end

local A = ns.achievements
local gathering = ns.categories.professionsGathering

-- Anniversary owns the skill levels, so these count the work instead. Fed by
-- core/Gathering.lua, which only hears about a node that was actually finished.

A.MINING = ns.Chain(gathering, {
    name = function(n) return ('Mine %d Nodes'):format(n) end,
    desc = function(n) return ('Mine %d ore veins out of the ground.'):format(n) end,
    criteria = ns.CRITERIA_GATHER,
    data = {ns.GATHER_MINING},
    label = 'Veins mined',
    icons = {'-Inv_Pick_02', '-Inv_Ore_Copper_01', '-Inv_Ore_Thorium_02'},
})

A.HERBALISM = ns.Chain(gathering, {
    name = function(n) return ('Pick %d Herbs'):format(n) end,
    desc = function(n) return ('Pick %d herbs out of the ground.'):format(n) end,
    criteria = ns.CRITERIA_GATHER,
    data = {ns.GATHER_HERBS},
    label = 'Herbs picked',
    icons = {'-Inv_Misc_Herb_07', '-Inv_Misc_Flower_02', '-Inv_Misc_Herb_11'},
})

A.SKINNING = ns.Chain(gathering, {
    name = function(n) return ('Skin %d Beasts'):format(n) end,
    desc = function(n) return ('Take the hide off %d beasts.'):format(n) end,
    criteria = ns.CRITERIA_GATHER,
    data = {ns.GATHER_SKINNING},
    label = 'Beasts skinned',
    icons = {'-Inv_Misc_Pelt_Wolf_01', '-Inv_Misc_ArmorKit_17', '-Inv_Misc_Pelt_Bear_03'},
})
