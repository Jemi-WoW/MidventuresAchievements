local _, ns = ...
if ns.disabled then return end

-- Simply being somewhere. Anniversary's EXPLORE_AREA wants the map uncovered, which the
-- open ocean never is, so this asks only that you stood there.
CA_Criterias.dataLengths[ns.CRITERIA_ZONE_VISIT] = 1
CA_Criterias.criterias[ns.CRITERIA_ZONE_VISIT] = {}

-- Subzone first, the same order core/ZoneLevel.lua reads it in.
local function here()
    local subZone = GetSubZoneText()
    if subZone and subZone ~= '' then return subZone end
    return GetZoneText()
end

local function check()
    local name = here()
    for areaID in pairs(CA_Criterias.criterias[ns.CRITERIA_ZONE_VISIT]) do
        if AreaTableLocale[areaID] == name then
            CA_Criterias:Trigger(ns.CRITERIA_ZONE_VISIT, {areaID})
        end
    end
end

local watcher = CreateFrame('Frame')
watcher:RegisterEvent('PLAYER_ENTERING_WORLD')
watcher:RegisterEvent('ZONE_CHANGED_NEW_AREA')
watcher:RegisterEvent('ZONE_CHANGED')
watcher:RegisterEvent('ZONE_CHANGED_INDOORS')
watcher:SetScript('OnEvent', function() C_Timer.After(1, check) end)
