local _, ns = ...
if ns.disabled then return end

local TYPE = CA_Criterias.TYPE
local A = ns.achievements
local azeroth, outland = ns.categories.reputationAzeroth, ns.categories.reputationOutland

-- How to write these: .AchievementGuide/Reputation.md
-- Append new achievements at the bottom, ids are handed out in load order.

local HONORED = 6

A.MAKING_FRIENDS = ns.Achievement(azeroth, {
    name   = 'Making Friends',
    desc   = 'Reach Honored with any faction.',
    points = 10,
    icon   = '-Spell_Holy_Mindsooth',
    criteria = {
        { TYPE.REACH_ANY_REPUTATION, {HONORED}, 1, 'Factions at Honored' },
    },
})

A.WELL_REGARDED = ns.Achievement(azeroth, {
    name     = 'Well Regarded',
    desc     = 'Reach Honored with 3 factions.',
    points   = 15,
    icon     = '-Spell_Holy_Prayerofspirit',
    previous = A.MAKING_FRIENDS,
    criteria = {
        { TYPE.REACH_ANY_REPUTATION, {HONORED}, 3, 'Factions at Honored' },
    },
})
