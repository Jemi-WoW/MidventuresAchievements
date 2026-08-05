local _, ns = ...
if ns.disabled then return end

-- Standing somewhere. Data is the spot key an achievement file registered below.
CA_Criterias.dataLengths[ns.CRITERIA_POSITION] = 1
CA_Criterias.criterias[ns.CRITERIA_POSITION] = {}

local spots = {}

-- Registers a spot next to the achievement that wants it. Coordinates are map percentages
-- as the game shows them, radius is how close counts, zones are AreaTableLocale ids.
function ns.Spot(key, def)
    spots[key] = def
    return key
end

local function inZone(def)
    local here = GetZoneText()
    for _, areaID in ipairs(def.zones) do
        if AreaTableLocale[areaID] == here then return true end
    end
    return false
end

-- Positions are per map, so a spot only ever matches on the map its numbers were read from.
local function atSpot(def)
    local mapID = C_Map.GetBestMapForUnit('player')
    if not mapID then return false end
    local position = C_Map.GetPlayerMapPosition(mapID, 'player')
    if not position then return false end

    local x, y = position:GetXY()
    if not x then return false end
    x, y = x * 100, y * 100
    return (x - def.x) ^ 2 + (y - def.y) ^ 2 <= def.radius ^ 2
end

local function check()
    for key, def in pairs(spots) do
        if inZone(def) and atSpot(def) then
            CA_Criterias:Trigger(ns.CRITERIA_POSITION, {key})
        end
    end
end

-- The player has to be moving to reach a summit, so this is the one thing that needs a
-- ticker rather than an event. It only runs while a registered zone is on screen.
local ticker
local function rearm()
    local wanted = false
    for _, def in pairs(spots) do
        if inZone(def) then
            wanted = true
            break
        end
    end

    if wanted and not ticker then
        ticker = C_Timer.NewTicker(1, check)
    elseif not wanted and ticker then
        ticker:Cancel()
        ticker = nil
    end
end

local watcher = CreateFrame('Frame')
watcher:RegisterEvent('PLAYER_ENTERING_WORLD')
watcher:RegisterEvent('ZONE_CHANGED_NEW_AREA')
watcher:RegisterEvent('ZONE_CHANGED')
watcher:SetScript('OnEvent', function() C_Timer.After(1, rearm) end)
