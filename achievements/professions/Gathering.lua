local _, ns = ...
if ns.disabled then return end

local A = ns.achievements
local gathering = ns.categories.professionsGathering

-- Anniversary owns the skill levels, so these count the work. Fed by core/Gathering.lua.

A.MINING = ns.Chain(gathering, {
    name = function(n) return ('Mine %d Nodes'):format(n) end,
    desc = function(n) return ('Mine %d ore veins out of the ground.'):format(n) end,
    criteria = ns.CRITERIA_GATHER,
    data = {ns.GATHER_MINING},
    label = 'Veins mined',
    icons = {'-inv_pick_01', '-inv_ore_mithril_01', '-inv_misc_qirajicrystal_02'},
})

A.HERBALISM = ns.Chain(gathering, {
    name = function(n) return ('Pick %d Herbs'):format(n) end,
    desc = function(n) return ('Pick %d herbs out of the ground.'):format(n) end,
    criteria = ns.CRITERIA_GATHER,
    data = {ns.GATHER_HERBS},
    label = 'Herbs picked',
    icons = {'-inv_mushroom_11', '-inv_rosebouquet01', '-inv_misc_cauldron_nature'},
})

A.SKINNING = ns.Chain(gathering, {
    name = function(n) return ('Skin %d Beasts'):format(n) end,
    desc = function(n) return ('Take the hide off %d beasts.'):format(n) end,
    criteria = ns.CRITERIA_GATHER,
    data = {ns.GATHER_SKINNING},
    label = 'Beasts skinned',
    icons = {'-Inv_Misc_Pelt_Wolf_01', '-inv_misc_armorkit_14', '-inv_misc_monsterclaw_02'},
})
