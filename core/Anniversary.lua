local _, ns = ...
if ns.disabled then return end

local loc = SexyLib:Localization('Anniversary Achievements')

local byName

-- Their localisation, so our criteria can reuse strings Anniversary already translates.
function ns.Localized(key, ...)
    return loc:Get(key, ...)
end

-- Anniversary's ids shift when it adds content, so its achievements are matched by name.
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
