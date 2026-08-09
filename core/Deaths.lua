local _, ns = ...
if ns.disabled then return end

-- Everything about dying. Anniversary counts what you kill and never what kills you.
CA_Criterias.dataLengths[ns.CRITERIA_DEATHS] = 0
CA_Criterias.criterias[ns.CRITERIA_DEATHS] = {}
CA_Criterias.dataLengths[ns.CRITERIA_DEATH_CAUSE] = 1
CA_Criterias.criterias[ns.CRITERIA_DEATH_CAUSE] = {}
CA_Criterias.dataLengths[ns.CRITERIA_CORPSE_RUNS] = 0
CA_Criterias.criterias[ns.CRITERIA_CORPSE_RUNS] = {}
CA_Criterias.dataLengths[ns.CRITERIA_WIPE] = 0
CA_Criterias.criterias[ns.CRITERIA_WIPE] = {}
CA_Criterias.dataLengths[ns.CRITERIA_LEEROY] = 0
CA_Criterias.criterias[ns.CRITERIA_LEEROY] = {}
CA_Criterias.dataLengths[ns.CRITERIA_DEATHLESS_LEVEL] = 1
CA_Criterias.criterias[ns.CRITERIA_DEATHLESS_LEVEL] = {}
CA_Criterias.dataLengths[ns.CRITERIA_DEATH_WITH_HEALER] = 0
CA_Criterias.criterias[ns.CRITERIA_DEATH_WITH_HEALER] = {}
CA_Criterias.dataLengths[ns.CRITERIA_BIG_FALL] = 1
CA_Criterias.criterias[ns.CRITERIA_BIG_FALL] = {}

local HEALERS = { PRIEST = true, DRUID = true, PALADIN = true, SHAMAN = true }

-- Deaths are counted across the whole career, so the tally outlives a session.
local function progress()
    MidventuresProgressDB = MidventuresProgressDB or {}
    MidventuresProgressDB.deaths = MidventuresProgressDB.deaths or { count = 0, runs = 0 }
    return MidventuresProgressDB.deaths
end

local playerGUID
local combatStarted, lastEnvironment, deadAt = nil, nil, nil

local function inDungeon()
    local _, kind = IsInInstance()
    return kind == 'party' or kind == 'raid'
end

local function groupUnits()
    local units = {}
    local prefix, slots = 'party', 4
    if IsInRaid() then prefix, slots = 'raid', 40 end
    for i = 1, slots do
        local unit = prefix .. i
        if UnitExists(unit) then units[#units + 1] = unit end
    end
    return units
end

-- A guildmate who could have healed you and did not.
local function guildHealerInGroup()
    for _, unit in ipairs(groupUnits()) do
        if UnitIsInMyGuild(unit) then
            local _, class = UnitClass(unit)
            if class and HEALERS[class:upper()] then return true end
        end
    end
    return false
end

-- Everyone else in the group being dead too makes it a wipe rather than a mistake.
local function everyoneDown()
    local units = groupUnits()
    if #units < 1 then return false end
    for _, unit in ipairs(units) do
        if not UnitIsDeadOrGhost(unit) then return false end
    end
    return true
end

local function onDeath()
    local record = progress()
    record.count = record.count + 1
    CA_Criterias:Trigger(ns.CRITERIA_DEATHS, nil, record.count, true)
    deadAt = GetTime and GetTime() or 0

    if lastEnvironment then
        CA_Criterias:Trigger(ns.CRITERIA_DEATH_CAUSE, {lastEnvironment})
    end
    if guildHealerInGroup() then
        CA_Criterias:Trigger(ns.CRITERIA_DEATH_WITH_HEALER)
    end
    if inDungeon() and combatStarted and deadAt - combatStarted <= 10 then
        CA_Criterias:Trigger(ns.CRITERIA_LEEROY)
    end
    -- The rest of the group takes a moment to fall over too.
    C_Timer.After(3, function()
        if everyoneDown() then CA_Criterias:Trigger(ns.CRITERIA_WIPE) end
    end)
end

-- Walking back beats being rezzed, so only a body reclaimed on foot counts.
local function onResurrect()
    if not deadAt then return end
    deadAt = nil
    local record = progress()
    record.runs = record.runs + 1
    CA_Criterias:Trigger(ns.CRITERIA_CORPSE_RUNS, nil, record.runs, true)
end

-- Levels only count while the tally is still zero, so one death ends the run for good.
local function checkDeathless()
    if progress().count > 0 then return end
    local level = UnitLevel('player')
    for wanted in pairs(CA_Criterias.criterias[ns.CRITERIA_DEATHLESS_LEVEL]) do
        if level >= wanted then
            CA_Criterias:Trigger(ns.CRITERIA_DEATHLESS_LEVEL, {wanted})
        end
    end
end

-- Falling and drowning arrive as environmental damage, which names what it was.
local function onCombatLog()
    local _, subEvent, _, sourceGUID, _, _, _, destGUID = CombatLogGetCurrentEventInfo()
    if destGUID ~= playerGUID then return end

    if subEvent == 'ENVIRONMENTAL_DAMAGE' then
        local kind, amount = select(12, CombatLogGetCurrentEventInfo())
        lastEnvironment = kind
        if kind == 'FALLING' and amount then
            for wanted in pairs(CA_Criterias.criterias[ns.CRITERIA_BIG_FALL]) do
                if amount >= wanted and not UnitIsDeadOrGhost('player') then
                    CA_Criterias:Trigger(ns.CRITERIA_BIG_FALL, {wanted})
                end
            end
        end
    elseif subEvent == 'UNIT_DIED' then
        return
    elseif sourceGUID and sourceGUID ~= playerGUID then
        -- Anything else that hurt us means the last fall or lungful is no longer the story.
        lastEnvironment = nil
    end
end

local watcher = CreateFrame('Frame')
watcher:RegisterEvent('PLAYER_LOGIN')
watcher:RegisterEvent('PLAYER_DEAD')
watcher:RegisterEvent('PLAYER_UNGHOST')
watcher:RegisterEvent('PLAYER_ALIVE')
watcher:RegisterEvent('PLAYER_LEVEL_UP')
watcher:RegisterEvent('PLAYER_REGEN_DISABLED')
watcher:RegisterEvent('PLAYER_REGEN_ENABLED')
watcher:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
watcher:SetScript('OnEvent', function(_, event)
    if event == 'COMBAT_LOG_EVENT_UNFILTERED' then
        if playerGUID then onCombatLog() end
    elseif event == 'PLAYER_LOGIN' then
        playerGUID = UnitGUID('player')
        C_Timer.After(5, checkDeathless)
    elseif event == 'PLAYER_DEAD' then
        onDeath()
    elseif event == 'PLAYER_UNGHOST' or event == 'PLAYER_ALIVE' then
        if not UnitIsDeadOrGhost('player') then onResurrect() end
    elseif event == 'PLAYER_LEVEL_UP' then
        C_Timer.After(1, checkDeathless)
    elseif event == 'PLAYER_REGEN_DISABLED' then
        combatStarted = GetTime and GetTime() or 0
    elseif event == 'PLAYER_REGEN_ENABLED' then
        combatStarted = nil
    end
end)
