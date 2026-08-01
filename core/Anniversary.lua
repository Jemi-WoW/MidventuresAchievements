local _, ns = ...
if ns.disabled then return end

local loc = SexyLib:Localization('Anniversary Achievements')

local byName

-- Resolves one of Anniversary's own achievements so it can gate one of ours.
-- Its ids come from a shared counter and shift when it adds content, so we match on name.
function ns.Anniversary(key, ...)
    if not byName then
        byName = {}
        for id, achievement in pairs(CA_Database:GetAllAchievements()) do
            if not ns.Owns(id) then byName[achievement.name] = achievement end
        end
    end

    local name = loc:Get(key, ...)
    local achievement = byName[name]
    if not achievement then
        error(('Midventures: no Anniversary achievement named "%s"'):format(name))
    end
    return achievement
end
