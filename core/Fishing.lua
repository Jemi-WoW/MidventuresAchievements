local _, ns = ...
if ns.disabled then return end

local TYPE = CA_Criterias.TYPE

-- What the lake gives back that nobody wanted; Anniversary counts the fish.
CA_Criterias.dataLengths[ns.CRITERIA_JUNK_FISH] = 0
CA_Criterias.criterias[ns.CRITERIA_JUNK_FISH] = {}

local POOR = 0
local FISHING_SPELL = 7620
local CAST_WINDOW = 5
local DIPLOMAT_MAPS = { [1453] = true, [1454] = true }

local function progress()
    MidventuresProgressDB = MidventuresProgressDB or {}
    MidventuresProgressDB.fishing = MidventuresProgressDB.fishing or { junk = 0 }
    return MidventuresProgressDB.fishing
end

-- IsFishingLoot() only answers while the loot window is up, which auto-loot skips.
local fishingName = GetSpellInfo(FISHING_SPELL)
local castAt = 0

local function isFishingChannel(spellID)
    if not (fishingName and spellID) then return false end
    return GetSpellInfo(spellID) == fishingName
end

local function fromTheWater()
    if IsFishingLoot and IsFishingLoot() then return true end
    return castAt > 0 and GetTime() - castAt <= CAST_WINDOW
end

local function lootedItems()
    local items = {}
    for slot = 1, GetNumLootItems() do
        local link = LootSlotHasItem(slot) and GetLootSlotLink(slot) or nil
        if link then
            local _, _, quantity = GetLootSlotInfo(slot)
            items[#items + 1] = { link = link, quantity = quantity or 1 }
        end
    end
    return items
end

local function countJunk(items)
    local junk = 0
    for _, item in ipairs(items) do
        -- On its own line: `link and GetItemInfo(link)` would keep only the first return.
        local _, _, quality = GetItemInfo(item.link)
        if quality == POOR then junk = junk + 1 end
    end
    if junk == 0 then return end

    local record = progress()
    record.junk = record.junk + junk
    CA_Criterias:Trigger(ns.CRITERIA_JUNK_FISH, nil, record.junk, true)
end

-- The same counting Anniversary does, for the catches its own handler never sees.
local function countFish(items)
    local mapID = C_Map.GetBestMapForUnit('player')
    if DIPLOMAT_MAPS[mapID] then
        CA_Criterias:Trigger(TYPE.FISH_ANY_ITEM, {mapID}, 1)
    end

    for _, item in ipairs(items) do
        local id = tonumber(item.link:match('item:(%d+)'))
        if id then
            CA_Criterias:Trigger(TYPE.FISH_AN_ITEM, {id}, item.quantity)
            CA_Criterias:Trigger(TYPE.FISH_ANY_ITEM, {-1}, item.quantity)
        end
    end
end

local session

local function onLoot(event)
    session = session or {}
    -- Anniversary counts on LOOT_OPENED, but only when IsFishingLoot() agrees there.
    if event == 'LOOT_OPENED' and IsFishingLoot and IsFishingLoot() then
        session.counted = true
    end

    if session.handled or not fromTheWater() then return end
    session.handled = true

    local items = lootedItems()
    if #items == 0 then return end
    countJunk(items)

    -- Long enough for LOOT_OPENED to follow LOOT_READY and say who counted it.
    local this = session
    C_Timer.After(0.5, function()
        if not this.counted then countFish(items) end
    end)
end

local watcher = CreateFrame('Frame')
watcher:RegisterEvent('LOOT_READY')
watcher:RegisterEvent('LOOT_OPENED')
watcher:RegisterEvent('LOOT_CLOSED')
watcher:RegisterEvent('UNIT_SPELLCAST_CHANNEL_START')
watcher:RegisterEvent('PLAYER_ENTERING_WORLD')
watcher:SetScript('OnEvent', function(_, event, unit, _, spellID)
    if event == 'LOOT_READY' or event == 'LOOT_OPENED' then
        onLoot(event)
    elseif event == 'LOOT_CLOSED' then
        session = nil
    elseif event == 'UNIT_SPELLCAST_CHANNEL_START' then
        if unit == 'player' and isFishingChannel(spellID) then castAt = GetTime() end
    else
        C_Timer.After(8, function()
            CA_Criterias:Trigger(ns.CRITERIA_JUNK_FISH, nil, progress().junk, true)
        end)
    end
end)
