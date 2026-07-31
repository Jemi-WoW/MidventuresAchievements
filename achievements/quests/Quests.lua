local _, ns = ...
if ns.disabled then return end

local TYPE = CA_Criterias.TYPE
local quests, A = ns.categories.quests, ns.achievements

-- How to write these: .AchievementGuide/Quests.md
-- Append new achievements at the bottom, ids are handed out in load order.
