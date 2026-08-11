local _, ns = ...
if ns.disabled then return end

local TYPE = CA_Criterias.TYPE
local A = ns.achievements
local PROF = ClassicAchievementsProfessions
local gathering, crafting, secondary =
    ns.categories.professionsGathering, ns.categories.professionsCrafting,
    ns.categories.professionsSecondary

-- Guide: .AchievementGuide/Professions.md. Append at the bottom, ids follow load order.

-- One criteria per profession, any of which earns it. PROF[x][3] is the localised name.
local function anyProfession(category, name, desc, points, icon, skill, professions, previous)
    local criteria = {}
    for i, profession in ipairs(professions) do
        criteria[i] = { TYPE.REACH_PROFESSION_LEVEL, {profession[1], skill}, nil, profession[3] }
    end
    return ns.Achievement(category, {
        name = name, desc = desc, points = points, icon = icon,
        anyCompletable = true, previous = previous, criteria = criteria,
    })
end

local GATHERING = { PROF.HERBALISM, PROF.MINING, PROF.SKINNING }
local CRAFTING = {
    PROF.ALCHEMY, PROF.BLACKSMITHING, PROF.ENCHANTING, PROF.ENGINEERING,
    PROF.LEATHERWORKING, PROF.TAILORING, PROF.JEWELCRAFTING,
}

A.STEADY_HANDS = anyProfession(gathering, 'Steady Hands',
    'Reach 75 skill in a gathering profession.', 10, '-Inv_Pick_01', 75, GATHERING)

A.WELL_STOCKED = anyProfession(gathering, 'Well Stocked',
    'Reach 150 skill in a gathering profession.', 15, '-Inv_Misc_ArmorKit_14', 150,
    GATHERING, A.STEADY_HANDS)

A.MAKING_THINGS = anyProfession(crafting, 'Making Things',
    'Reach 75 skill in a crafting profession.', 10, '-Inv_Misc_ArmorKit_04', 75, CRAFTING)

A.JOURNEYMAN = anyProfession(crafting, 'Journeyman',
    'Reach 150 skill in a crafting profession.', 15, '-Inv_Enchant_DustIllusion', 150,
    CRAFTING, A.MAKING_THINGS)

-- A plain secondary skill level duplicates Anniversary; the main professions do not.
