local _, ns = ...
if ns.disabled then return end

-- Bandages. One aura covers the lot, from linen to netherweave.
CA_Criterias.dataLengths[ns.CRITERIA_BANDAGE_GUILD] = 0
CA_Criterias.criterias[ns.CRITERIA_BANDAGE_GUILD] = {}
CA_Criterias.dataLengths[ns.CRITERIA_BANDAGE_LOW] = 0
CA_Criterias.criterias[ns.CRITERIA_BANDAGE_LOW] = {}

local RECENTLY_BANDAGED = 11196
local DEATHS_DOOR = 0.10

local function progress()
    MidventuresProgressDB = MidventuresProgressDB or {}
    MidventuresProgressDB.bandages = MidventuresProgressDB.bandages or { guild = 0 }
    return MidventuresProgressDB.bandages
end

local function healthFraction()
    local maximum = UnitHealthMax('player') or 0
    if maximum <= 0 then return 1 end
    return (UnitHealth('player') or 0) / maximum
end

local function onAura(sourceName, destName, spellID)
    if spellID ~= RECENTLY_BANDAGED then return end
    if sourceName ~= UnitName('player') then return end

    if destName == UnitName('player') then
        if healthFraction() < DEATHS_DOOR then
            CA_Criterias:Trigger(ns.CRITERIA_BANDAGE_LOW)
        end
        return
    end

    -- The roster alone decides here: whoever is bandaged is rarely who is targeted.
    if not ns.IsGuildmate(destName) then return end
    local record = progress()
    record.guild = record.guild + 1
    CA_Criterias:Trigger(ns.CRITERIA_BANDAGE_GUILD, nil, record.guild, true)
end

local function onCombatLog()
    local _, event, _, _, sourceName, _, _, _, destName, _, _, spellID =
        CombatLogGetCurrentEventInfo()
    if event ~= 'SPELL_AURA_APPLIED' then return end
    onAura(sourceName, destName, spellID)
end

local watcher = CreateFrame('Frame')
watcher:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
watcher:RegisterEvent('PLAYER_ENTERING_WORLD')
watcher:SetScript('OnEvent', function(_, event)
    if event == 'COMBAT_LOG_EVENT_UNFILTERED' then
        onCombatLog()
    else
        C_Timer.After(8, function()
            CA_Criterias:Trigger(ns.CRITERIA_BANDAGE_GUILD, nil, progress().guild, true)
        end)
    end
end)
