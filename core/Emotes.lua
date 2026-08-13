local _, ns = ...
if ns.disabled then return end

-- Data is the emote token and the target: a guildmate, the guild master, or a creature.
CA_Criterias.dataLengths[ns.CRITERIA_EMOTE_AT] = 2
CA_Criterias.criterias[ns.CRITERIA_EMOTE_AT] = {}

-- Guildmates dancing in the same spot. Data is how many of them, counting the player.
CA_Criterias.dataLengths[ns.CRITERIA_DANCE_PARTY] = 1
CA_Criterias.criterias[ns.CRITERIA_DANCE_PARTY] = {}

ns.GUILDMATE = 'GUILDMATE'
ns.GUILD_MASTER = 'GUILD_MASTER'

-- Does the target answer to the kind asked for? A leading star means a pattern.
local function matches(kind, target)
    if not target or target == '' then return false end
    if kind == ns.GUILDMATE then
        if target == UnitName('player') then return false end
        local unit = UnitName('target') == target and 'target' or nil
        return ns.IsGuildmate(target, unit)
    end
    if kind == ns.GUILD_MASTER then return target == ns.GuildMasterName() end
    if kind:sub(1, 1) == '*' then
        return target:lower():find(kind:sub(2)) ~= nil
    end
    return target == kind
end

-- The client's token for a slash command is not always the name we asked for.
local alias = {}

-- /midv emote says what arrived and from where, for when one of these looks stuck.
local debugging = false

local function say(message)
    DEFAULT_CHAT_FRAME:AddMessage('|cff00ff00Midventures|r ' .. message)
end

SLASH_MIDVENTURES1 = '/midv'
SlashCmdList.MIDVENTURES = function(argument)
    if not argument:lower():find('emote') then
        say('try /midv emote')
        return
    end
    debugging = not debugging
    say(('emote logging %s. Guild Master is %s.')
        :format(debugging and 'on' or 'off', tostring(ns.GuildMasterName())))
end

-- Client tokens are upper case, but nothing guarantees it for one added later.
local function record(token, target, route)
    if not token then return end
    token = token:upper()
    token = alias[token] or token

    if debugging then
        say(('%s: %s at %s'):format(route or '?', token, tostring(target)))
    end

    local byToken = CA_Criterias.criterias[ns.CRITERIA_EMOTE_AT][token]
    if not byToken then
        if debugging then say('nothing wants ' .. token) end
        return
    end

    for kind in pairs(byToken) do
        if matches(kind, target) then
            CA_Criterias:Trigger(ns.CRITERIA_EMOTE_AT, {token, kind})
            if debugging then say('counted ' .. token .. ' at ' .. kind) end
        elseif debugging then
            say(('%s wanted %s, target is %s'):format(token, kind, tostring(target)))
        end
    end
end

local function emoteTarget(text)
    if text and text ~= '' then return text end
    return UnitName('target')
end

-- Older clients route every slash emote through DoEmote.
hooksecurefunc('DoEmote', function(token, target)
    record(token, emoteTarget(target), 'DoEmote')
end)

-- This one is where the Anniversary client actually sends them.
if C_ChatInfo and C_ChatInfo.PerformEmote then
    hooksecurefunc(C_ChatInfo, 'PerformEmote', function(token, target)
        record(token, emoteTarget(target), 'PerformEmote')
    end)
end

-- What the client calls the emote behind a slash command, which need not be our name.
local function clientToken(command)
    command = command:upper()
    if type(hash_EmoteTokenList) == 'table' and hash_EmoteTokenList[command] then
        return hash_EmoteTokenList[command]
    end
    for i = 1, (MAXEMOTEINDEX or 600) do
        local token = _G['EMOTE' .. i .. '_TOKEN']
        if token then
            for j = 1, 9 do
                local cmd = _G['EMOTE' .. i .. '_CMD' .. j]
                if not cmd then break end
                if cmd:upper() == command then return token end
            end
        end
    end
end

-- Stands in for an emote the client does not have, so the achievement is still reachable.
local function addCommand(token)
    local name = 'MIDVENTURES' .. token
    _G['SLASH_' .. name .. '1'] = '/' .. token:lower()
    SlashCmdList[name] = function()
        local target = UnitName('target')
        SendChatMessage(target and ('does a %s at %s.'):format(token:lower(), target)
            or ('does a %s.'):format(token:lower()), 'EMOTE')
        record(token, target, 'slash')
    end
end

-- Tokens are only trustworthy once the client's own emote list is up.
local resolver = CreateFrame('Frame')
resolver:RegisterEvent('PLAYER_LOGIN')
resolver:SetScript('OnEvent', function(self)
    self:UnregisterAllEvents()
    for token in pairs(CA_Criterias.criterias[ns.CRITERIA_EMOTE_AT]) do
        local theirs = clientToken('/' .. token:lower())
        if not theirs then
            addCommand(token)
        elseif theirs ~= token then
            alias[theirs] = token
        end
    end
end)

-- Dancing together. Only party and raid units: nobody can ask who else is on screen.
local dancing = {}
local WINDOW = 10

local function groupUnits()
    local units = {'player'}
    local prefix, slots = 'party', 4
    if IsInRaid() then prefix, slots = 'raid', 40 end
    for i = 1, slots do
        local unit = prefix .. i
        if UnitExists(unit) then units[#units + 1] = unit end
    end
    return units
end

-- Someone counts while their dance is still fresh and they are one of ours.
local function dancers()
    local now = GetTime and GetTime() or 0
    local count = 0
    for _, unit in ipairs(groupUnits()) do
        local name = UnitName(unit)
        local at = name and dancing[name]
        if at and now - at <= WINDOW then
            if unit == 'player' or UnitIsInMyGuild(unit) then count = count + 1 end
        end
    end
    return count
end

local function checkParty()
    local count = dancers()
    for wanted in pairs(CA_Criterias.criterias[ns.CRITERIA_DANCE_PARTY]) do
        if count >= wanted then
            CA_Criterias:Trigger(ns.CRITERIA_DANCE_PARTY, {wanted})
        end
    end
end

local function onEmoteText(message, sender)
    if not sender then return end
    if message and message:lower():find('dance', 1, true) then
        dancing[sender] = GetTime and GetTime() or 0
        checkParty()
    end
end

local watcher = CreateFrame('Frame')
watcher:RegisterEvent('CHAT_MSG_TEXT_EMOTE')
watcher:SetScript('OnEvent', function(_, _, message, sender) onEmoteText(message, sender) end)

-- Our own dance never comes back as CHAT_MSG_TEXT_EMOTE, so it is recorded at the source.
hooksecurefunc('DoEmote', function(token)
    if token ~= 'DANCE' then return end
    dancing[UnitName('player')] = GetTime and GetTime() or 0
    checkParty()
end)
