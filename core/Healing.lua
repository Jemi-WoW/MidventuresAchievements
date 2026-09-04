local _, ns = ...
if ns.disabled then return end

-- A heal of yours on someone, and them reaching for a potion regardless.
CA_Criterias.dataLengths[ns.CRITERIA_POTION_HEALED] = 0
CA_Criterias.criterias[ns.CRITERIA_POTION_HEALED] = {}

-- The spell each health potion casts, which is what the combat log names.
local POTIONS = {
    [439] = true,    -- Minor Healing Potion
    [440] = true,    -- Lesser Healing Potion
    [441] = true,    -- Healing Potion
    [2024] = true,   -- Greater Healing Potion
    [4042] = true,   -- Superior Healing Potion
    [17534] = true,  -- Major Healing Potion
    [28495] = true,  -- Super Healing Potion
}

-- The items the list above came from, asked again in case a spell id ever moves.
local POTION_ITEMS = {118, 858, 929, 1710, 3928, 13446, 22829}

local function learn()
    for _, itemID in ipairs(POTION_ITEMS) do
        local _, spellID = GetItemSpell(itemID)
        if spellID then POTIONS[spellID] = true end
    end
end

-- The potion can go down either side of the heal, so both halves are remembered.
local WINDOW = 6

local healedAt, pottedAt = {}, {}

-- Which of our spells are heals, learned from the ones that land.
local healSpells = {}

local function isPlayer(guid)
    return guid ~= nil and guid:sub(1, 6) == 'Player'
end

local function pair(guid)
    local healed, potted = healedAt[guid], pottedAt[guid]
    if not (healed and potted) then return end
    if math.abs(healed - potted) > WINDOW then return end

    healedAt[guid], pottedAt[guid] = nil, nil
    CA_Criterias:Trigger(ns.CRITERIA_POTION_HEALED)
end

ns.OnCombatLog({'SPELL_HEAL', 'SPELL_PERIODIC_HEAL'}, function(_, sourceGUID, _, destGUID, _, spellID)
    if sourceGUID == UnitGUID('player') and destGUID ~= sourceGUID then
        healSpells[spellID] = true
        healedAt[destGUID] = GetTime()
        return pair(destGUID)
    end

    -- A potion heals whoever drank it, so the two ends of the event are one player.
    if POTIONS[spellID] and sourceGUID == destGUID and isPlayer(destGUID) then
        pottedAt[destGUID] = GetTime()
        pair(destGUID)
    end
end)

-- A cast still in the air is the whole point, so it counts as being healed too.
ns.OnCombatLog({'SPELL_CAST_START'}, function(_, sourceGUID, _, destGUID, _, spellID)
    if sourceGUID ~= UnitGUID('player') then return end
    if not (healSpells[spellID] and isPlayer(destGUID)) then return end

    healedAt[destGUID] = GetTime()
    pair(destGUID)
end)

-- Item data is not up at login, so the second look is the one that usually answers.
local watcher = CreateFrame('Frame')
watcher:RegisterEvent('PLAYER_LOGIN')
watcher:RegisterEvent('PLAYER_ENTERING_WORLD')
watcher:SetScript('OnEvent', function()
    healedAt, pottedAt = {}, {}
    learn()
    C_Timer.After(10, learn)
end)
