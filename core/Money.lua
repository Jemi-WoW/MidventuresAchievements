local _, ns = ...
if ns.disabled then return end

-- Money and the things it passes through: vendors, the auction house, and your bags.
CA_Criterias.dataLengths[ns.CRITERIA_VENDOR_SALES] = 0
CA_Criterias.criterias[ns.CRITERIA_VENDOR_SALES] = {}
CA_Criterias.dataLengths[ns.CRITERIA_AUCTIONS] = 0
CA_Criterias.criterias[ns.CRITERIA_AUCTIONS] = {}
CA_Criterias.dataLengths[ns.CRITERIA_BAGS_FULL] = 0
CA_Criterias.criterias[ns.CRITERIA_BAGS_FULL] = {}
CA_Criterias.dataLengths[ns.CRITERIA_MONEY] = 1
CA_Criterias.criterias[ns.CRITERIA_MONEY] = {}
CA_Criterias.dataLengths[ns.CRITERIA_BROKE] = 0
CA_Criterias.criterias[ns.CRITERIA_BROKE] = {}
CA_Criterias.dataLengths[ns.CRITERIA_GOLD_HELD] = 0
CA_Criterias.criterias[ns.CRITERIA_GOLD_HELD] = {}

local RICH_ENOUGH = 100 * 10000  -- a hundred gold, in copper
local SKINT = 100                -- one silver

local function progress()
    MidventuresProgressDB = MidventuresProgressDB or {}
    MidventuresProgressDB.money = MidventuresProgressDB.money
        or { sales = 0, auctions = 0, wasRich = false }
    return MidventuresProgressDB.money
end

local function bump(key, criteriaType)
    local record = progress()
    record[key] = (record[key] or 0) + 1
    CA_Criterias:Trigger(criteriaType, nil, record[key], true)
end

-- Selling has no event of its own: an item used while a merchant is open is a sale.
local merchantOpen = false

local function onSell()
    if merchantOpen then bump('sales', ns.CRITERIA_VENDOR_SALES) end
end

if C_Container and C_Container.UseContainerItem then
    hooksecurefunc(C_Container, 'UseContainerItem', onSell)
elseif UseContainerItem then
    hooksecurefunc('UseContainerItem', onSell)
end

if PostAuction then
    hooksecurefunc('PostAuction', function() bump('auctions', ns.CRITERIA_AUCTIONS) end)
end

local numSlots = C_Container and C_Container.GetContainerNumSlots or GetContainerNumSlots
local itemID = C_Container and C_Container.GetContainerItemID or GetContainerItemID

local function bagSlots()
    if not (numSlots and itemID) then return 0, 0 end

    local free, total = 0, 0
    for bag = 0, NUM_BAG_SLOTS do
        local slots = numSlots(bag) or 0
        total = total + slots
        for slot = 1, slots do
            if not itemID(bag, slot) then free = free + 1 end
        end
    end
    return free, total
end

local function checkBags()
    -- A character with no bags at all has no achievement to earn here.
    local free, total = bagSlots()
    if free == 0 and total > 0 then
        CA_Criterias:Trigger(ns.CRITERIA_BAGS_FULL)
    end
end

local function checkMoney()
    local money = GetMoney() or 0
    CA_Criterias:Trigger(ns.CRITERIA_GOLD_HELD, nil, money, true)

    for wanted in pairs(CA_Criterias.criterias[ns.CRITERIA_MONEY]) do
        if money >= wanted then CA_Criterias:Trigger(ns.CRITERIA_MONEY, {wanted}) end
    end

    local record = progress()
    if money >= RICH_ENOUGH then record.wasRich = true end
    if record.wasRich and money < SKINT then
        CA_Criterias:Trigger(ns.CRITERIA_BROKE)
    end
end

local watcher = CreateFrame('Frame')
watcher:RegisterEvent('PLAYER_ENTERING_WORLD')
watcher:RegisterEvent('MERCHANT_SHOW')
watcher:RegisterEvent('MERCHANT_CLOSED')
watcher:RegisterEvent('PLAYER_MONEY')
watcher:RegisterEvent('BAG_UPDATE')
watcher:SetScript('OnEvent', function(_, event)
    if event == 'MERCHANT_SHOW' then
        merchantOpen = true
    elseif event == 'MERCHANT_CLOSED' then
        merchantOpen = false
    elseif event == 'BAG_UPDATE' then
        C_Timer.After(1, checkBags)
    else
        C_Timer.After(1, checkMoney)
    end
end)
