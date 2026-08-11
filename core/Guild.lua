local _, ns = ...
if ns.disabled then return end

-- Anniversary has no guild criteria type, so we register one of our own.
CA_Criterias.dataLengths[ns.CRITERIA_GUILD] = 0
CA_Criterias.criterias[ns.CRITERIA_GUILD] = {}

-- Every other guild criteria asks this first, so none of them count in another guild.
function ns.InOurGuild()
    return GetGuildInfo('player') == ns.GUILD_NAME
end

-- Every member has to be one of ours, whatever size the group is.
local MIN_GROUP = 5

function ns.InGuildParty()
    if not ns.InOurGuild() then return false end

    -- Raid units include the player, party units do not, hence the check on each one.
    local prefix, slots = 'party', 4
    if IsInRaid() then prefix, slots = 'raid', 40 end

    local members = 1
    for i = 1, slots do
        local unit = prefix .. i
        if UnitExists(unit) and not UnitIsUnit(unit, 'player') then
            if not UnitIsInMyGuild(unit) then return false end
            members = members + 1
        end
    end
    return members >= MIN_GROUP
end

-- Realm suffixes only show up on some clients, and never mean another realm here.
local function plainName(name)
    return name and (name:match('^([^-]+)') or name) or nil
end

-- Names are cached and never dropped: the roster reads empty for most of a session.
local cachedNames, cachedMaster = {}, nil

local function refresh()
    if not ns.InOurGuild() then return end
    local total = GetNumGuildMembers() or 0
    for i = 1, total do
        local name, _, rankIndex = GetGuildRosterInfo(i)
        name = plainName(name)
        if name then
            cachedNames[name] = true
            if rankIndex == 0 then cachedMaster = name end
        end
    end
end

function ns.GuildMemberNames()
    if not ns.InOurGuild() then return {} end
    refresh()
    return cachedNames
end

-- Rank zero is the guild master, whoever holds it today.
function ns.GuildMasterName()
    ns.GuildMemberNames()
    return cachedMaster
end

-- A name is one of ours if the roster says so, or if they are still standing there.
function ns.IsGuildmate(name, unit)
    if not (name and ns.InOurGuild()) then return false end
    if unit and UnitExists(unit) and UnitIsInMyGuild(unit) then return true end
    return ns.GuildMemberNames()[plainName(name)] == true
end

local function askForRoster()
    if C_GuildInfo and C_GuildInfo.GuildRoster then
        C_GuildInfo.GuildRoster()
    elseif GuildRoster then
        GuildRoster()
    end
end

-- Reads membership rather than listening for a join, so installing later still counts.
local function check()
    if ns.InOurGuild() then
        CA_Criterias:Trigger(ns.CRITERIA_GUILD)
    end
end

-- Guild data is not up yet at login, so every event gets a moment to settle.
local watcher = CreateFrame('Frame')
watcher:RegisterEvent('PLAYER_ENTERING_WORLD')
watcher:RegisterEvent('PLAYER_GUILD_UPDATE')
watcher:RegisterEvent('GUILD_ROSTER_UPDATE')
watcher:SetScript('OnEvent', function()
    C_Timer.After(2, function()
        check()
        refresh()
    end)
end)

-- Ask for the roster ourselves, and again at a duel, so names are known when they matter.
local asker = CreateFrame('Frame')
asker:RegisterEvent('PLAYER_ENTERING_WORLD')
asker:RegisterEvent('DUEL_REQUESTED')
asker:SetScript('OnEvent', function() askForRoster() end)
C_Timer.After(10, askForRoster)
