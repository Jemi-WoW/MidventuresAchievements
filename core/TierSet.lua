local _, ns = ...
if ns.disabled then return end

-- Wearing a full Tier 0.5 set somewhere. Data is the AreaTableLocale id to be standing in.
CA_Criterias.dataLengths[ns.CRITERIA_TIER_SET] = 1
CA_Criterias.criterias[ns.CRITERIA_TIER_SET] = {}

-- Dungeon Set 2, one row per class, ids straight out of AtlasLoot's ItemSet data.
local SETS = {
    {21999, 22001, 21997, 21996, 21998, 21994, 22000, 21995}, -- Battlegear of Heroism
    {22005, 22008, 22009, 22004, 22006, 22002, 22007, 22003}, -- Darkmantle Armor
    {22109, 22112, 22113, 22108, 22110, 22106, 22111, 22107}, -- Feralheart Raiment
    {22080, 22082, 22083, 22079, 22081, 22078, 22085, 22084}, -- Vestments of the Virtuous
    {22013, 22016, 22060, 22011, 22015, 22010, 22017, 22061}, -- Beastmaster Armor
    {22091, 22093, 22089, 22088, 22090, 22086, 22092, 22087}, -- Soulforge Armor
    {22065, 22068, 22069, 22063, 22066, 22062, 22067, 22064}, -- Sorcerer's Regalia
    {22074, 22073, 22075, 22071, 22077, 22070, 22072, 22076}, -- Deathmist Raiment
    {22097, 22101, 22102, 22095, 22099, 22098, 22100, 22096}, -- The Five Thunders
}

-- The slots that read as wearing the set, rather than any five pieces.
local REQUIRED_SLOTS = {
    1,  -- Head
    3,  -- Shoulders
    5,  -- Chest
    7,  -- Legs
    10, -- Gloves
}

-- All of them have to come from the same set, so half of one and half of another is not it.
local function wearingASet()
    local worn = {}
    for _, slot in ipairs(REQUIRED_SLOTS) do
        local itemID = GetInventoryItemID('player', slot)
        if not itemID then return false end
        worn[itemID] = true
    end

    for _, set in ipairs(SETS) do
        local pieces = 0
        for _, itemID in ipairs(set) do
            if worn[itemID] then pieces = pieces + 1 end
        end
        if pieces == #REQUIRED_SLOTS then return true end
    end
    return false
end

local function check()
    local zone = GetZoneText()
    for areaID in pairs(CA_Criterias.criterias[ns.CRITERIA_TIER_SET]) do
        if AreaTableLocale[areaID] == zone and wearingASet() then
            CA_Criterias:Trigger(ns.CRITERIA_TIER_SET, {areaID})
        end
    end
end

-- Gear takes a moment to be readable after a zone in, and the set can also go on afterwards.
local watcher = CreateFrame('Frame')
watcher:RegisterEvent('PLAYER_ENTERING_WORLD')
watcher:RegisterEvent('ZONE_CHANGED_NEW_AREA')
watcher:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
watcher:SetScript('OnEvent', function() C_Timer.After(2, check) end)
