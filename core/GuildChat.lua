local _, ns = ...
if ns.disabled then return end

-- Counts what this character says in guild chat. Anniversary has no chat criteria at all.
CA_Criterias.dataLengths[ns.CRITERIA_GUILD_CHAT] = 0
CA_Criterias.criterias[ns.CRITERIA_GUILD_CHAT] = {}

-- Naming a guildmate in guild chat, which is what the roster is read for.
CA_Criterias.dataLengths[ns.CRITERIA_GUILD_NAMED] = 0
CA_Criterias.criterias[ns.CRITERIA_GUILD_NAMED] = {}

-- Messages sent from one place. Data is an AreaTableLocale id.
CA_Criterias.dataLengths[ns.CRITERIA_GUILD_CHAT_ZONE] = 1
CA_Criterias.criterias[ns.CRITERIA_GUILD_CHAT_ZONE] = {}

local function progress()
    MidventuresProgressDB = MidventuresProgressDB or {}
    MidventuresProgressDB.chat = MidventuresProgressDB.chat or { named = 0, byZone = {} }
    return MidventuresProgressDB.chat
end

-- A whole word, so "Meowd" in "Meowdy" is not a mention.
local function namesSomeone(message)
    local lowered = ' ' .. message:lower() .. ' '
    for name in pairs(ns.GuildMemberNames()) do
        if name ~= UnitName('player')
            and lowered:find('%A' .. name:lower() .. '%A') then
            return true
        end
    end
    return false
end

local function here()
    local subZone = GetSubZoneText()
    if subZone and subZone ~= '' then return subZone end
    return GetZoneText()
end

local function countZone()
    local record, name = progress(), here()
    for areaID in pairs(CA_Criterias.criterias[ns.CRITERIA_GUILD_CHAT_ZONE]) do
        if AreaTableLocale[areaID] == name then
            record.byZone[areaID] = (record.byZone[areaID] or 0) + 1
            CA_Criterias:Trigger(ns.CRITERIA_GUILD_CHAT_ZONE, {areaID},
                record.byZone[areaID], true)
        end
    end
end

-- CHAT_MSG_GUILD only ever carries our own guild, so the sender is the whole test.
-- Some clients suffix the realm onto the sender and never onto UnitName, hence the strip.
local function check(message, sender)
    if not ns.InOurGuild() then return end
    local name = sender and (sender:match('^([^-]+)') or sender)
    if name ~= UnitName('player') then return end

    CA_Criterias:Trigger(ns.CRITERIA_GUILD_CHAT)
    countZone()

    if message and namesSomeone(message) then
        local record = progress()
        record.named = record.named + 1
        CA_Criterias:Trigger(ns.CRITERIA_GUILD_NAMED, nil, record.named, true)
    end
end

local watcher = CreateFrame('Frame')
watcher:RegisterEvent('CHAT_MSG_GUILD')
watcher:SetScript('OnEvent', function(_, _, ...) check(...) end)
