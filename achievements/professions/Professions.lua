local _, ns = ...
if ns.disabled then return end

local TYPE = CA_Criterias.TYPE
local professions, A = ns.categories.professions, ns.achievements
local PROF = ClassicAchievementsProfessions

-- How to write these: .AchievementGuide/Professions.md
-- Append new achievements at the bottom, ids are handed out in load order.
