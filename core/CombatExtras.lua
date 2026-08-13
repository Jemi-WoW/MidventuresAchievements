local _, ns = ...
if ns.disabled then return end

-- The rest of what the combat log knows: raising people, stopping casts, and the like.
CA_Criterias.dataLengths[ns.CRITERIA_RESURRECTS] = 0
CA_Criterias.criterias[ns.CRITERIA_RESURRECTS] = {}
CA_Criterias.dataLengths[ns.CRITERIA_INTERRUPTS] = 0
CA_Criterias.criterias[ns.CRITERIA_INTERRUPTS] = {}
CA_Criterias.dataLengths[ns.CRITERIA_DISPELS] = 0
CA_Criterias.criterias[ns.CRITERIA_DISPELS] = {}
CA_Criterias.dataLengths[ns.CRITERIA_OVERKILL] = 1
CA_Criterias.criterias[ns.CRITERIA_OVERKILL] = {}
CA_Criterias.dataLengths[ns.CRITERIA_SURVIVE_LOW] = 0
CA_Criterias.criterias[ns.CRITERIA_SURVIVE_LOW] = {}
CA_Criterias.dataLengths[ns.CRITERIA_FASHION_KILL] = 0
CA_Criterias.criterias[ns.CRITERIA_FASHION_KILL] = {}
CA_Criterias.dataLengths[ns.CRITERIA_PACIFIST] = 2
CA_Criterias.criterias[ns.CRITERIA_PACIFIST] = {}
CA_Criterias.dataLengths[ns.CRITERIA_UNARMED_HITS] = 0
CA_Criterias.criterias[ns.CRITERIA_UNARMED_HITS] = {}

-- Overkill sits one past the amount: fourth in the payload with a spell first, first for a swing.
local AMOUNT_AT = {
    SWING_DAMAGE          = 1,
    SPELL_DAMAGE          = 4,
    SPELL_PERIODIC_DAMAGE = 4,
    RANGE_DAMAGE          = 4,
}

-- Nothing in these slots is the whole point of Fashion Over Function.
local USEFUL_SLOTS = {
    'HEADSLOT', 'SHOULDERSLOT', 'CHESTSLOT', 'WAISTSLOT', 'LEGSSLOT', 'FEETSLOT',
    'WRISTSLOT', 'HANDSSLOT', 'BACKSLOT', 'MAINHANDSLOT', 'SECONDARYHANDSLOT',
    'RANGEDSLOT', 'NECKSLOT', 'FINGER0SLOT', 'FINGER1SLOT',
}

local playerGUID

local function progress()
    MidventuresProgressDB = MidventuresProgressDB or {}
    MidventuresProgressDB.combat = MidventuresProgressDB.combat
        or { resurrects = 0, interrupts = 0, dispels = 0, kills = 0, unarmed = 0 }
    return MidventuresProgressDB.combat
end

local function bump(key, criteriaType)
    local record = progress()
    record[key] = (record[key] or 0) + 1
    CA_Criterias:Trigger(criteriaType, nil, record[key], true)
end

local function wearingNothingUseful()
    for _, slot in ipairs(USEFUL_SLOTS) do
        if GetInventoryItemID('player', GetInventorySlotInfo(slot)) then return false end
    end
    return true
end

-- A level reached while the kill count is still low. Data is the level and the ceiling.
local function checkPacifist()
    local kills, level = progress().kills, UnitLevel('player')
    for wanted, byKills in pairs(CA_Criterias.criterias[ns.CRITERIA_PACIFIST]) do
        for ceiling in pairs(byKills) do
            if level >= wanted and kills < ceiling then
                CA_Criterias:Trigger(ns.CRITERIA_PACIFIST, {wanted, ceiling})
            end
        end
    end
end

local DAMAGE = {'SWING_DAMAGE', 'SPELL_DAMAGE', 'SPELL_PERIODIC_DAMAGE', 'RANGE_DAMAGE'}
local OTHERS = {'SPELL_RESURRECT', 'SPELL_INTERRUPT', 'SPELL_DISPEL', 'SPELL_STOLEN', 'PARTY_KILL'}

local function onCombatLog(subEvent, sourceGUID, _, destGUID, destName, ...)
    if not playerGUID then return end

    if subEvent == 'SPELL_RESURRECT' and sourceGUID == playerGUID then
        if ns.IsGuildmate(destName) then bump('resurrects', ns.CRITERIA_RESURRECTS) end
        return
    end

    if sourceGUID ~= playerGUID then return end

    if subEvent == 'SPELL_INTERRUPT' then
        bump('interrupts', ns.CRITERIA_INTERRUPTS)
    elseif subEvent == 'SPELL_DISPEL' or subEvent == 'SPELL_STOLEN' then
        bump('dispels', ns.CRITERIA_DISPELS)
    elseif subEvent == 'PARTY_KILL' then
        local record = progress()
        record.kills = record.kills + 1
        checkPacifist()
        if wearingNothingUseful() then
            CA_Criterias:Trigger(ns.CRITERIA_FASHION_KILL)
        end
    else
        -- A swing with an empty main hand is a punch, whatever the class.
        if subEvent == 'SWING_DAMAGE'
            and not GetInventoryItemID('player', GetInventorySlotInfo('MAINHANDSLOT')) then
            bump('unarmed', ns.CRITERIA_UNARMED_HITS)
        end

        if destGUID == playerGUID then return end
        local _, overkill = select(AMOUNT_AT[subEvent], ...)
        if not overkill or overkill <= 0 then return end
        for wanted in pairs(CA_Criterias.criterias[ns.CRITERIA_OVERKILL]) do
            if overkill >= wanted then
                CA_Criterias:Trigger(ns.CRITERIA_OVERKILL, {wanted})
            end
        end
    end
end

ns.OnCombatLog(DAMAGE, onCombatLog)
ns.OnCombatLog(OTHERS, onCombatLog)

-- Dropping low in a dungeon and still being there half a minute later.
local LOW = 0.05
local SURVIVED_AFTER = 30
local pending = false

local function onHealth()
    if pending or UnitIsDeadOrGhost('player') then return end
    local _, kind = IsInInstance()
    if not (kind == 'party' or kind == 'raid') then return end

    local health, maximum = UnitHealth('player'), UnitHealthMax('player')
    if not (health and maximum and maximum > 0) then return end
    if health / maximum > LOW then return end

    pending = true
    C_Timer.After(SURVIVED_AFTER, function()
        pending = false
        if not UnitIsDeadOrGhost('player') then
            CA_Criterias:Trigger(ns.CRITERIA_SURVIVE_LOW)
        end
    end)
end

local watcher = CreateFrame('Frame')
watcher:RegisterEvent('PLAYER_LOGIN')
watcher:RegisterEvent('PLAYER_LEVEL_UP')
watcher:RegisterEvent('UNIT_HEALTH')
watcher:SetScript('OnEvent', function(_, event, unit)
    if event == 'PLAYER_LOGIN' then
        playerGUID = UnitGUID('player')
        C_Timer.After(5, checkPacifist)
    elseif event == 'PLAYER_LEVEL_UP' then
        C_Timer.After(1, checkPacifist)
    elseif unit == 'player' then
        onHealth()
    end
end)
