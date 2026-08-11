local _, ns = ...
if ns.disabled then return end

-- Every dungeon with a guild run achievement. `ids` is the final boss, wings listed apart.

local dungeons = {}
ns.Dungeons = dungeons

dungeons.classic = {
    { key = 'RAGEFIRE_CHASM', name = 'Ragefire Chasm',
        title = "The Guild's on Fire", boss = 'Taragaman the Hungerer',
        ids = {11520}, icon = '-spell_fire_fire' },

    { key = 'WAILING_CAVERNS', name = 'Wailing Caverns',
        title = 'Snake? Snake! SNAKE!', boss = 'Mutanus the Devourer',
        ids = {3654}, icon = 'achievement_boss_mutanus_the_devourer' },

    { key = 'DEADMINES', name = 'The Deadmines',
        title = 'Deadmined', boss = 'Edwin VanCleef',
        ids = {639}, icon = 'achievement_boss_edwinvancleef' },

    { key = 'SHADOWFANG_KEEP', name = 'Shadowfang Keep',
        title = 'Howling Good Time', boss = 'Archmage Arugal',
        ids = {4275}, icon = 'achievement_boss_archmagearugal' },

    { key = 'BLACKFATHOM_DEEPS', name = 'Blackfathom Deeps',
        title = 'Into the Deep End', boss = "Aku'mai",
        ids = {4829}, icon = 'achievement_boss_bazil_akumai' },

    { key = 'STOCKADE', name = 'The Stockade',
        title = 'Prison Break', boss = 'Bazil Thredd',
        ids = {1716}, icon = 'achievement_boss_bazil_thredd' },

    { key = 'GNOMEREGAN', name = 'Gnomeregan',
        title = "Where's the Exit?", boss = 'Mekgineer Thermaplugg',
        ids = {7800}, icon = 'gnomeregan' },

    { key = 'RAZORFEN_KRAUL', name = 'Razorfen Kraul',
        title = 'Hog Wild', boss = 'Charlga Razorflank',
        ids = {4421}, icon = 'achievement_boss_charlgarazorflank' },

    { key = 'SM_GRAVEYARD', name = 'Scarlet Monastery: Graveyard',
        title = 'Dead Tired', boss = 'Bloodmage Thalnos',
        ids = {4543}, icon = '-Spell_Shadow_DeathScream' },

    { key = 'SM_LIBRARY', name = 'Scarlet Monastery: Library',
        title = "Shhh... We're Reading", boss = 'Arcanist Doan',
        ids = {6487}, icon = '-Inv_Misc_Book_07' },

    { key = 'SM_ARMORY', name = 'Scarlet Monastery: Armory',
        title = 'Armed and Dangerous', boss = 'Herod',
        ids = {3975}, icon = '-Inv_Sword_39' },

    { key = 'SM_CATHEDRAL', name = 'Scarlet Monastery: Cathedral',
        title = 'Holy Diver', boss = 'High Inquisitor Whitemane',
        ids = {3977}, icon = '-Spell_Holy_Senseundead' },

    { key = 'RAZORFEN_DOWNS', name = 'Razorfen Downs',
        title = 'Here Today, Gone Tomorrow', boss = 'Amnennar the Coldbringer',
        ids = {7358}, icon = 'achievement_boss_amnennar_the_coldbringer' },

    { key = 'ULDAMAN', name = 'Uldaman',
        title = 'What Is This Place?', boss = 'Archaedas',
        ids = {2748}, icon = 'achievement_boss_archaedas' },

    { key = 'ZULFARRAK', name = "Zul'Farrak",
        title = "Don't Touch the Graves", boss = 'Chief Ukorz Sandscalp',
        ids = {7267}, icon = 'achievement_boss_chiefukorzsandscalp' },

    { key = 'MARAUDON', name = 'Maraudon',
        title = 'This Place Is Huge', boss = 'Princess Theradras',
        ids = {12201}, icon = 'achievement_boss_princesstheradras' },

    { key = 'SUNKEN_TEMPLE', name = 'The Sunken Temple',
        title = 'Just Keep Swimming', boss = 'Shade of Eranikus',
        ids = {5709}, icon = 'achievement_boss_shadeoferanikus' },

    { key = 'BLACKROCK_DEPTHS', name = 'Blackrock Depths',
        title = 'We Have Time for This, Right?', boss = 'Emperor Dagran Thaurissan',
        ids = {9019}, icon = 'achievement_boss_emperordagranthaurissan' },

    { key = 'LOWER_BLACKROCK_SPIRE', name = 'Lower Blackrock Spire',
        title = 'Lower Your Expectations', boss = 'Overlord Wyrmthalak',
        ids = {9568}, icon = 'achievement_boss_overlord_wyrmthalak' },

    { key = 'UPPER_BLACKROCK_SPIRE', name = 'Upper Blackrock Spire',
        title = 'This Is Getting Serious', boss = 'General Drakkisath',
        ids = {10363}, icon = 'achievement_boss_generaldrakkisath' },

    { key = 'DIRE_MAUL_EAST', name = 'Dire Maul East',
        title = "We're Going East", boss = 'Alzzin the Wildshaper',
        ids = {11492}, icon = '-ability_druid_challangingroar' },

    { key = 'DIRE_MAUL_WEST', name = 'Dire Maul West',
        title = "We're Going West", boss = 'Prince Tortheldrin',
        ids = {11486}, icon = '-Spell_Arcane_MassDispel' },

    { key = 'DIRE_MAUL_NORTH', name = 'Dire Maul North',
        title = 'The Tribute Run', boss = 'King Gordok',
        ids = {11501}, icon = '-inv_crown_01' },

    { key = 'SCHOLOMANCE', name = 'Scholomance',
        title = 'Class Dismissed', boss = 'Darkmaster Gandling',
        ids = {1853}, icon = '-Spell_Shadow_ShadowPower' },

    { key = 'STRATHOLME', name = 'Stratholme',
        title = 'A Night to Remember', boss = 'Baron Rivendare',
        ids = {10440}, icon = '-ability_mount_undeadhorse' },
}

dungeons.tbc = {
    { key = 'HELLFIRE_RAMPARTS', name = 'Hellfire Ramparts',
        title = 'Ramp It Up', boss = 'Nazan & Vazruden',
        ids = {17537, 18434, 17536, 18432}, icon = 'achievement_boss_omartheunscarred_01' },

    { key = 'BLOOD_FURNACE', name = 'The Blood Furnace',
        title = 'Blood Brothers', boss = "Keli'dan the Breaker",
        ids = {17377, 18607}, icon = 'achievement_boss_kelidanthebreaker' },

    { key = 'SHATTERED_HALLS', name = 'The Shattered Halls',
        title = 'Shattered Expectations', boss = 'Warchief Kargath Bladefist',
        ids = {16808, 20597}, icon = 'achievement_boss_kargathbladefist_01' },

    { key = 'MANA_TOMBS', name = 'Mana-Tombs',
        title = 'Grave Robbers', boss = 'Nexus-Prince Shaffar',
        ids = {18344, 20266}, icon = 'achievement_boss_nexus_prince_shaffar' },

    { key = 'AUCHENAI_CRYPTS', name = 'Auchenai Crypts',
        title = 'Crypt Keepers', boss = 'Exarch Maladaar',
        ids = {18373, 20306}, icon = 'achievement_boss_exarch_maladaar' },

    { key = 'SETHEKK_HALLS', name = 'Sethekk Halls',
        title = 'Bird Watching', boss = 'Talon King Ikiss',
        ids = {18473, 20706}, icon = 'achievement_boss_talonkingikiss' },

    { key = 'SHADOW_LABYRINTH', name = 'Shadow Labyrinth',
        title = 'Did You Hear That?', boss = 'Murmur',
        ids = {18708, 20657}, icon = 'achievement_boss_murmur' },

    { key = 'SLAVE_PENS', name = 'The Slave Pens',
        title = 'Emancipation', boss = 'Quagmirran',
        ids = {17942, 19894}, icon = 'achievement_boss_quagmirran' },

    { key = 'UNDERBOG', name = 'The Underbog',
        title = 'Bog Standard', boss = 'The Black Stalker',
        ids = {17882, 20184}, icon = 'achievement_boss_theblackstalker' },

    { key = 'STEAMVAULT', name = 'The Steamvault',
        title = 'Letting Off Steam', boss = 'Warlord Kalithresh',
        ids = {17798, 20633}, icon = 'achievement_boss_warlord_kalithresh' },

    { key = 'OLD_HILLSBRAD', name = 'Old Hillsbrad Foothills',
        title = 'Back in My Day', boss = 'Epoch Hunter',
        ids = {18096, 20531}, icon = 'achievement_boss_epochhunter' },

    { key = 'BLACK_MORASS', name = 'The Black Morass',
        title = 'Just in Time', boss = 'Aeonus',
        ids = {17881, 20737}, icon = 'achievement_boss_aeonus_01' },

    { key = 'ARCATRAZ', name = 'The Arcatraz',
        title = 'Jailbreak', boss = 'Harbinger Skyriss',
        ids = {20912, 21599}, icon = 'achievement_boss_harbinger_skyriss' },

    { key = 'BOTANICA', name = 'The Botanica',
        title = 'Green Thumb', boss = 'Warp Splinter',
        ids = {17977, 21582}, icon = 'achievement_boss_warpsplinter' },

    { key = 'MECHANAR', name = 'The Mechanar',
        title = 'Does Not Compute', boss = 'Pathaleon the Calculator',
        ids = {19220, 21537}, icon = 'achievement_boss_pathaleonthecalculator' },

    { key = 'MAGISTERS_TERRACE', name = "Magisters' Terrace",
        title = 'A Terrace with a View', boss = "Kael'thas Sunstrider",
        ids = {24664, 24857}, icon = 'achievement_boss_kaelthassunstrider_01' },
}

-- Every final boss, keyed by creature id, for the kill tracker in core/GuildDungeons.lua.
dungeons.byCreature = {}
for _, list in pairs({dungeons.classic, dungeons.tbc}) do
    for _, dungeon in ipairs(list) do
        for _, creatureID in ipairs(dungeon.ids) do
            dungeons.byCreature[creatureID] = dungeon
        end
    end
end
