local _, ns = ...
if ns.disabled then return end

-- Who else is about. Data is how many, so one criteria type covers every tier.
CA_Criterias.dataLengths[ns.CRITERIA_GUILD_ONLINE] = 1
CA_Criterias.criterias[ns.CRITERIA_GUILD_ONLINE] = {}

-- Different guildmates grouped with, ever, rather than at once.
CA_Criterias.dataLengths[ns.CRITERIA_GUILD_GROUPED] = 0
CA_Criterias.criterias[ns.CRITERIA_GUILD_GROUPED] = {}

local function progress()
    MidventuresProgressDB = MidventuresProgressDB or {}
    MidventuresProgressDB.grouped = MidventuresProgressDB.grouped or {}
    return MidventuresProgressDB.grouped
end

local function onlineCount()
    if not ns.InOurGuild() then return 0 end
    local online = 0
    for i = 1, (GetNumGuildMembers() or 0) do
        local _, _, _, _, _, _, _, _, isOnline = GetGuildRosterInfo(i)
        if isOnline then online = online + 1 end
    end
    return online
end

local function checkOnline()
    local count = onlineCount()
    for wanted in pairs(CA_Criterias.criterias[ns.CRITERIA_GUILD_ONLINE]) do
        if count >= wanted then
            CA_Criterias:Trigger(ns.CRITERIA_GUILD_ONLINE, {wanted})
        end
    end
end

-- Names are kept rather than a tally, so grouping with the same person twice counts once.
local function checkGroup()
    if not ns.InOurGuild() then return end

    local prefix, slots = 'party', 4
    if IsInRaid() then prefix, slots = 'raid', 40 end

    local seen, added = progress(), false
    for i = 1, slots do
        local unit = prefix .. i
        if UnitExists(unit) and not UnitIsUnit(unit, 'player') and UnitIsInMyGuild(unit) then
            local name = UnitName(unit)
            if name and not seen[name] then
                seen[name] = true
                added = true
            end
        end
    end

    if not added then return end
    local total = 0
    for _ in pairs(seen) do total = total + 1 end
    CA_Criterias:Trigger(ns.CRITERIA_GUILD_GROUPED, nil, total, true)
end

local function refill()
    local seen, total = progress(), 0
    for _ in pairs(seen) do total = total + 1 end
    if total > 0 then
        CA_Criterias:Trigger(ns.CRITERIA_GUILD_GROUPED, nil, total, true)
    end
end

local watcher = CreateFrame('Frame')
watcher:RegisterEvent('PLAYER_ENTERING_WORLD')
watcher:RegisterEvent('GUILD_ROSTER_UPDATE')
watcher:RegisterEvent('GROUP_ROSTER_UPDATE')
watcher:RegisterEvent('PARTY_MEMBERS_CHANGED')
watcher:RegisterEvent('RAID_ROSTER_UPDATE')
watcher:SetScript('OnEvent', function(_, event)
    if event == 'PLAYER_ENTERING_WORLD' then
        C_Timer.After(8, refill)
    end
    C_Timer.After(2, function()
        checkOnline()
        checkGroup()
    end)
end)
