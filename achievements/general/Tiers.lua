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
            -- Scale turns a tier the name reads in, like gold, into what the game counts.
            { def.criteria, def.data, count * (def.scale or 1), def.label, def.format },
        },
    })
end

-- A chain with its own numbers still needs the house rung count, or ids shift under it.
local function ladder(def, tiers, points, house, housePoints)
    if not tiers then return house, housePoints end
    if #tiers ~= #house then
        error(('Midventures: chain has %d rungs where %d are expected'):format(#tiers, #house))
    end
    return tiers, points
end

-- `name(count)` and `desc(count)` write the wording, `previous` shows one tier at a time.
function ns.Chain(category, def)
    local tiers, points = ladder(def, def.tiers, def.points, ns.TIERS, POINTS)
    local previous, made = nil, {}
    for i, count in ipairs(tiers) do
        previous = rung(category, def, i, count, points[i], previous)
        made[i] = previous
    end

    ns.chains[#ns.chains + 1] = { category = category, def = def, made = made }
    return made
end

-- The rungs above the house ladder, hung off the end of every chain already built.
function ns.ExtendChains()
    local base = #ns.TIERS
    for _, chain in ipairs(ns.chains) do
        local def, made = chain.def, chain.made
        local previous = made[base]

        local tiers, points = ladder(def, def.extraTiers, def.extraPoints,
            ns.EXTRA_TIERS, EXTRA_POINTS)
        for i, count in ipairs(tiers) do
            previous = rung(chain.category, def, base + i, count, points[i], previous)
            made[base + i] = previous
        end

        -- Only a chain that asked for it goes on past the shared top rung.
        if def.topTiers then
            local top = base + #ns.EXTRA_TIERS
            for i, count in ipairs(def.topTiers) do
                previous = rung(chain.category, def, top + i, count, def.topPoints[i], previous)
                made[top + i] = previous
            end
        end
    end
end
