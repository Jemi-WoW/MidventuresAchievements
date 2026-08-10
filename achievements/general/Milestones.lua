local _, ns = ...
if ns.disabled then return end

local A = ns.achievements
local milestones = ns.categories.generalMilestones

-- Roll-ups that reach across into Anniversary's own achievements. `meta` compiles to a
-- COMPLETE_ACHIEVEMENT criteria, which they resolve by reading the other achievement's
-- state rather than waiting for an event, so all of these work retroactively.
--
-- ns.Anniversary(key) matches on the localised name, never an id: see core/Anniversary.lua.
-- Mixing one of theirs with one of ours is the point - a roll-up over only theirs would
-- just be their achievement again.
local AN = ns.Anniversary

-- The guild career, one rung at a time. Each asks for a level and something of ours.
A.DENTERLING = ns.Achievement(milestones, {
    name   = 'Denterling',
    desc   = ('Reach level 10 as a %s guildmate.'):format(ns.GUILD_NAME),
    points = 20,
    icon   = 'level_10',
    meta   = { AN('AN_LVL', 10), A.MIDVENTURER },
})

A.PROPER_DENTER = ns.Achievement(milestones, {
    name     = 'Proper Denter',
    desc     = 'Reach level 40 in the guild tabard.',
    points   = 40,
    icon     = 'level_40',
    previous = A.DENTERLING,
    meta     = { AN('AN_LVL', 40), A.A_TRUE_DENTER },
})

A.DENTER_OF_THE_REALM = ns.Achievement(milestones, {
    name     = 'Denter of the Realm',
    desc     = 'Reach level 70 with a thousand messages behind you.',
    points   = 75,
    icon     = 'level_70',
    previous = A.PROPER_DENTER,
    meta     = { AN('AN_LVL', 70), A.GUILD_CHAT_1000 },
})

-- Cross-domain, which is the one shape Anniversary never builds: they roll up within a
-- category and never across them.
A.WELL_ROUNDED = ns.Achievement(milestones, {
    name   = 'Well Rounded',
    desc   = 'Be good at a bit of everything.',
    points = 50,
    icon   = 'achievement_dungeon_gloryofthehero',
    meta   = { AN('AN_LVL', 60), AN('AN_PROFS_ARTISAN'), AN('AN_EXPLORE_AZEROTH') },
})

A.TOURIST_TRAP = ns.Achievement(milestones, {
    name   = 'Tourist Trap',
    desc   = 'See both continents, and the one bay that matters.',
    points = 40,
    icon   = 'eastern_kingdoms',
    meta   = { AN('AN_EXPLORE_KALIMDOR'), AN('AN_EXPLORE_EASTERN_KINGDOMS'),
               A.BOOTY_BAY_TOURIST },
})

A.OUTLANDER = ns.Achievement(milestones, {
    name     = 'Outlander',
    desc     = 'See all of Outland, from the air.',
    points   = 50,
    icon     = 'outland',
    previous = A.TOURIST_TRAP,
    meta     = { AN('AN_EXPLORE_OUTLAND'), AN('AN_RIDING_225') },
})

A.THE_LONG_WAY_ROUND = ns.Achievement(milestones, {
    name   = 'The Long Way Round',
    desc   = 'Explore everything, and take the gryphon every single time.',
    points = 60,
    icon   = 'kalimdor',
    meta   = { AN('AN_EXPLORE_AZEROTH'), A.FREQUENT_FLYER[9] },
})

-- Two Leeroys is funnier than one.
A.LEEROY_AGAIN = ns.Achievement(milestones, {
    name   = 'Leeroy Jenkins, Again',
    desc   = 'Do it once for them, and once more for us.',
    points = 30,
    icon   = '-ability_warrior_innerrage',
    meta   = { AN('AN_LEEROY'), A.LEEROY },
})

A.SQUIRREL_WHISPERER = ns.Achievement(milestones, {
    name   = 'Squirrel Whisperer',
    desc   = 'Love every critter, and the guild too.',
    points = 30,
    icon   = '-ability_hunter_pet_turtle',
    meta   = { AN('AN_LOVE'), A.HUG_IT_OUT[5] },
})

A.CERTIFIED_MENACE = ns.Achievement(milestones, {
    name   = 'Certified Menace',
    desc   = 'Beat everyone, then beat the guild some more.',
    points = 60,
    icon   = '-Inv_Sword_39',
    meta   = { AN('AN_DUELS_100'), A.MAKGORA_LEGEND },
})

A.FISTS_OF_DENTVENTURES = ns.Achievement(milestones, {
    name   = 'Fists of Dentventures',
    desc   = 'Put the weapon down and keep going.',
    points = 40,
    icon   = '-ability_warrior_rallyingcry',
    meta   = { AN('AN_UNARMED_SKILL'), A.KNUCKLE_SANDWICH[8] },
})

A.IRON_STOMACH = ns.Achievement(milestones, {
    name   = 'Iron Stomach',
    desc   = 'Cook it yourself, then eat all of it.',
    points = 40,
    icon   = '-inv_misc_food_84_roastclefthoof',
    meta   = { AN('AN_COOKING_ARTISAN'), A.SECOND_BREAKFAST[9] },
})

A.REGULAR_AT_THE_BAR = ns.Achievement(milestones, {
    name   = 'Regular at the Bar',
    desc   = 'Join the club, and then never leave.',
    points = 35,
    icon   = '-inv_cask_01',
    meta   = { AN('AN_BREWFEST_BEER_CLUB'), A.BREWFEST_REGULAR },
})

-- Every holiday Anniversary tracks, in one place. Takes a year to earn on purpose.
-- The seven holidays alone are Anniversary's own meta, so ours asks that you were drinking
-- and eating cake through them as well.
A.PARTY_ANIMAL = ns.Achievement(milestones, {
    name   = 'Party Animal',
    desc   = 'Turn up to every holiday in the calendar, and make a night of it.',
    points = 100,
    icon   = 'achievement_worldevent_merrymaker',
    meta   = {
        AN('AN_HALLOWSEND'), AN('AN_WINTERVEIL'), AN('AN_VALENTINES'),
        AN('AN_LUNAR'), AN('AN_CHILDREN'), AN('AN_MIDSUMMER'), AN('AN_BREWFEST'),
        A.BREWFEST_REGULAR, A.CAKE_DAY,
    },
})

A.DENTVENTURES_VETERAN = ns.Achievement(milestones, {
    name   = 'Dentventures Veteran',
    desc   = 'The long service medal.',
    points = 150,
    icon   = 'achievement_dungeon_gloryoftheraider',
    meta   = {
        A.DENTER_OF_THE_REALM, A.GUILD_DUNGEON_MASTER, A.MAKGORA_VETERAN,
        A.GUILD_TOUR_GUIDE, A.WELL_ROUNDED,
    },
})

-- Roll-ups over our own, which is the rest of this file. Tier chains are indexed off
-- ns.TIERS: 1 is 10, 6 is 100, 10 is 500, 11 is 1000.
local T = { [10] = 1, [50] = 5, [100] = 6, [200] = 7, [500] = 10, [1000] = 11 }

A.DRESSED_FOR_SUCCESS = ns.Achievement(milestones, {
    name   = 'Dressed for Success',
    desc   = 'Put some clothes on, and a bit of jewellery.',
    points = 25,
    icon   = '-Inv_Misc_ArmorKit_14',
    meta   = { A.SHOULDERS_OF_GIANTS, A.BLING, A.BLING_BLING, A.TRAVELLING_CLOTHES },
})

A.FULL_KIT_DENTER = ns.Achievement(milestones, {
    name     = 'Full Kit Denter',
    desc     = 'Every slot filled, every slot blue, tabard on.',
    points   = 50,
    icon     = '-Spell_Frost_WizardMark',
    previous = A.DRESSED_FOR_SUCCESS,
    meta     = { A.I_AM_GREEN, A.BLUE_IS_THE_COLOR, A.A_TRUE_DENTER, A.BLING_BLING },
})

A.GUILD_MASTERS_NIGHTMARE = ns.Achievement(milestones, {
    name   = "Guild Master's Nightmare",
    desc   = 'Do all five of them to the person who invited you.',
    points = 50,
    icon   = '-spell_shadow_abominationexplosion',
    meta   = { A.SILENT_BUT_DEADLY[T[10]], A.PUCKER_UP, A.HOW_RUDE,
               A.GROUP_HUG, A.INSUBORDINATION },
})

A.PEOPLE_PERSON = ns.Achievement(milestones, {
    name   = 'People Person',
    desc   = 'Know everybody, and be there when they are.',
    points = 50,
    icon   = '-Inv_Banner_03',
    meta   = { A.ROLL_CALL, A.DANCE_PARTY, A.GUILD_TOUR_GUIDE, A.HUG_IT_OUT[T[50]] },
})

A.CHATTERBOX = ns.Achievement(milestones, {
    name   = 'Chatterbox',
    desc   = 'Never once let the guild chat go quiet.',
    points = 60,
    icon   = '-spell_Shadow_ConeOfSilence',
    meta   = { A.GUILD_CHAT_1000, A.SAY_MY_NAME[T[100]], A.BARRENS_CHAT_SURVIVOR },
})

A.PROFESSIONAL_CORPSE = ns.Achievement(milestones, {
    name   = 'Professional Corpse',
    desc   = 'Make dying a career.',
    points = 50,
    icon   = '-spell_shadow_psychichorrors',
    meta   = { A.SKILL_ISSUE[T[500]], A.CORPSE_RUN_CHAMPION, A.WIPE_COMMANDER,
               A.NAKED_AND_AFRAID },
})

A.ROAD_WARRIOR = ns.Achievement(milestones, {
    name   = 'Road Warrior',
    desc   = 'Every way of getting somewhere, used to death.',
    points = 50,
    icon   = '-Ability_Mount_Gryphon_01',
    meta   = { A.FREQUENT_FLYER[T[500]], A.NO_PLACE_LIKE_HOME[T[500]], A.SEASICK,
               A.SUMMONERS_SICKNESS },
})

A.FED_AND_WATERED = ns.Achievement(milestones, {
    name   = 'Fed and Watered',
    desc   = 'Never adventure on an empty stomach.',
    points = 40,
    icon   = '-inv_misc_food_15',
    meta   = { A.SECOND_BREAKFAST[T[500]], A.HYDRATION_NATION[T[500]], A.ONE_MORE_ROUND,
               A.CAKE_DAY },
})

A.BOOM_AND_BUST = ns.Achievement(milestones, {
    name   = 'Boom and Bust',
    desc   = 'Make it, spend it, and do it all again.',
    points = 60,
    icon   = '-inv_misc_coin_02',
    meta   = { A.GNOME_PIGGY_BANK, A.BROKE, A.VENDOR_TRASH_TYCOON, A.AUCTION_ADDICT,
               A.BAG_SPACE_PROBLEMS },
})

A.CRITICAL_THINKER = ns.Achievement(milestones, {
    name   = 'Critical Thinker',
    desc   = 'Hit things far harder than strictly necessary.',
    points = 50,
    icon   = '-Inv_Hammer_Unique_Sulfuras',
    meta   = { A.A_REALER_CRITTER, A.AN_EVEN_REALER_CRITTER, A.THE_REALEST_CRITTER,
               A.OVERKILL },
})

A.SUPPORT_MAIN = ns.Achievement(milestones, {
    name   = 'Support Main',
    desc   = 'Do everything for everyone and get thanked for none of it.',
    points = 60,
    icon   = '-spell_holy_sealofsacrifice',
    meta   = { A.HELPFUL_1000, A.REZZED_AGAIN[T[100]], A.INTERRUPTED[T[200]],
               A.DISPEL_THIS[T[200]], A.THANKS_FOR_NOTHING },
})

A.ZOO_KEEPER = ns.Achievement(milestones, {
    name   = 'Zoo Keeper',
    desc   = 'Hold a conversation with the local wildlife.',
    points = 25,
    icon   = '-ability_hunter_pet_turtle',
    meta   = { A.CHICKEN_DINNER, A.MOO, A.HERE_KITTY },
})

A.CERTIFIED_WEIRDO = ns.Achievement(milestones, {
    name   = 'Certified Weirdo',
    desc   = 'No gear, no weapon, no explanation.',
    points = 50,
    icon   = '-inv_shirt_08',
    meta   = { A.FASHION_OVER_FUNCTION, A.NAKED_GNOME_RUN, A.KNUCKLE_SANDWICH[T[100]],
               A.ZOO_KEEPER },
})

A.TOURIST_OF_THE_DAMNED = ns.Achievement(milestones, {
    name   = 'Tourist of the Damned',
    desc   = 'Stand in every place worth standing in.',
    points = 40,
    icon   = '-inv_misc_map02',
    meta   = { A.DEEP_SEA_DIVER, A.MOUNTAIN_GOAT, A.BOOTY_BAY_TOURIST, A.ONE_SMALL_STEP },
})

A.SCARLET_COMPLETIONIST = ns.Achievement(milestones, {
    name   = 'Scarlet Completionist',
    desc   = 'Every wing of the Monastery, with a full guild group.',
    points = 40,
    icon   = '-Spell_Holy_Senseundead',
    meta   = { A.GUILD_RUN_SM_GRAVEYARD, A.GUILD_RUN_SM_LIBRARY,
               A.GUILD_RUN_SM_ARMORY, A.GUILD_RUN_SM_CATHEDRAL },
})

A.MAUL_OF_FAME = ns.Achievement(milestones, {
    name   = 'Maul of Fame',
    desc   = 'Every wing of Dire Maul, with a full guild group.',
    points = 35,
    icon   = '-inv_crown_01',
    meta   = { A.GUILD_RUN_DIRE_MAUL_EAST, A.GUILD_RUN_DIRE_MAUL_WEST,
               A.GUILD_RUN_DIRE_MAUL_NORTH },
})

A.BLACKROCK_REGULAR = ns.Achievement(milestones, {
    name   = 'Blackrock Regular',
    desc   = 'The whole mountain, top to bottom, with a full guild group.',
    points = 40,
    icon   = 'achievement_boss_generaldrakkisath',
    meta   = { A.GUILD_RUN_BLACKROCK_DEPTHS, A.GUILD_RUN_LOWER_BLACKROCK_SPIRE,
               A.GUILD_RUN_UPPER_BLACKROCK_SPIRE },
})

A.RENAISSANCE_DENTER = ns.Achievement(milestones, {
    name   = 'Renaissance Denter',
    desc   = 'Good at everything, sensible about none of it.',
    points = 150,
    icon   = 'achievement_dungeon_gloryofthehero',
    meta   = { A.DRESSED_FOR_SUCCESS, A.PEOPLE_PERSON, A.ROAD_WARRIOR,
               A.FED_AND_WATERED, A.CERTIFIED_WEIRDO },
})
