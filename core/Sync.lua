local _, ns = ...
if ns.disabled then return end

local POINTS_THROTTLE = 10       -- seconds between our own points broadcasts
local PING_THROTTLE = 15         -- seconds between "who is out there" pings
local DETAIL_THROTTLE = 15       -- seconds between detail requests for one player
local RELAY_THROTTLE = 300       -- seconds between roster relays to one player
local RELAY_LIMIT = 40           -- players per relay, highest ranked first
local SEED_LIMIT = 5             -- guildmates whose list we fetch unasked each login
local SEED_SPACING = 12          -- seconds between those, to keep the wire quiet
local LOGIN_DELAY = 10           -- let the guild roster arrive before the first broadcast
local EARN_DELAY = 5             -- coalesce a burst of achievements into one broadcast

local sync = {}
ns.Sync = sync

-- AceComm rides on Anniversary's embedded libs, so degrade quietly if they ever go.
local AceComm = LibStub and LibStub:GetLibrary('AceComm-3.0', true)
if not AceComm then
    sync.unavailable = true
    local function noop() end
    sync.BroadcastPoints, sync.Ping, sync.RequestDetail = noop, noop, noop
    sync.RequestGuildRoster, sync.AskGuildMemory, sync.SeedDetail = noop, noop, noop
    return
end
AceComm:Embed(sync)

local to36, from36 = ns.To36, ns.From36

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
local lastDetail, lastRelay = {}, {}

-- Counted only so /mvlb can tell "nobody answered" from "we dropped the answer".
local seen = { sent = 0, points = 0, pings = 0, detail = 0, roster = 0, learned = 0, dropped = 0, last = nil }
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
function sync.RequestDetail(record, force)
    if not record or ns.Roster.IsMe(record) then return end
    -- Whispering someone offline only earns us a "no player" error in the chat frame.
    if not record.online then return end

    local now = GetTime()
    if not force then
        if now - (lastDetail[record.name] or 0) < DETAIL_THROTTLE then return end
        if record.ids and record.idsVer == record.ver then return end
    end
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

-- Asks the guild what they remember of our own list, saying how much of it we hold.
function sync.AskGuildMemory()
    local _, _, annDone, midiDone = ns.Snapshot.Totals()
    send(table.concat({ 'B', annDone, midiDone }, '|'), 'GUILD')
end

-- What we hold for somebody else, handed back only when it beats what they still have.
local function sendMemory(target, annDone, midiDone)
    local record = ns.Roster.Find(target)
    if not (record and record.ids) then return end

    local ann = record.ids[ns.SECTION_ANNIVERSARY] or {}
    local midi = record.ids[ns.SECTION_MIDVENTURES] or {}
    if #ann + #midi <= annDone + midiDone then return end

    local days = record.days or {}
    send(table.concat({
        'S',
        'A:' .. encodeIDs(ann, days),
        'M:' .. encodeIDs(midi, days),
    }, '|'), 'WHISPER', target, 'BULK')
end

-- Everyone holding everyone's list is what makes a character recoverable at all.
function sync.SeedDetail()
    local wanted = {}
    for _, record in ipairs(ns.Roster.Get()) do
        if record.online and not ns.Roster.IsMe(record) and record.idsVer ~= record.ver then
            wanted[#wanted + 1] = record
            if #wanted >= SEED_LIMIT then break end
        end
    end

    for index, record in ipairs(wanted) do
        C_Timer.After(index * SEED_SPACING, function() sync.RequestDetail(record) end)
    end
end

-- Everyone else we know of, so a guildmate learns the players who are offline right now.
local function sendRoster(target)
    local now = GetTime()
    if now - (lastRelay[target] or 0) < RELAY_THROTTLE then return end
    lastRelay[target] = now

    local parts = { 'R' }
    for _, record in ipairs(ns.Roster.Shareable(ns.Roster.PlainName(target), RELAY_LIMIT)) do
        parts[#parts + 1] = table.concat({
            record.name, record.class or '', record.className or '', record.level or 0,
            record.annPoints or 0, record.midiPoints or 0,
            record.annDone or 0, record.midiDone or 0, to36(record.lastSeen or 0),
        }, '~')
    end

    if #parts == 1 then return end
    send(table.concat(parts, '|'), 'WHISPER', target, 'BULK')
end

-- Relayed records are always older news than the player's own broadcast, so they yield to it.
local function receiveRoster(fields)
    local learned = 0
    -- Nobody may relay us more players than we would ever relay ourselves.
    for i = 2, math.min(#fields, RELAY_LIMIT + 1) do
        local parts = {}
        for part in (fields[i] .. '~'):gmatch('([^~]*)~') do parts[#parts + 1] = part end

        if parts[1] and parts[1] ~= '' then
            local record = ns.Roster.Relay(parts[1], {
                class = parts[2] ~= '' and parts[2] or nil,
                className = parts[3] ~= '' and parts[3] or nil,
                level = tonumber(parts[4]),
                annPoints = tonumber(parts[5]) or 0,
                midiPoints = tonumber(parts[6]) or 0,
                annDone = tonumber(parts[7]) or 0,
                midiDone = tonumber(parts[8]) or 0,
                lastSeen = from36(parts[9] or '0'),
            })
            if record then learned = learned + 1 end
        end
    end

    seen.learned = seen.learned + learned
    if learned > 0 and sync.onUpdate then sync.onUpdate() end
end

local function receivePoints(sender, fields)
    -- Somebody we have never heard from before, which is how a new guild member arrives.
    local first = ns.Roster.Find(sender) == nil

    local record = ns.Roster.Put(sender, {
        annPoints = tonumber(fields[2]) or 0,
        midiPoints = tonumber(fields[3]) or 0,
        annDone = tonumber(fields[4]) or 0,
        midiDone = tonumber(fields[5]) or 0,
        -- Hearing from someone is the most reliable proof they are online.
        online = true,
    })
    -- Put only fails before the guild name is known, which would lose the player.
    if not record then
        seen.dropped = seen.dropped + 1
        return
    end

    if first then
        sync.RequestGuildRoster()
        C_Timer.After(1 + math.random() * 2, function() sync.BroadcastPoints(true) end)
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
        online = true,
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
        -- Only the player who asked needs our copy of the roster.
        C_Timer.After(3 + math.random() * 3, function() sendRoster(sender) end)
    elseif kind == 'Q' and distribution == 'WHISPER' then
        sendDetail(sender)
    elseif kind == 'D' and distribution == 'WHISPER' then
        seen.detail = seen.detail + 1
        receiveDetail(sender, fields)
    elseif kind == 'R' and distribution == 'WHISPER' then
        seen.roster = seen.roster + 1
        receiveRoster(fields)
    elseif kind == 'B' and distribution == 'GUILD' then
        local annDone, midiDone = tonumber(fields[2]) or 0, tonumber(fields[3]) or 0
        -- Short jitter: only guildmates holding more than they do answer at all.
        C_Timer.After(math.random() * 2, function() sendMemory(sender, annDone, midiDone) end)
    elseif kind == 'S' and distribution == 'WHISPER' then
        if ns.Restore then ns.Restore.Receive(fields) end
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

local knownInGuild = {}

local function guildGainedSomeone()
    local total = GetNumGuildMembers() or 0
    if total == 0 then return false end

    local gained = false
    for i = 1, total do
        local name = ns.Roster.PlainName(GetGuildRosterInfo(i))
        if name and not knownInGuild[name] then
            knownInGuild[name] = true
            gained = true
        end
    end
    return gained
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
            C_Timer.After(LOGIN_DELAY, sync.SeedDetail)
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
        if guildGainedSomeone() then sync.Ping() end
        if sync.onUpdate then sync.onUpdate() end
    end
end)

-- /mvlb says what the leaderboard knows, for when a guildmate is missing from it.
SLASH_MIDVENTURESLEADERBOARD1 = '/mvlb'
SlashCmdList.MIDVENTURESLEADERBOARD = function(argument)
    local say = ns.Print

    if argument == 'ping' then
        lastPing, lastPoints, lastRelay = 0, 0, {}
        sync.RequestGuildRoster()
        sync.Ping()
        sync.BroadcastPoints(true)
        say('asked the guild to report in.')
        return
    end

    say(('guild: %s, comms: %s'):format(GetGuildInfo('player') or 'none', AceComm and 'up' or 'missing'))
    say(('sent %d, received %d points / %d pings / %d detail / %d roster (%d learned), dropped %d, last: %s'):format(
        seen.sent, seen.points, seen.pings, seen.detail, seen.roster, seen.learned,
        seen.dropped, seen.last or 'nothing'))

    local records = ns.Roster.Get()
    say(('%d player(s) known:'):format(#records))
    for _, record in ipairs(records) do
        say(('  %s (%s) - %d + %d points, %s'):format(
            record.name, (record.online or ns.Roster.IsMe(record)) and 'online' or 'offline',
            record.annPoints or 0, record.midiPoints or 0,
            record.ids and 'achievements cached' or 'points only'))
    end

    if seen.points == 0 and seen.pings == 0 then
        say('nothing received from anyone: they are not running this build of the addon.')
    end
    say('/mvlb ping re-asks the guild.')
end
