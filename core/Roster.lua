local _, ns = ...
if ns.disabled then return end

local PRUNE_AFTER = 30 * 24 * 60 * 60

local ONLINE_GRACE = 2 * 60

-- Everyone in the guild running this addon, ranked.
local roster = {}
ns.Roster = roster

local sorted, sortedDirty = {}, true

-- Guilds never span realms here, so realm plus guild names the whole cache.
local function store()
    local guild = GetGuildInfo('player')
    if not guild then return nil end

    MidventuresLeaderboardDB = MidventuresLeaderboardDB or {}
    local realm = GetRealmName() or 'Unknown'
    local realms = MidventuresLeaderboardDB
    realms[realm] = realms[realm] or {}
    realms[realm][guild] = realms[realm][guild] or {}
    return realms[realm][guild]
end

-- Realm suffixes only show up on some clients, and never mean another realm here.
local function plainName(name)
    if not name then return nil end
    return (name:match('^([^-]+)') or name)
end
roster.PlainName = plainName

function roster.Records()
    return store() or {}
end

function roster.Find(name)
    local records = store()
    return records and records[plainName(name)]
end

-- Merges a received points packet, creating the record if this is a new player.
function roster.Put(name, fields)
    local records = store()
    if not records then return nil end

    name = plainName(name)
    local record = records[name]
    if not record then
        record = { name = name }
        records[name] = record
    end

    for key, value in pairs(fields) do record[key] = value end
    record.ver = ns.Snapshot.Version(record.annPoints, record.midiPoints, record.annDone, record.midiDone)
    record.lastSeen = time()
    record.heardAt = record.lastSeen
    sortedDirty = true
    return record
end

-- Second-hand records, so guildmates who are offline still rank while nobody can hear them.
function roster.Relay(name, fields)
    local records = store()
    if not records then return nil end

    name = plainName(name)
    if not name or name == UnitName('player') then return nil end

    -- Passing an old record around must not undo a prune.
    local lastSeen = fields.lastSeen or 0
    if lastSeen < time() - PRUNE_AFTER then return nil end

    local record = records[name]
    -- Anything we heard first hand is fresher than what someone else remembers.
    if record and (record.lastSeen or 0) >= lastSeen then return nil end

    if not record then
        record = { name = name }
        records[name] = record
    end

    record.annPoints, record.midiPoints = fields.annPoints or 0, fields.midiPoints or 0
    record.annDone, record.midiDone = fields.annDone or 0, fields.midiDone or 0
    record.class = fields.class or record.class
    record.className = fields.className or record.className
    record.level = fields.level or record.level
    record.ver = ns.Snapshot.Version(record.annPoints, record.midiPoints, record.annDone, record.midiDone)
    record.lastSeen = lastSeen
    sortedDirty = true
    return record
end

-- What we can pass on about everyone else, best ranked first when the list is capped.
function roster.Shareable(exclude, limit)
    local mine = UnitName('player')
    local out = {}
    for _, record in ipairs(roster.Get()) do
        if record.name ~= mine and record.name ~= exclude then
            out[#out + 1] = record
            if limit and #out >= limit then break end
        end
    end
    return out
end

-- Our own numbers are always fresher than anything on the wire.
function roster.RefreshSelf()
    local records = store()
    if not records then return end

    local mine = ns.Snapshot.Record()
    records[mine.name] = mine
    mine.ver = ns.Snapshot.Version(mine.annPoints, mine.midiPoints, mine.annDone, mine.midiDone)
    mine.lastSeen = time()
    sortedDirty = true
end

-- Class, level and online state come from the guild roster, not the wire.
-- Offline members are only listed while the guild frame's "show offline" box is ticked,
-- so absence means offline, never that the player left.
function roster.MergeGuildRoster()
    local records = store()
    if not records then return end

    -- An empty roster means it has not arrived yet, not that the guild went offline.
    local total = GetNumGuildMembers() or 0
    if total == 0 then return end

    local fresh = time() - ONLINE_GRACE
    for _, record in pairs(records) do record.online = (record.heardAt or 0) >= fresh end

    -- Index 5 is the localised class name, index 11 the file name colours and icons need.
    for i = 1, total do
        local name, _, _, level, className, _, _, _, online, _, classFile = GetGuildRosterInfo(i)
        local record = name and records[plainName(name)]
        if record then
            record.class = classFile or record.class
            record.className = className or record.className
            record.level = level or record.level
            record.online = online and true or false
        end
    end
    sortedDirty = true
end

function roster.Prune()
    local records = store()
    if not records then return end

    local cutoff = time() - PRUNE_AFTER
    for name, record in pairs(records) do
        if (record.lastSeen or 0) < cutoff then records[name] = nil end
    end
    sortedDirty = true
end

local function byTotalPoints(a, b)
    local totalA = (a.annPoints or 0) + (a.midiPoints or 0)
    local totalB = (b.annPoints or 0) + (b.midiPoints or 0)
    if totalA ~= totalB then return totalA > totalB end
    if (a.midiPoints or 0) ~= (b.midiPoints or 0) then return (a.midiPoints or 0) > (b.midiPoints or 0) end
    return (a.name or '') < (b.name or '')
end

-- Ranked list, highest combined score first.
function roster.Get()
    if not sortedDirty then return sorted end

    sorted = {}
    for _, record in pairs(roster.Records()) do sorted[#sorted + 1] = record end
    table.sort(sorted, byTotalPoints)
    sortedDirty = false
    return sorted
end

function roster.Invalidate()
    sortedDirty = true
end
