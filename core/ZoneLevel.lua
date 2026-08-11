local _, ns = ...
if ns.disabled then return end

-- Being somewhere before a level. Data is an AreaTableLocale id and the level to beat.
CA_Criterias.dataLengths[ns.CRITERIA_ZONE_BELOW_LEVEL] = 2
CA_Criterias.criterias[ns.CRITERIA_ZONE_BELOW_LEVEL] = {}

-- Either name counts: Booty Bay is a subzone, Winterspring a zone with none worth naming.
local function check()
    local subZone, zone = GetSubZoneText(), GetZoneText()
    local level = UnitLevel('player')
    for areaID, byLevel in pairs(CA_Criterias.criterias[ns.CRITERIA_ZONE_BELOW_LEVEL]) do
        local wanted = AreaTableLocale[areaID]
        if wanted == subZone or wanted == zone then
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
