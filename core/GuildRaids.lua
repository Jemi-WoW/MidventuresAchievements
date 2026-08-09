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

-- Guild dungeons ask that everyone is one of ours. A raid only asks that enough of us are,
-- counting the player, because forty guildmates in one place is a different addon.
function ns.GuildsInRaid()
    if not ns.InOurGuild() then return 0 end

    local prefix, slots = 'party', 4
    if IsInRaid() then prefix, slots = 'raid', 40 end

    local ours = 1
    for i = 1, slots do
        local unit = prefix .. i
        if UnitExists(unit) and not UnitIsUnit(unit, 'player') and UnitIsInMyGuild(unit) then
            ours = ours + 1
        end
    end
    return ours
end

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

-- The same replay core/GuildDungeons.lua does, for the same reason: a kill earned before
-- the addon knew about it still counts.
local loader = CreateFrame('Frame')
loader:RegisterEvent('PLAYER_ENTERING_WORLD')
loader:SetScript('OnEvent', function() C_Timer.After(7, evaluateAll) end)
