local _, ns = ...
if ns.disabled then return end

-- Sidebar order is creation order, so append new categories at the bottom.
local categories = {}
categories.general     = ns.Category('General')
categories.quests      = ns.Category('Quests')
categories.exploration = ns.Category('Exploration')
categories.dungeons    = ns.Category('Dungeons & Raids')
categories.professions = ns.Category('Professions')
categories.pvp         = ns.Category('Player vs. Player')
categories.reputation  = ns.Category('Reputation')

-- Subcategories nest under a parent and stay hidden until it is selected.
categories.generalLevelling = ns.Category('Levelling', categories.general)
categories.generalCombat    = ns.Category('Combat', categories.general)
categories.generalWealth    = ns.Category('Wealth & Gear', categories.general)

categories.questsAzeroth = ns.Category('Azeroth', categories.quests)
categories.questsOutland = ns.Category('Outland', categories.quests)
categories.questsDailies = ns.Category('Dailies', categories.quests)

categories.explorationEasternKingdoms = ns.Category('Eastern Kingdoms', categories.exploration)
categories.explorationKalimdor        = ns.Category('Kalimdor', categories.exploration)
categories.explorationOutland         = ns.Category('Outland', categories.exploration)

categories.dungeonsClassic = ns.Category('WoW Classic', categories.dungeons)
categories.dungeonsTBC     = ns.Category('The Burning Crusade', categories.dungeons)
categories.dungeonsRaids   = ns.Category('Raids', categories.dungeons)

categories.professionsGathering = ns.Category('Gathering', categories.professions)
categories.professionsCrafting  = ns.Category('Crafting', categories.professions)
categories.professionsSecondary = ns.Category('Secondary Skills', categories.professions)

categories.pvpBattlegrounds = ns.Category('Battlegrounds', categories.pvp)
categories.pvpArenas        = ns.Category('Arenas', categories.pvp)

categories.reputationAzeroth = ns.Category('Azeroth', categories.reputation)
categories.reputationOutland = ns.Category('Outland', categories.reputation)

-- Appended after the first pass, because creation order is what hands out id blocks.
categories.generalGuild = ns.Category('Guild', categories.general)
categories.pvpDuels     = ns.Category('Duels', categories.pvp)

categories.generalDeath    = ns.Category('Death', categories.general)
categories.generalTravel   = ns.Category('Travel', categories.general)
categories.generalFood     = ns.Category('Food & Drink', categories.general)
categories.generalMoney    = ns.Category('Money', categories.general)
categories.generalOddities = ns.Category('Oddities', categories.general)
categories.generalMilestones = ns.Category('Milestones', categories.general)

categories.questsGuildErrands = ns.Category('Guild Errands', categories.quests)
categories.questsBadHabits    = ns.Category('Bad Habits', categories.quests)
categories.explorationTrespassing = ns.Category('Trespassing', categories.exploration)
categories.explorationLandmarks   = ns.Category('Landmarks', categories.exploration)

ns.categories = categories

-- The summary's Progress Overview grid is derived in achievements/Register.lua.
