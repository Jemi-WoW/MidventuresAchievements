local _, ns = ...
if ns.disabled then return end

local completion = CA_CompletionManager:GetLocal()
local dirty, earned = false, false
local infoCache = {}

-- GetAchievementInfo sorts the whole category on every row, so memoise ours.
local function pack(...) return { n = select('#', ...), ... } end

local baseGetAchievementInfo = GetAchievementInfo

function GetAchievementInfo(id, index)
    if index == nil or not ns.Owns(id) then
        return baseGetAchievementInfo(id, index)
    end

    local rows = infoCache[id]
    if not rows then
        rows = {}
        infoCache[id] = rows
    end

    local row = rows[index]
    if not row then
        row = pack(baseGetAchievementInfo(id, index))
        rows[index] = row
    end
    return unpack(row, 1, row.n)
end

function ns.InvalidateProgress(achievementEarned)
    dirty = true
    earned = earned or achievementEarned or false
    infoCache = {}
end

-- Returns changed, earnedSomething. Both false while nothing happened.
function ns.ConsumeProgressChange()
    if not dirty then return false, false end
    local wasEarned = earned
    dirty, earned = false, false
    return true, wasEarned
end

-- All progress moves through these four on the shared completion object.
for _, method in ipairs({
    'CompleteAchievement',
    'CompleteCriteria',
    'SetCriteriaProgression',
    'IncrementCriteriaProgression',
}) do
    local base = completion[method]
    local earns = method == 'CompleteAchievement'
    completion[method] = function(self, ...)
        ns.InvalidateProgress(earns)
        return base(self, ...)
    end
end
