local _, ns = ...
if ns.disabled then return end

local POINTS_THROTTLE = 10       -- seconds between our own points broadcasts
local PING_THROTTLE = 15         -- seconds between "who is out there" pings
local DETAIL_THROTTLE = 15       -- seconds between detail requests for one player
local LOGIN_DELAY = 10           -- let the guild roster arrive before the first broadcast
local EARN_DELAY = 5             -- coalesce a burst of achievements into one broadcast

local sync = {}
ns.Sync = sync

-- AceComm rides on Anniversary's embedded libs, so degrade quietly if they ever go.
local AceComm = LibStub and LibStub:GetLibrary('AceComm-3.0', true)
if not AceComm then
    sync.unavailable = true
    local function noop() end
    sync.BroadcastPoints, sync.Ping, sync.RequestDetail, sync.RequestGuildRoster = noop, noop, noop, noop
    return
end
AceComm:Embed(sync)

local DIGITS = '0123456789abcdefghijklmnopqrstuvwxyz'

local function to36(n)
    n = math.floor(n or 0)
    if n <= 0 then return '0' end
    local out = ''
    while n > 0 do
        local digit = n % 36
        out = DIGITS:sub(digit + 1, digit + 1) .. out
        n = math.floor(n / 36)
    end
    return out
end

local function from36(text)
    return tonumber(text, 36) or 0
end

-- Ids as base36 deltas, each with its earned day; the day is dropped while it repeats.
local function encodeIDs(ids, days)
    local parts, lastID, lastDay = {}, 0, nil
    for _, id in ipairs(ids) do
        local day = days[id] or 0
        local piece = to36(id - lastID)
        if day ~= lastDay then piece = piece .. '.' .. to36(day) end
        parts[#parts + 1] = piece
        lastID, lastDay = id, day
    end
    return table.concat(parts, ',')
end

local function decodeIDs(text, ids, days)
    local lastID, lastDay = 0, 0
    for piece in text:gmatch('[^,]+') do
        local idPart, dayPart = piece:match('^([^.]+)%.?(.*)$')
        if idPart then
            local id = lastID + from36(idPart)
            if dayPart ~= '' then lastDay = from36(dayPart) end
            ids[#ids + 1] = id
            days[id] = lastDay
            lastID = id
        end
    end
end

sync.Encode, sync.Decode = encodeIDs, decodeIDs

local lastPoints, lastPing = 0, 0
local lastDetail = {}

-- Counted only so /mvlb can tell "nobody answered" from "we dropped the answer".
local seen = { sent = 0, points = 0, pings = 0, detail = 0, dropped = 0, last = nil }
sync.seen = seen

local function canSend()
    return IsInGuild() and GetGuildInfo('player') ~= nil
end

-- Class and level for the sidebar come from the roster, so ask for it ourselves.
function sync.RequestGuildRoster()
    if not IsInGuild() then return end
    if C_GuildInfo and C_GuildInfo.GuildRoster then
        C_GuildInfo.GuildRoster()
    elseif GuildRoster then
        GuildRoster()
    end
end

local function send(text, channel, target, priority)
    if not canSend() then return end
    seen.sent = seen.sent + 1
    sync:SendCommMessage(ns.COMM_PREFIX, text, channel, target, priority or 'NORMAL')
end

-- Our points, so everyone can rank us without asking for the full list.
function sync.BroadcastPoints(force)
    if not canSend() then return end
    local now = GetTime()
    if not force and now - lastPoints < POINTS_THROTTLE then return end
    lastPoints = now

    ns.Roster.RefreshSelf()
    send('P|' .. table.concat({ ns.Snapshot.Totals() }, '|'), 'GUILD')
    if sync.onUpdate then sync.onUpdate() end
end

-- Asks the guild to report in, for when the leaderboard is opened.
function sync.Ping(force)
    local now = GetTime()
    if not force and now - lastPing < PING_THROTTLE then return end
    lastPing = now
    send('?', 'GUILD')
end

-- Pulls one player's completed achievements, but only when ours are out of date.
function sync.RequestDetail(record)
    if not record or record.isPlayer then return end

    local now = GetTime()
    if now - (lastDetail[record.name] or 0) < DETAIL_THROTTLE then return end
    if record.ids and record.idsVer == record.ver then return end
    lastDetail[record.name] = now

    send('Q', 'WHISPER', record.name)
end

local function sendDetail(target)
    local mine = ns.Snapshot.Record()
    local body = {
        'D', mine.annPoints, mine.midiPoints, mine.annDone, mine.midiDone,
        'A:' .. encodeIDs(mine.ids[ns.SECTION_ANNIVERSARY], mine.days),
        'M:' .. encodeIDs(mine.ids[ns.SECTION_MIDVENTURES], mine.days),
    }
    send(table.concat(body, '|'), 'WHISPER', target, 'BULK')
end

local function receivePoints(sender, fields)
    local record = ns.Roster.Put(sender, {
        annPoints = tonumber(fields[2]) or 0,
        midiPoints = tonumber(fields[3]) or 0,
        annDone = tonumber(fields[4]) or 0,
        midiDone = tonumber(fields[5]) or 0,
    })
    -- Put only fails before the guild name is known, which would lose the player.
    if not record then
        seen.dropped = seen.dropped + 1
        return
    end
    if sync.onUpdate then sync.onUpdate(record) end
end

local function receiveDetail(sender, fields)
    local ids, days = { [ns.SECTION_ANNIVERSARY] = {}, [ns.SECTION_MIDVENTURES] = {} }, {}

    for i = 6, #fields do
        local section, payload = fields[i]:match('^(%a):(.*)$')
        if section and ids[section] then decodeIDs(payload, ids[section], days) end
    end

    local record = ns.Roster.Put(sender, {
        annPoints = tonumber(fields[2]) or 0,
        midiPoints = tonumber(fields[3]) or 0,
        annDone = tonumber(fields[4]) or 0,
        midiDone = tonumber(fields[5]) or 0,
        ids = ids,
        days = days,
    })
    if record then
        record.idsVer = record.ver
        if sync.onUpdate then sync.onUpdate(record) end
    end
end

-- AceComm hands us "Name-Realm", so our own messages need the suffix off to match.
function sync:OnCommReceived(prefix, message, distribution, sender)
    if prefix ~= ns.COMM_PREFIX then return end
    if ns.Roster.PlainName(sender) == UnitName('player') then return end

    local fields = {}
    for field in (message .. '|'):gmatch('([^|]*)|') do fields[#fields + 1] = field end

    local kind = fields[1]
    seen.last = ('%s from %s'):format(tostring(kind), tostring(sender))

    if kind == 'P' and distribution == 'GUILD' then
        seen.points = seen.points + 1
        receivePoints(sender, fields)
    elseif kind == '?' and distribution == 'GUILD' then
        seen.pings = seen.pings + 1
        -- Stagger the replies so a big guild does not answer all at once.
        C_Timer.After(math.random() * 3, function() sync.BroadcastPoints(true) end)
    elseif kind == 'Q' and distribution == 'WHISPER' then
        sendDetail(sender)
    elseif kind == 'D' and distribution == 'WHISPER' then
        seen.detail = seen.detail + 1
        receiveDetail(sender, fields)
    end
end

sync:RegisterComm(ns.COMM_PREFIX, 'OnCommReceived')

-- Broadcast once the roster is up, then whenever we earn something.
local earnPending = false

local baseInvalidate = ns.InvalidateProgress
ns.InvalidateProgress = function(achievementEarned)
    baseInvalidate(achievementEarned)
    if not achievementEarned or earnPending then return end
    earnPending = true
    C_Timer.After(EARN_DELAY, function()
        earnPending = false
        ns.Sync.BroadcastPoints(true)
    end)
end

local events = CreateFrame('Frame')
events:RegisterEvent('PLAYER_ENTERING_WORLD')
events:RegisterEvent('GUILD_ROSTER_UPDATE')
events:RegisterEvent('PLAYER_GUILD_UPDATE')
events:SetScript('OnEvent', function(_, event)
    if event == 'PLAYER_ENTERING_WORLD' then
        sync.RequestGuildRoster()
        C_Timer.After(LOGIN_DELAY, function()
            ns.Roster.Prune()
            ns.Roster.MergeGuildRoster()
            sync.BroadcastPoints(true)
            sync.Ping()
        end)
    elseif event == 'PLAYER_GUILD_UPDATE' then
        -- Joining a guild is our cue to introduce ourselves and ask who is there.
        sync.RequestGuildRoster()
        C_Timer.After(3, function()
            sync.BroadcastPoints(true)
            sync.Ping()
        end)
    else
        ns.Roster.MergeGuildRoster()
        if sync.onUpdate then sync.onUpdate() end
    end
end)

-- /mvlb says what the leaderboard knows, for when a guildmate is missing from it.
SLASH_MIDVENTURESLEADERBOARD1 = '/mvlb'
SlashCmdList.MIDVENTURESLEADERBOARD = function(argument)
    local function say(text) DEFAULT_CHAT_FRAME:AddMessage('|cff00ff00Midventures:|r ' .. text) end

    if argument == 'ping' then
        lastPing, lastPoints = 0, 0
        sync.RequestGuildRoster()
        sync.Ping()
        sync.BroadcastPoints(true)
        say('asked the guild to report in.')
        return
    end

    say(('guild: %s, comms: %s'):format(GetGuildInfo('player') or 'none', AceComm and 'up' or 'missing'))
    say(('sent %d, received %d points / %d pings / %d detail, dropped %d, last: %s'):format(
        seen.sent, seen.points, seen.pings, seen.detail, seen.dropped, seen.last or 'nothing'))

    local records = ns.Roster.Get()
    say(('%d player(s) known:'):format(#records))
    for _, record in ipairs(records) do
        say(('  %s - %d + %d points, %s'):format(
            record.name, record.annPoints or 0, record.midiPoints or 0,
            record.ids and 'achievements cached' or 'points only'))
    end

    if seen.points == 0 and seen.pings == 0 then
        say('nothing received from anyone: they are not running this build of the addon.')
    end
    say('/mvlb ping re-asks the guild.')
end
