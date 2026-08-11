local _, ns = ...
if ns.disabled then return end

-- Eating and drinking. One aura per kind, read by spell id so other locales work.
CA_Criterias.dataLengths[ns.CRITERIA_EAT] = 0
CA_Criterias.criterias[ns.CRITERIA_EAT] = {}
CA_Criterias.dataLengths[ns.CRITERIA_DRINK] = 0
CA_Criterias.criterias[ns.CRITERIA_DRINK] = {}
CA_Criterias.dataLengths[ns.CRITERIA_ALCOHOL] = 0
CA_Criterias.criterias[ns.CRITERIA_ALCOHOL] = {}
CA_Criterias.dataLengths[ns.CRITERIA_CONSUME_ITEM] = 1
CA_Criterias.criterias[ns.CRITERIA_CONSUME_ITEM] = {}

-- Booze applies no Drink aura, so it is a list; add ids here to widen it.
local ALCOHOL = {
    [2593]  = true, -- Flask of Port
    [2594]  = true, -- Flagon of Dwarven Honeymead
    [2723]  = true, -- Bottle of Pinot Noir
    [4595]  = true, -- Junglevine Wine
    [18269] = true, -- Gordok Green Grog
    [18284] = true, -- Kreeg's Stout Beatdown
    [20709] = true, -- Rumsey Rum Light
    [21114] = true, -- Rumsey Rum
    [21151] = true, -- Rumsey Rum Black Label
    [33036] = true, -- Mudder's Milk
    [33042] = true, -- Small Step Brew
    [33043] = true, -- Long Stride Brew
    [33044] = true, -- Path of Brew
    [33045] = true, -- Jungle River Water
    [33046] = true, -- Brewdoo Magic
    [33047] = true, -- Wild Winter Pilsner
    [33048] = true, -- Izzard's Ever Flavor
    [33049] = true, -- Aromatic Honey Brew
    [33050] = true, -- Metok's Bubble Bock
    [33051] = true, -- Springs Water
    [33052] = true, -- Blackrock Lager
    [33053] = true, -- Stout Shrunken Head
    [33054] = true, -- Gordok Grog
    [33055] = true, -- Rock Scorpion Brew
}

local playerGUID
local FOOD_AURA, DRINK_AURA

local function progress()
    MidventuresProgressDB = MidventuresProgressDB or {}
    MidventuresProgressDB.consumed = MidventuresProgressDB.consumed
        or { food = 0, drink = 0, alcohol = 0 }
    return MidventuresProgressDB.consumed
end

local function bump(key, criteriaType)
    local record = progress()
    record[key] = (record[key] or 0) + 1
    CA_Criterias:Trigger(criteriaType, nil, record[key], true)
end

-- The aura is what proves it went down, rather than the item leaving the bag.
local function onCombatLog()
    local _, subEvent, _, _, _, _, _, destGUID = CombatLogGetCurrentEventInfo()
    if subEvent ~= 'SPELL_AURA_APPLIED' or destGUID ~= playerGUID then return end

    local name = select(13, CombatLogGetCurrentEventInfo())
    if name == FOOD_AURA then
        bump('food', ns.CRITERIA_EAT)
    elseif name == DRINK_AURA then
        bump('drink', ns.CRITERIA_DRINK)
    end
end

-- Using an item casts a spell of the same name, which is how a specific one is spotted.
local wanted = {}

local function rememberWantedItems()
    for itemID in pairs(CA_Criterias.criterias[ns.CRITERIA_CONSUME_ITEM]) do
        local name = GetItemInfo(itemID)
        if name then wanted[name] = itemID end
    end
    for itemID in pairs(ALCOHOL) do
        local name = GetItemInfo(itemID)
        if name then wanted[name] = wanted[name] or itemID end
    end
end

local function onCast(unit, _, spellID)
    if unit ~= 'player' then return end
    local name = spellID and GetSpellInfo(spellID)
    if not name then return end

    local itemID = wanted[name]
    if not itemID then return end
    if ALCOHOL[itemID] then bump('alcohol', ns.CRITERIA_ALCOHOL) end
    if CA_Criterias.criterias[ns.CRITERIA_CONSUME_ITEM][itemID] then
        CA_Criterias:Trigger(ns.CRITERIA_CONSUME_ITEM, {itemID})
    end
end

local watcher = CreateFrame('Frame')
watcher:RegisterEvent('PLAYER_LOGIN')
watcher:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
watcher:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
watcher:SetScript('OnEvent', function(_, event, ...)
    if event == 'COMBAT_LOG_EVENT_UNFILTERED' then
        if playerGUID then onCombatLog() end
    elseif event == 'PLAYER_LOGIN' then
        playerGUID = UnitGUID('player')
        -- Spell 433 is the Food aura and 430 the Drink one, in whatever language.
        FOOD_AURA, DRINK_AURA = GetSpellInfo(433), GetSpellInfo(430)
        C_Timer.After(5, rememberWantedItems)
        C_Timer.After(20, rememberWantedItems)
    else
        onCast(...)
    end
end)
