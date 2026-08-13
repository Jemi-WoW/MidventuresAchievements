local _, ns = ...
if ns.disabled then return end

local TYPE = CA_Criterias.TYPE

-- Anniversary stops at the first area of that name, so 44 of its criteria lose to a namesake.
local byName = {}

for areaID, name in pairs(AreaTableLocale or {}) do
    local ids = byName[name]
    if not ids then
        ids = {}
        byName[name] = ids
    end
    ids[#ids + 1] = areaID
end

-- Exploring an area never comes undone, so each one is only ever handed over once.
local seen, one = {}, {}

local function credit(areaID)
    if not areaID or seen[areaID] then return end
    seen[areaID] = true
    one[1] = areaID
    CA_Criterias:Trigger(TYPE.EXPLORE_AREA, one)
end

-- Cities always name a district as the subzone, so the zone is credited as well.
local function creditHere()
    local names = {}
    names[GetSubZoneText() or ''] = true
    names[GetZoneText() or ''] = true
    names[GetMinimapZoneText() or ''] = true
    names[''] = nil

    for name in pairs(names) do
        for _, areaID in ipairs(byName[name] or {}) do credit(areaID) end
    end

    local map = C_Map.GetBestMapForUnit('player')
    local position = map and C_Map.GetPlayerMapPosition(map, 'player')
    if not position then return end
    for _, areaID in ipairs(C_MapExplorationInfo.GetExploredAreaIDsAtPosition(map, position) or {}) do
        credit(areaID)
    end
end

-- Anniversary keeps only the first id at each point, losing whatever overlaps it.
local STEP = 0.01
local RANGES = {{1411, 1458}, {1941, 1955}, {1957, 1957}}
local SCAN_VERSION = 1

-- Ten thousand points per map, so the vector is written over rather than rebuilt.
local point = CreateVector2D(0, 0)

local function scanMap(mapID)
    if not C_Map.GetMapInfo(mapID) then return end
    for x = 0, 1, STEP do
        for y = 0, 1, STEP do
            point.x, point.y = x, y
            local areaIDs = C_MapExplorationInfo.GetExploredAreaIDsAtPosition(mapID, point)
            if areaIDs then
                for _, areaID in ipairs(areaIDs) do credit(areaID) end
            end
        end
    end
end

local scanning = false

local function scanAll(onDone)
    if scanning then return end
    scanning = true

    local maps = {}
    for _, range in ipairs(RANGES) do
        for mapID = range[1], range[2] do maps[#maps + 1] = mapID end
    end

    local index = 0
    local function step()
        index = index + 1
        if index > #maps then
            scanning = false
            if onDone then onDone() end
            return
        end
        scanMap(maps[index])
        C_Timer.After(0.1, step)
    end
    step()
end

function ns.RescanExploredAreas()
    creditHere()
    scanAll(function()
        DEFAULT_CHAT_FRAME:AddMessage('|cff00ff00Midventures|r: explored areas rescanned.')
    end)
end

local function progress()
    MidventuresProgressDB = MidventuresProgressDB or {}
    MidventuresProgressDB.exploration = MidventuresProgressDB.exploration or {}
    return MidventuresProgressDB.exploration
end

local watcher = CreateFrame('Frame')
watcher:RegisterEvent('PLAYER_ENTERING_WORLD')
watcher:RegisterEvent('ZONE_CHANGED')
watcher:RegisterEvent('ZONE_CHANGED_INDOORS')
watcher:RegisterEvent('ZONE_CHANGED_NEW_AREA')
watcher:SetScript('OnEvent', function(_, event)
    if event ~= 'PLAYER_ENTERING_WORLD' then
        creditHere()
        return
    end

    -- Live tracking covers everything from here on, so the sweep is a one-off back-fill.
    C_Timer.After(5, creditHere)
    if progress().scanned == SCAN_VERSION then return end
    C_Timer.After(20, function()
        scanAll(function() progress().scanned = SCAN_VERSION end)
    end)
end)
