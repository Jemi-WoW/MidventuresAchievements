local _, ns = ...
if ns.disabled then return end

local A = ns.achievements
local money = ns.categories.generalMoney

-- Fed by core/Money.lua; Anniversary counts quest gold and nothing else about money.

A.VENDOR_TRASH_TYCOON = ns.Achievement(money, {
    name   = 'Vendor Trash Tycoon',
    desc   = 'Sell 10,000 items to vendors.',
    points = 40,
    icon   = '-inv_misc_coin_02',
    criteria = {
        { ns.CRITERIA_VENDOR_SALES, nil, 10000, 'Items sold' },
    },
})

A.AUCTION_ADDICT = ns.Achievement(money, {
    name   = 'Auction Addict',
    desc   = 'Post 500 auctions.',
    points = 25,
    icon   = '-inv_misc_elvencoins',
    criteria = {
        { ns.CRITERIA_AUCTIONS, nil, 500, 'Auctions posted' },
    },
})

A.BAG_SPACE_PROBLEMS = ns.Achievement(money, {
    name   = 'Bag Space Problems',
    desc   = 'Fill every single bag slot you own.',
    points = 15,
    icon   = '-inv_misc_bag_27',
    criteria = {
        { ns.CRITERIA_BAGS_FULL, nil, nil, 'Not one slot spare' },
    },
})

A.GNOME_PIGGY_BANK = ns.Achievement(money, {
    name   = 'Gnome Piggy Bank',
    desc   = 'Carry 1000 gold at once.',
    points = 35,
    icon   = '-inv_box_01',
    criteria = {
        { ns.CRITERIA_MONEY, {1000 * 10000}, nil, '1000 gold carried' },
    },
})

A.BROKE = ns.Achievement(money, {
    name   = 'Broke',
    desc   = 'Own 100 gold, then drop below one silver.',
    points = 20,
    icon   = '-inv_misc_coin_02',
    criteria = {
        { ns.CRITERIA_BROKE, nil, nil, 'Rich once, skint now' },
    },
})

-- The bar counts copper, so it is shown as coins the way quest gold is.
local function coins(current, required)
    return GetCoinTextureString(current) .. ' / ' .. GetCoinTextureString(required)
end

local GOLD = 10000

A.HOLDING_GOLD = ns.Chain(money, {
    name = function(n) return ('Character Holds %d Gold'):format(n) end,
    desc = function(n) return ('Carry %d gold at once.'):format(n) end,
    criteria = ns.CRITERIA_GOLD_HELD,
    label = 'Gold carried',
    scale = GOLD,
    format = coins,
    icons = {'-inv_misc_coin_01', '-inv_misc_coin_17', '-inv_misc_coin_08'},
})
