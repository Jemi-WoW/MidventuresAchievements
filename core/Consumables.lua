local _, ns = ...
if ns.disabled then return end

-- Eating and drinking. The buff sitting on the player is the proof, read by name so
-- every rank and every locale counts.
CA_Criterias.dataLengths[ns.CRITERIA_EAT] = 0
CA_Criterias.criterias[ns.CRITERIA_EAT] = {}
CA_Criterias.dataLengths[ns.CRITERIA_DRINK] = 0
CA_Criterias.criterias[ns.CRITERIA_DRINK] = {}
CA_Criterias.dataLengths[ns.CRITERIA_ALCOHOL] = 0
CA_Criterias.criterias[ns.CRITERIA_ALCOHOL] = {}
CA_Criterias.dataLengths[ns.CRITERIA_CONSUME_ITEM] = 1
CA_Criterias.criterias[ns.CRITERIA_CONSUME_ITEM] = {}

-- Nothing marks an item as booze, so it is a list; add ids here to widen it.
local ALCOHOL = {
    [2593]  = true, -- Flask of Port
    [2594]  = true, -- Flagon of Dwarven Honeymead
    [2595]  = true, -- Jug of Bourbon
    [2596]  = true, -- Skin of Dwarven Stout
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

local FOOD_AURA, DRINK_AURA = 'Food', 'Drink'

local eating, drinking = false, false
local drankAt = 0

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

local function auras()
    local food, drink = false, false
    for i = 1, 40 do
        local name = UnitBuff('player', i)
        if not name then break end
        if name == FOOD_AURA then food = true end
        if name == DRINK_AURA then drink = true end
    end
    return food, drink
end

-- Quiet primes the state after a loading screen, where the aura is already there.
local function checkAuras(quiet)
    local food, drink = auras()

    if food and not eating and not quiet then bump('food', ns.CRITERIA_EAT) end
    if drink and not drinking then
        drankAt = GetTime()
        if not quiet then bump('drink', ns.CRITERIA_DRINK) end
    end

    eating, drinking = food, drink
end

local function onAlcohol()
    bump('alcohol', ns.CRITERIA_ALCOHOL)

    -- Booze counts as a drink, but the few kinds that also buff must not count twice.
    local at = GetTime()
    C_Timer.After(1, function()
        if drankAt < at then bump('drink', ns.CRITERIA_DRINK) end
    end)
end

-- Using an item casts a spell, which is how a specific one is spotted.
local bySpell, byName, pending = {}, {}, {}

-- Every drink casts Drink and every food casts Food, so those name no item at all.
local function shared(spellName)
    return spellName == FOOD_AURA or spellName == DRINK_AURA
end

local function remember(itemID)
    local spellName, spellID = GetItemSpell(itemID)
    if spellName and shared(spellName) then spellName, spellID = nil, nil end

    if spellID then bySpell[spellID] = itemID end
    if spellName then byName[spellName] = byName[spellName] or itemID end

    local itemName = GetItemInfo(itemID)
    if itemName then byName[itemName] = byName[itemName] or itemID end

    return spellID ~= nil or itemName ~= nil
end

-- Which item the cast came from, named exactly by whatever the player clicked.
local lastUse, lastUseAt = nil, 0

local function noteUse(itemID)
    if itemID then lastUse, lastUseAt = itemID, GetTime() end
end

local function hook(name, fn)
    if _G[name] then hooksecurefunc(name, fn) end
end

hook('UseContainerItem', function(bag, slot) noteUse(GetContainerItemID(bag, slot)) end)
hook('UseInventoryItem', function(slot) noteUse(GetInventoryItemID('player', slot)) end)
hook('UseAction', function(slot)
    local kind, id = GetActionInfo(slot)
    if kind == 'item' then noteUse(tonumber(id)) end
end)

if GetItemInfoInstant then
    hook('UseItemByName', function(item) noteUse((GetItemInfoInstant(item))) end)
end

-- A click is only that item if the spell that followed is the one the item casts.
local function fromUse(spellID)
    if not lastUse or GetTime() - lastUseAt > 2 then return end

    local spellName = GetItemSpell(lastUse)
    if spellName and spellName == GetSpellInfo(spellID) then return lastUse end
end

-- An item the server has not sent yet answers nothing, so it is asked for again later.
local function want(itemID)
    if not remember(itemID) then pending[itemID] = true end
end

local function collect()
    for itemID in pairs(CA_Criterias.criterias[ns.CRITERIA_CONSUME_ITEM]) do want(itemID) end
    for itemID in pairs(ALCOHOL) do want(itemID) end
end

local function onCast(unit, _, spellID)
    if unit ~= 'player' or not spellID then return end

    local itemID = fromUse(spellID)
    if itemID then
        lastUse = nil
    else
        itemID = bySpell[spellID]
        if not itemID then
            local name = GetSpellInfo(spellID)
            itemID = name and byName[name]
        end
    end
    if not itemID then return end

    if ALCOHOL[itemID] then onAlcohol() end
    if CA_Criterias.criterias[ns.CRITERIA_CONSUME_ITEM][itemID] then
        CA_Criterias:Trigger(ns.CRITERIA_CONSUME_ITEM, {itemID})
    end
end

local watcher = CreateFrame('Frame')
watcher:RegisterEvent('PLAYER_LOGIN')
watcher:RegisterEvent('PLAYER_ENTERING_WORLD')
watcher:RegisterEvent('GET_ITEM_INFO_RECEIVED')
watcher:RegisterUnitEvent('UNIT_AURA', 'player')
watcher:RegisterUnitEvent('UNIT_SPELLCAST_SUCCEEDED', 'player')
watcher:SetScript('OnEvent', function(_, event, ...)
    if event == 'PLAYER_LOGIN' then
        -- Spell 433 is the Food aura and 430 the Drink one, in whatever language.
        FOOD_AURA = GetSpellInfo(433) or FOOD_AURA
        DRINK_AURA = GetSpellInfo(430) or DRINK_AURA
        checkAuras(true)
        C_Timer.After(5, collect)
        C_Timer.After(20, collect)
    elseif event == 'PLAYER_ENTERING_WORLD' then
        checkAuras(true)
    elseif event == 'GET_ITEM_INFO_RECEIVED' then
        local itemID = ...
        if pending[itemID] and remember(itemID) then pending[itemID] = nil end
    elseif event == 'UNIT_AURA' then
        if ... == 'player' then checkAuras(false) end
    else
        onCast(...)
    end
end)
