local _, ns = ...
if ns.disabled then return end

-- Anniversary has no guild criteria type, so we register one of our own.
CA_Criterias.dataLengths[ns.CRITERIA_GUILD] = 0
CA_Criterias.criterias[ns.CRITERIA_GUILD] = {}

-- Every other guild criteria asks this first, so none of them count in another guild.
function ns.InOurGuild()
    return GetGuildInfo('player') == ns.GUILD_NAME
end

-- True while the party is exactly five, all of them guildmates.
function ns.InGuildParty()
    if not ns.InOurGuild() then return false end
    for i = 1, 4 do
        local unit = 'party' .. i
        if not UnitExists(unit) or not UnitIsInMyGuild(unit) then return false end
    end
    return not UnitExists('party5')
end

-- Realm suffixes only show up on some clients, and never mean another realm here.
local function plainName(name)
    return name and (name:match('^([^-]+)') or name) or nil
end

-- Guildmate names without their realm suffix, for matching a name out of a chat line.
function ns.GuildMemberNames()
    local names = {}
    if not ns.InOurGuild() then return names end
    for i = 1, (GetNumGuildMembers() or 0) do
        local name = plainName(GetGuildRosterInfo(i))
        if name then names[name] = true end
    end
    return names
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
watcher:SetScript('OnEvent', function() C_Timer.After(2, check) end)
