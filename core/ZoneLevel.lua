local _, ns = ...
if ns.disabled then return end

-- Being somewhere before a level. Data is an AreaTableLocale id and the level to beat.
CA_Criterias.dataLengths[ns.CRITERIA_ZONE_BELOW_LEVEL] = 2
CA_Criterias.criterias[ns.CRITERIA_ZONE_BELOW_LEVEL] = {}

-- Subzone first, the way Anniversary reads exploration, so Booty Bay is not all of STV.
local function here()
    local subZone = GetSubZoneText()
    if subZone and subZone ~= '' then return subZone end
    return GetZoneText()
end

-- The registered criteria are the whole list of places worth checking, so walk those
-- rather than keeping a second copy of the same thing.
local function check()
    local name, level = here(), UnitLevel('player')
    for areaID, byLevel in pairs(CA_Criterias.criterias[ns.CRITERIA_ZONE_BELOW_LEVEL]) do
        if AreaTableLocale[areaID] == name then
            for maxLevel in pairs(byLevel) do
                if level < maxLevel then
                    CA_Criterias:Trigger(ns.CRITERIA_ZONE_BELOW_LEVEL, {areaID, maxLevel})
                end
            end
        end
    end
end

local watcher = CreateFrame('Frame')
watcher:RegisterEvent('PLAYER_ENTERING_WORLD')
watcher:RegisterEvent('ZONE_CHANGED_NEW_AREA')
watcher:RegisterEvent('ZONE_CHANGED')
watcher:RegisterEvent('ZONE_CHANGED_INDOORS')
watcher:SetScript('OnEvent', function() C_Timer.After(1, check) end)
