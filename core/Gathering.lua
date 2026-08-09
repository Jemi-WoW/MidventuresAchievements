local _, ns = ...
if ns.disabled then return end

-- Nodes worked out of the world. Data is which kind, so one criteria type covers all three.
CA_Criterias.dataLengths[ns.CRITERIA_GATHER] = 1
CA_Criterias.criterias[ns.CRITERIA_GATHER] = {}

ns.GATHER_MINING = 'MINING'
ns.GATHER_HERBS = 'HERBS'
ns.GATHER_SKINNING = 'SKINNING'

-- The gathering spells are named the same at every rank, and the client translates them,
-- so the name of one known rank is what a cast is matched against.
local SPELLS = {
    [ns.GATHER_MINING] = 2575,
    [ns.GATHER_HERBS] = 2366,
    [ns.GATHER_SKINNING] = 8613,
}

local names

local function spellNames()
    if names then return names end
    names = {}
    for kind, spellID in pairs(SPELLS) do
        local name = GetSpellInfo(spellID)
        if name then names[name] = kind end
    end
    return names
end

local function progress()
    MidventuresProgressDB = MidventuresProgressDB or {}
    MidventuresProgressDB.gathering = MidventuresProgressDB.gathering or {}
    return MidventuresProgressDB.gathering
end

local function credit(kind)
    local record = progress()
    record[kind] = (record[kind] or 0) + 1
    CA_Criterias:Trigger(ns.CRITERIA_GATHER, {kind}, record[kind], true)
end

-- A gather that was interrupted never reaches here, which is exactly the point.
local function onCast(unit, _, spellID)
    if unit ~= 'player' then return end
    local name = GetSpellInfo(spellID)
    local kind = name and spellNames()[name]
    if kind then credit(kind) end
end

local function refill()
    for kind, total in pairs(progress()) do
        CA_Criterias:Trigger(ns.CRITERIA_GATHER, {kind}, total, true)
    end
end

local watcher = CreateFrame('Frame')
watcher:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
watcher:RegisterEvent('PLAYER_ENTERING_WORLD')
watcher:SetScript('OnEvent', function(_, event, ...)
    if event == 'UNIT_SPELLCAST_SUCCEEDED' then
        onCast(...)
    else
        C_Timer.After(8, refill)
    end
end)
