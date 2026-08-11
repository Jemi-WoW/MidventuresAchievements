local _, ns = ...
if ns.disabled then return end

-- The 2000 to 5000 rungs, built here so the ids already handed out stay where they are.
ns.ExtendChains()
