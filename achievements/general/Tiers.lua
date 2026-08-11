local _, ns = ...
if ns.disabled then return end

-- The house tier ladder, so a new chain is one call rather than eleven copies.
ns.TIERS = {10, 20, 30, 40, 50, 100, 200, 300, 400, 500, 1000}

-- Points grow with the tier without getting silly at the top.
local POINTS = {5, 5, 10, 10, 10, 15, 20, 25, 30, 35, 50}

ns.EXTRA_TIERS = {2000, 3000, 4000, 5000}
local EXTRA_POINTS = {60, 70, 80, 100}

-- Every chain ns.Chain has built, for Extend.lua to come back to.
ns.chains = {}

-- One rung. `index` is its place on the whole ladder, which is what picks the icon.
local function rung(category, def, index, count, points, previous)
    return ns.Achievement(category, {
        name     = def.name(count),
        desc     = def.desc(count),
        points   = points,
        icon     = def.icons[(index - 1) % #def.icons + 1],
        previous = previous,
        criteria = {
            { def.criteria, def.data, count, def.label },
        },
    })
end

-- `name(count)` and `desc(count)` write the wording, `previous` shows one tier at a time.
function ns.Chain(category, def)
    local previous, made = nil, {}
    for i, count in ipairs(ns.TIERS) do
        previous = rung(category, def, i, count, POINTS[i], previous)
        made[i] = previous
    end

    ns.chains[#ns.chains + 1] = { category = category, def = def, made = made }
    return made
end

-- The rungs above 1000, hung off the end of every chain already built.
function ns.ExtendChains()
    local base = #ns.TIERS
    for _, chain in ipairs(ns.chains) do
        local made = chain.made
        local previous = made[base]
        for i, count in ipairs(ns.EXTRA_TIERS) do
            previous = rung(chain.category, chain.def, base + i, count, EXTRA_POINTS[i], previous)
            made[base + i] = previous
        end
    end
end
