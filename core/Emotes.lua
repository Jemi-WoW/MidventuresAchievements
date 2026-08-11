local _, ns = ...
if ns.disabled then return end

-- An emote aimed at something. Data is the emote token and who it was aimed at: a
-- guildmate, the guild master, or a creature name like 'Chicken'.
CA_Criterias.dataLengths[ns.CRITERIA_EMOTE_AT] = 2
CA_Criterias.criterias[ns.CRITERIA_EMOTE_AT] = {}

-- Guildmates dancing in the same spot. Data is how many of them, counting the player.
CA_Criterias.dataLengths[ns.CRITERIA_DANCE_PARTY] = 1
CA_Criterias.criterias[ns.CRITERIA_DANCE_PARTY] = {}

ns.GUILDMATE = 'GUILDMATE'
ns.GUILD_MASTER = 'GUILD_MASTER'

-- Does this target answer to the kind an achievement asked about? A kind starting with a
-- star is a pattern rather than a name, for creatures that come in a dozen varieties.
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

-- Tokens arrive from the client as they are written in its emote table, which is upper
-- case, but nothing guarantees that for an emote added later.
local function record(token, target)
    if not token then return end
    token = token:upper()

    local byToken = CA_Criterias.criterias[ns.CRITERIA_EMOTE_AT][token]
    if not byToken then return end
    for kind in pairs(byToken) do
        if matches(kind, target) then
            CA_Criterias:Trigger(ns.CRITERIA_EMOTE_AT, {token, kind})
        end
    end
end

local function emoteTarget(text)
    if text and text ~= '' then return text end
    return UnitName('target')
end

-- Every slash emote goes through DoEmote, so one hook covers all of them.
hooksecurefunc('DoEmote', function(token, target)
    record(token, emoteTarget(target))
end)

local function clientKnowsFart()
    if type(hash_EmoteTokenList) ~= 'table' then return false end
    for _, token in pairs(hash_EmoteTokenList) do
        if token == 'FART' then return true end
    end
    return false
end

if not clientKnowsFart() then
    SLASH_MIDVENTURESFART1 = '/fart'
    SlashCmdList.MIDVENTURESFART = function()
        local target = UnitName('target')
        SendChatMessage(target and ('farts in %s\'s general direction.'):format(target)
            or 'farts. Nobody owns up to it.', 'EMOTE')
        record('FART', target)
    end
end

-- Dancing together. Party and raid units are walked rather than everyone nearby, because
-- there is no way to ask the client who else is on screen.
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

-- Other people's emotes arrive as text, so the client's own dance line is the pattern.
local DANCE = EMOTE10_CMD1 and _G['EMOTE10_CMD1'] or '/dance'

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
