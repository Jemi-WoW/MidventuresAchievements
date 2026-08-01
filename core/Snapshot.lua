local _, ns = ...
if ns.disabled then return end

local db = CA_Database

-- Everything we publish about ourselves to the guild.
local snapshot = {}
ns.Snapshot = snapshot

-- Walks one tab against the local completion, newest first.
local function collect(tab)
    local completion = CA_CompletionManager:GetLocal()
    local points, ids, days = 0, {}, {}

    for _, category in pairs(tab:GetCategories()) do
        for id, achievement in pairs(category:GetAchievements()) do
            if completion:IsAchievementCompleted(id) then
                points = points + achievement.points
                ids[#ids + 1] = id
                days[id] = math.floor((completion:GetAchievementCompletionTime(id) or 0) / 86400)
            end
        end
    end

    table.sort(ids)
    return points, ids, days
end

-- Points and earned counts only, which is what gets broadcast.
function snapshot.Totals()
    local annPoints, annIDs = collect(db:GetTab(db.TAB_ID_PLAYER))
    local midiPoints, midiIDs = collect(ns.tab)
    return annPoints, midiPoints, #annIDs, #midiIDs
end

-- Full record for ourselves, in the same shape as a received one.
function snapshot.Record()
    local annPoints, annIDs, annDays = collect(db:GetTab(db.TAB_ID_PLAYER))
    local midiPoints, midiIDs, midiDays = collect(ns.tab)

    local days = {}
    for id, day in pairs(annDays) do days[id] = day end
    for id, day in pairs(midiDays) do days[id] = day end

    local className, classFile = UnitClass('player')

    return {
        name = UnitName('player'),
        class = classFile,
        className = className,
        level = UnitLevel('player'),
        annPoints = annPoints,
        midiPoints = midiPoints,
        annDone = #annIDs,
        midiDone = #midiIDs,
        ids = { [ns.SECTION_ANNIVERSARY] = annIDs, [ns.SECTION_MIDVENTURES] = midiIDs },
        days = days,
        isPlayer = true,
    }
end

-- Changes whenever anything worth re-fetching changed.
function snapshot.Version(annPoints, midiPoints, annDone, midiDone)
    return table.concat({ annPoints, midiPoints, annDone, midiDone }, '.')
end
