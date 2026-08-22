local _, ns = ...
if ns.disabled then return end

-- The last boss of every raid, and how many of us have to be there for it to count.
local raids = {}
ns.Raids = raids

raids.SMALL_RAID = 5
raids.BIG_RAID = 10

raids.classic = {
    { key = 'ONYXIA', name = "Onyxia's Lair", title = 'Big Red Lizard',
        boss = 'Onyxia', id = 10184, need = raids.BIG_RAID, points = 25,
        icon = 'achievement_boss_onyxia' },

    { key = 'MOLTEN_CORE', name = 'Molten Core', title = 'Firelord Down',
        boss = 'Ragnaros', id = 11502, need = raids.BIG_RAID, points = 30,
        icon = 'achievement_boss_ragnaros' },

    { key = 'BLACKWING_LAIR', name = 'Blackwing Lair', title = 'Family Business',
        boss = 'Nefarian', id = 11583, need = raids.BIG_RAID, points = 35,
        icon = 'achievement_boss_nefarion' },

    { key = 'ZUL_GURUB', name = "Zul'Gurub", title = 'Soul Drained',
        boss = 'Hakkar', id = 14834, need = raids.BIG_RAID, points = 25,
        icon = 'achievement_boss_hakkar' },

    { key = 'AQ20', name = "Ruins of Ahn'Qiraj", title = 'Ruined',
        boss = 'Ossirian the Unscarred', id = 15339, need = raids.BIG_RAID, points = 25,
        icon = 'achievement_boss_ossiriantheunscarred' },

    { key = 'AQ40', name = "Temple of Ahn'Qiraj", title = 'Eye Opener',
        boss = "C'Thun", id = 15727, need = raids.BIG_RAID, points = 40,
        icon = 'achievement_boss_cthun' },

    { key = 'NAXXRAMAS', name = 'Naxxramas', title = 'Frozen Out',
        boss = "Kel'Thuzad", id = 15990, need = raids.BIG_RAID, points = 50,
        icon = '-inv_trinket_naxxramas06' },
}

raids.tbc = {
    { key = 'KARAZHAN', name = 'Karazhan', title = 'Opera Night',
        boss = 'Prince Malchezaar', id = 15690, need = raids.SMALL_RAID, points = 25,
        icon = 'achievement_boss_princemalchezaar_02' },

    { key = 'GRUUL', name = "Gruul's Lair", title = 'Dragonkiller Down',
        boss = 'Gruul the Dragonkiller', id = 19044, need = raids.BIG_RAID, points = 25,
        icon = 'achievement_boss_gruulthedragonkiller' },

    { key = 'MAGTHERIDON', name = "Magtheridon's Lair", title = 'Pit Stop',
        boss = 'Magtheridon', id = 17257, need = raids.BIG_RAID, points = 25,
        icon = 'achievement_boss_magtheridon' },

    { key = 'SSC', name = 'Serpentshrine Cavern', title = 'Drained',
        boss = 'Lady Vashj', id = 21212, need = raids.BIG_RAID, points = 35,
        icon = 'achievement_boss_ladyvashj' },

    { key = 'TEMPEST_KEEP', name = 'Tempest Keep', title = 'Eye Poked',
        boss = "Kael'thas Sunstrider", id = 19622, need = raids.BIG_RAID, points = 35,
        icon = 'achievement_boss_kaelthassunstrider_01' },

    { key = 'HYJAL', name = 'Hyjal Summit', title = 'Summit Meeting',
        boss = 'Archimonde', id = 17968, need = raids.BIG_RAID, points = 40,
        icon = '-spell_fire_felflamebreath' },

    { key = 'BLACK_TEMPLE', name = 'Black Temple', title = 'Not Prepared',
        boss = 'Illidan Stormrage', id = 22917, need = raids.BIG_RAID, points = 50,
        icon = 'achievement_boss_illidan' },

    { key = 'ZUL_AMAN', name = "Zul'Aman", title = 'Bear Necessities',
        boss = "Zul'jin", id = 23863, need = raids.SMALL_RAID, points = 25,
        icon = 'achievement_boss_zuljin' },

    { key = 'SUNWELL', name = 'Sunwell Plateau', title = 'Well, Well, Well',
        boss = "Kil'jaeden", id = 25315, need = raids.BIG_RAID, points = 60,
        icon = 'achievement_boss_kiljaedan' },
}

-- One lookup for the killing tracker, the same shape core/Dungeons.lua builds.
raids.byCreature = {}
for _, list in pairs({raids.classic, raids.tbc}) do
    for _, raid in ipairs(list) do
        raids.byCreature[raid.id] = raid
    end
end
