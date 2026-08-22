local _, ns = ...
if ns.disabled then return end

local A = ns.achievements
local secondary = ns.categories.professionsSecondary

-- Anniversary tiers the skills, so these ask what the skill was used for.

A.BANDAGE_BRIGADE = ns.Chain(secondary, {
    name = function(n) return ('Bandage %d Guildmates'):format(n) end,
    desc = function(n)
        return ('Patch up %s guildmates %d times.'):format(ns.GUILD_NAME, n)
    end,
    criteria = ns.CRITERIA_BANDAGE_GUILD,
    label = 'Guildmates bandaged',
    icons = {'-Inv_Misc_Bandage_08', '-Inv_Misc_Bandage_12', '-inv_misc_bandage_netherweave_heavy'},
})

A.RUBBISH_ANGLER = ns.Achievement(secondary, {
    name   = 'Rubbish Angler',
    desc   = 'Fish 50 pieces of rubbish out of the water.',
    points = 15,
    icon   = '-inv_misc_fish_02',
    criteria = {
        { ns.CRITERIA_JUNK_FISH, nil, 50, 'Rubbish landed' },
    },
})

A.FIRST_AID_FIRST = ns.Achievement(secondary, {
    name   = 'First Aid First',
    desc   = 'Bandage yourself below a tenth of your health, which is cutting it fine.',
    points = 10,
    icon   = '-Spell_Holy_Heal',
    criteria = {
        { ns.CRITERIA_BANDAGE_LOW, nil, nil, 'Patched up at death\'s door' },
    },
})

-- The hundred tier of the bandage chain, which is where it stops being an accident.
local HUNDRED = 6

A.GUILD_ARTISAN = ns.Achievement(secondary, {
    name   = 'Guild Artisan',
    desc   = 'Be the one the guild whispers when something needs making or mending.',
    points = 40,
    icon   = '-Trade_Engineering',
    meta = {
        A.GUILD_SUPPLIER,
        A.BANDAGE_BRIGADE[HUNDRED],
        A.ENCHANTERS_FRIEND,
    },
})
