local _, ns = ...
if ns.disabled then return end

local A = ns.achievements
local death = ns.categories.generalDeath

-- Everything here is fed by core/Deaths.lua. Anniversary counts what you kill and never
-- once asks what killed you, so the whole category is ours.

A.SKILL_ISSUE = ns.Chain(death, {
    name = function(n) return ('Skill Issue %d Times'):format(n) end,
    desc = function(n) return ('Die %d times.'):format(n) end,
    criteria = ns.CRITERIA_DEATHS,
    label = 'Deaths',
    icons = {'-Inv_Misc_Bone_DwarfSkull_01', '-Spell_Shadow_DeathScream', '-spell_shadow_psychichorrors'},
})

A.LONG_WAY_DOWN = ns.Achievement(death, {
    name   = "That's a Long Way Down",
    desc   = 'Survive a fall that takes 1000 health off you.',
    points = 20,
    icon   = '-ability_rogue_quickrecovery',
    criteria = {
        { ns.CRITERIA_BIG_FALL, {1000}, nil, 'Fall survived' },
    },
})

A.LEEROY = ns.Achievement(death, {
    name   = 'Leeroy',
    desc   = 'Die within ten seconds of a fight starting in a dungeon.',
    points = 15,
    icon   = '-ability_warrior_innerrage',
    criteria = {
        { ns.CRITERIA_LEEROY, nil, nil, 'At least I have chicken' },
    },
})

A.CORPSE_RUN_CHAMPION = ns.Achievement(death, {
    name   = 'Corpse Run Champion',
    desc   = 'Walk back to your own body 100 times rather than taking the spirit healer.',
    points = 25,
    icon   = '-ability_racial_shadowmeld',
    criteria = {
        { ns.CRITERIA_CORPSE_RUNS, nil, 100, 'Corpse runs' },
    },
})

A.DROWNED_RAT = ns.Achievement(death, {
    name   = 'Drowned Rat',
    desc   = 'Drown.',
    points = 10,
    icon   = '-inv_misc_fish_02',
    criteria = {
        { ns.CRITERIA_DEATH_CAUSE, {'DROWNING'}, nil, 'Drowned' },
    },
})

A.WELL_DONE = ns.Achievement(death, {
    name   = 'Well Done',
    desc   = 'Die in lava.',
    points = 10,
    icon   = '-Spell_Fire_Lavaspawn',
    criteria = {
        { ns.CRITERIA_DEATH_CAUSE, {'LAVA'}, nil, 'Cooked' },
    },
})

A.NAKED_AND_AFRAID = ns.Achievement(death, {
    name   = 'Naked and Afraid',
    desc   = 'Have five pieces of gear broken at the same time.',
    points = 15,
    icon   = '-ability_repair',
    criteria = {
        { ns.CRITERIA_LOW_DURABILITY, {5}, nil, 'Broken pieces worn at once' },
    },
})

A.WIPE_COMMANDER = ns.Achievement(death, {
    name   = 'Wipe Commander',
    desc   = 'Be part of a group where everybody is dead at the same time.',
    points = 15,
    icon   = '-Spell_Shadow_DeathScream',
    criteria = {
        { ns.CRITERIA_WIPE, nil, nil, 'Group wiped' },
    },
})

-- The rest of what the world can do to you. Environmental damage names its own type, so
-- these cost nothing beyond a row each.
A.BURNT_OUT = ns.Achievement(death, {
    name   = 'Burnt Out',
    desc   = 'Burn to death.',
    points = 10,
    icon   = '-spell_fire_fire',
    criteria = {
        { ns.CRITERIA_DEATH_CAUSE, {'FIRE'}, nil, 'Burned' },
    },
})

A.SLIME_TIME = ns.Achievement(death, {
    name   = 'Slime Time',
    desc   = 'Dissolve in slime.',
    points = 10,
    icon   = '-Spell_Nature_Acid_01',
    criteria = {
        { ns.CRITERIA_DEATH_CAUSE, {'SLIME'}, nil, 'Dissolved' },
    },
})

A.TOO_FAR_FROM_SHORE = ns.Achievement(death, {
    name   = 'Too Far From Shore',
    desc   = 'Swim until the water gives up on you.',
    points = 15,
    icon   = '-inv_misc_fish_02',
    criteria = {
        { ns.CRITERIA_DEATH_CAUSE, {'FATIGUE'}, nil, 'Exhausted' },
    },
})

A.SPLAT = ns.Achievement(death, {
    name   = 'Splat',
    desc   = 'Learn what gravity thinks of you.',
    points = 10,
    icon   = '-ability_rogue_quickrecovery',
    criteria = {
        { ns.CRITERIA_DEATH_CAUSE, {'FALLING'}, nil, 'Fell' },
    },
})

A.EVERY_WAY_TO_GO = ns.Achievement(death, {
    name   = 'Every Way To Go',
    desc   = 'Find every way the world has of killing you.',
    points = 50,
    icon   = '-spell_shadow_psychichorrors',
    meta   = { A.DROWNED_RAT, A.WELL_DONE, A.BURNT_OUT, A.SLIME_TIME,
               A.TOO_FAR_FROM_SHORE, A.SPLAT },
})

A.HARDCORE_ADJACENT = ns.Achievement(death, {
    name   = 'Hardcore Adjacent',
    desc   = 'Reach level 20 without dying once.',
    points = 30,
    icon   = '-Inv_Shield_06',
    criteria = {
        { ns.CRITERIA_DEATHLESS_LEVEL, {20}, nil, 'Level 20, still breathing' },
    },
})
