local _, ns = ...
if ns.disabled then return end

local dungeons = ns.Dungeons

-- One criteria per dungeon, keyed by a dungeon key from core/Dungeons.lua.
CA_Criterias.dataLengths[ns.CRITERIA_GUILD_RUN] = 1
CA_Criterias.criterias[ns.CRITERIA_GUILD_RUN] = {}

-- How the runs went, rather than which ones they were.
CA_Criterias.dataLengths[ns.CRITERIA_GUILD_RUNS] = 0
CA_Criterias.criterias[ns.CRITERIA_GUILD_RUNS] = {}
CA_Criterias.dataLengths[ns.CRITERIA_RUN_FLAWLESS] = 0
CA_Criterias.criterias[ns.CRITERIA_RUN_FLAWLESS] = {}
CA_Criterias.dataLengths[ns.CRITERIA_RUN_CLASSES] = 0
CA_Criterias.criterias[ns.CRITERIA_RUN_CLASSES] = {}

-- Kills are kept per character so the criteria can be refilled after a reload.
local function killed()
    MidventuresProgressDB = MidventuresProgressDB or {}
    MidventuresProgressDB.guildBosses = MidventuresProgressDB.guildBosses or {}
    return MidventuresProgressDB.guildBosses
end

local function progress()
    MidventuresProgressDB = MidventuresProgressDB or {}
    MidventuresProgressDB.guildRuns = MidventuresProgressDB.guildRuns or { total = 0 }
    return MidventuresProgressDB.guildRuns
end

-- A five man instance holds nobody but the group, so any player death is one of ours.
local clean = true

-- Five guildmates who between them cover five classes, which takes some arranging.
local function fiveClasses()
    local seen, total = {}, 0
    for i = 0, 4 do
        local unit = i == 0 and 'player' or 'party' .. i
        if UnitExists(unit) then
            local _, class = UnitClass(unit)
            if class and not seen[class] then
                seen[class] = true
                total = total + 1
            end
        end
    end
    return total >= 5
end

-- Every qualifying kill is a run, repeats included, which is what makes it a counter.
local function creditRun()
    local record = progress()
    record.total = record.total + 1
    CA_Criterias:Trigger(ns.CRITERIA_GUILD_RUNS, nil, record.total, true)

    if clean then CA_Criterias:Trigger(ns.CRITERIA_RUN_FLAWLESS) end
    if fiveClasses() then CA_Criterias:Trigger(ns.CRITERIA_RUN_CLASSES) end
end

-- Any id in the list is the same boss: TBC bosses carry a heroic id too.
local function done(dungeon, record)
    for _, creatureID in ipairs(dungeon.ids) do
        if record[creatureID] then return true end
    end
    return false
end

local function evaluate(dungeon)
    if done(dungeon, killed()) then
        CA_Criterias:Trigger(ns.CRITERIA_GUILD_RUN, {dungeon.key})
    end
end

local function evaluateAll()
    for _, list in pairs({dungeons.classic, dungeons.tbc}) do
        for _, dungeon in ipairs(list) do evaluate(dungeon) end
    end
end

-- Anniversary's tracker decides whether a kill was ours, so credit matches its own.
local function onKill(creatureID)
    if not ns.InGuildParty() then return end
    local dungeon = dungeons.byCreature[creatureID]
    if not dungeon then return end

    creditRun()

    local record = killed()
    if record[creatureID] then return end
    record[creatureID] = true
    evaluate(dungeon)
end

local watched = {}
for creatureID in pairs(dungeons.byCreature) do watched[#watched + 1] = creatureID end
CA_CreatureKillingTracker:AddHandler(watched, onKill)

-- A player death ends the flawless run, and walking in starts a new one.
local function onCombatLog()
    if not clean then return end
    local _, event, _, _, _, _, _, destGUID = CombatLogGetCurrentEventInfo()
    if event ~= 'UNIT_DIED' then return end
    if destGUID and destGUID:sub(1, 6) == 'Player' then clean = false end
end

-- Saved kills outlive the criteria they feed, so replay them once the roster is up.
local loader = CreateFrame('Frame')
loader:RegisterEvent('PLAYER_ENTERING_WORLD')
loader:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
loader:SetScript('OnEvent', function(_, event)
    if event == 'COMBAT_LOG_EVENT_UNFILTERED' then
        onCombatLog()
        return
    end

    clean = true
    C_Timer.After(7, function()
        evaluateAll()
        CA_Criterias:Trigger(ns.CRITERIA_GUILD_RUNS, nil, progress().total, true)
    end)
end)
