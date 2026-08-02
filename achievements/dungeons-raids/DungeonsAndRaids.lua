local _, ns = ...
if ns.disabled then return end

local TYPE = CA_Criterias.TYPE
local A = ns.achievements
local classic, tbc, raids =
    ns.categories.dungeonsClassic, ns.categories.dungeonsTBC, ns.categories.dungeonsRaids

-- How to write these: .AchievementGuide/DungeonsAndRaids.md
-- Append new achievements at the bottom, ids are handed out in load order.

-- Anniversary already has a kill-the-last-boss achievement for every dungeon, so those
-- duplicate it. Ask for more than the kill, or gate on theirs:
--   meta = { ns.Anniversary('AN_RAGEFIRE_CHASM') }
