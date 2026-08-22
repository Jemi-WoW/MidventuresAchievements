local _, ns = ...
if ns.disabled then return end

local A = ns.achievements
local memorials = ns.categories.explorationMemorials

-- Real people, remembered in the game. Wandering ones are bowed to, graves are bowed at.
-- Only the memorials a 2.5 client actually has; the rest were added in later expansions.

-- Bow to whoever is standing there.
local function bowTo(name, achievement, desc, icon)
    return ns.Achievement(memorials, {
        name = achievement, desc = desc, points = 15, icon = icon,
        criteria = {
            { ns.CRITERIA_EMOTE_AT, {'BOW', name}, nil, ('Bowed to %s'):format(name) },
        },
    })
end

-- Bow on the grave itself, since there is nobody to target.
local function bowAt(key, spot, achievement, desc, icon, label)
    return ns.Achievement(memorials, {
        name = achievement, desc = desc, points = 15, icon = icon,
        criteria = {
            { ns.CRITERIA_EMOTE_AT_SPOT, {'BOW', ns.Spot(key, spot)}, nil, label },
        },
    })
end

-- Eastern Kingdoms.

A.MEMORIAL_STARK = bowTo('Rousch', 'Always Ready to Help',
    'Bow to Rousch on the cliffs south of Dun Garok, in Hillsbrad Foothills. '
    .. 'He remembers Anthony Ray Stark, 1961-2005.',
    '-inv_rosebouquet01')

A.MEMORIAL_MORALES = bowAt('MEMORIAL_MORALES', {
    zones = {267}, x = 50.2, y = 68.2, radius = 3,
}, 'A Headstone in Southshore',
    'Bow at the Decorated Headstone in the Southshore graveyard, in Hillsbrad Foothills. '
    .. 'It remembers Jesse Morales, who worked on the game and did not live to see it.',
    '-inv_misc_candle_01', 'Bowed at the headstone')

A.MEMORIAL_OSSEX = bowTo('Captain Armando Ossex', 'Cavalieri dell\'Alba',
    'Bow to Captain Armando Ossex, who patrols the cave to Alterac Valley in the '
    .. 'Alterac Mountains. He remembers a player his guild lost.',
    '-spell_holy_prayerofhealing')

A.MEMORIAL_SARNO = bowTo('Brother Sarno', 'Patience of a Saint',
    'Bow to Brother Sarno in the Cathedral of Light in Stormwind City. '
    .. 'He remembers Richard Sarno, who answered everybody\'s questions.',
    '-spell_holy_revivechampion')

-- Kalimdor.

A.MEMORIAL_MITCHEL = bowTo('Crildor', 'He Never Got to Play',
    'Bow to Crildor, who walks between the Cenarion Enclave and the Temple Gardens in '
    .. 'Darnassus. He remembers Mitchel, who died before the game was released.',
    '-inv_rosebouquet01')

A.MEMORIAL_KOITER = bowAt('MEMORIAL_KOITER', {
    zones = {17}, x = 47, y = 29, radius = 4,
}, 'The Fallen Warrior',
    'Bow at the Shrine of the Fallen Warrior, on the hill southwest of the Crossroads in '
    .. 'The Barrens. The obelisk reads MK, for Michel Koiter.',
    '-spell_holy_prayerofhealing', 'Bowed at the shrine')

A.MEMORIAL_EZRA = bowTo('Ahab Wheathoof', 'Ezra\'s Voice',
    'Bow to Ahab Wheathoof in Bloodhoof Village, Mulgore. He was designed and voiced by '
    .. 'Ezra Chatterton, who was ten.',
    '-inv_misc_candle_01')

-- Outland.

A.MEMORIAL_DAK = bowTo('Caylee Dak', 'Do Not Stand at My Grave',
    'Bow to Caylee Dak on the Aldor Rise in Shattrath City. She stands where Dak Krause '
    .. 'logged out for the last time.',
    '-spell_holy_revivechampion')

A.MEMORIAL_ASHES = bowAt('MEMORIAL_ASHES', {
    zones = {3483}, x = 45.0, y = 87.2, radius = 3,
}, 'Ashes of a Fallen Peon',
    'Bow at the Jar of Ashes in southern Hellfire Peninsula, left for a community manager '
    .. 'who burned out.',
    '-inv_misc_candle_01', 'Bowed at the jar')

A.MEMORIAL_NOVA = bowAt('MEMORIAL_NOVA', {
    zones = {3523}, x = 40.9, y = 82.7, radius = 3,
}, 'The Ghost of Nova',
    'Bow at the Nova grave in the Crumbling Waste, Netherstorm. It remembers a game that '
    .. 'was never finished.',
    '-spell_holy_prayerofhealing', 'Bowed at the grave')

A.RESPECTS_PAID_AZEROTH = ns.Achievement(memorials, {
    name   = 'Respects Paid: Azeroth',
    desc   = 'Pay your respects at every memorial in Eastern Kingdoms and Kalimdor.',
    points = 40,
    icon   = '-inv_rosebouquet01',
    meta = {
        A.MEMORIAL_STARK,
        A.MEMORIAL_MORALES,
        A.MEMORIAL_OSSEX,
        A.MEMORIAL_SARNO,
        A.MEMORIAL_MITCHEL,
        A.MEMORIAL_KOITER,
        A.MEMORIAL_EZRA,
    },
})

A.RESPECTS_PAID_OUTLAND = ns.Achievement(memorials, {
    name   = 'Respects Paid: Outland',
    desc   = 'Pay your respects at every memorial on the other side of the portal.',
    points = 30,
    icon   = '-spell_holy_prayerofhealing',
    meta = {
        A.MEMORIAL_DAK,
        A.MEMORIAL_ASHES,
        A.MEMORIAL_NOVA,
    },
})
