local _, ns = ...
if ns.disabled then return end

-- The house tier ladder. Every counting achievement climbs these, so a new chain is one
-- call rather than eleven copies of the same five lines.
ns.TIERS = {10, 20, 30, 40, 50, 100, 200, 300, 400, 500, 1000}

-- Points grow with the tier without getting silly at the top.
local POINTS = {5, 5, 10, 10, 10, 15, 20, 25, 30, 35, 50}

-- `name(count)` and `desc(count)` write the wording, `icons` is one per tier and repeats
-- from the start if it is shorter. Every tier shares one criteria, so they all fill at once
-- and `previous` is what shows them one at a time.
function ns.Chain(category, def)
    local previous, made = nil, {}
    for i, count in ipairs(ns.TIERS) do
        local achievement = ns.Achievement(category, {
            name     = def.name(count),
            desc     = def.desc(count),
            points   = POINTS[i],
            icon     = def.icons[(i - 1) % #def.icons + 1],
            previous = previous,
            criteria = {
                { def.criteria, def.data, count, def.label },
            },
        })
        previous = achievement
        made[i] = achievement
    end
    return made
end
