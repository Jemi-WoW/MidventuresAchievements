local _, ns = ...
if ns.disabled then return end

local dungeons = ns.Dungeons

-- One criteria per dungeon, keyed by a dungeon key from core/Dungeons.lua.
CA_Criterias.dataLengths[ns.CRITERIA_GUILD_RUN] = 1
CA_Criterias.criterias[ns.CRITERIA_GUILD_RUN] = {}

-- Kills are remembered per character rather than per session, so the criteria can be
-- refilled after a reload and a dungeon earned before the addon updated still counts.
local function killed()
    MidventuresProgressDB = MidventuresProgressDB or {}
    MidventuresProgressDB.guildBosses = MidventuresProgressDB.guildBosses or {}
    return MidventuresProgressDB.guildBosses
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

-- Anniversary's tracker already decides whether a kill was ours, so credit matches its own
-- dungeon achievements exactly. It only calls us for the ids we ask about.
local function onKill(creatureID)
    if not ns.InGuildParty() then return end
    local dungeon = dungeons.byCreature[creatureID]
    if not dungeon then return end

    local record = killed()
    if record[creatureID] then return end
    record[creatureID] = true
    evaluate(dungeon)
end

local watched = {}
for creatureID in pairs(dungeons.byCreature) do watched[#watched + 1] = creatureID end
CA_CreatureKillingTracker:AddHandler(watched, onKill)

-- Saved kills outlive the criteria they feed, so replay them once the roster is up.
local loader = CreateFrame('Frame')
loader:RegisterEvent('PLAYER_ENTERING_WORLD')
loader:SetScript('OnEvent', function() C_Timer.After(7, evaluateAll) end)
