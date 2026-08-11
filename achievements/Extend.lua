local _, ns = ...
if ns.disabled then return end

-- The 2000 to 5000 rungs of every tier ladder.
-- built here rather than in achievements/general/Tiers.lua so the ids already handed out stay where they are.
ns.ExtendChains()
