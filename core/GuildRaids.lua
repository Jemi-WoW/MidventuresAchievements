local _, ns = ...
if ns.disabled then return end

local raids = ns.Raids

-- One criteria per raid, keyed by a raid key from core/Raids.lua.
CA_Criterias.dataLengths[ns.CRITERIA_GUILD_RAID] = 1
CA_Criterias.criterias[ns.CRITERIA_GUILD_RAID] = {}

local function killed()
    MidventuresProgressDB = MidventuresProgressDB or {}
    MidventuresProgressDB.guildRaids = MidventuresProgressDB.guildRaids or {}
    return MidventuresProgressDB.guildRaids
end

-- A raid only asks that enough of us are there, which core/Guild.lua already counts.
ns.GuildsInRaid = ns.GuildmatesInGroup

local function evaluate(raid)
    if killed()[raid.id] then
        CA_Criterias:Trigger(ns.CRITERIA_GUILD_RAID, {raid.key})
    end
end

local function evaluateAll()
    for _, list in pairs({raids.classic, raids.tbc}) do
        for _, raid in ipairs(list) do evaluate(raid) end
    end
end

local function onKill(creatureID)
    local raid = raids.byCreature[creatureID]
    if not raid then return end
    if ns.GuildsInRaid() < raid.need then return end

    local record = killed()
    if record[raid.id] then return end
    record[raid.id] = true
    evaluate(raid)
end

local watched = {}
for creatureID in pairs(raids.byCreature) do watched[#watched + 1] = creatureID end
CA_CreatureKillingTracker:AddHandler(watched, onKill)

-- The same replay core/GuildDungeons.lua does, for the same reason.
local loader = CreateFrame('Frame')
loader:RegisterEvent('PLAYER_ENTERING_WORLD')
loader:SetScript('OnEvent', function() C_Timer.After(7, evaluateAll) end)
