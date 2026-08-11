local _, ns = ...
if ns.disabled then return end

-- What is worn where, since GEAR_QUALITY skips whites and has no tabard slot.
CA_Criterias.dataLengths[ns.CRITERIA_EQUIPMENT] = 1
CA_Criterias.criterias[ns.CRITERIA_EQUIPMENT] = {}

-- Gear worn through to nothing. Data is how many pieces are at zero at once.
CA_Criterias.dataLengths[ns.CRITERIA_LOW_DURABILITY] = 1
CA_Criterias.criterias[ns.CRITERIA_LOW_DURABILITY] = {}

-- Two cities reached with nothing on, in one attempt.
CA_Criterias.dataLengths[ns.CRITERIA_NAKED_RUN] = 0
CA_Criterias.criterias[ns.CRITERIA_NAKED_RUN] = {}

local GUILD_TABARD = 5976

-- Everything that would count as being dressed.
local ALL_SLOTS = {
    'HEADSLOT', 'SHOULDERSLOT', 'CHESTSLOT', 'WAISTSLOT', 'LEGSSLOT', 'FEETSLOT',
    'WRISTSLOT', 'HANDSSLOT', 'BACKSLOT', 'MAINHANDSLOT', 'SECONDARYHANDSLOT',
    'RANGEDSLOT', 'NECKSLOT', 'FINGER0SLOT', 'FINGER1SLOT', 'TRINKET0SLOT',
    'TRINKET1SLOT', 'SHIRTSLOT', 'TABARDSLOT',
}

local function itemIn(slot)
    return GetInventoryItemID('player', GetInventorySlotInfo(slot))
end

-- Data is one of these keys, so an achievement asks for a state rather than a slot number.
local CHECKS = {
    SHOULDERS    = function() return itemIn('SHOULDERSLOT') ~= nil end,
    RING_ANY     = function() return itemIn('FINGER0SLOT') ~= nil or itemIn('FINGER1SLOT') ~= nil end,
    RING_BOTH    = function() return itemIn('FINGER0SLOT') ~= nil and itemIn('FINGER1SLOT') ~= nil end,
    GUILD_TABARD = function() return itemIn('TABARDSLOT') == GUILD_TABARD end,
}

-- Only the checks something actually asks for are worth running.
local function evaluate()
    for key in pairs(CA_Criterias.criterias[ns.CRITERIA_EQUIPMENT]) do
        local check = CHECKS[key]
        if check and check() then
            CA_Criterias:Trigger(ns.CRITERIA_EQUIPMENT, {key})
        end
    end
end

local function naked()
    for _, slot in ipairs(ALL_SLOTS) do
        if itemIn(slot) then return false end
    end
    return true
end

-- Pieces at zero durability, which the client reports per slot.
local function brokenPieces()
    local broken = 0
    for _, slot in ipairs(ALL_SLOTS) do
        local id = GetInventorySlotInfo(slot)
        local current, maximum = GetInventoryItemDurability and GetInventoryItemDurability(id)
        if current == 0 and maximum and maximum > 0 then broken = broken + 1 end
    end
    return broken
end

local function checkDurability()
    local broken = brokenPieces()
    for wanted in pairs(CA_Criterias.criterias[ns.CRITERIA_LOW_DURABILITY]) do
        if broken >= wanted then
            CA_Criterias:Trigger(ns.CRITERIA_LOW_DURABILITY, {wanted})
        end
    end
end

-- Stormwind then Ironforge with nothing on; putting anything back on clears it.
local NAKED_RUN_ZONES = { 'Stormwind City', 'Ironforge' }
local startedAt = nil

local function checkNakedRun()
    if not naked() then
        startedAt = nil
        return
    end

    local zone = GetZoneText()
    if zone == NAKED_RUN_ZONES[1] then
        startedAt = startedAt or zone
    elseif zone == NAKED_RUN_ZONES[2] and startedAt then
        CA_Criterias:Trigger(ns.CRITERIA_NAKED_RUN)
    end
end

-- Equipment is readable from login onwards, so what is already worn counts straight away.
local watcher = CreateFrame('Frame')
watcher:RegisterEvent('PLAYER_ENTERING_WORLD')
watcher:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
watcher:RegisterEvent('UPDATE_INVENTORY_DURABILITY')
watcher:RegisterEvent('ZONE_CHANGED_NEW_AREA')
watcher:SetScript('OnEvent', function()
    C_Timer.After(1, function()
        evaluate()
        checkDurability()
        checkNakedRun()
    end)
end)
