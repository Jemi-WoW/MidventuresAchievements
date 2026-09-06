local _, ns = ...
if ns.disabled then return end

-- Simply being somewhere; EXPLORE_AREA wants the map uncovered, the ocean never is.
CA_Criterias.dataLengths[ns.CRITERIA_ZONE_VISIT] = 1
CA_Criterias.criterias[ns.CRITERIA_ZONE_VISIT] = {}

-- The same, but you have to get there yourself. A boat or a gryphon does not count.
CA_Criterias.dataLengths[ns.CRITERIA_ZONE_SWIM] = 1
CA_Criterias.criterias[ns.CRITERIA_ZONE_SWIM] = {}

-- Inside the place rather than over it, for areas that read as a subzone from the air.
CA_Criterias.dataLengths[ns.CRITERIA_ZONE_INSIDE] = 1
CA_Criterias.criterias[ns.CRITERIA_ZONE_INSIDE] = {}

-- Either name counts, the same way core/ZoneLevel.lua reads it.
local function here(areaID)
    local wanted = AreaTableLocale[areaID]
    return wanted == GetSubZoneText() or wanted == GetZoneText()
end

-- Being inside puts you on the area's own map; the exterior belongs to the zone around it.
local function inside(areaID)
    local wanted = AreaTableLocale[areaID]
    if wanted ~= GetZoneText() then return false end

    local mapID = C_Map.GetBestMapForUnit('player')
    local info = mapID and C_Map.GetMapInfo(mapID)
    return info ~= nil and info.name == wanted
end

local function check()
    for areaID in pairs(CA_Criterias.criterias[ns.CRITERIA_ZONE_VISIT]) do
        if here(areaID) then CA_Criterias:Trigger(ns.CRITERIA_ZONE_VISIT, {areaID}) end
    end

    if UnitOnTaxi('player') then return end
    for areaID in pairs(CA_Criterias.criterias[ns.CRITERIA_ZONE_INSIDE]) do
        if inside(areaID) then CA_Criterias:Trigger(ns.CRITERIA_ZONE_INSIDE, {areaID}) end
    end
end

-- Zone events fire on arrival, so the swim itself needs watching for.
local function checkSwim()
    if not IsSwimming() or UnitOnTaxi('player') or IsMounted() then return end

    for areaID in pairs(CA_Criterias.criterias[ns.CRITERIA_ZONE_SWIM]) do
        if here(areaID) then CA_Criterias:Trigger(ns.CRITERIA_ZONE_SWIM, {areaID}) end
    end
end

local watcher = CreateFrame('Frame')
watcher:RegisterEvent('PLAYER_ENTERING_WORLD')
watcher:RegisterEvent('ZONE_CHANGED_NEW_AREA')
watcher:RegisterEvent('ZONE_CHANGED')
watcher:RegisterEvent('ZONE_CHANGED_INDOORS')
watcher:SetScript('OnEvent', function() C_Timer.After(1, check) end)

C_Timer.NewTicker(2, checkSwim)
