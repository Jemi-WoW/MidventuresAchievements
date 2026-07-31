local _, ns = ...
if ns.disabled then return end

-- Sidebar order is creation order, so append new categories at the bottom.
local categories = {}
categories.general     = ns.Category('General')
categories.quests      = ns.Category('Quests')
categories.exploration = ns.Category('Exploration')
categories.dungeons    = ns.Category('Dungeons & Raids')
categories.professions = ns.Category('Professions')

-- Subcategories nest under a parent and stay hidden until it is selected.
categories.Subcategorygneral_TEST         = ns.Category('Subcategory_TEST', categories.general)

categories.dungeonsClassic = ns.Category('WoW Classic', categories.dungeons)
categories.dungeonsTBC     = ns.Category('The Burning Crusade', categories.dungeons)

ns.categories = categories

-- The summary's Progress Overview grid is derived in achievements/Register.lua.
