local _, ns = ...
if ns.disabled then return end

-- Simply being somewhere. Anniversary's EXPLORE_AREA wants the map uncovered, which the
-- open ocean never is, so this asks only that you stood there.
CA_Criterias.dataLengths[ns.CRITERIA_ZONE_VISIT] = 1
CA_Criterias.criterias[ns.CRITERIA_ZONE_VISIT] = {}

-- Either name counts, the same way core/ZoneLevel.lua reads it: a spot like Booty Bay is a
-- subzone, a whole city like Stormwind is the zone, and an achievement may ask for either.
local function check()
    local subZone, zone = GetSubZoneText(), GetZoneText()
    for areaID in pairs(CA_Criterias.criterias[ns.CRITERIA_ZONE_VISIT]) do
        local wanted = AreaTableLocale[areaID]
        if wanted == subZone or wanted == zone then
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
