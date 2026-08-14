local _, ns = ...
if ns.disabled then return end

-- Saved variables never leave the machine they were written on, so every character's
-- progress is mirrored account-wide and can be carried to another PC as text.
local backup = {}
ns.Backup = backup

local SAVE_EVERY = 300
local RESTORE_DELAY = 5

local DIGITS = '0123456789abcdefghijklmnopqrstuvwxyz'

function ns.To36(number)
    number = math.floor(number or 0)
    if number <= 0 then return '0' end
    local out = ''
    while number > 0 do
        local digit = number % 36
        out = DIGITS:sub(digit + 1, digit + 1) .. out
        number = math.floor(number / 36)
    end
    return out
end

function ns.From36(text)
    return tonumber(text, 36) or 0
end

local to36, from36 = ns.To36, ns.From36

local function store()
    MidventuresBackupDB = MidventuresBackupDB or {}
    local realm = GetRealmName() or 'Unknown'
    MidventuresBackupDB[realm] = MidventuresBackupDB[realm] or {}
    return MidventuresBackupDB[realm], realm
end

local function copy(value)
    if type(value) ~= 'table' then return value end
    local out = {}
    for key, item in pairs(value) do out[key] = copy(item) end
    return out
end

-- Anniversary parks its tracker under string keys in here, so only ids are ours to touch.
local function isAchievement(id, entry)
    return type(id) == 'number' and type(entry) == 'table' and type(entry[3]) == 'table'
end

-- Achievements are only ever won, so the two sides are unioned and progress climbs.
local function mergeOne(target, id, entry)
    local mine = target[id]
    if not mine then
        mine = { false, 0, {} }
        target[id] = mine
    end
    mine[3] = mine[3] or {}

    local when, ours = entry[2] or 0, mine[2] or 0
    if when > 0 and (ours == 0 or when < ours) then mine[2] = when end

    for criteriaID, criteria in pairs(entry[3]) do
        local kept = mine[3][criteriaID]
        if not kept then
            kept = { false, 0 }
            mine[3][criteriaID] = kept
        end
        kept[1] = kept[1] or criteria[1] or false
        kept[2] = math.max(kept[2] or 0, criteria[2] or 0)
    end

    if not (entry[1] and not mine[1]) then return 0 end
    mine[1] = true
    return 1
end

local function mergeAchievements(target, source)
    local gained = 0
    for id, entry in pairs(source) do
        if isAchievement(id, entry) then gained = gained + mergeOne(target, id, entry) end
    end
    return gained
end

-- Counters that are already here are this machine's business, so only gaps are filled.
local function fill(target, source)
    for key, value in pairs(source) do
        if target[key] == nil then
            target[key] = copy(value)
        elseif type(value) == 'table' and type(target[key]) == 'table' then
            fill(target[key], value)
        end
    end
end

local function entryFor(records, name)
    local entry = records[name]
    if not entry then
        entry = { ann = {}, progress = {} }
        records[name] = entry
    end
    entry.ann = entry.ann or {}
    entry.progress = entry.progress or {}
    return entry
end

-- Mirrors this character into the account-wide copy.
function backup.Save()
    local name = UnitName('player')
    if not name then return end

    local records, realm = store()
    local entry = entryFor(records, name)

    entry.realm = realm
    entry.saved = time()
    entry.level = UnitLevel('player')
    entry.class = select(2, UnitClass('player'))
    mergeAchievements(entry.ann, CA_LocalData or {})
    -- This machine is the authority on our own counters, but not before they have loaded.
    if next(MidventuresProgressDB or {}) then entry.progress = copy(MidventuresProgressDB) end
end

local function refresh()
    if ns.InvalidateProgress then ns.InvalidateProgress(true) end
    if ns.Roster then ns.Roster.RefreshSelf() end
    if AchievementFrame_ForceUpdate then AchievementFrame_ForceUpdate() end
end

-- False on a machine this character has never been played on, which is the case worth fixing.
function backup.Knows()
    return store()[UnitName('player')] ~= nil
end

-- Pulls the account-wide copy back into this character. Returns achievements regained.
function backup.RestoreCurrent()
    local records = store()
    local entry = records[UnitName('player')]
    if not entry then return 0 end

    CA_LocalData = CA_LocalData or {}
    MidventuresProgressDB = MidventuresProgressDB or {}
    local gained = mergeAchievements(CA_LocalData, entry.ann or {})
    fill(MidventuresProgressDB, entry.progress or {})

    if gained > 0 then refresh() end
    return gained
end

local function escape(text)
    return (text:gsub('[^%w]', function(char) return ('%%%02X'):format(char:byte()) end))
end

local function unescape(text)
    return (text:gsub('%%(%x%x)', function(hex) return string.char(tonumber(hex, 16)) end))
end

-- Ids ascending as base36 deltas. '!' means done, '*' carries a count.
local function encodeAchievements(data)
    local ids = {}
    for id, entry in pairs(data) do
        if isAchievement(id, entry) then ids[#ids + 1] = id end
    end
    table.sort(ids)

    local parts, lastID = {}, 0
    for _, id in ipairs(ids) do
        local entry = data[id]
        local piece = to36(id - lastID)
        lastID = id
        if entry[1] then piece = piece .. '!' .. to36(entry[2] or 0) end

        local criteriaIDs = {}
        for criteriaID in pairs(entry[3] or {}) do criteriaIDs[#criteriaIDs + 1] = criteriaID end
        table.sort(criteriaIDs)

        local bits, lastCriteria = {}, 0
        for _, criteriaID in ipairs(criteriaIDs) do
            local criteria = entry[3][criteriaID]
            local bit = to36(criteriaID - lastCriteria)
            lastCriteria = criteriaID
            -- A finished criteria is always at its full count, so the count is left out.
            if criteria[1] then
                bit = bit .. '!'
            elseif (criteria[2] or 0) > 0 then
                bit = bit .. '*' .. to36(criteria[2])
            end
            bits[#bits + 1] = bit
        end
        if #bits > 0 then piece = piece .. ':' .. table.concat(bits, ';') end

        parts[#parts + 1] = piece
    end

    return table.concat(parts, ',')
end

local function decodeAchievements(text, into)
    local lastID = 0

    for piece in text:gmatch('[^,]+') do
        local head, tail = piece:match('^([^:]*):?(.*)$')
        local idPart, when = head:match('^(%w+)!(%w*)$')
        local completed = idPart ~= nil
        if not completed then idPart = head:match('^(%w+)$') end

        if idPart then
            local id = lastID + from36(idPart)
            lastID = id

            -- A mangled paste can only invent ids nothing answers to, so those are dropped.
            local achievement = CA_Database:GetAchievement(id)
            if achievement then
                local entry = { completed or false, completed and from36(when) or 0, {} }
                into[id] = entry

                local criterias = achievement:GetCriterias()
                local lastCriteria = 0
                for bit in tail:gmatch('[^;]+') do
                    local criteriaPart, flags = bit:match('^(%w+)(.*)$')
                    if criteriaPart then
                        local criteriaID = lastCriteria + from36(criteriaPart)
                        lastCriteria = criteriaID

                        local done = flags:find('!', 1, true) ~= nil
                        local count = from36(flags:match('%*(%w+)') or '0')
                        if done and count == 0 then
                            local criteria = criterias and criterias[criteriaID]
                            count = criteria and criteria.quantity or 0
                        end
                        entry[3][criteriaID] = { done, count }
                    end
                end
            end
        end
    end
end

-- Our own progress table is free-form, so it travels as a tagged tree.
local function encodeValue(value)
    local kind = type(value)
    if kind == 'number' then return 'n' .. value end
    if kind == 'boolean' then return value and 'b1' or 'b0' end
    if kind == 'string' then return 's' .. escape(value) end
    if kind ~= 'table' then return 'z' end

    local parts = {}
    for key, item in pairs(value) do
        parts[#parts + 1] = encodeValue(key) .. '=' .. encodeValue(item)
    end
    return 't(' .. table.concat(parts, '&') .. ')'
end

local function decodeValue(text, index)
    local tag = text:sub(index, index)
    index = index + 1

    if tag == 't' then
        index = index + 1
        local out = {}
        if text:sub(index, index) == ')' then return out, index + 1 end

        while true do
            local key, item
            key, index = decodeValue(text, index)
            index = index + 1
            item, index = decodeValue(text, index)
            if key ~= nil then out[key] = item end

            local separator = text:sub(index, index)
            index = index + 1
            if separator ~= '&' then break end
        end
        return out, index
    end

    local stop = text:find('[&=%)]', index) or (#text + 1)
    local body = text:sub(index, stop - 1)
    if tag == 'n' then return tonumber(body) or 0, stop end
    if tag == 'b' then return body == '1', stop end
    if tag == 's' then return unescape(body), stop end
    return nil, stop
end

local VERSION = 'MV1'

-- One string for the whole account, or just whoever is logged in.
function backup.Export(everyone)
    backup.Save()

    local records = store()
    local mine = UnitName('player')
    local parts = { VERSION }

    for name, entry in pairs(records) do
        if everyone or name == mine then
            parts[#parts + 1] = table.concat({
                escape(name),
                escape(entry.realm or ''),
                to36(entry.saved or 0),
                encodeAchievements(entry.ann or {}),
                encodeValue(entry.progress or {}),
            }, '~')
        end
    end

    return table.concat(parts, '#')
end

-- Returns characters read and achievements regained here, or nil and why not.
function backup.Import(text)
    if type(text) ~= 'string' then return nil, 'nothing to import.' end
    text = text:gsub('%s+', '')
    if text:sub(1, #VERSION) ~= VERSION then
        return nil, 'that does not look like a Midventures transfer string.'
    end

    local records = store()
    local mine = UnitName('player')
    local characters, gained = 0, 0

    for block in text:sub(#VERSION + 1):gmatch('#([^#]+)') do
        local fields = {}
        for field in (block .. '~'):gmatch('([^~]*)~') do fields[#fields + 1] = field end
        local name = unescape(fields[1] or '')

        if name ~= '' and #fields >= 5 then
            local ann = {}
            decodeAchievements(fields[4], ann)

            local entry = entryFor(records, name)
            entry.realm = entry.realm or unescape(fields[2])
            entry.saved = math.max(entry.saved or 0, from36(fields[3]))
            mergeAchievements(entry.ann, ann)
            fill(entry.progress, decodeValue(fields[5], 1) or {})

            characters = characters + 1
            if name == mine then gained = backup.RestoreCurrent() end
        end
    end

    if characters == 0 then return nil, 'no characters found in that string.' end
    return characters, gained
end

-- A deliberate wipe must not be undone by the mirror at the next login.
local completion = CA_CompletionManager:GetLocal()
local baseReset = completion.Reset
completion.Reset = function(self, ...)
    local records = store()
    records[UnitName('player')] = nil
    return baseReset(self, ...)
end

local watcher = CreateFrame('Frame')
watcher:RegisterEvent('PLAYER_LOGIN')
watcher:RegisterEvent('PLAYER_LOGOUT')
watcher:SetScript('OnEvent', function(_, event)
    if event == 'PLAYER_LOGOUT' then
        backup.Save()
        return
    end

    -- Anniversary hands out what the server already knows first, so the merge waits.
    C_Timer.After(RESTORE_DELAY, function()
        local regained = backup.RestoreCurrent()
        if regained > 0 then
            ns.Print(('restored %d achievement(s) from this account\'s backup.'):format(regained))
        end
        backup.Save()
        C_Timer.NewTicker(SAVE_EVERY, backup.Save)
    end)
end)
