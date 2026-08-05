local _, ns = ...
if ns.disabled then return end

-- Every five-man dungeon, for the guild run achievements in achievements/dungeons-raids/.
-- `final` is what completing the dungeon means; `bosses` is what clearing it means.
-- Each entry is a group of creature ids that all count as the same boss - TBC bosses carry
-- a second id for heroic. Boss lists come from AtlasLoot, minus rares, quest-only spawns,
-- summons and anything random, so a clear only ever asks for what a normal run walks past.

local dungeons = {}
ns.Dungeons = dungeons

dungeons.classic = {
    { key = 'RAGEFIRE_CHASM', name = 'Ragefire Chasm',
        final = { {11520} },
        bosses = {
            {11520}, -- Taragaman the Hungerer
            {11518}, -- Jergosh the Invoker
        },
    },
    { key = 'WAILING_CAVERNS', name = 'Wailing Caverns',
        final = { {3654} },
        bosses = {
            {3669}, -- Lord Cobrahn
            {3671}, -- Lady Anacondra
            {3653}, -- Kresh
            {3670}, -- Lord Pythas
            {3674}, -- Skum
            {3673}, -- Lord Serpentis
            {5775}, -- Verdan the Everliving
            {3654}, -- Mutanus the Devourer
        },
    },
    { key = 'DEADMINES', name = 'The Deadmines',
        final = { {639} },
        bosses = {
            {644}, -- Rhahk'Zor
            {643}, -- Sneed
            {642}, -- Sneed's Shredder
            {1763}, -- Gilnid
            {646}, -- Mr. Smite
            {647}, -- Captain Greenskin
            {639}, -- Edwin VanCleef
            {645}, -- Cookie
        },
    },
    { key = 'SHADOWFANG_KEEP', name = 'Shadowfang Keep',
        final = { {4275} },
        bosses = {
            {3914}, -- Rethilgore
            {3865, 3864}, -- Fel Steed / Shadow Charger
            {3886}, -- Razorclaw the Butcher
            {3887}, -- Baron Silverlaine
            {4278}, -- Commander Springvale
            {4279}, -- Odo the Blindwatcher
            {4627}, -- Arugal's Voidwalker
            {4274}, -- Fenrus the Devourer
            {3927}, -- Wolf Master Nandos
            {4275}, -- Archmage Arugal
        },
    },
    { key = 'BLACKFATHOM_DEEPS', name = 'Blackfathom Deeps',
        final = { {4829} },
        bosses = {
            {4887}, -- Ghamoo-ra
            {4831}, -- Lady Sarevess
            {6243}, -- Gelihast
            {4832}, -- Twilight Lord Kelris
            {4830}, -- Old Serra'kis
            {4829}, -- Aku'mai
        },
    },
    { key = 'STOCKADE', name = 'The Stockade',
        final = { {1716} },
        bosses = {
            {1666}, -- Kam Deepfury
            {1716}, -- Bazil Thredd
        },
    },
    { key = 'GNOMEREGAN', name = 'Gnomeregan',
        final = { {7800} },
        bosses = {
            {6231}, -- Techbot
            {7361}, -- Grubbis
            {7079}, -- Viscous Fallout
            {6235}, -- Electrocutioner 6000
            {6229}, -- Crowd Pummeler 9-60
            {7800}, -- Mekgineer Thermaplugg
        },
    },
    { key = 'RAZORFEN_KRAUL', name = 'Razorfen Kraul',
        final = { {4421} },
        bosses = {
            {4424}, -- Aggem Thorncurse
            {4428}, -- Death Speaker Jargba
            {4420}, -- Overlord Ramtusk
            {4438}, -- Razorfen Spearhide
            {4422}, -- Agathelos the Raging
            {4421}, -- Charlga Razorflank
        },
    },
    { key = 'SCARLET_MONASTERY', name = 'Scarlet Monastery',
        final = { {4543}, {6487}, {3975}, {3977} },
        bosses = {
            {3983}, -- Interrogator Vishas
            {4543}, -- Bloodmage Thalnos
            {3974}, -- Houndmaster Loksey
            {6487}, -- Arcanist Doan
            {3975}, -- Herod
            {4542}, -- High Inquisitor Fairbanks
            {3976}, -- Scarlet Commander Mograine
            {3977}, -- High Inquisitor Whitemane
        },
    },
    { key = 'RAZORFEN_DOWNS', name = 'Razorfen Downs',
        final = { {7358} },
        bosses = {
            {7355}, -- Tuten'kash
            {7357}, -- Mordresh Fire Eye
            {8567}, -- Glutton
            {7358}, -- Amnennar the Coldbringer
            {7356}, -- Plaguemaw the Rotting
        },
    },
    { key = 'ULDAMAN', name = 'Uldaman',
        final = { {2748} },
        bosses = {
            {6907}, -- Eric \
            {6906}, -- Baelog
            {6908}, -- Olaf
            {6910}, -- Revelosh
            {7228}, -- Ironaya
            {7023}, -- Obsidian Sentinel
            {7206}, -- Ancient Stone Keeper
            {7291}, -- Galgann Firehammer
            {4854}, -- Grimlok
            {2748}, -- Archaedas
        },
    },
    { key = 'ZULFARRAK', name = "Zul'Farrak",
        final = { {7267} },
        bosses = {
            {8127}, -- Antu'sul
            {7271}, -- Witch Doctor Zum'rah
            {7275}, -- Shadowpriest Sezz'ziz
            {7274}, -- Sandfury Executioner
            {7273}, -- Gahz'rilla
            {7267}, -- Chief Ukorz Sandscalp
        },
    },
    { key = 'MARAUDON', name = 'Maraudon',
        final = { {12201} },
        bosses = {
            {13282}, -- Noxxion
            {12258}, -- Razorlash
            {12236}, -- Lord Vyletongue
            {12225}, -- Celebras the Cursed
            {12203}, -- Landslide
            {13601}, -- Tinkerer Gizlock
            {13596}, -- Rotgrip
            {12201}, -- Princess Theradras
        },
    },
    { key = 'SUNKEN_TEMPLE', name = 'The Sunken Temple',
        final = { {5709} },
        bosses = {
            {5716, 5712, 5717, 5714, 5715, 5713}, -- Balcony Minibosses
            {5710}, -- Jammal'an the Prophet
            {5711}, -- Ogom the Wretched
            {5721}, -- Dreamscythe
            {5720}, -- Weaver
            {5722}, -- Hazzas
            {5719}, -- Morphaz
            {5709}, -- Shade of Eranikus
        },
    },
    { key = 'BLACKROCK_DEPTHS', name = 'Blackrock Depths',
        final = { {9019} },
        bosses = {
            {9025}, -- Lord Roccor
            {9018}, -- High Interrogator Gerstahn
            {9319}, -- Houndmaster Grebmar
            {9438, 9442, 9443, 9439, 9437, 9441}, -- Dark Coffer
            {9041}, -- Warder Stilgiss
            {9042}, -- Verek
            {9056}, -- Fineous Darkvire
            {9017}, -- Lord Incendius
            {9016}, -- Bael'Gar
            {9033}, -- General Angerforge
            {8983}, -- Golem Lord Argelmach
            {9537, 12944, 9543, 9499}, -- Guzzler
            {9502}, -- Phalanx
            {9156}, -- Ambassador Flamelash
            {9034, 9035, 9036, 9037, 9038, 9039, 9040}, -- Chest of The Seven
            {9938}, -- Magmus
            {8929}, -- Princess Moira Bronzebeard
            {9019}, -- Emperor Dagran Thaurissan
        },
    },
    { key = 'LOWER_BLACKROCK_SPIRE', name = 'Lower Blackrock Spire',
        final = { {9568} },
        bosses = {
            {9196}, -- Highlord Omokk
            {9236}, -- Shadow Hunter Vosh'gajin
            {9237}, -- War Master Voone
            {10596}, -- Mother Smolderweb
            {9736}, -- Quartermaster Zigris
            {10220}, -- Halycon
            {10268}, -- Gizrul the Slavener
            {9568}, -- Overlord Wyrmthalak
        },
    },
    { key = 'UPPER_BLACKROCK_SPIRE', name = 'Upper Blackrock Spire',
        final = { {10363} },
        bosses = {
            {9816}, -- Pyroguard Emberseer
            {10264}, -- Solakar Flamewreath
            {10899}, -- Goraluk Anvilcrack
            {10339}, -- Gyth
            {10429}, -- Warchief Rend Blackhand
            {10430}, -- The Beast
            {10363}, -- General Drakkisath
        },
    },
    { key = 'DIRE_MAUL', name = 'Dire Maul',
        final = { {11492}, {11486}, {11501} },
        bosses = {
            {14354}, -- Pusillin
            {11490}, -- Zevrim Thornhoof
            {13280}, -- Hydrospawn
            {14327}, -- Lethtendris
            {11492}, -- Alzzin the Wildshaper
            {11489}, -- Tendris Warpwood
            {11488}, -- Illyanna Ravenoak
            {11487}, -- Magister Kalendris
            {11496}, -- Immol'thar
            {11486}, -- Prince Tortheldrin
            {14326}, -- Guard Mol'dar
            {14322}, -- Stomper Kreeg
            {14321}, -- Guard Fengus
            {14323}, -- Guard Slip'kik
            {14325}, -- Captain Kromcrush
            {14324}, -- Cho'Rush the Observer
            {11501}, -- King Gordok
        },
    },
    { key = 'SCHOLOMANCE', name = 'Scholomance',
        final = { {1853} },
        bosses = {
            {10506}, -- Kirtonos the Herald
            {10503}, -- Jandice Barov
            {11622}, -- Rattlegore
            {10433}, -- Marduk Blackpool
            {10432}, -- Vectus
            {10508}, -- Ras Frostwhisper
            {10505}, -- Instructor Malicia
            {11261}, -- Doctor Theolen Krastinov
            {10901}, -- Lorekeeper Polkelt
            {10507}, -- The Ravenian
            {10504}, -- Lord Alexei Barov
            {10502}, -- Lady Illucia Barov
            {1853}, -- Darkmaster Gandling
        },
    },
    { key = 'STRATHOLME', name = 'Stratholme',
        final = { {10440} },
        bosses = {
            {10516}, -- The Unforgiven
            {11143}, -- Postmaster Malown
            {10808}, -- Timmy the Cruel
            {11032}, -- Malor the Zealous
            {11120}, -- Crimson Hammersmith
            {10997}, -- Cannon Master Willey
            {10811}, -- Archivist Galford
            {10812, 10813}, -- Balnazzar
            {10435}, -- Magistrate Barthilas
            {10436}, -- Baroness Anastari
            {11121}, -- Black Guard Swordsmith
            {10437}, -- Nerub'enkan
            {10438}, -- Maleki the Pallid
            {10439}, -- Ramstein the Gorger
            {10440}, -- Baron Rivendare
        },
    },
}

dungeons.tbc = {
    { key = 'HELLFIRE_RAMPARTS', name = 'Hellfire Ramparts',
        final = { {17537, 18434, 17536, 18432} },
        bosses = {
            {17306, 18436}, -- Watchkeeper Gargolmar
            {17308, 18433}, -- Omor the Unscarred
            {17537, 18434, 17536, 18432}, -- Nazan & Vazruden
        },
    },
    { key = 'BLOOD_FURNACE', name = 'The Blood Furnace',
        final = { {17377, 18607} },
        bosses = {
            {17381, 18621}, -- The Maker
            {17380, 18601}, -- Broggok
            {17377, 18607}, -- Keli'dan the Breaker
        },
    },
    { key = 'SHATTERED_HALLS', name = 'The Shattered Halls',
        final = { {16808, 20597} },
        bosses = {
            {16807, 20568}, -- Grand Warlock Nethekurse
            {16809, 20596}, -- Warbringer O'mrogg
            {16808, 20597}, -- Warchief Kargath Bladefist
        },
    },
    { key = 'MANA_TOMBS', name = 'Mana-Tombs',
        final = { {18344, 20266} },
        bosses = {
            {18341, 20267}, -- Pandemonius
            {18343, 20268}, -- Tavarok
            {18344, 20266}, -- Nexus-Prince Shaffar
        },
    },
    { key = 'AUCHENAI_CRYPTS', name = 'Auchenai Crypts',
        final = { {18373, 20306} },
        bosses = {
            {18371, 20318}, -- Shirrak the Dead Watcher
            {18373, 20306}, -- Exarch Maladaar
        },
    },
    { key = 'SETHEKK_HALLS', name = 'Sethekk Halls',
        final = { {18473, 20706} },
        bosses = {
            {18472, 20690}, -- Darkweaver Syth
            {18473, 20706}, -- Talon King Ikiss
        },
    },
    { key = 'SHADOW_LABYRINTH', name = 'Shadow Labyrinth',
        final = { {18708, 20657} },
        bosses = {
            {18731, 20636}, -- Ambassador Hellmaw
            {18667, 20637}, -- Blackheart the Inciter
            {18732, 20653}, -- Grandmaster Vorpil
            {18708, 20657}, -- Murmur
        },
    },
    { key = 'SLAVE_PENS', name = 'The Slave Pens',
        final = { {17942, 19894} },
        bosses = {
            {17941, 19893}, -- Mennu the Betrayer
            {17991, 19895}, -- Rokmar the Crackler
            {17942, 19894}, -- Quagmirran
        },
    },
    { key = 'UNDERBOG', name = 'The Underbog',
        final = { {17882, 20184} },
        bosses = {
            {17770, 20169}, -- Hungarfen
            {18105, 20168}, -- Ghaz'an
            {17826, 20183}, -- Swamplord Musel'ek
            {17882, 20184}, -- The Black Stalker
        },
    },
    { key = 'STEAMVAULT', name = 'The Steamvault',
        final = { {17798, 20633} },
        bosses = {
            {17797, 20629}, -- Hydromancer Thespia
            {17796, 20630}, -- Mekgineer Steamrigger
            {17798, 20633}, -- Warlord Kalithresh
        },
    },
    { key = 'OLD_HILLSBRAD', name = 'Old Hillsbrad Foothills',
        final = { {18096, 20531} },
        bosses = {
            {17848, 20535}, -- Lieutenant Drake
            {17862, 20521}, -- Captain Skarloc
            {18096, 20531}, -- Epoch Hunter
        },
    },
    { key = 'BLACK_MORASS', name = 'The Black Morass',
        final = { {17881, 20737} },
        bosses = {
            {17879, 20738}, -- Chrono Lord Deja
            {17880, 20745}, -- Temporus
            {17881, 20737}, -- Aeonus
        },
    },
    { key = 'ARCATRAZ', name = 'The Arcatraz',
        final = { {20912, 21599} },
        bosses = {
            {20870, 21626}, -- Zereketh the Unbound
            {20885, 21590}, -- Dalliah the Doomsayer
            {20886, 21624}, -- Wrath-Scryer Soccothrates
            {20912, 21599}, -- Harbinger Skyriss
        },
    },
    { key = 'BOTANICA', name = 'The Botanica',
        final = { {17977, 21582} },
        bosses = {
            {17976, 21551}, -- Commander Sarannis
            {17975, 21558}, -- High Botanist Freywinn
            {17978, 21581}, -- Thorngrin the Tender
            {17980, 21559}, -- Laj
            {17977, 21582}, -- Warp Splinter
        },
    },
    { key = 'MECHANAR', name = 'The Mechanar',
        final = { {19220, 21537} },
        bosses = {
            {19219, 21533}, -- Mechano-Lord Capacitus
            {19221, 21536}, -- Nethermancer Sepethrea
            {19220, 21537}, -- Pathaleon the Calculator
            {19218, 21525}, -- Gatewatcher Gyro-Kill
            {19710, 21526}, -- Gatewatcher Iron-Hand
        },
    },
    { key = 'MAGISTERS_TERRACE', name = "Magisters' Terrace",
        final = { {24664, 24857} },
        bosses = {
            {24723, 25562}, -- Selin Fireheart
            {24744, 25573}, -- Vexallus
            {24560, 25560}, -- Priestess Delrissa
            {24664, 24857}, -- Kael'thas Sunstrider
        },
    },
}

-- Every boss of every dungeon, keyed by creature id, for the kill tracker.
dungeons.byCreature = {}
for _, list in pairs({dungeons.classic, dungeons.tbc}) do
    for _, dungeon in ipairs(list) do
        for _, group in ipairs(dungeon.bosses) do
            for _, creatureID in ipairs(group) do
                dungeons.byCreature[creatureID] = dungeon
            end
        end
    end
end
