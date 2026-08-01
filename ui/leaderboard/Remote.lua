local _, ns = ...
if ns.disabled then return end

-- Feeds a guild member's completions into Anniversary's own category and row API.
local leaderboard = {}
ns.Leaderboard = leaderboard

leaderboard.section = ns.SECTION_ANNIVERSARY
leaderboard.record = nil

local namesByID, idsByName, nextIndex = {}, {}, 0

-- Sidebar ids must not move when the ranking does, so each name keeps its own.
function leaderboard.CategoryID(name)
    if not idsByName[name] then
        local id = ns.LEADERBOARD_ID_BASE + nextIndex
        idsByName[name], namesByID[id] = id, name
        nextIndex = nextIndex + 1
    end
    return idsByName[name]
end

function leaderboard.RecordFor(categoryID)
    local name = namesByID[categoryID]
    return name and ns.Roster.Find(name) or nil
end

function leaderboard.IsPlayerCategory(categoryID)
    return namesByID[categoryID] ~= nil
end

local cache = { list = {}, has = {}, key = nil }

-- Rebuilt whenever the viewed player, their data or the section changes.
-- idsVer is part of the key because detail usually arrives with the points unmoved.
local function rebuild()
    local record = leaderboard.record
    local key = record and table.concat(
        { record.name, record.ver or '', record.idsVer or '', leaderboard.section }, '/')
    if key == cache.key then return end

    cache.key, cache.list, cache.has = key, {}, {}
    if not record or not record.ids then return end

    for _, ids in pairs(record.ids) do
        for _, id in ipairs(ids) do cache.has[id] = true end
    end

    local days = record.days or {}
    for _, id in ipairs(record.ids[leaderboard.section] or {}) do
        local achievement = CA_Database:GetAchievement(id)
        if achievement then cache.list[#cache.list + 1] = achievement end
    end

    -- Newest first, the way the summary shows recent unlocks.
    table.sort(cache.list, function(a, b)
        local dayA, dayB = days[a.id] or 0, days[b.id] or 0
        if dayA ~= dayB then return dayA > dayB end
        return a.id > b.id
    end)
end

function leaderboard.List()
    rebuild()
    return cache.list
end

function leaderboard.SetRecord(record)
    leaderboard.record = record
    rebuild()
end

function leaderboard.SetSection(section)
    leaderboard.section = section
    rebuild()
end

-- True once we hold the viewed player's completed list, not just their points.
function leaderboard.HasDetail()
    local record = leaderboard.record
    return record ~= nil and record.ids ~= nil
end

local function viewing()
    return ns.leaderboard and leaderboard.record ~= nil
end

local function pack(...) return { n = select('#', ...), ... } end

local baseGetCategoryInfo = GetCategoryInfo

function GetCategoryInfo(categoryID)
    local name = namesByID[categoryID]
    if name then return name, -1, 0 end
    return baseGetCategoryInfo(categoryID)
end

local baseGetCategoryNumAchievements = GetCategoryNumAchievements

function GetCategoryNumAchievements(categoryID, includeAll, completion)
    local record = leaderboard.RecordFor(categoryID)
    if not record then return baseGetCategoryNumAchievements(categoryID, includeAll, completion) end

    -- Only the selected player has a built list; the rest answer from their points packet.
    local total
    if record == leaderboard.record then
        total = #leaderboard.List()
    elseif leaderboard.section == ns.SECTION_ANNIVERSARY then
        total = record.annDone or 0
    else
        total = record.midiDone or 0
    end
    return total, total, 0
end

-- Completion times travel as whole days, so noon keeps the date off a boundary.
local function earnedOn(record, id)
    local day = (record.days or {})[id]
    if not day or day == 0 then day = math.floor((record.lastSeen or time()) / 86400) end
    local when = day * 86400 + 43200
    return tonumber(date('%m', when)), tonumber(date('%d', when)), tonumber(date('%y', when))
end

local baseGetAchievementInfo = GetAchievementInfo

-- Same tuple Anniversary returns, with the viewed player's completion swapped in.
local function remoteInfo(id)
    local info = pack(baseGetAchievementInfo(id))
    local record = leaderboard.record

    if not cache.has[id] then
        info[4], info[5], info[6], info[7], info[13], info[14] = false, nil, nil, nil, false, nil
        return unpack(info, 1, 15)
    end

    info[4] = true
    info[5], info[6], info[7] = earnedOn(record, id)
    info[13] = record.isPlayer or false
    info[14] = record.name
    return unpack(info, 1, 15)
end

function GetAchievementInfo(id, index)
    if not viewing() then return baseGetAchievementInfo(id, index) end

    if index and namesByID[id] then
        local achievement = leaderboard.List()[index]
        if not achievement then return nil end
        return remoteInfo(achievement.id)
    end
    if index then return baseGetAchievementInfo(id, index) end
    return remoteInfo(id)
end

-- Everything we list was earned, so its criteria are all done regardless of ours.
local function asCompleted(achievementID, values)
    if not (viewing() and cache.has[achievementID]) then return unpack(values, 1, values.n) end

    values[3] = true
    if values[5] then
        values[4] = values[5]
        values[9] = values[5] .. ' / ' .. values[5]
    end
    return unpack(values, 1, values.n)
end

local baseCriteriaInfo = GetAchievementCriteriaInfo

function GetAchievementCriteriaInfo(achievementID, index)
    return asCompleted(achievementID, pack(baseCriteriaInfo(achievementID, index)))
end

local baseCriteriaInfoByID = GetAchievementCriteriaInfoByID

function GetAchievementCriteriaInfoByID(achievementID, criteriaID)
    return asCompleted(achievementID, pack(baseCriteriaInfoByID(achievementID, criteriaID)))
end

-- The earned pop-up is always about us, whoever happens to be on screen.
if AchievementAlertFrame_SetUp then
    local baseSetUp = AchievementAlertFrame_SetUp
    AchievementAlertFrame_SetUp = function(...)
        local record = leaderboard.record
        leaderboard.record = nil
        baseSetUp(...)
        leaderboard.record = record
    end
end
