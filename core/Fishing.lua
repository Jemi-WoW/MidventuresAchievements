local _, ns = ...
if ns.disabled then return end

-- What the lake gives back that nobody wanted. Anniversary counts the fish, so this counts
-- everything else.
CA_Criterias.dataLengths[ns.CRITERIA_JUNK_FISH] = 0
CA_Criterias.criterias[ns.CRITERIA_JUNK_FISH] = {}

local POOR = 0

local function progress()
    MidventuresProgressDB = MidventuresProgressDB or {}
    MidventuresProgressDB.fishing = MidventuresProgressDB.fishing or { junk = 0 }
    return MidventuresProgressDB.fishing
end

-- The client says outright when a loot window came off a fishing line, so there is nothing
-- to guess at here.
local function onLoot()
    if not (IsFishingLoot and IsFishingLoot()) then return end

    -- The quality has to be read on its own line: `link and GetItemInfo(link)` would keep
    -- only the first of the values it returns.
    local junk = 0
    for slot = 1, GetNumLootItems() do
        local link = LootSlotHasItem(slot) and GetLootSlotLink(slot) or nil
        if link then
            local _, _, quality = GetItemInfo(link)
            if quality == POOR then junk = junk + 1 end
        end
    end
    if junk == 0 then return end

    local record = progress()
    record.junk = record.junk + junk
    CA_Criterias:Trigger(ns.CRITERIA_JUNK_FISH, nil, record.junk, true)
end

local watcher = CreateFrame('Frame')
watcher:RegisterEvent('LOOT_OPENED')
watcher:RegisterEvent('PLAYER_ENTERING_WORLD')
watcher:SetScript('OnEvent', function(_, event)
    if event == 'LOOT_OPENED' then
        onLoot()
    else
        C_Timer.After(8, function()
            CA_Criterias:Trigger(ns.CRITERIA_JUNK_FISH, nil, progress().junk, true)
        end)
    end
end)
