local _, ns = ...
if ns.disabled then return end

-- Everything about a quest except the quest itself, which Anniversary already counts.
CA_Criterias.dataLengths[ns.CRITERIA_QUEST_GUILD] = 0
CA_Criterias.criterias[ns.CRITERIA_QUEST_GUILD] = {}
CA_Criterias.dataLengths[ns.CRITERIA_QUEST_BUDDIES] = 0
CA_Criterias.criterias[ns.CRITERIA_QUEST_BUDDIES] = {}
CA_Criterias.dataLengths[ns.CRITERIA_QUEST_ABANDON] = 0
CA_Criterias.criterias[ns.CRITERIA_QUEST_ABANDON] = {}
CA_Criterias.dataLengths[ns.CRITERIA_QUEST_LOG_FULL] = 0
CA_Criterias.criterias[ns.CRITERIA_QUEST_LOG_FULL] = {}
CA_Criterias.dataLengths[ns.CRITERIA_QUEST_NO_XP] = 0
CA_Criterias.criterias[ns.CRITERIA_QUEST_NO_XP] = {}

-- A quest handed in somewhere. Data is an AreaTableLocale id.
CA_Criterias.dataLengths[ns.CRITERIA_QUEST_IN_ZONE] = 1
CA_Criterias.criterias[ns.CRITERIA_QUEST_IN_ZONE] = {}

-- The same, but only while you are too low to be there. Data is the area and the level.
CA_Criterias.dataLengths[ns.CRITERIA_QUEST_BELOW_LEVEL] = 2
CA_Criterias.criterias[ns.CRITERIA_QUEST_BELOW_LEVEL] = {}

local function progress()
    MidventuresProgressDB = MidventuresProgressDB or {}
    MidventuresProgressDB.quests = MidventuresProgressDB.quests
        or { guild = 0, abandoned = 0, noXP = 0, buddies = {}, zones = {} }
    return MidventuresProgressDB.quests
end

local function bump(key, criteriaType)
    local record = progress()
    record[key] = (record[key] or 0) + 1
    CA_Criterias:Trigger(criteriaType, nil, record[key], true)
end

local function count(list)
    local total = 0
    for _ in pairs(list) do total = total + 1 end
    return total
end

-- Guildmates standing beside you when the quest is handed in, remembered by name so the
-- same friend all afternoon is one buddy rather than fifty.
local function creditGroup()
    if not ns.InOurGuild() then return end

    local prefix, slots = 'party', 4
    if IsInRaid() then prefix, slots = 'raid', 40 end

    local record, together = progress(), false
    for i = 1, slots do
        local unit = prefix .. i
        if UnitExists(unit) and not UnitIsUnit(unit, 'player') and UnitIsInMyGuild(unit) then
            together = true
            local name = UnitName(unit)
            if name then record.buddies[name] = true end
        end
    end

    if not together then return end
    bump('guild', ns.CRITERIA_QUEST_GUILD)
    CA_Criterias:Trigger(ns.CRITERIA_QUEST_BUDDIES, nil, count(record.buddies), true)
end

local function here()
    local subZone = GetSubZoneText()
    if subZone and subZone ~= '' then return subZone end
    return GetZoneText()
end

-- The zone counters are keyed by area, so a quest in Nagrand never fills in for Netherstorm.
local function creditZone()
    local record, name, zone = progress(), here(), GetZoneText()
    for areaID in pairs(CA_Criterias.criterias[ns.CRITERIA_QUEST_IN_ZONE]) do
        local wanted = AreaTableLocale[areaID]
        if wanted == name or wanted == zone then
            record.zones[areaID] = (record.zones[areaID] or 0) + 1
            CA_Criterias:Trigger(ns.CRITERIA_QUEST_IN_ZONE, {areaID}, record.zones[areaID], true)
        end
    end

    local level = UnitLevel('player')
    for areaID, byLevel in pairs(CA_Criterias.criterias[ns.CRITERIA_QUEST_BELOW_LEVEL]) do
        local wanted = AreaTableLocale[areaID]
        if wanted == name or wanted == zone then
            for maxLevel in pairs(byLevel) do
                if level < maxLevel then
                    CA_Criterias:Trigger(ns.CRITERIA_QUEST_BELOW_LEVEL, {areaID, maxLevel})
                end
            end
        end
    end
end

-- A quest worth no experience is one you outgrew, or one you did at seventy.
local function onTurnIn(_, xpReward)
    creditGroup()
    creditZone()
    if (xpReward or 0) == 0 then bump('noXP', ns.CRITERIA_QUEST_NO_XP) end
end

-- The log holds the same number of quests for everyone, and the client tells us which.
local function checkLog()
    local _, quests = GetNumQuestLogEntries()
    local cap = MAX_QUESTS or 25
    if (quests or 0) >= cap then
        CA_Criterias:Trigger(ns.CRITERIA_QUEST_LOG_FULL)
    end
end

-- Abandoning has no event, only the call the confirmation dialog makes.
if AbandonQuest then
    hooksecurefunc('AbandonQuest', function()
        bump('abandoned', ns.CRITERIA_QUEST_ABANDON)
    end)
end

-- Counters outlive the criteria they feed, so they are put back after a reload.
local function refill()
    local record = progress()
    CA_Criterias:Trigger(ns.CRITERIA_QUEST_GUILD, nil, record.guild, true)
    CA_Criterias:Trigger(ns.CRITERIA_QUEST_ABANDON, nil, record.abandoned, true)
    CA_Criterias:Trigger(ns.CRITERIA_QUEST_NO_XP, nil, record.noXP, true)
    CA_Criterias:Trigger(ns.CRITERIA_QUEST_BUDDIES, nil, count(record.buddies), true)
    for areaID, total in pairs(record.zones) do
        CA_Criterias:Trigger(ns.CRITERIA_QUEST_IN_ZONE, {areaID}, total, true)
    end
end

local watcher = CreateFrame('Frame')
watcher:RegisterEvent('QUEST_TURNED_IN')
watcher:RegisterEvent('QUEST_LOG_UPDATE')
watcher:RegisterEvent('PLAYER_ENTERING_WORLD')
watcher:SetScript('OnEvent', function(_, event, ...)
    if event == 'QUEST_TURNED_IN' then
        onTurnIn(...)
    elseif event == 'QUEST_LOG_UPDATE' then
        checkLog()
    else
        C_Timer.After(8, refill)
    end
end)
